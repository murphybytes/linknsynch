module PQR

  class Calculator
    attr_reader :total_kw_generated

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @samples = opts.fetch( :samples )
    end

    def run
      @samples.each do |sample|
        @total_kw_generated += sample.generated_kilowatts
      end
    end

  end

end
