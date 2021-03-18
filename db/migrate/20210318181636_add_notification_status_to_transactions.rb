class AddNotificationStatusToTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :notification, :integer, index: true
    add_column :transactions, :last_notification_at, :datetime
    add_column :transactions, :notification_attempts, :integer, default: 0
  end
end
