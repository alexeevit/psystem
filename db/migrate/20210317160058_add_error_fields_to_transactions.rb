class AddErrorFieldsToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :validation_errors, :json
  end
end
