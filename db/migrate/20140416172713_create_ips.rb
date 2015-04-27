class CreateIps < ActiveRecord::Migration
  def change
    create_table :ips do |t|
      t.string :addr
      t.integer :subnet_id
      t.integer :vlan_id
      t.string :fqdn

      t.timestamps
    end
  end
end
