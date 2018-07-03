class Cryptotickers < ActiveRecord::Migration[5.2]
  def change
  	create_table :Cryptocurrency do |t|
  		t.string :ticker
  		t.timestamps
  	end
  end
end
