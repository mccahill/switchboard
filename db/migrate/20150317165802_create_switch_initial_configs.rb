class CreateSwitchInitialConfigs < ActiveRecord::Migration
  def change
    create_table :switch_initial_configs do |t|
      t.string :ip
      t.string :vlan
      t.integer :switch_connection_type_id
      t.integer :switch_id
      
      t.timestamps
    end
  end
end
