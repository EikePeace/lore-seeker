class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :slug, limit: 32, null: false
      t.string :name, null: false
      t.datetime :announcement
      t.datetime :mainboard_submissions
      t.datetime :sideboard_submissions
      t.datetime :start
      t.datetime :end
      t.text :summary
      t.string :rel, limit: 4, null: false, default: "reg"
      t.string :challonge

      t.timestamps
    end

    create_table :event_signups do |t|
      t.string :event_slug, limit: 32, null: false
      t.integer :snowflake, limit: 8, null: false
      t.string :challonge
      t.string :deck_name, null: false
      t.text :mainboard, null: false
      t.text :sideboard
      t.string :deck_hash, limit: 8

      t.timestamps
    end
  end
end
