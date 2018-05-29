class ChangeNameOfBudgetHeading < ActiveRecord::Migration
  def up
    change_column :budget_headings, :name, :string, :limit => 100
  end

  def down
    change_column :budget_headings, :name, :string, :limit => 50
  end 
end
