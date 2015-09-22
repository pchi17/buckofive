class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user, null: false, index: true
      t.string :provider, null: false
      t.string :uid,      null: false
      t.string :token
      t.string :secret

      t.timestamps null: false

      t.index [:provider, :uid], unique: true
    end
    add_foreign_key :authentications, :users, on_delete: :cascade
  end
end
