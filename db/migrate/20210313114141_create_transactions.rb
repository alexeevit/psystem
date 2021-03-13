class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.uuid :uuid, null: false
      t.string :type, null: false
      t.string :status
      t.string :auth_code, index: true
      t.integer :amount, null: false
      t.belongs_to :account, index: true, foreign_key: true

      t.string :customer_email
      t.string :customer_phone
      t.string :notification_url

      t.timestamps
    end
  end
end
