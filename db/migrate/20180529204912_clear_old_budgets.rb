class ClearOldBudgets < ActiveRecord::Migration
  def up	
     Budget.all().each do |a| a.delete end
  end

  def down
  end
end
