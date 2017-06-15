class ChessController < ApplicationController
	include ChessHelper
	extend ChessHelper
@@arr
@@color
@@cpu
@@player
@@game

@@playerCheckmate = false
@@cpuCheckmate = false

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
    @@playerCheck = @game.playerCheck
    @@cpuCheck = @game.cpuCheck
    
    @@counter = 1

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

      array = Array.new(8){Array.new(8)}
      
      array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
             j = @@arr[x][y]
        end
      end
      
      if possible(pieceVal, squareVal, a, b, c, d, array, false)  && preCheck(a, b, c, d, pieceVal, @@playercolor, @@cpucolor)
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

     array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
             j = @@arr[x][y]
        end
      end

      @@cpuCheck = check?(@@cpucolor, @@playercolor, array)
      if @@cpuCheck
        @@cpuCheckmate = checkMate?(@@cpucolor, @@playercolor, array)
        puts "Checkmate? #{@@cpuCheckmate}"
      end
      cpumove(@@cpucolor, @@playercolor, @@arr)
        
      @@counter += 1

      redirect_to update_path 

      end
      
      
    


    end
    
    def update
      @arr =  @@arr
      @cpu = @@cpu
      @player = @@player
    end
    
    def possible(p, s, a, b, c, d, arr, checking)
     indS = [c,d]     
     indP = [a, b]
     bool = false
     piece = arr[a][b]


     if indS != indP
     
       if ((p[0] != s[0] || s[0] === 0)) && (checkBetween(p.last, indS, indP, arr, p, checking)) 
       	 bool = p.last.any? {|x| x === [c,d]}
       else
       
       end
  
     end
     bool
    end

    def checkBetween(moves, ind, indP, boardArr, pl, checking)
      rl = []
      ud =[]
      diag1 = []
      diag2 = []
      bool = true
      
     


      a = boardArr[indP[0]][indP[1]]
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
        bool = pawnLogic(moves, ind, indP, start, boardArr, pl, checking)
      elsif ind[0] === indP[0]
       arr = rl.map {|x| x = [ind[0], x]}
        arr.shift
        arr.each do |i|
           if boardArr[i[0]][i[1]] != [0]
           	 bool = false
           end
        end
       elsif ind[1] === indP[1]
         arr = ud.map {|x| x = [x,ind[1]]}
         arr.shift
         arr.each do |i|
           if boardArr[i[0]][i[1]] != [0]
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
            
            a= i[0]
            b = i[1]

           
            if arr != nil && b != nil && a != nil
             
              if boardArr[a][b] != [0]
           	   bool =false
              end
             end
          end
       end
      
      #puts " piece: #{piece} curpos: #{indP} possible? #{bool}   "
   

      bool

    end
    
    def pawnLogic(moves, sq, pl, st, arr, player, checking)
      array =[]
      move = moves
      bool = true
      
      if st === 1 
        if arr[pl[0]+1][pl[1]+1] != nil 
          att1 = arr[pl[0]+1][pl[1]+1]
          (att1[0] != player[0] && att1 != [0] && !move.include?([pl[0]+1, pl[1]+1]) ) ?  move.push([pl[0]+1, pl[1]+1]) : 0
        end
        if arr[pl[0]+1][pl[1]-1] != nil
          att2 = arr[pl[0]+1][pl[1]-1]
          (att2[0] != player[0] && att2 != [0] && !move.include?([pl[0]+1, pl[1]-1])) ?  move.push([pl[0]+1, pl[1]-1]) : 0
        end
      elsif st === 6
         if arr[pl[0]-1][pl[1]+1] != [0] && pl[1]+1 < 8
           att3 = arr[pl[0]-1][pl[1]+1]
           (att3[0] != player[0] && att3 != [0] && !move.include?([pl[0]-1, pl[1]+1])) ? move.push([pl[0]-1, pl[1]+1]) : 0
         end
         if arr[pl[0]-1][pl[1]-1] != [0] && pl[1]-1 > -1
           att4 = arr[pl[0]-1][pl[1]-1]
           (att4[0] != player[0] && att4 != [0] && !move.include?([pl[0]-1, pl[1]-1]) )  ?  move.push([pl[0]-1, pl[1]-1]) : 0
         end
      end

      if sq[1] === pl[1] && sq[0] > pl[0] 
        (pl[0]...sq[0]).to_a.each {|x| array.push(x)}
      elsif sq[1] === pl[1] && sq[0] < pl[0] 
        (sq[0]...pl[0]).to_a.reverse.each { |x| array.push(x)}
      end
      
      array = array.map {|x| x = [pl[0], x]}
      array.shift
      array.each do |i|
           if arr[i[0]][i[1]] != [0]
             bool =false
           end
      end

      move.each do |x| 
        if x[1] === pl[1] && arr[x[0]][x[1]] != [0] && !checking
          move.delete(x) 
        end
      end
      bool = move.include?(sq)

      bool
    end
     
    def check?(color1, color2, arr, piece = nil) 
      bool = false
      kingPos = [0,0] 



      array = Array.new(8){Array.new(8)}
      
      array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
            j = arr[x][y]
        end
      end

      array.each do |i|
         i.each do |j|
           if j[0] === color1 && j[2] === "king" 
              kingPos = j[3]
           end
         end
      end
      
      if piece != nil && piece[3] != kingPos && piece[2] === "king"
        kingPos = piece[3]
      end

      array.each do |i|
         i.each do |j|
           
             if j[0] === color2 && j[0] != [0]
              if possible(j, array[kingPos[0]][kingPos[1]] , j[3][0], j[3][1],kingPos[0], kingPos[1], array, true)
                bool = true
              end
             end 
            
         end
      end
      puts "#{color1} in check: #{bool}, #{kingPos}"
      bool
    end 
    
    def preCheck(a, b, c, d, piece, c1, c2)
      array = Array.new(8){Array.new(8)}
      
      array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
          if x === a && y ===b
             j = [0]
          elsif x === c && y ===d
             j = ChessHelper::updatePiece(piece,[c,d])
             piece = j
          else
             j = @@arr[x][y]
          end
        end
      end
      
      

      bool = !check?(c1, c2, array, piece)
      #puts "#{a} #{b} #{c} #{d}"
      bool
    end

    def checkMate?(color1, color2, array)
      bool = false
      possibleMoves =[]
        array.each do |i|
          i.each do |j|
            if j[0] === color1 && j[0] != [0]

               j.last.each do |x| 
                if possible(j, array[x[0]][x[1]], j[3][0], j[3][1], x[0], x[1], array, true) && preCheck(j[3][0], j[3][1], x[0], x[1], j, color1, color2) 
                  possibleMoves.push([j[0], j[2], x]) 
                end
              end 
            end
          end
        end
      
       puts "possible moves: #{possibleMoves}"
       if possibleMoves.empty?
         bool = true
       end

       bool

    end

    def cpumove(color1, color2, arr)
    #puts all possible, valid computer moves 
       possibleMoves =[]
       
       array = Array.new(8){Array.new(8)}
      
       array = array.each_with_index.map do |i, x|
        i.each_with_index.map  do |j, y|
            j = @@arr[x][y]
        end
      end

        array.each do |i|
          i.each do |j|
            if j[0] === color1 && j[0] != [0]
              j.last.each do |x| 
                if possible(j, array[x[0]][x[1]], j[3][0], j[3][1], x[0], x[1], array, false) && preCheck(j[3][0], j[3][1], x[0], x[1], j, color1, color2) 
                  possibleMoves.push([j[0], j[2], j[3], x]) 
                end
              end 
            end
          end
        end
       #puts "possible moves: #{array}"
       #random possible move
       index = rand(0...possibleMoves.size)

       curpos = possibleMoves[index][2]
       newpos = possibleMoves[index][3]

       a = curpos[0]
       b = curpos[1]
       c = newpos[0]
       d = newpos[1] 

       pieceVal = @@arr[a][b]

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

end
















