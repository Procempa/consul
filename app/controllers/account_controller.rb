class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, :set_address
  load_and_authorize_resource class: "User"

  def show
      if @account.address.nil?
        @account.address ||= Address.new({user_id: @account.id})
        @account.save(validate: false)
        true
      end
      
  end

  def update
    if @account.update_total(account_params)
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
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
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :public_activity, :public_interests, :email_on_comment,
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge, :document_type, :document_number, address_attributes: [:street, :postal_code, :neighbourhood, :number, :complement, :id] ]
                   end
      params.require(:account).permit(*attributes)
    end

end
