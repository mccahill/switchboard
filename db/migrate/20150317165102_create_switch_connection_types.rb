class CreateSwitchConnectionTypes < ActiveRecord::Migration
  def change
    create_table :switch_connection_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
