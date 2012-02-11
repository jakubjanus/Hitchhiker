class RemoveUpToDateAttrFromDrives < ActiveRecord::Migration
  def up
    change_table :drives do |t|
      t.remove :is_up_to_date
    end
  end

  def down
    change_table :drives do |t|
      t.boolean  "is_up_to_date",       :default => true,
    end
  end
end
