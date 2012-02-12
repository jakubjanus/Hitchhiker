class ChangeHometownInUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :hometown
      t.integer :hometown_id
    end
  end

  def down
  end
end
