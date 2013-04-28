namespace :app do
  namespace :fixtures do
    desc "Generates fixture files for tests"
    task :create  do
      # generate a year worth of sample data
      File.open( 'test/fixtures/samples.yml', 'w' )  do | f |
        f.puts "# Generated with rake app:fixtures:create"
        f.puts
        base = Time.new( 2011, 1, 1 )
        
        (0...8760).each do | hour |
          curr = base + (hour * 3600) 
          f.puts "hour#{hour}:"
          f.puts "  set_meta_id: 1"
          f.puts "  sample_time: #{curr.strftime( "%Y-%m-%d %H:00:00" )}"
          f.puts "  generated_kilowatts: 10000"
          f.puts "  temperature: 50"
          f.puts 
        end
      end

      File.open( 'test/fixtures/samples.yml', 'a' )  do | f |
        f.puts "# Generated with rake app:fixtures:create"
        f.puts
        base = Time.new( 2011, 1, 1 )
        counter = 0
        (0...744).each do | hour |
          curr = base + (hour * 3600) 
          f.puts "hour#{hour + 8760}:"
          f.puts "  set_meta_id: 2"
          f.puts "  sample_time: #{curr.strftime( "%Y-%m-%d %H:00:00" )}"
          f.puts "  generated_kilowatts: #{counter % 10}"
          f.puts "  temperature: 50"
          f.puts 
	  counter += 1
        end
      end

      # puts "Booo #{Dir.pwd}"
    end
  end
end
