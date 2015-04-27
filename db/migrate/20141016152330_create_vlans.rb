class CreateVlans < ActiveRecord::Migration
  def change
    create_table :vlans do |t|
      t.string :vlan_name
      t.text :description

      t.timestamps
    end
  end
end
