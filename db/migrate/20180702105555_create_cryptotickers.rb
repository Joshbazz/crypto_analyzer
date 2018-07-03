class CreateCryptotickers < ActiveRecord::Migration[5.2]
  def change
    create_table :cryptotickers do |t|

      t.timestamps
    end
  end
end
