class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.integer :ip_id
      t.string :status, :default=> 'PENDING'
      t.integer :approved_by_id
      t.date :approved_at
      t.integer :link_request_id
      t.integer :owner_group_id

      t.timestamps
    end
  end
end
