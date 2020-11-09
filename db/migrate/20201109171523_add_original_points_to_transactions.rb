class AddOriginalPointsToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :original_points, :integer
  end
end
