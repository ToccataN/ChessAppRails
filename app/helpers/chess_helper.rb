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
            @boardPos = [['r','k','b','q','ki','b','k','r'],
                        ['p','p','p','p','p','p','p','p'],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        [0,0,0,0,0,0,0,0],
                        ['p','p','p','p','p','p','p','p'],
                        ['r','k','b','q','ki','b','k','r']]
           
           end
         
           def boardPos
             @boardPos
           end

		   def boardCol(a, b, c)
		   
             setup = c.each_with_index.map do |e, i|
                 if (i === 0 || i === 1)  
                  e = e.each_with_index.map do |l, j| 
                  l =Piece.new(a, l, i, [i, j])
                  l = l.parse
                  end
                 elsif (i === 6 || i === 7 )
                  e = e.each_with_index.map do |l, j| 
                  l =Piece.new(b, l, i, [i, j])
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

           def playerColor
               @player.color
           end

           def cpuColor
             @cpu.color
           end
           
           def playerCheck
             @player.checkState
           end
           
           def cpuCheck
             @cpu.checkState
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
    def checkState
       false
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
    def checkState
      false
    end


end

class Piece 
	class << self
	  attr_accessor :piece, :start_index, :curpos
    end
    def initialize(color, num, start_index, curpos)
      @piece = [color, generate(num, start_index, curpos)]
      @start_index = start_index
      @curpos = curpos
      @color = color
      @n = num
    end
    
    def generate(n, s, c) 
      case n
      when 'p'
        att = Pawn.new(s,c, n).att
      when 'r' 
      	att = Rook.new(s,c,n).att
      when 'k' 
      	att = Knight.new(s,c,n).att
      when 'b' 
      	att = Bishop.new(s,c,n).att
      	when 'q' 
      	att = Queen.new(s,c,n).att
      	when 'ki' 
      	att = King.new(s,c,n).att
      else
        att = {:n => n,:name => "unknown", :moves =>[0,0]}  
    end
    end

    def parse
      arr = [@piece[0], @piece[1][:n] , @piece[1][:name], @piece[1][:curpos], @piece[1][:start], @piece[1][:moves]]
      arr
     
    end

end

class Pawn 
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "pawn"
    @n = n 
  end
  
  def move
  	p = []
    if @start_index === 1
       if @curpos[0] === 1
          p = [[@curpos[0]+1, @curpos[1]], [@curpos[0]+2, @curpos[1]]]
       else
       	  p = [[@curpos[0]+1, @curpos[1]]] 
       end
    elsif @start_index === 6
       if @curpos[0] === 6
          p = [[@curpos[0]-1, @curpos[1]], [@curpos[0]-2, @curpos[1]]] 
       else
       	  p = [[@curpos[0]-1, @curpos[1]]] 
       end
    end
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end

class Rook 
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "rook"
    @n = n 
  end
  
  def move
  	p = []
    boardPos = Array.new(8) {Array.new(8)}
     boardPos.each_with_index do |e1, i1|
        e1.each_with_index do |e2, i2|
          if i1 === @curpos[0]
            p.push([i1, i2])
          elsif i2 === @curpos[1]
          	p.push([i1, i2])
          end
        end
      end	
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end

class Knight
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "knight"
    @n = n 
  end
  
  def move
  	p = []
    
    a =[[1, 2],[-1, -2],[-1, 2] ,[1, -2] , [2, 1] , [-2, -1], [-2, 1] ,[2, -1]]
    a.each do |i|
      if ((@curpos[0]+i[0] >= 0) && (@curpos[0]+i[0] < 8)) && ((@curpos[1]+ i[1] >= 0) && (@curpos[1]+ i[1] < 8))
        p.push([@curpos[0]+i[0], @curpos[1]+ i[1]])
      end
    end
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end

class Bishop
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "bishop"
    @n = n 
  end
  
  def move
  	p = []

    8.times do |i|
      if (@curpos[0] + i < 8 && @curpos[1]+i < 8)
        p.push([@curpos[0]+i, @curpos[1]+i])
      end
    end
     8.times do |i|
      if (@curpos[0] - i >= 0 && @curpos[1]+i < 8)
      	 p.push([@curpos[0] - i, @curpos[1]+i])
      end
     end
     8.times do |i|
        if (@curpos[0] - i >= 0 && @curpos[1]-i >= 0)
      	 p.push([@curpos[0] - i, @curpos[1]-i])
      	end
      end
     8.times do |i|
       if (@curpos[0] + i < 8 && @curpos[1]-i >= 0 )
      	 p.push([@curpos[0] + i, @curpos[1]-i])
      	end
     end
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end


class Queen
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "queen"
    @n = n 
  end
  
  def move
  	p = []

    8.times do |i|
      if (@curpos[0] + i < 8 && @curpos[1]+i < 8)
        p.push([@curpos[0]+i, @curpos[1]+i])
      end
    end
     8.times do |i|
      if (@curpos[0] - i >= 0 && @curpos[1]+i < 8)
      	 p.push([@curpos[0] - i, @curpos[1]+i])
      end
     end
     8.times do |i|
        if (@curpos[0] - i >= 0 && @curpos[1]-i >= 0)
      	 p.push([@curpos[0] - i, @curpos[1]-i])
      	end
      end
     8.times do |i|
       if (@curpos[0] + i < 8 && @curpos[1]-i >= 0 )
      	 p.push([@curpos[0] + i, @curpos[1]-i])
      	end
     end
     boardPos = Array.new(8) {Array.new(8)}
     boardPos.each_with_index do |e1, i1|
        e1.each_with_index do |e2, i2|
          if i1 === @curpos[0]
            p.push([i1, i2])
          elsif i2 === @curpos[1]
          	p.push([i1, i2])
          end
        end
      end	
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end


class King
   class << self
	  attr_accessor :name, :start_index, :curpos
    end

  def initialize(start_index, curpos, n)
    @start_index = start_index
    @curpos = curpos
    @name = "king"
    @n = n 
  end
  
  def move
  	p = []
    
    a =[[1, 0],[-1, 0],[0, 1] ,[0, -1] , [1, 1] , [-1, -1], [-1, 1] ,[1, -1]]
    a.each do |i|
      if ((@curpos[0]+i[0] >= 0) && (@curpos[0]+i[0] < 8)) && ((@curpos[1]+ i[1] >= 0) && (@curpos[1]+ i[1] < 8))
        p.push([@curpos[0]+i[0], @curpos[1]+ i[1]])
      end
    end
    p
  end
  
  def att
   at = {:name => @name, :n => @n,:moves => move, :start => @start_index, :curpos => @curpos }
   at
  end
end

def self.updatePiece(arr , n)
  l = Piece.new(arr[0], arr[1], arr[4], n)
  l.parse
end
end
