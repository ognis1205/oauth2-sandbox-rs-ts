/**
 * @fileoverview Defined Next Auth OpenID Connect route.
 * @copyright Shingo OKAWA 2023
 */
import NextAuth, { NextAuthOptions, JWT } from 'next-auth';
import GoogleProvider from 'next-auth/providers/google';
import CognitoProvider from 'next-auth/providers/cognito';

const nextAuthOptions: NextAuthOptions = {
  providers: [
    CognitoProvider({
      clientId: process.env.COGNITO_CLIENT_ID || '',
      clientSecret: process.env.COGNITO_CLIENT_SECRET || '',
      issuer: process.env.COGNITO_ISSUER,
    }),
  ],
};

const handler = NextAuth(nextAuthOptions);

export { handler as GET, handler as POST };
