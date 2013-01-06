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
          f.puts "  set_meta_id: one"
          f.puts "  sample_time: #{curr.strftime( "%Y-%m-%d %H:00:00" )}"
          f.puts "  generated_kilowatts: 1"
          f.puts "  temperature: 50"
          f.puts 
        end
      end
      # puts "Booo #{Dir.pwd}"
    end
  end
end
