class CreateTurns < ActiveRecord::Migration[5.1]
  def change
    create_table :turns do |t|
      t.integer :turn
      t.json :board, default: "{}"
      t.json :pmoves, default: "{}"
      t.references :games, foreign_key: true, index: true

      t.timestamps
    end
  end
end

=begin
class CreatePositions < ActiveRecord::Migration[5.1]
  def change
    create_table :positions do |t|
      t.string :color
      t.string :name
      t.integer :start
      t.string :n
      t.integer :moves, array: true, default: "{}"
      t.integer :curpos, array: true, default: "{}"
      t.boolean :repos
      t.references :turns, foreign_key: true, index: true

      t.timestamps
    end
  end
end


#{:color => @color, :name => "pawn", :n => @n,:moves => move,
#  :start => @start_index, :curpos => @curpos, :repos => @r}
=end
