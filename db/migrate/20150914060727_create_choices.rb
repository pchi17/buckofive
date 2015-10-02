class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.references :poll,     null: false, index: true
      t.string     :value,    null: false, limit: 50
      t.integer :votes_count, null: false, default: 0

      t.timestamps null: false

      t.index [:poll_id, :value], unique: true
    end
    add_foreign_key :choices, :polls, on_delete: :cascade
  end
end
