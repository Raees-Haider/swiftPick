class ChangeRoleToBeStringInUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :role, :string
  end

  def down
    change_column :users, :role, :integer
  end
end
