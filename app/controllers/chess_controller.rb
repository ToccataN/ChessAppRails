class ChessController < ApplicationController
	include ChessHelper
	extend ChessHelper

  def pre

  end

  def new
  	# board setup
    name = params[:name]
    color = params[:color]
  	@game = Game.new(color, name )
    @@game = @game
    @arr = @game.board
    #player info
    @cpu = @game.cpuName
    @player = @game.playerName
    @@playercolor = @game.playerColor
    @@cpucolor = @game.cpuColor
    @@cpu = @cpu
    @@player = @player
    #globalized check variables
    @@playerCheck = @game.playerCheck
    @@cpuCheck = @game.cpuCheck
    @@playerCheckmate = false
    @@cpuCheckmate = false
    #counter
    @@counter = 1
    @counter= @@counter
    @@arr = @arr
    if color == "black"
      cpumove(@@cpucolor, @@playercolor, @@arr)
    end
    @arr = @@arr

    @@castleFigures = {}
    @arr.each do |i|
      i.each do |j|
        if j[2] == "rook" || j[2] =="king"
          str = j[0] + "" + j[2] + "" + j[4].to_s
          @@castleFigures[str] = false                    
        end
      end
    end
    @@castleFigures.each {|x|  puts "#{x}"}
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

      array = copy(@@arr)
      
      if possible(pieceVal, squareVal, a, b, c, d, array, false)  && preCheck(a, b, c, d, pieceVal, @@playercolor, @@cpucolor)
        @@arr = pieceMove(a,b,c,d,array,pieceVal)
        castleFilter(pieceVal)

      array = copy(@@arr)

      @@cpuCheck = check?(@@cpucolor, @@playercolor, array)
       if @@cpuCheck
         @@cpuCheckmate = checkMate?(@@cpucolor, @@playercolor, array)
         puts "Checkmate? #{@@cpuCheckmate}"
         if @@cpuCheckmate 
           return redirect_to win_path
         else
           cpumove(@@cpucolor, @@playercolor, @@arr)
         end
       elsif !@@cpuCheck
         @@cpuCheckmate = checkMate?(@@cpucolor, @@playercolor, array)
         if @@cpuCheckmate 
           return redirect_to lose_path
         else
           cpumove(@@cpucolor, @@playercolor, @@arr)
         end
       end
       
      array = copy(@@arr)
        
       @@playerCheck = check?(@@playercolor, @@cpucolor, array)
       if @@playerCheck
        @@playerCheckmate = checkMate?( @@playercolor, @@cpucolor, array)
        puts "Checkmate? #{@@playerCheckmate}"
        if @@playerCheckmate
          return  redirect_to lose_path
        end
       elsif !@@playerCheck
          @@playerCheckmate = checkMate?( @@playercolor, @@cpucolor, array)
          puts "Checkmate? #{@@playerCheckmate}"
          if @@playerCheckmate
            return  redirect_to lose_path
          end
       end
      
      @@counter += 1
      redirect_to update_path 
       
      

      end

    end
    
    def update
      @arr =  @@arr
      @cpu = @@cpu
      @player = @@player
      @counter = @@counter
    end
    
    def possible(p, s, a, b, c, d, arr, checking)
     indS = [c,d]     
     indP = [a, b]
     bool = false
     piece = arr[a][b]
     
     pClone = p.last

     if indS != indP
     
       if ((p[0] != s[0] || s[0] === 0)) && (checkBetween(p.last, indS, indP, arr, p, checking)) 
       	 bool = p.last.any? {|x| x === [c,d]}
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
      badMove =[]
      move = moves
      bool = true
     
        move.each do |i|
          puts "heres each move: #{i}"
          a = arr[i[0]][i[1]]
          
          if a[0] == 0 && pl[1]+1 == i[1]
            badMove.push(i)
          end
          if a[0] == player[0] &&  pl[1]+1 == i[1]
            badMove.push(i)
          end
          if a[0] == 0 && pl[1]-1 == i[1]
            badMove.push(i)
          end
          if a[0] == player[0] && pl[1]-1 == i[1]
            badMove.push(i)
          end
          if  (pl[1] === i[1] && a != [0]) || (pl[1] === i[1] && a != [0])
              badMove.push(i)
          end
          if pl[0]+2 == i[0]  && arr[pl[0]+1][pl[1]] != [0] 
              badMove.push(i)
          end
          if pl[0]-2 == i[0] && arr[pl[0]-1][pl[1]] != [0]
             badMove.push(i)
          end
        end
      
        bool = !badMove.include?(sq)  
      
      bool
  
    end
     
    def check?(color1, color2, arr, piece = nil) 
      bool = false
      kingPos = [0,0] 

      arr.each do |i|
         i.each do |j|
           if j[0] === color1 && j[2] === "king" 
              kingPos = j[3]
           end
         end
      end
      
      if piece != nil && piece[3] != kingPos && piece[2] === "king"
        kingPos = piece[3]
      end

      arr.each do |i|
         i.each do |j|
             if j[0] === color2 && j[0] != [0]
              if possible(j, arr[kingPos[0]][kingPos[1]] , j[3][0], j[3][1],kingPos[0], kingPos[1], arr, true)
                bool = true
              end
             end      
         end
      end
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
       attackMoves =[]

       array = copy(@@arr)

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

       priThreat = attThreat?(3, color2, possibleMoves)

       nonThreat = possibleMoves - priThreat
        
       attackMoves = canAttack?(color2, possibleMoves)
      
       threats = attThreat?(3, color2, attackMoves)

       newattackMoves = attackMoves - threats

       #puts "possible moves: #{nonThreat}"
       #random possible move
       if !newattackMoves.empty?
          index = rand(0...newattackMoves.size)
          curpos = newattackMoves[index][2]
          newpos = newattackMoves[index][3]
       elsif   !attackMoves.empty?
          index = rand(0...attackMoves.size)
          curpos = attackMoves[index][2]
          newpos = attackMoves[index][3]
       elsif !nonThreat.empty?
          index = rand(0...nonThreat.size)
          curpos = nonThreat[index][2]
          newpos = nonThreat[index][3]
       else
         index = rand(0...possibleMoves.size)
         curpos = possibleMoves[index][2]
         newpos = possibleMoves[index][3]
       end

       a = curpos[0]
       b = curpos[1]
       c = newpos[0]
       d = newpos[1] 

       pieceVal = @@arr[a][b]
       
       castleFilter(pieceVal)

       @@arr = pieceMove(a,b,c,d,array,pieceVal)

    end

    def pawnChange(piece, n)
       if piece[4] === 1 && n[0] === 7
        ChessHelper::pawnFun(piece, n)
       elsif piece[4]===6 && n[0] ===0
        ChessHelper::pawnFun(piece, n)
       else 
        ChessHelper::updatePiece(piece,n)
       end
    end

    def canAttack?(color1, arr)
       newArr=[]
       arr.each do |i|
         j = i.last
           enemyPiece = @@arr[j[0]][j[1]]
           if enemyPiece[0] === color1
             newArr.push(i)
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
                 if b[0] ==  c && b[0] != [0] 
                   b.last.each {|sq|  (sq === j && possible(b, col, sq[0], sq[1], j[0], j[1], array, true)) ? true : false }
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

    def pieceMove(a,b,c,d,array,piece)
       array = array.each_with_index.map do | e1, i1|
         e1.each_with_index.map do |e2, i2|
           if (i1 === a && i2 ===b)
              e2 = [0]
           elsif (i1 === c && i2 === d)
              if piece[2] != "pawn"
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

    def posMoves(array)
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
        possibleMoves
    end

    def castleFilter(piece)
       starts = [0 , 7 , [0,7] , [0,0] , [7,0] , [7,7]]
       if (piece[2] == "rook" || piece[2] =="king") && starts.include?(piece[4])
         str = piece[0] + "" + piece[2] + "" + piece[4].to_s
         @@castleFigures[str] = true                    
         @@castleFigures.each {|x|  puts "#{x}"}
       end
    end

end
















