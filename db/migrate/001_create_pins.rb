class CreatePins < ActiveRecord::Migration[6.1]
  def change
    create_table :pins do |t|
      t.references :user, null: false, index: true
      t.references :issue, null: false, index: true
      
      t.timestamps
    end
    
    add_index :pins, [:user_id, :issue_id], unique: true
  end
end
