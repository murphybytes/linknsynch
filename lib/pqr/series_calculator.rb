require 'pqr/common'

module PQR

  class SeriesCalculator
    include PQR::Common
    
    def initialize( opts = {} )
      @samples = opts.fetch( :samples )
      @partition_count = opts.fetch( :partition_count, 10 )
      @home_profiles = opts.fetch( :home_profiles, nil )
    end



    #####################################################################################
    # Returns an array of pairs [[x,y] ... ] where x is a count, and y is the partition
    # index, suitable for use in duration chart
    #####################################################################################
    def get_generation_series
      result = []
      @samples.sort! { |x,y| x.generated_kilowatts <=> y.generated_kilowatts }
      max = @samples.last.generated_kilowatts
      min = @samples.first.generated_kilowatts
      counts = []
      counts.fill( 0, 0, @partition_count + 1 )

      @samples.each do |sample|
        normalized_value = (((sample.generated_kilowatts - min).to_f / ( max - min ).to_f) * @partition_count).to_i
        counts[normalized_value] += 1
      end

      ( 0 .. @partition_count ).each do |n|

        result << [counts[n], n  ]

      end

      result.sort! { |x,y| y.first <=> x.first }
      count = 0
      series = []
      result.each do |x|
        series << [ count, x.first ] if count > 0
        count += 1
      end
      series
    end

    def sum_kw_required_for_heating( profiles, sample )
      sum = BigDecimal.new( '0' )
      profiles.each do |profile|
        sum += get_kw_required_for_heating( profile, sample ) 
      end
      sum
    end

    def get_demand_series
      result = []
      kw_requireds = @samples.map do |sample| 
        sum_kw_required_for_heating( @home_profiles, sample ) 
      end
      kw_requireds.sort!

      max = kw_requireds.last
      min = kw_requireds.first
      counts = []
      counts.fill( 0, 0, @partition_count + 1 )

      kw_requireds.each do |kwr|
        normalized_value = (((kwr - min).to_f / ( max - min ).to_f) * @partition_count).to_i
        counts[normalized_value] += 1
      end

      ( 0 .. @partition_count ).each do |n|

        result << [counts[n], n  ]

      end

      result.sort! { |x,y| y.first <=> x.first }
      count = 0
      series = []
      result.each do |x|
        series << [count,x.first] if count > 0
        count +=1
      end
      series
    end

  end

end
