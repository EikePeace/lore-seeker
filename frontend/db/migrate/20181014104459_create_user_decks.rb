class CreateUserDecks < ActiveRecord::Migration[5.1]
  def change
    create_table :user_decks do |t|
      t.string :name
      t.references :user, foreign_key: true, null: true
      t.string :format
      t.text :mainboard
      t.text :commandboard
      t.text :sideboard
      t.text :maybeboard
      t.text :description
      t.boolean :public

      t.timestamps
    end
  end
end
