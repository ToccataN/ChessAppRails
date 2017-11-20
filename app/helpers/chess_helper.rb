module ChessHelper

  class Game

	    class << self
           attr_accessor :boardPos,  :player, :cpu
	    end

		  def initialize(color, name)
		  	 @player = Player.new(color, name).playerState
		  	 if color == "black"
		       @cpu = Player.new("white", "The Black Knight!!!!").playerState
					 @boardPos = Board.new(@cpu, @player).board
		     elsif color == "white"
		       @cpu = Player.new("black", "The Black Knight!!!!").playerState
					 @boardPos = Board.new(@cpu, @player).board
		     else
		    	 return "try another color, white or black"
		     end

      end

			def gameState
        state = { :player => @player,
                  :cpu => @cpu,
								  :board => @boardPos}
				state
			end
  #end game class
	end

  class Player
	  class << self
  	  attr_accessor :color, :name
    end

    def initialize(color, name)
      @color = color
      @name =name
    end
    def playerState
    	state ={:color => @color, :name => @name, :checked? => false}
  		state
    end
	 #end player class
  end

  class Piece
	  class << self
	    attr_accessor :piece, :start_index, :curpos, :color, :moves, :name
    end
    def initialize(color, num, start_index, curpos, r = false)
      @piece
			@color = color
			@n = num
			@curpos = curpos
			@start_index = start_index
			@r = r
    end

		def update(col = @color, n = @n, s = @start_index, c = @curpos, r = true)
			case n
			when 'p'
				 Pawn.new(col, n,s,c, r).att
			when 'r'
				 Rook.new(col, n,s,c, r).att
			when 'k'
				 Knight.new(col, n,s,c).att
			when 'b'
				 Bishop.new(col, n,s,c).att
			when 'q'
				 Queen.new(col, n,s,c).att
			when 'ki'
				 King.new(col, n,s,c, r).att
			else
				 {:color => col,:name => "unknown", :start => 0}
			end
		end

  end

  class Pawn < Piece

    def move
  	  p = []
      if @start_index === 1
        if @curpos[0] === 1
          p = [[@curpos[0]+1, @curpos[1]], [@curpos[0]+2, @curpos[1]]]
        else
      	  p = [[@curpos[0]+1, @curpos[1]]]
        end
        if @curpos[1] - 1 >= 0
          p.push([@curpos[0]+1, @curpos[1]-1])
        end
        if @curpos[1] + 1 < 8
           p.push([@curpos[0]+1, @curpos[1]+1])
        end

       elsif @start_index === 6
         if @curpos[0] === 6
           p = [[@curpos[0]-1, @curpos[1]], [@curpos[0]-2, @curpos[1]]]
         else
        	  p = [[@curpos[0]-1, @curpos[1]]]
         end
         if @curpos[1] - 1 >= 0
            p.push([@curpos[0]-1, @curpos[1]-1])
         end
         if @curpos[1] + 1 < 8
           p.push([@curpos[0]-1, @curpos[1]+1])
         end
       end
      p
    end

    def att
      piece = {:color => @color, :name => "pawn", :n => @n,:moves => move,
	      :start => @start_index, :curpos => @curpos, :repos => @r}
		  piece
    end
  end

  class Rook < Piece


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
	 	  piece = {:color => @color, :name => "rook", :n => @n,:moves => move,
				:start => @start_index, :curpos => @curpos, :repos => @r}
	  	piece
	  end
  end

  class Knight < Piece

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
	    piece = {:color => @color, :name => "knight", :n => @n,:moves => move,
		      :start => @start_index, :curpos => @curpos}
			piece
   end
  end

  class Bishop < Piece
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
		  piece = {:color => @color, :name => "bishop", :n => @n,:moves => move,
				:start => @start_index, :curpos => @curpos}
		  piece
	  end
  end


  class Queen < Piece

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
		  piece = {:color => @color, :name => "queen", :n => @n,:moves => move,
				:start => @start_index, :curpos => @curpos}
		  piece
	  end
  end


  class King < Piece

    def move
  	  p = []

      a =[[1, 0],[-1, 0],[0, 1] ,[0, -1] , [1, 1] , [-1, -1], [-1, 1] ,[1, -1]]
      a.each do |i|
        if ((@curpos[0]+i[0] >= 0) && (@curpos[0]+i[0] < 8)) && ((@curpos[1]+ i[1] >= 0) && (@curpos[1]+ i[1] < 8))
          p.push([@curpos[0]+i[0], @curpos[1]+ i[1]])
        end
      end

      if @curpos[1] === 4
        p.push([@curpos[0], @curpos[1]+2], [@curpos[0], @curpos[1]-2])
      elsif @curpos[1] ===3
        p.push([@curpos[0], @curpos[1]-2], [@curpos[0], @curpos[1]+2])
      end
		  p
    end

	  def att
		  piece = {:color => @color, :name => "king", :n => @n,:moves => move,
			 	:start => @start_index, :curpos => @curpos, :repos => @r }
		  piece
	  end
  end

  class Board
  #initialize with color orientation
	  def initialize(c, pl)
      @cpu = c
		  @player = pl
      #board setup conditions, will probably be moved to database later
	    @boardPosW = [['r','k','b','q','ki','b','k','r'],
							['p','p','p','p','p','p','p','p'],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							['p','p','p','p','p','p','p','p'],
							['r','k','b','q','ki','b','k','r']]
	    @boardPosB = [['r','k','b','ki' ,'q','b','k','r'],
							['p','p','p','p','p','p','p','p'],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							[0,0,0,0,0,0,0,0],
							['p','p','p','p','p','p','p','p'],
							['r','k','b','ki','q' ,'b','k','r']]
			 end
    #board parser, will need to change this method
		def boardCol(a, b, c)
			 setup = c.each_with_index.map do |e, i|
						  if (i === 0 || i === 1)
						 		e = e.each_with_index.map do |l, j|
								  l = generate(a, l, i, [i, j])
						  	end
						  elsif (i === 6 || i === 7 )
						 		e = e.each_with_index.map do |l, j|
						   		l = generate(b, l, i, [i, j])
						  	end
						 	else
						  		e = e.each_with_index.map do |l, j|
										l = generate(0, l, i,[i, j])
									end
						 	end
				end
		 	 setup
 	  end
	  #configures new board by color distinction
	  def board
		     if @player[:color] == "white"
				   b = boardCol(@cpu[:color], @player[:color], @boardPosW)
		     elsif @player[:color] == "black"
					 b = boardCol(@cpu[:color], @player[:color], @boardPosB)
				 end
       b
	  end
		def generate(col, n, s, c)
			case n
			when 'p'
				 Pawn.new(col, n,s,c).att
			when 'r'
				 Rook.new(col, n,s,c).att
			when 'k'
				 Knight.new(col, n,s,c).att
			when 'b'
				 Bishop.new(col, n,s,c).att
			when 'q'
				 Queen.new(col, n,s,c).att
			when 'ki'
				 King.new(col, n,s,c).att
			else
				 {:color => col,:name => "unknown", :start => 0}
			end
		end
#end Board Class
 end

 def self.updatePiece(arr, n)
   l = Piece.new(arr[:color], arr[:n], arr[:start], n, true).update
   l
 end

 def self.pawnFun(arr, n)
   l = Piece.new(arr[:color], 'q', arr[:curpos], n).update
   l
 end
#module end
end
