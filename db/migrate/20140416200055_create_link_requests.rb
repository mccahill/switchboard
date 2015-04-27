class CreateLinkRequests < ActiveRecord::Migration
  def change
    create_table :link_requests do |t|
      t.integer :user_id
      t.text :comment
      t.integer :duration
      t.date :start
      t.date :end
      t.integer :traffic,default: 0 # defaults to the first value
      t.timestamps
    end
  end
end
