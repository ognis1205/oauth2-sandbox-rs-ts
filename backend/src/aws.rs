use aws_config::sts::AssumeRoleProvider;
use aws_config::SdkConfig;
use aws_sdk_s3::presigning::PresigningConfig;
use aws_sdk_s3::Client;
use std::error::Error;
use std::time::Duration;

pub async fn get_client(
    config: &SdkConfig,
    role_name: String,
    external_id: String,
    session_name: String,
) -> Result<Client, Box<dyn Error>> {
    let provider = AssumeRoleProvider::builder(role_name)
        .external_id(external_id)
        .session_name(session_name)
        .configure(config)
        .build()
        .await;
    let local_config = aws_config::from_env()
        .credentials_provider(provider)
        .load()
        .await;
    let client = Client::new(&local_config);
    Ok(client)
}

pub async fn sign_object(
    client: &Client,
    bucket: &str,
    object: &str,
    expires_in: u64,
) -> Result<String, Box<dyn Error>> {
    let expires_in = Duration::from_secs(expires_in);
    let presigned_request = client
        .get_object()
        .bucket(bucket)
        .key(object)
        .presigned(PresigningConfig::expires_in(expires_in)?)
        .await?;
    Ok(presigned_request.uri().to_string())
}
