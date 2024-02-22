import { ClientAuthMethod } from 'openid-client';

export const sessionSecret = 'keyboard cattens';
const demoUrl = "https://keycloak.cdssandbox.xyz";
const oidcDevUrl = "http://dev.sicv2.id.alpha.canada.ca:3000";

export const oidc_clients = [
  {
    name: 'signincanada',
    description: 'signincanada OIDC',
    ap: `${demoUrl}/realms/master/`,
    sic: false,
    config: {
      client_id: 'signincanada',
      client_secret: 'lH4HsmZP8wjNd2fKOvbsYjOrA06JWR53',
      grant_types: ['refresh_token', 'authorization_code', 'openid'],
      redirect_uris: [`${oidcDevUrl}/auth/callback/signincanada`],
      post_logout_redirect_uris: [`${oidcDevUrl}/logout/callback`],
      token_endpoint_auth_method: 'client_secret_post' as ClientAuthMethod,
    }
  },
]

export const ui_config = {
  client_label: 'RP1',
  title_en: 'OIDC RP Simulator',
  title_fr: 'Simulateur OIDC de la partie utilisatrice',
  wet_cdts_hosturl: 'https://www.canada.ca/etc/designs/canada/cdts/gcweb',
  wet_cdts_version: 'v4_0_44',
  jquery_version: '2.2.4'
};
