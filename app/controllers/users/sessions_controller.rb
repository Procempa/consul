require_dependency Rails.root.join('app', 'controllers', 'users', 'sessions_controller').to_s

class Users::SessionsController < Devise::SessionsController

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      url = request.referer
      if !url.nil? &&  !url.match(/\/admin\//).nil?
         return url[0,url.index("/admin/")]
      else
         return url.present? ? url : super
      end
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

end
