class AddFavouriteIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favourite_id, :integer
  end
end
