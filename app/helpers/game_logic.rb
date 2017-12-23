module GameLogic

  def cpuMoveInfo
    @@cpuMoveInfo
  end

  def sequence(player1, player2, arr)
    bool = false
    player1[:checked?] = check?(player1[:color], player2[:color], arr)
    if player1[:checked?]
       @@cpuCheckmate = checkMate?(player1[:color], player2[:color], arr)
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
       if (piece[:name] == 'king' && checking == false)
         if (piece[:repos] === false && castle(a, b, c, d, arr) && (b-d).abs > 1 && bool === true)
          bool = true
         elsif ((b-d).abs > 1 || (a-c).abs > 1)
          bool = false
         elsif ((b-d).abs < 2)
          bool = true
         else
          bool = false
         end
       end
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
    bool = false
      arr.each do |x|
        x.each do |y|
          #puts "this? #{x} #{y}"
          if y[:color] == c1 && y[:name] == 'king'
             kingPos = y[:curpos]
          end
        end
      end

    arr.each do |i|
       i.each do |j|
           if j[:color] == c2
            if possible(j, arr[kingPos[0]][kingPos[1]] , j[:curpos][0],
                        j[:curpos][1], kingPos[0], kingPos[1], arr, true, c1, c2)
               j[:moves].include?(kingPos) ?  bool = true : nil
            end
           end
       end
    end
    return bool
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
     possibleMoves = posMoves(color1, color2, arr)
     tPieces = threatennedPieces(color1, color2, arr)
     attackMoves = canAttack?(color2, possibleMoves, arr)

     puts "possible moves: #{tPieces}"

     #random possible move
     if attackMoves.size > 0
       index = rand(0...attackMoves.size)
       curpos = attackMoves[index][2]
       newpos = attackMoves[index][3]
     else
       index = rand(0...possibleMoves.size)
       curpos = possibleMoves[index][2]
       newpos = possibleMoves[index][3]
     end

     a = curpos[0]
     b = curpos[1]
     c = newpos[0]
     d = newpos[1]

     pieceVal = arr[a][b]

    #puts "possible moves for cpu:  #{possibleMoves}"
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
         r = [a, b, c, d, false]

         array = array.each_with_index.map do | e1, i1|
           e1.each_with_index.map do |e2, i2|
             if (i1 === a && i2 ===b)
                e2 = {:color => 0 ,:name => "unknown", :start => 0}
             elsif (i1 === c && i2 === d)
                if (piece[:name] == 'king') && (piece[:repos]===true || (b-d).abs === 1)
                  puts "king1 ?#{piece} fun111: #{(b-d).abs}"
                  e2 = ChessHelper::updatePiece(piece,[c,d])
                elsif (piece[:name] == 'king' && (b-d).abs > 1 )
                  puts "king2 ?#{piece}"
                  r = castleMove(a, b, c, d)
                  e2 = ChessHelper::updatePiece(piece,[c,d])
                elsif piece[:name] != "pawn" && piece[:name] != 'king'
                  puts "king3 ?#{piece}"
                  e2 = ChessHelper::updatePiece(piece,[c,d])
                else
                  puts "king4 ?#{piece}"
                  e2 = pawnChange(piece, [c,d])
               end
             else
               e2 = array[i1][i2]
             end
          end
        end
        if r[4] === true
          puts "piece: #{r[0]} #{r[1]} #{r[2]} #{r[3]} #{array[r[0]][r[1]]} king? #{array[r[0]][r[1]-1]}"
          array = pieceMove(r[0], r[1], r[2], r[3], array, array[r[0]][r[1]])
        end
      return  array
  end

  def threatennedPieces(color1, color2, arr)
    tPieces =[]
    arr.each do |i|
      i.each do |j|
        if j[:color] == color1 && threats(color1, color2, j[:curpos], arr)
          tPieces.push(j)
        end
      end
    end
    return tPieces
  end

  def threats(color1, color2,curpos, arr)
    bool = false
    arr.each do |i|
      i.each do |j|
        if j[:color] == color2 && j[:moves].include?(curpos)
          j[:moves].each do |x|
            if (possible(j, arr[x[0]][x[1]], j[:curpos][0], j[:curpos][1],x[0], x[1], arr, true, color1, color2) && preCheck(j[:curpos][0], j[:curpos][1], x[0], x[1], j, color1, color2, arr))
               bool = true
            end
          end
        end
      end
    end
    return  bool
  end

  def canAttack?(color1, pos,  arr)
     newArr=[]
     array = copy(arr)
     pos.each do |i|
       j = i.last
       piece = i[2]
         enemyPiece = array[j[0]][j[1]]
         if enemyPiece[:color] == color1  && attThreat?(enemyPiece, piece, array)
           newArr.push(i)
         end
     end
     newArr
  end

  def attThreat?(enemy, piece, arr)

       array = copy(arr)
       piece = array[piece[0]][piece[1]]
       if enemy.has_key?(:rank)
         if piece[:rank] > enemy[:rank] && filter(array, enemy, piece)
           return false
         end
       elsif enemy[:color] == 0 && filter(array, enemy, piece)
           return false
       end
       return true

  end

  def filter(arr, enemy, piece)
        color1 = enemy[:color]
        color2 = piece[:color]
        bool = false
        arr.each do |i|
          i.each do |j|
            if j[:color] == color1 && j[:moves].include?(enemy[:curpos])
              j[:moves].each do |x|
                if (possible(j, arr[x[0]][x[1]], j[:curpos][0], j[:curpos][1],x[0], x[1], arr, true, color1, color2) && preCheck(j[:curpos][0], j[:curpos][1], x[0], x[1], j, color1, color2, arr))
                  bool = true
                end
              end
            end
          end
        end
        return bool
  end

  def copy(arr)
    array = Array.new(8){Array.new(8)}

     array = array.each_with_index.map do |i, x|
      i.each_with_index.map  do |j, y|
          j = arr[x][y]
      end
    end

    return array
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
   return array
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

  def castle(a, b, c, d, arr)
    arr = copy(arr)
    #puts " castle counts #{b} #{d}"
    if arr[c][d+1][:name] == "rook"  && !arr[c][d+1][:repos]
        return true
    elsif arr[c][d-1][:name] == "rook"  && arr[c][d-1][:repos]
        return true
    elsif arr[c][d-2][:name] == "rook"  && !arr[c][d+2][:repos]
        return true
    elsif arr[c][d+2][:name] == "rook"  && !arr[c][d-2][:repos]
        return true
    end

  end

  def castleMove(a, b, c, d)

       if b < d && b === 4
         cY = a
         cX = d+1
         cY2 = c
         cX2 = d-1
       elsif b > d && b === 3
         cY = a
         cX = d-1
         cY2 = c
         cX2 = d+1
       elsif b > d && b === 4
         cY = a
         cX = d-2
         cY2 = c
         cX2 = d+1
       else
        cY = a
        cX = d+2
        cY2 = c
        cX2 = d-1
       end
     return [cY, cX, cY2, cX2, true]
  end


  def kingFilter(arr)
    bad =[]
    bad.each do |x|
        arr.include?(x) ? arr.delete(x) : nil
    end
    arr
  end

end
