class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts, id: false do |t|
      t.references :user, primary_key: true
      t.string :password_digest
      t.string :remember_digest
      t.string :activation_digest
      t.string :reset_digest
      t.datetime :activated_at
      t.datetime :reset_sent_at

      t.timestamps null: false
    end
    add_foreign_key :accounts, :users, on_delete: :cascade
  end
end
