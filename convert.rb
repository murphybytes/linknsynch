require 'date'
first_line=true
File.open( 'data/dataset2.csv', 'w' ) do | f |
  File.open( 'data/dataset.csv' ).each_line do | line |
    if first_line
      first_line = false
      next
    end
    puts "processing #{line}"
    parts = line.split(",")
    year = ["10","11","12"].count( parts[0] ) > 0 ? 2011 : 2012
    dt = DateTime.new( year, parts[0].to_i, parts[1].to_i, parts[2].to_i / 100 )
    f.puts "#{dt.iso8601},#{parts[3].to_i}, #{parts[6]}"
  end
end
