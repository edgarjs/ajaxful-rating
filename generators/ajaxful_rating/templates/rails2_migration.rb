class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.integer :user_id
      t.integer :rateable_id
      t.string  :rateable_type, :limit => 30
      t.integer :rate
      
      t.timestamps
    end
    
    add_index :rates, :user_id
    add_index :rates, :rateable_id
  end
  
  def self.down
    drop_table :rates
  end
end