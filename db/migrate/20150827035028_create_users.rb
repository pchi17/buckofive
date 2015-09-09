class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name,  null: false
      t.string :email
      t.string :password_digest
      t.string :remember_digest
      t.string :activation_digest
      t.string :reset_digest
      t.boolean :admin,     default: false
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.datetime :reset_sent_at

      t.string :image_url

      t.timestamps null: false
      t.index :email, unique: true
    end
  end
end
