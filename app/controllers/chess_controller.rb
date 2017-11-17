class ChessController < ApplicationController
	include ChessHelper
	extend ChessHelper

  def pre

  end

  def stateUpdate(a, c, p, co, m)
		@@State ={
		  :arr => a,
		  :cpu => c,
		  :player => p,
		  :counter => co,
		  :moves => m
		}
	end

  def new
  	# board setup
    name = params[:name]
    color = params[:color]
  	game = Game.new(color, name).gameState

		@arr = game[:board]
    @cpu = game[:cpu]
    @player = game[:player]

    #globalized check variables
    @@playerCheckmate = false
    @@cpuCheckmate = false
    #counter
    @counter = 1
		#persistent board state glabal init

		#if cpu goes first
    if color == "black"
      cpumove(@cpu[:color], @player[:color], @arr)
			@game[:board] = @arr
    end

    @moves = {}
    @@cpuMoveInfo = []
    stateUpdate(@arr, @cpu, @player, @counter, @moves)

  end

 def select
	     @player = @@State[:player]
	     @select = false
    	 pos = params[:pos].each_char.map(&:to_i)
         a = pos[0]
      	 b = pos[2]
         first = @@State[:arr][a]
         second = first[b]
					 (second[:color] == @player[:color]) ?  @select = true : @select = false
         respond_to do |format|
           format.json { render json: @select }
          end
    end

    def move
      @arr = @@State[:arr]
			@cpu = @@State[:cpu]
			@player = @@State[:player]
			@counter = @@State[:counter]
			@moves = @@State[:moves]

      piece = params[:piece].chomp(",").each_char.map(&:to_i)
      a = piece[0]
      b = piece[2]

      square = params[:square].chomp(",").each_char.map(&:to_i)
      c= square[0]
      d= square[2]

			#piece moved
      pieceVal = @arr[a][b]
			#square moved to
      squareVal = @arr[c][d]
      #make copy of @arr
      array = copy(@arr)
      #is the move legal?
      if possible(pieceVal, squareVal, a, b, c, d, array, false, @player[:color], @cpu[:color])
       preCheck(a, b, c, d, pieceVal, @player[:color], @cpu[:color], array) ?  @arr = pieceMove(a,b,c,d,array,pieceVal) : nil
			 array = copy(@arr)
		 	 if !sequence(@cpu, @player, array)
			   @arr = cpumove(@cpu[:color], @player[:color], array)
			 else
				 return redirect_to win_path
			 end
			 array = copy(@arr)
			 if sequence(@player, @cpu, array)
				 return redirect_to lose_path
			 end

       @moves[@counter] = pastMove(piece, square, @@cpuMoveInfo)
       @counter += 1
 		   stateUpdate(array, @cpu, @player, @counter, @moves)
       return redirect_to update_path
      end

    end

    def update
      @arr = @@State[:arr]
      @cpu = @@State[:cpu]
      @player = @@State[:player]
      @counter = @@State[:counter]
      @moves = @@State[:moves]
    end

    def sequence(player1, player2, arr)
      bool = false
			player1[:checked?] = check?(player1[:color], player2[:color], arr)
			if player1[:checked?]
				 @@cpuCheckmate = checkMate?(player1[:color], player2[:color], arr)
				 puts "Checkmate? #{@@cpuCheckmate}"
				 checkFlash(player1[:color])
				 if @@cpuCheckmate
					 bool = true
				 end
			 elsif !player1[:checked?]
				 @@cpuCheckmate = checkMate?(player1[:color], player2[:color], arr)
				 if @@cpuCheckmate
					 bool = true
				 end
			 end
			 return bool
		end

    def possible(piece, s, a, b, c, d, arr, checking, c1, c2)
     indS = [c,d]
     indP = [a, b]
     bool = false

       if ((piece[:color] != s[:color]) && (checkBetween(piece, a, b, c, d, arr,checking, c1, c2)))
       	 bool = piece[:moves].any? {|x| x === [c,d]}
				 bool
       end

    end

    def checkBetween(piece, a, b, c, d, arr, checking, c1, c2)
			#anything in between?
      bool = true

			if piece[:name] == 'pawn'
				bool = pawnLogic(piece, a, b, c, d, arr, checking)
			elsif piece[:name] == 'knight'
				bool = true
			elsif ((a-c).abs == 1 || (b-d).abs == 1)
				bool = true
			else
        bool = checkCases(a, b, c, d, piece, arr)
			end
      #puts "#{piece[:color]}, #{piece[:name]}, #{checking}, #{bool}"
			bool
    end

    def checkCases(a, b, c, d, piece, arr)
       vert = a-c
       hor  = b-d
			 val = []
			 val[0] = vert
			 val[1] = hor
			 move =[]
			 piece[:moves].each { |x| (x[0] != c || x[1] != d )  ? move.push(x) : nil}
       bool = true

       #puts "Values #{val[0]} #{val[1]} #{a} #{b}"

       if val[0] == 0 && val[1] == 0
				 bool = false
		   elsif val[0] > 0 && val[1] == 0 #up
              move.each do |y|
                 if (y[0] < a && y[0] > c ) && y[1] == b
                   obj = arr[y[0]][y[1]]
                   obj[:color] != 0  ?  bool = false : nil
								 end
							end
			 elsif val[0] < 0 && val[1] == 0 #down
					 move.each do |y|
						  obj = arr[y[0]][y[1]]
							if (y[0] > a && y[0] != c && y[0] < c) && y[1] == b
							  (obj[:color] != 0) ? bool = false : nil
							end
					 end
			 elsif val[0] == 0 && val[1] > 0 #right
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if y[0] == a && (y[1] < b && y[1] > d)
								(obj[:color] != 0) ? bool = false : nil
							end
					 end
			 elsif val[0] == 0 && val[1] < 0 #left
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if y[0] == a && (y[1] > b && y[1] < d)
								(obj[:color] != 0) ? bool = false : nil
							end
					 end
			 elsif (val[0] > 0 && val[1] < 0) #up-right
				   #puts "UP-RIGHT"
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if (y[0] < a && y[0] > c) && (y[1] > b && y[1] < d)
								(obj[:color] != 0) ? bool =  false : nil
							end
					 end
			 elsif val[0] > 0 && val[1] > 0 #up-left
				 #puts "UP-LEFT"
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if  (y[0] < a && y[0] > c) && (y[1] < b && y[1] > d)
								(obj[:color] != 0) ? bool =  false : nil
							end
					 end
			 elsif val[0] < 0 && val[1] > 0 #down-right
				 #puts "DOWN-RIGHT"
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if  (y[0] > a && y[0] < c)&& (y[1] < b && y[1] > d)
								(obj[:color] != 0) ? bool = false : nil
							end
					 end
			 elsif  val[0] < 0 && val[1] < 0 #down-left
				 #puts "DOWN_LEFT"
					 move.each do |y|
						 obj = arr[y[0]][y[1]]
							if  (y[0] > a && y[0] < c)&& (y[1] > b && y[1] < d)
								(obj[:color] != 0) ? bool = false : nil
							end
					 end
			 else
         bool = true
			 end

			 bool
		end

    def pawnLogic(piece, a, b, c, d, arr, checking)
      badMove =[]
      bool = true

			sqob = [c, d]

			piece[:moves].each do |i|
        move = arr[i[0]][i[1]]
        #puts "PAWNSSS!!!!  #{move}, #{piece[:color]},  #{piece[:curpos]}"
				if (move[:color] == 0  || move[:color] == piece[:color]) && piece[:curpos][1]+1 ==i[1]
           badMove.push(i)
				end
				if (move[:color] == 0  || move[:color] == piece[:color]) && piece[:curpos][1]-1 == i[1]
					 badMove.push(i)
				end
				if piece[:curpos][1] == i[1] && move[:color] != 0
					badMove.push(i)
        end
				if (piece[:curpos][0] + 2 == i[0] && move[:color] != 0)
          badMove.push(i)
				end
				if (piece[:curpos][0] - 2 == i[0] && move[:color] != 0)
			    badMove.push(i)
				end

			end

        bool = !badMove.include?(sqob)

        return bool
    end

    def check?(c1, c2, arr, piece=nil)
      kingPos = [0, 0]

      if piece != nil && piece[:curpos] != kingPos && piece[:name] === "king"
        kingPos = piece[:curpos]
			else
				arr.each do |x|
          x.each do |y|
						if y[:color] == c1 && y[:name] == 'king'
							 kingPos = y[:curpos]
						end
					end
				end
      end
      puts "Kingpos #{kingPos}"
      arr.each do |i|
         i.each do |j|
             if j[:color] == c2
							 puts c2
              if possible(j, arr[kingPos[0]][kingPos[1]] , j[:curpos][0],
								          j[:curpos][1], kingPos[0], kingPos[1], arr, true, c1, c2)
                return  true
							else
								return  false
              end
             end
         end
      end

    end

    def preCheck(a, b, c, d, piece, c1, c2, arr)
      array = vCopy(a, b, c, d, arr, piece)

      return !check?(c1, c2, array, piece)
      #puts "#{a} #{b} #{c} #{d}"
    end

    def checkMate?(color1, color2, array)
      bool = false
      possibleMoves = posMoves(color1, color2, array)

       if possibleMoves.empty?
         bool = true
       end

       bool

    end

    def cpumove(color1, color2, arr)
    #puts all possible, valid computer moves
		   array = copy(arr)
       possibleMoves = posMoves(color1, color2, array)
       attackMoves =[]

       #puts "possible moves: #{nonThreat}"
       #random possible move

         index = rand(0...possibleMoves.size)
         curpos = possibleMoves[index][2]
         newpos = possibleMoves[index][3]

       a = curpos[0]
       b = curpos[1]
       c = newpos[0]
       d = newpos[1]

       pieceVal = @@State[:arr][a][b]

      puts "possible moves for cpu:  #{possibleMoves}"
      @@cpuMoveInfo = [a,b,c,d,pieceVal]

      @arr = pieceMove(a,b,c,d,array,pieceVal)
			@arr
    end

    def pawnChange(piece, n)
       if piece[:start] === 1 && n[0] === 7
        ChessHelper::pawnFun(piece, n)
			elsif piece[:start]===6 && n[0] ===0
        ChessHelper::pawnFun(piece, n)
       else
        ChessHelper::updatePiece(piece, n)
       end
    end

	  def pieceMove(a,b,c,d,array,piece)
		       array = array.each_with_index.map do | e1, i1|
		         e1.each_with_index.map do |e2, i2|
		           if (i1 === a && i2 ===b)
		              e2 = {:color => 0 ,:name => "unknown", :start => 0}
		           elsif (i1 === c && i2 === d)
		              if piece[:name] != "pawn"
		                e2 = ChessHelper::updatePiece(piece,[c,d])
		              else
		                e2 = pawnChange(piece, [c,d])
		             end
		           else
		             e2 = array[i1][i2]
		           end
		        end
		      end
		      array
	  end

    def canAttack?(color1, arr)
       newArr=[]
       arr.each do |i|
         if i.is_a?(Hash)
         j = i[:moves]
           enemyPiece = @@arr[j[0]][j[1]]
           if enemyPiece[:color] === color1
             newArr.push(i)
           end
       end
		   end
       newArr
    end

    def attThreat?(n, color1, arr)
         threats =[]
         arr.each do |i|
           j = i[n]
           if filter(i, j, color1)
              threats.push(i)
           end
         end
         #puts "#{threats}"
         threats

    end

    def filter(col, j, c)
          array = copy(@@arr)

           array.each_with_index do |i, x|
              i.each_with_index do |b, y|
                 if b[:color] ==  c && b != 0
                   b[:moves].each {|sq|  (sq === j && possible(b, col, sq[0], sq[1], j[0], j[1], array, true)) ? true : false }
                 end
							 end
           end

    end

    def copy(arr)
      array = Array.new(8){Array.new(8)}

       array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
            j = arr[x][y]
        end
      end

      array
    end

		def vCopy(a, b, c, d, arr, piece)
			array = Array.new(8){Array.new(8)}

 		  array = array.each_with_index.map do |i, x|
 			  i.each_with_index.map  do |j, y|
 				 if x === a && y ===b
 						j = {:color => 0 ,:name => "unknown", :start_index => 0}
 				 elsif x === c && y ===d
 						j = ChessHelper::updatePiece(piece,[c,d])
 				 else
 						j = arr[x][y]
 				 end
 			 end
 		 end
		end

		def posMoves(color1, color2, array)
      possibleMoves =[]
			array.each do |i|
				i.each do |j|
					if j[:color] === color1
						j[:moves].each do |x|
							if possible(j, array[x[0]][x[1]], j[:curpos][0], j[:curpos][1],x[0], x[1], array, true, color1, color2)
								bool = preCheck(j[:curpos][0], j[:curpos][1], x[0], x[1], j, color1, color2, array)
								bool ? possibleMoves.push([j[:color], j[:name], j[:curpos], x]) : nil
							end
						end
					end
				end
			end
      return possibleMoves
    end
=begin
    def castleMove(piece, a, b, c, d, arr)
      rookPlace = []
      rook =[]
      array = arr

      if d == 6
          rookStr = piece[:color] + "rook" + (d+1).to_s
          rookPlace = [a, d+1]
          rook = [a, d-1]
      elsif d == 2
          rookStr = piece[:color] + "rook" + (d-1).to_s
          rookPlace = [a, d-2]
          rook = [a, d+1]
      elsif d == 1
          rookStr = piece[:color] + "rook" + (d-1).to_s
          rookPlace = [a, d-1]
          rook = [a, d+1]
      elsif d == 5
          rookStr = piece[:color] + "rook" + (d-1).to_s
          rookPlace = [a, d+2]
          rook = [a, d-1]
      end

      rookPiece = arr[rookPlace[0]][rookPlace[1]]

      if @@castleFigures[str] != true && @@castleFigures[rookStr] != true && rookPiece != [0]
          array = arr.each_with_index.map do | e1, i1|
            e1.each_with_index.map do |e2, i2|
             if (i1 === a && i2 ===b) || ([i1, i2] == rookPlace)
              e2 = [0]
             elsif (i1 === c && i2 === d)
              e2 = ChessHelper::updatePiece(piece,[c,d])
             else
              e2 = arr[i1][i2]
             end
           end
         end
      end
      @@castleFigures[rookStr] = true
     array[rook[0]][rook[1]] = ChessHelper::updatePiece(rookPiece, rook)
     array

    end
=end
    def checkFlash(player)
      flash.alert = "#{player} is in check!!!!"
    end

    def pastMove(p, s, cpu)
       letter = ('a'..'h').to_a
       number = (1..8).to_a

       str1 = "#{@player} #{letter[p[0]]}#{number[p[2]]} -->
			         #{letter[s[0]]}#{number[s[2]]}; "
       str2 = "#{@cpu} #{letter[cpu[0]]}#{number[1]} -->
			         #{letter[cpu[2]]}#{number[cpu[3]]}"
       str = str1 + str2
       str
    end

    def kingFilter(arr)
      bad =[]
      bad.each do |x|
          arr.include?(x) ? arr.delete(x) : nil
      end
      arr
    end
end
