class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  feature_flag :proposals

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def hide_resource(resource)
    super(resource)
    if resource.author && resource.author.email_on_proposal_moderation
      begin
        resource.send_hide_proposal_email()
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        render json: { message: 'Problems sending mail' }, status: :bad_request
      end        
    end
  end

  private

    def resource_model
      Proposal
    end
end
