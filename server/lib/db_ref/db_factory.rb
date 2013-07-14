class DbRef::DbFactory
  cattr_accessor :db_ref_full
  @@db_ref_full = []

  def self.pgn2fen(file_path)
    @@game_number_path = file_path.gsub('.pgn', '_GameNumber.txt')
    @@bd_ref_path = file_path.gsub('.pgn', '_BD-REF.txt')
    @@pgn_path = file_path
    @@file_path = file_path.gsub('.pgn', '.txt')

    puts "exec ~> '#{PGN_TO_FEN}' '#{@@pgn_path}'"
    file = `#{PGN_TO_FEN} #{@@pgn_path}`
    File.open(@@file_path, 'w') do |f|
      f.puts(file)
    end
  end

  def self.add_game_number
    inFile = File.open(@@file_path, "r")
    outFile = File.open(@@game_number_path,"w")
    gameNumber = 0
    inFile.each do |line|
      fenArray = line.split(' ')
      if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
        gameNumber += 1
      end
      newLine = line.chop + " " + gameNumber.to_s
      outFile.puts(newLine)
    end
    inFile.close
    outFile.close
  end

  def self.generate_DB_REF(file_path)
    puts 'generating db reference for ' + file_path
    pgn2fen file_path
    add_game_number

    nameDb = String.new(@@pgn_path)
    nameDb.slice! ".pgn"
    nameDb = nameDb.split('/').last

    @@db_ref = @@db_ref_full.select{ |db| db.amI? nameDb }.first
    if @@db_ref.nil?
      @@db_ref = DbRef::DbRef.new nameDb

      pgnFile = File.open(@@pgn_path,"r")
      fenFile = File.open(@@game_number_path,"r")
      finalFile = File.open(@@bd_ref_path,"w")

      winner = "d"
      fenFile.each do |fenLine|
        match = fenLine.split(' ').last
        fenArray = fenLine.split(' ')
        if (fenArray[1].eql? 'w') && (fenArray[5].to_i==1)
          until (pgnLine = pgnFile.readline).start_with? '[Result '; end
          result = pgnLine.split('"')[1]
          if result.eql? '1-0'
            winner = "w"
          elsif result.eql? '0-1'
            winner = "b"
          else
            winner = "d"
          end
        end
        newLine = fenLine.chop + " " + winner
        finalFile.puts(newLine)

        fenmove = DbRef::FenMove.new newLine.split(' ')[0], newLine.split(' ')[6], winner
        @@db_ref.add_fen_move fenmove
      end

      @@db_ref_full << @@db_ref

      finalFile.close
      fenFile.close
      pgnFile.close
      puts 'DB creada correctamente'
      return 'DB creada correctamente'
    else
      return 'DB ya existente'
    end
  end
end
