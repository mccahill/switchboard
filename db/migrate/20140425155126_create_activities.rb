class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id
      t.string :verb
      t.integer :link_request_id
      t.integer :ip_id
      t.text :notes
      t.date :occurred
    end
  end
end
