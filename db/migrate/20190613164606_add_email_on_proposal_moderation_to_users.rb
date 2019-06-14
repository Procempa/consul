class AddEmailOnProposalModerationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_proposal_moderation, :boolean, :default => true        
  end
end
