class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.references :<%= file_name %>
      t.references :rateable, :polymorphic => true
      t.integer :stars
      t.string :dimension

      t.timestamps
    end
    
    add_index :rates, :<%= file_name %>_id
    add_index :rates, :rateable_id
  end

  def self.down
    drop_table :rates
  end
end
