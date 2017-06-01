module ChessHelper

	class Game 
         
         @select = false

	     class << self
           attr_accessor :boardPos,  :player, :cpu
	     end



		  def initialize(color, name)
		  	@name = name
		  	@color = color
		  	@player = Player.new(@color, @name)
		  	if color == "black"
		     @cpu = Cpu.new("white", "MOTHERFUCKER!!!!")
		    elsif color == "white"
		     @cpu = Cpu.new("black", "MOTHERFUCKER!!!!")
		    else
		    	return "try another color, white or black"
		    end
            @boardPos = [[2,3,4,5,6,4,3,2],
                        [1,1,1,1,1,1,1,1],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [1,1,1,1,1,1,1,1],
                        [2,3,4,5,6,4,3,2]]
           
           end



		   def boardCol(a, b, c)
		   
             setup = c.each_with_index.map do |e, i|
                 if (i === 0 || i === 1)  
                  e = e.map do |l| 
                  l =Piece.new(a, l)
                  l = l.parse
                  end
                 elsif (i === 6 || i === 7 )
                  e = e.map do |l| 
                  l =Piece.new(b, l)
                  l = l.parse
                  end
                 else
                  e = e.map{|l| l = [0]} 
                end 
              end
             setup
		   end
           def board
              boardCol(@cpu.color, @player.color, @boardPos)
           end

           def playerName
              @player.name
           end

           def cpuName
              @cpu.name
           end

           
	  
	end

class Player
	class << self
	  attr_accessor :color, :name
    end

   def initialize(color, name)
     @color = color
     @name =name
   end
   def color
   	@color
   end
   def name
   	  @name
   	end
end

class Cpu 
	class << self
	  attr_accessor :color, :name
    end
	 def initialize(color, name)
     @color = color
     @name =name
   end
   def color
   	  @color
   	end
def name
   	  @name
   	end
end

class Piece 
	class << self
	  attr_accessor :piece
    end
    def initialize(color, num)
      @piece = [color, generate(num)]
    end
    
    def generate(n) 
      case n.to_i
      when 1 
        att = {:name => "pawn", :moves => [0, 1]}
      when 2 
      	att = {:name => "rook", :moves => [1,1]}
      when 3 
      	att = {:name => "knight", :moves => [1,1]}
      when 4 
      	att = {:name => "bishop", :moves => [1,1]}
      	when 5 
      	att = {:name => "queen", :moves => [1,1]}
      	when 6 
      	att = {:name => "king", :moves => [1,1]}
      else
        att = {:name => "unknown", :moves =>[0,0]}  
    end
    end

    def parse
      arr = [@piece[0], @piece[1][:name], @piece[1][:moves]]
      arr
     
    end

end

end
