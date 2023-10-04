import { Issuer } from 'openid-client';
discover();

async function discover() {
  const issuer = await Issuer.discover(process.env.AP);
  console.log(issuer);
}
