class ChessController < ApplicationController
	include ChessHelper

  def new
  	@select = false
  	@game = Game.new("white", "ARSEFACE!!!")
    @arr = @game.board
    @cpu = @game.cpuName
    @player = @game.playerName
   
   

  end

 def select
    	 pos = params[:pos]
         a = pos[0]
      	 b = pos[1]

      	 if(@arr[a][b][0]===@color)
            @select = !@select
         end

         respond_to do |format|
           format.json { render json: true }
          end
    end
end
