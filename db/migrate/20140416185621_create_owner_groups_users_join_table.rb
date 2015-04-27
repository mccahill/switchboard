class CreateOwnerGroupsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :owner_groups_users, :id => false do |t|
      t.integer :owner_group_id
      t.integer :user_id
    end

    add_index :owner_groups_users, :owner_group_id
    add_index :owner_groups_users, :user_id

  end
end
