class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :type, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :status
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
