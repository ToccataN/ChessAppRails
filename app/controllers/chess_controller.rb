class ChessController < ApplicationController
	include ChessHelper
	extend ChessHelper
  #initialize game_logic module
	class Logic
	  include GameLogic
  end

	@@logic = Logic.new

  def pre
    reset_session
  end

  def stateUpdate(a, c, p, co, m)
		@@State ={
		  :arr => a,
		  :cpu => c,
		  :player => p,
		  :counter => co,
		  :moves => m
		}
		return @@State
	end

  def new
		#Rails.cache.clear
  	# board setup
		reset_session
    name = params[:name]
    color = params[:color]
  	game = Game.new(color, name).gameState

		@arr = game[:board]
    @cpu = game[:cpu]
    @player = game[:player]
    @@current_game = Games.create!(player: @player.to_json, cpu: @cpu.to_json)
		session[:game] = @@current_game.id
		session[:counter] = @counter
    #globalized check variables
    @@playerCheckmate = false
    @@cpuCheckmate = false
    #counter
    @counter = 1
		@moves = {}

		#persistent board state glabal init
    @@State = stateUpdate(@arr, @cpu, @player, @counter, @moves)
		@State = @@State

		boarder = hasher(@arr)
		Turn.create!(turn: session[:counter], board: boarder.to_json, games_id: session[:game], pmoves: @@State[:moves].to_json)
		#if cpu goes first
    if color == "black"
      @arr = @@logic.cpumove(@cpu[:color], @player[:color], @arr)
    end

    @@cpuMoveInfo = []
    @@State = stateUpdate(@arr, @cpu, @player, @counter, @moves)
    #Rails.cache.write name, @@State
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
			@State = @@State
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
      array = @@logic.copy(@arr)
      #is the move legal?
      if @@logic.possible(pieceVal, squareVal, a, b, c, d, array, false, @player[:color], @cpu[:color])
       @@logic.preCheck(a, b, c, d, pieceVal, @player[:color], @cpu[:color], array) ?  @arr = @@logic.pieceMove(a,b,c,d,@arr,pieceVal) : nil
			 array = @@logic.copy(@arr)
		 	 if !@@logic.sequence(@cpu, @player, @arr)
			   @arr = @@logic.cpumove(@cpu[:color], @player[:color], @arr)
			 else
				 return redirect_to win_path
			 end
			 array = @@logic.copy(@arr)
			 if @@logic.sequence(@player, @cpu, array)
				 return redirect_to lose_path
			 end

       @moves[@counter] = pastMove(piece, square, @@logic.cpuMoveInfo)
       @counter += 1
			 session[:counter] = @counter

			 arrHash = hasher(array)
			 Turn.create!(turn: session[:counter], board: arrHash.to_json, games_id: session[:game], pmoves: @@State[:moves].to_json)
 		   @@State = stateUpdate(array, @cpu, @player, @counter, @moves)
			 @player[:checked?] ? checkFlash(@player[:name]) : nil
       return redirect_to update_path
      end

    end

    def update
			  @newState = Turn.where(games_id: session[:game], turn: session[:counter]).first
			  array = stringParser(@newState.board)
			  @moves = JSON.parse(@newState.pmoves)
			  @player = JSON.parse(Games.find(session[:game]).player).symbolize_keys
			  @cpu = JSON.parse(Games.find(session[:game]).cpu).symbolize_keys
			  @@State = stateUpdate(array, @cpu, @player, session[:counter], @moves)
        @counter = @@State[:counter]

			#puts arrHash.to_json
			#puts arr

			turn_id = Turn.where(games_id: session[:game], turn: session[:counter]).first.id
			arr = Turn.find(turn_id).board
			@arr = stringParser(arr)

    end

		def pastMove(p, s, cpu)
	     letter = ('a'..'h').to_a
	     number = (1..8).to_a

	     str1 = "#{@player[:name]} #{letter[p[0]]}#{number[p[2]]} -->
	             #{letter[s[0]]}#{number[s[2]]}; "
	     str2 = "#{@cpu[:name]} #{letter[cpu[0]]}#{number[1]} -->
	             #{letter[cpu[2]]}#{number[cpu[3]]}"
	     str = str1 + str2
	     str
	  end

		def checkFlash(player)
			flash.alert = "#{player} is in check!!!!"
		end

		def rollback
			if session[:counter].nil? || session[:counter] - 1 < 2
        return redirect_to root_path
			else
		  Turn.where(games_id: session[:game], turn: session[:counter]).first.destroy

			session[:counter] = session[:counter] - 1
      @newState = Turn.where(games_id: session[:game], turn: session[:counter]).first
			@arr = stringParser(@newState.board)
			@moves = JSON.parse(@newState.pmoves)
			@player = JSON.parse(Games.find(session[:game]).player).symbolize_keys
			@cpu = JSON.parse(Games.find(session[:game]).cpu).symbolize_keys
			@@State = stateUpdate(@arr, @cpu, @player, session[:counter], @moves)
      @counter = @@State[:counter]
		end
      #puts "\n this is the array!       \n\n   #{array}"
		end

		def stringParser(arr)
			theBoard = JSON.parse(arr)

      array = Array.new(8){Array.new(8)}
      theBoard.each do |key, value|
        key = key.split("")
				a = key[0].to_i
				b = key[1].to_i
				value = value.deep_symbolize_keys
			  array.each_with_index do |i, x|
					i.each_with_index do |j, y|
						if (x === a && y === b)
               array[x][y] = value
						end
			    end
		    end

			end #end hash iterator
			return array
		end

		def hasher(arr)
			arrHash = {}
			arr.each_with_index do |i, x|
        i.each_with_index do |j, y|
          prop = x.to_s+""+y.to_s
					arrHash[prop] = j
				end
			end
			return arrHash
		end


end
