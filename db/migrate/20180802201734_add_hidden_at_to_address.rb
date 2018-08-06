class AddHiddenAtToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :hidden_at, :datetime
    add_index :addresses, :hidden_at
  end  
end
