Rails.application.config.middleware.use OmniAuth::Builder do
   provider :saml,
     :issuer                             => "consul",
     :idp_sso_target_url                 => ENV['CONSUL_AP_IDP_SSO_TARGET_URL'],
     :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param, :GLO => "true"},
     :idp_cert                           => ENV['CONSUL_AP_SAML_CERT'],
     :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
     #:idp_slo_target_url => ENV['CONSUL_AP_IDP_SSO_TARGET_URL'] + "/slo",
     :idp_slo_target_url => ENV['CONSUL_AP_IDP_SSO_TARGET_URL'] + "?SLO=true",
     :single_logout_service_url => "true"
end
