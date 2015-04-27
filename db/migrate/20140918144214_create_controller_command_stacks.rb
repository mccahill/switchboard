class CreateControllerCommandStacks < ActiveRecord::Migration
  def change
    create_table :controller_command_stacks do |t|
      t.text :command

      t.timestamps
    end
  end
end
