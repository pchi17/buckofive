class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references  :user,    null: false, index: true
      t.references  :poll,    null: false, index: true
      t.string      :message, null: false, limit: 140
      t.timestamps null: false
    end
    add_foreign_key :comments, :users, on_delete: :cascade
    add_foreign_key :comments, :polls, on_delete: :cascade
  end
end
