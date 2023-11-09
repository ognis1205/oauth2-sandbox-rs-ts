mod aws;
use aws_config::meta::region::RegionProviderChain;
use aws_config::SdkConfig;
use aws_types::region::Region;
use axum::extract::Extension;
use axum::{response::IntoResponse, routing::get, Router};
use clap::Parser;
use std::net::SocketAddr;
use std::sync::Arc;

#[derive(Debug, Parser)]
struct Opt {
    #[structopt(long)]
    region: Option<String>,

    #[structopt(long)]
    role_arn: String,

    #[structopt(long)]
    external_id: String,

    #[structopt(long)]
    bucket: String,

    #[structopt(long)]
    object: String,

    #[structopt(long)]
    expires_in: u64,
}

struct State {
    pub shared_config: SdkConfig,
    pub role_arn: String,
    pub external_id: String,
    pub bucket: String,
    pub object: String,
    pub expires_in: u64,
}

type SharedState = Arc<State>;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    let Opt {
        region,
        role_arn,
        external_id,
        bucket,
        object,
        expires_in,
    } = Opt::parse();

    let region_provider = RegionProviderChain::first_try(region.map(Region::new))
        .or_default_provider()
        .or_else(Region::new("us-west-2"));

    let shared_config = aws_config::from_env().region(region_provider).load().await;

    let state = Arc::new(State {
        shared_config,
        role_arn,
        external_id,
        bucket,
        object,
        expires_in,
    });

    let app = Router::new()
        .route("/", get(root))
        .layer(Extension(state.clone()));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    tracing::debug!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn root(Extension(state): Extension<SharedState>) -> impl IntoResponse {
    let client = aws::get_client(
        &state.shared_config,
        state.role_arn.clone(),
        state.external_id.clone(),
        "test".to_string(),
    )
    .await
    .unwrap();
    if let Ok(presigned) =
        aws::sign_object(&client, &state.bucket, &state.object, state.expires_in).await
    {
        presigned
    } else {
        "Failed to sign S3 URL".to_string()
    }
}
