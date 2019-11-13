class AddRotationInfoToExhCards < ActiveRecord::Migration[5.2]
  def change
    add_column :exh_cards, :rotation, :string
  end
end
