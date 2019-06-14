class Admin::ProposalsController < Admin::BaseController
  include FeatureFlags

  has_filters %w{without_confirmed_hide all with_confirmed_hide}, only: :index

  feature_flag :proposals

  before_action :load_proposal, only: [:confirm_hide, :restore]

  def index
    @proposals = Proposal.only_hidden.send(@current_filter).order(hidden_at: :desc)
                         .page(params[:page])
  end

  def confirm_hide
    if @proposal.author && @proposal.author.email_on_proposal_moderation
      begin
        @proposal.send_confirm_hide_proposal_email()
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        render json: { message: 'Problems sending mail' }, status: :bad_request
      ensure
        @proposal.confirm_hide        
      end    
    end    
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore    
    @proposal.restore
    @proposal.ignore_flag
    Activity.log(current_user, :restore, @proposal)    
    if @proposal.author && @proposal.author.email_on_proposal_moderation
      begin
        @proposal.send_restore_proposal_email()
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
        render json: { message: 'Problems sending mail' }, status: :bad_request
      end    
    end
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_proposal
      @proposal = Proposal.with_hidden.find(params[:id])
    end

end
