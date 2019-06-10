class ChangeSizeTitleProposal < ActiveRecord::Migration
  def change
    change_column :tags, :name, :string, :limit => 70
  end
end
