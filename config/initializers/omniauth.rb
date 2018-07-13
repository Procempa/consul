Rails.application.config.middleware.use OmniAuth::Builder do
   provider :saml,
     :issuer                             => "consul",
     :idp_sso_target_url                 => "https://acessopoa-hom.procempa.com.br/auth/realms/acessopoa/protocol/saml",
     :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},
     :idp_cert                           => "MIICoTCCAYkCBgFcoaH+VzANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAlhY2Vzc29wb2EwHhcNMTcwNjEzMTMyNDI3WhcNMjcwNjEzMTMyNjA3WjAUMRIwEAYDVQQDDAlhY2Vzc29wb2EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQClGi7JUP2qiP4XY1bUKNUpgoeeniQhy0PgaoLko4hIlICNWe9B3HOPG8ZpIxuKBMx1s3iM1LiLhbX8C5olRd+4IlpYVYaUlSg+CsesSY0vMKIHiGyJF8gDNVGAqkFME9/d4FI01FhCko4j65zvDWTgr3KNtQYHQQE2JwmRl1H0Lz0PiCCKQ0uu3ZlQOqEzQ/5mr1WdXDpggkemUVSN85AZDC4NcEwPVLoAC32Ncunynwp2cRaG+jmvb6qn9ZUlwyXL1MjHlj/O3FNODpjAtF/9lc0UW9Hc7xiYLDKOXXrM7ib2kv7R0a44D2oA+9JnWiBUwwJFROVYqY8VaTS2XQS9AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAII1sbx6kt3cQXZbWdUuxL60ESSP0yHV+PJyRafY/0o8lmBdt5XWoRAM5CnWJRc9BEWMiRSBoVU/J5jk29J+86jE61bWsbY1bwJ6g+a2q5L9QXPugVG6trMDUbmEWqKg30J6x66URCeMfWQY7u5yGq4O7vg8lvCRX9126fxTJVOUC6zBd9vXTCPQGr5IQmqeIIdVVFDioNAAEhWl3ABh+hvqlxYvEysvYunoFqCVKiL91pfbENTSODLhcOGHJxyZx5Xte4Jq7l905nHpv+DWxMOi3UnyO/dN0AakqAquFnzlSZJh65ZFnkS+MGekHqvdngsOLFkbsIefDZixW4HZIvs=",
     :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
end
