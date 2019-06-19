require_dependency Rails.root.join('app', 'controllers', 'users', 'sessions_controller').to_s
require 'net/http'

class Users::SessionsController < Devise::SessionsController



  def destroy
    # Preserve the saml_uid in the session
    saml_uid = session["saml_uid"]
    super do
      session["saml_uid"] = saml_uid
    end
  end

  def new
    if (request.method == 'GET')
      #redirect_to root_path
      redirect_to user_omniauth_authorize_path(:saml) + "?kc_locale=" + I18n.locale.to_s
    else
      super
    end
  end

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(_)
      if session['saml_uid'] # && SAML_SETTINGS.idp_slo_target_url
        user_omniauth_authorize_path(:saml) + "/spslo"+ "?kc_locale=" + I18n.locale.to_s
      else
        super
      end
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end
