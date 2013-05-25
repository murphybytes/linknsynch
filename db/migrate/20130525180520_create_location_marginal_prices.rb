class CreateLocationMarginalPrices < ActiveRecord::Migration
  def change
    create_table :location_marginal_prices do |t|
      t.timestamp :period
      t.decimal :value
      t.integer :node_id

      t.timestamps
    end
    add_index :location_marginal_prices, :period
  end
end
