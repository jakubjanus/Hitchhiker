class AddAttrsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.date :birthdate
      t.string :phone_number
      t.string :alt_email
      t.integer :hometown
      t.string :show_email
      t.string :show_alt_email
      t.string :show_phone_number
      t.string :show_hometown
    end
  end
end
