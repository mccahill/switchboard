class CreateNetConfigTransactions < ActiveRecord::Migration
  def change
    create_table :net_config_transactions do |t|
      t.string :who
      t.string :description
      t.string :target
      t.text :command
      t.string :status
      t.text :response

      t.timestamps
    end
  end
end
