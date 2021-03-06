class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  def twitter
    sign_in_with :twitter_login, :twitter, :twitter
  end

  def facebook
    sign_in_with :facebook_login, :facebook, :facebook
  end

  def google_oauth2
    sign_in_with :google_login, :google_oauth2, :google_oauth2
  end

  def saml
    sign_in_with :saml, :salm, "Acesso Poa"
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      super(resource)
    end
  end

  private

    def sign_in_with(feature, provider, provider_name)
#      raise ActionController::RoutingError.new('Not Found') unless Setting["feature.#{feature}"]

      auth = env["omniauth.auth"]

      identity = Identity.first_or_create_from_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)

      if save_user
        identity.update(user: @user)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider_name.to_s.capitalize) if is_navigational_format?
      else
        session["devise.#{provider}_data"] = auth
        redirect_to new_user_registration_url
      end
    end

    def save_user
      @user.save || @user.save_requiring_finish_signup
    end

end
