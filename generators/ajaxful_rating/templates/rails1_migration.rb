class CreateRates < ActiveRecord::Migration
  def self.up
    create_table :rates do |t|
      t.column :user_id,        :integer
      t.column :rateable_id,    :integer
      t.column :rateable_type,  :string, :limit => 30
      t.column :rate,           :integer
      
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    add_index :rates, :user_id
    add_index :rates, :rateable_id
  end
  
  def self.down
    drop_table :rates
  end
end