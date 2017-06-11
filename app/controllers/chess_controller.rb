class ChessController < ApplicationController
	include ChessHelper
	extend ChessHelper
@@arr
@@color
@@cpu
@@player
@@game
  def new
  	
  	@game = Game.new("white", "ARSEFACE!!!")
    @@game = @game
    @arr = @game.board
    @@arr = @arr
    @cpu = @game.cpuName
    @player = @game.playerName
    @@playercolor = @game.playerColor
    @@cpucolor = @game.cpuColor
    @@cpu = @cpu
    @@player = @player
  end

 def select
 	     @select = false
    	 pos = params[:pos].each_char.map(&:to_i)
         a = pos[0]
      	 b = pos[2]
         first = @@arr[a]
         second = first[b]
      	 if(second[0]===@@playercolor)
            @select = !@select
         end

         respond_to do |format|
           format.json { render json: @select }
          end
    end
    
    def move
      piece = params[:piece].chomp(",").each_char.map(&:to_i)
      a = piece[0]
      b = piece[2]

      square = params[:square].chomp(",").each_char.map(&:to_i)
      c= square[0]
      d= square[2]

      pieceVal = @@arr[a][b]
      squareVal = @@arr[c][d]
      
      if possible(pieceVal, squareVal, a, b, c, d)
      @@arr = @@arr.each_with_index.map do | e1, i1|
        @@arr[i1].each_with_index.map do |e2, i2|
           if (i1 === a && i2 ===b)
           	 @@arr[a][b]  = [0]
           elsif (i1 === c && i2 === d)
            @@arr[c][d] = ChessHelper::updatePiece(pieceVal,[c,d])
           else
            e2 = @@arr[i1][i2] 
           end
        end
      end
      end
      
     
      redirect_to update_path 
    


    end
    
    def update
      @arr =  @@arr
      @cpu = @@cpu
      @player = @@player
    end
    
    def possible(p, s, a, b, c, d)
     indS = [c,d]     
     indP = [a, b]
     bool = false
     if indS != indP
     
       if ((p[0] != s[0] || s[0] === 0)) && (checkBetween(p.last, indS, indP))
       	 bool = p.last.any? {|x| x === [c,d]}
       else
       
       end
  
     end
     bool
    end

    def checkBetween(moves, ind, indP)
      rl = []
      ud =[]
      diag1 = []
      diag2 = []
      bool = true

      a = @@arr[indP[0]][indP[1]]
      piece = a[2]
      start = a[4]

      if ind[0] > indP[0] && ind[1] === indP[1]
        (indP[0]...ind[0]).to_a.each {|x| ud.push(x)}
      elsif ind[0] < indP[0] && ind[1] === indP[1]
      	(ind[0]...indP[0]).to_a.each {|x| ud.push(x)}
      elsif ind[1] > indP[1] && ind[0] === indP[0]
        (indP[1]...ind[1]).to_a.each {|x| rl.push(x)}
      elsif ind[1] < indP[1] && ind[0] === indP[0]
      	(ind[1]...indP[1]).to_a.each {|x| rl.push(x)}
      elsif ind[0] > indP[0] && ind[1] > indP[1] 
        (indP[0]..ind[0]).to_a.each {|x| diag1.push(x)}
        (indP[1]..ind[1]).to_a.each {|x| diag2.push(x)}
      elsif ind[0] < indP[0] && ind[1] > indP[1] 
      	(ind[0]..indP[0]).to_a.each {|x| diag1.push(x)}
      	(indP[1]..ind[1]).to_a.each {|x| diag2.push(x)}
        diag2 = diag2.reverse
      elsif ind[0] < indP[0] && ind[1] < indP[1] 
      	(ind[0]..indP[0]).to_a.each {|x| diag1.push(x)}
      	(ind[1]..indP[1]).to_a.each {|x| diag2.push(x)}
      elsif ind[0] > indP[0] && ind[1] < indP[1] 
         (indP[0]..ind[0]).to_a.each {|x| diag1.push(x)}
         (ind[1]..indP[1]).to_a.each {|x| diag2.push(x)}
         diag2 = diag2.reverse
      end

      if piece == "pawn"
        bool = pawnLogic(moves, ind, indP, start)
      elsif ind[0] === indP[0]
       arr = rl.map {|x| x = [ind[0], x]}
        arr.shift
        arr.each do |i|
           if @@arr[i[0]][i[1]] != [0]
           	 bool = false
           end
        end
       elsif ind[1] === indP[1]
         arr = ud.map {|x| x = [x,ind[1]]}
         arr.shift
         arr.each do |i|
           if @@arr[i[0]][i[1]] != [0]
           	 bool =false
           end
        end
       elsif piece == "knight"
         bool = true
      
       else
         
       	 arr = diag1.each_with_index.map { |x, y| x = [x, diag2[y]] }
       	 arr.shift
      
           arr = arr.empty? ? arr : (arr.first arr.size-1)
         arr.each do |i|
           if arr != nil
           if @@arr[i[0]][i[1]] != [0]
           	 bool =false
           end
         end

        end
       end

   

      bool

    end
    
    def pawnLogic(moves, sq, pl, st)
      array =[]
      move = moves
      bool = true
      
      att1 = @@arr[pl[0]+1][pl[1]+1]
      att2 = @@arr[pl[0]+1][pl[1]-1]
      if @@arr[pl[0]-1][pl[1]+1] != nil
        att3 = @@arr[pl[0]-1][pl[1]+1]
      else
        att3= @@arr[pl[0]-1][pl[1]]
      end
      if @@arr[pl[0]-1][pl[1]-1] != nil
        att4 = @@arr[pl[0]-1][pl[1]-1]
      end

      if sq[1] === pl[1] && sq[0] > pl[0] 
        (pl[0]...sq[0]).to_a.each {|x| array.push(x)}
      elsif sq[1] === pl[1] && sq[0] < pl[0] 
        (sq[0]...pl[0]).to_a.each { |x| array.push(x)}
      end
      
      array = array.map {|x| x = [pl[0], x]}
      array.shift
      array.each do |i|
           if @@arr[i[0]][i[1]] != [0]
             bool =false
           end
      end

      if st === 1  
        if att1[0] != @@playercolor && att1 != [0]
          move.push([pl[0]+1, pl[1]+1])
        end
        if att2[0] != @@playercolor && att2 != [0]
           move.push([pl[0]+1, pl[1]-1])
        end
      elsif st === 6 
        if att3[0] != @@playercolor && att3 != [0]
          move.push([pl[0]-1, pl[1]+1])
        end
        if att4[0] != @@playercolor && att4 != [0]
           move.push([pl[0]-1, pl[1]-1])
        end
      end
      move.each do |x| 
        if x[1] === pl[1] && @@arr[x[0]][x[1]] != [0] 
          move.delete(x) 
        end
      end
      
      bool = move.include?(sq)

      bool
    end
    
end
















