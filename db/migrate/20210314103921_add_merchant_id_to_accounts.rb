class AddMerchantIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference :accounts, :merchant, null: false, index: true, foreign_key: {to_table: :users}
  end
end
