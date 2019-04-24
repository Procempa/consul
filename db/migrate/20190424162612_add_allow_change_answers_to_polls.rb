class AddAllowChangeAnswersToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :allow_change_answers, :boolean, :default => false    
  end
end
