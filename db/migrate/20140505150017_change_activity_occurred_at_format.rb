class ChangeActivityOccurredAtFormat < ActiveRecord::Migration
  def change
    change_column :activities, :occurred, :datetime
  end
end
