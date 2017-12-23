class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.json :player
      t.json :cpu

      t.timestamps
    end
  end
end
