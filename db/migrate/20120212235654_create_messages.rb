class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :title, :null => false
      t.string :contents, :null => false
      t.integer :sender_id, :null => false
      t.integer :recipient_id, :null => false
      t.boolean :is_read, :default => false

      t.timestamps
    end
  end
end
