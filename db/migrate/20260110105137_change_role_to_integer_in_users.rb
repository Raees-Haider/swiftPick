class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :role_tmp, :integer, default: 0

    execute <<-SQL
      UPDATE users
      SET role_tmp = CASE role
        WHEN 'admin' THEN 1
        ELSE 0
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end

  def down
    add_column :users, :role_tmp, :string

    execute <<-SQL
      UPDATE users
      SET role_tmp = CASE role
        WHEN 1 THEN 'admin'
        ELSE 'customer'
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_tmp, :role
  end
end
