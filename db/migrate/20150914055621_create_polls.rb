class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.references  :user,        null: false, index: true
      t.string      :content,     null: false, limit: 250 
      t.integer     :total_votes, null: false, default: 0
      t.integer     :flags,       null: false, default: 0
      t.string      :picture

      t.timestamps null: false

      t.index :content, unique: true
    end
    add_foreign_key :polls, :users, on_delete: :cascade
  end
end
