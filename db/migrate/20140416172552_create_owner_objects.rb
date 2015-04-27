class CreateOwnerObjects < ActiveRecord::Migration
  def change
    create_table :owner_objects do |t|
      t.integer :owner_group_id
      t.integer :ownable_id
      t.string :ownable_type
      t.timestamps
    end
  end
end
