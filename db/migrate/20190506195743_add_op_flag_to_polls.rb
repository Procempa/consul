class AddOpFlagToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :op, :boolean, :default => false    
  end
end
