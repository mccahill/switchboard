class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :netid
      t.string :duid
      t.string :displayName
      t.string :phone
      t.string :email

      t.timestamps
    end
    add_index :users, :duid, :unique => true
    add_index :users, :netid, :unique => true
    
  end
end
