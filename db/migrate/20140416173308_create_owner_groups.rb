class CreateOwnerGroups < ActiveRecord::Migration
  def change
    create_table :owner_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
