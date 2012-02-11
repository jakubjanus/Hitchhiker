class AddDistanceCommentCostToDrives < ActiveRecord::Migration
  def change
    change_table :drives do |t|
      t.text :comment
      t.integer :distance
      t.decimal :cost
      t.string :currency
    end
  end
end
