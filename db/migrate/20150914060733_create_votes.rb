class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user,   null: false, index: true
      t.references :choice, null: false, index: true

      t.timestamps null: false

      t.index [:user_id, :choice_id], unique: true
    end
    add_foreign_key :votes, :users,   on_delete: :cascade
    add_foreign_key :votes, :choices, on_delete: :cascade
  end
end
