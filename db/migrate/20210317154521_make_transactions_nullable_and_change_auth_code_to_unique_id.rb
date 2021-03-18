class MakeTransactionsNullableAndChangeAuthCodeToUniqueId < ActiveRecord::Migration[6.1]
  def change
    change_table :transactions do |t|
      t.change :amount, :integer, null: true
      t.uuid :unique_id, null: false

      t.index :uuid
      t.remove_index :auth_code
      t.remove :auth_code
    end
  end
end
