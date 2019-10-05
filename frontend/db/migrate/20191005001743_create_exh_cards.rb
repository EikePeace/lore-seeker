class CreateExhCards < ActiveRecord::Migration[5.2]
  def change
    create_table :exh_cards do |t|
      t.string :name, null: false
      t.integer :voter_ids, limit: 8, array: true, null: false, default: []

      t.timestamps
    end
  end
end
