class AddDefaultSortAndViewToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sort, :string, null: false, default: "default"
    add_column :users, :view, :string, null: false, default: "default"
  end
end
