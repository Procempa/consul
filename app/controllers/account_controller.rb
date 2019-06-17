class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, :set_address
  load_and_authorize_resource class: "User"

  def show
      if @account.address.nil?
        @account.address ||= Address.new({user_id: @account.id})
        @account.save(validate: false)        
      end
      if (request.referrer && !request.referrer.match("account"))
        session[:referrer_poll] = nil        
        if !current_user.account_complete? && request.referrer.match(request.domain) && (request.referrer.match("polls") || request.referrer.match("proposals"))
          session[:referrer_poll] = request.referrer                
        end
      end      
      true
  end

  def update
    if @account.update_total(account_params)      
      if (current_user.account_complete? && session[:referrer_poll]) 
        referrer_poll = session[:referrer_poll]
        session.delete(:referrer_poll)
        redirect_to referrer_poll, notice: t("flash.actions.save_changes.notice")
      else
        redirect_to account_path, notice: t("flash.actions.save_changes.notice")
      end
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end

  private

    def set_account
      @account = current_user
    end

    def set_address
      @account.address ||= Address.new({user_id: current_user.id})
    end

    def account_params
      attributes = if @account.organization?
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter, :email_on_proposal_moderation,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :public_activity, :public_interests, :email_on_comment, :email_on_proposal_moderation, 
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge, :document_type, :document_number, address_attributes: [:street, :postal_code, :neighbourhood, :number, :complement, :id] ]
                   end
      params.require(:account).permit(*attributes)
    end

end
