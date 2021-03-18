class MakeStatusesIntegers < ActiveRecord::Migration[6.1]
  def change
    remove_column :transactions, :status, :string
    remove_column :users, :status, :string

    add_column :transactions, :status, :integer, null: false
    add_column :users, :status, :integer
  end
end
