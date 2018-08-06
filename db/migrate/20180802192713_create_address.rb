class CreateAddress < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :street
      t.string :street_type
      t.string :number
      t.string :letter
      t.string :neighbourhood
      t.string :district
      t.string :postal_code
      t.string :toponymy
      t.string :complement
      t.timestamps null: false
    end
  end
end
