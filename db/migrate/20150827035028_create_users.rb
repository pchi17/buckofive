class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name,  null: false
      t.string :email
      t.string :image
      t.boolean :admin,     default: false
      t.boolean :activated, default: false

      t.timestamps null: false
      t.index :email, unique: true
    end
  end
end
