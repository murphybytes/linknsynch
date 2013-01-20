module PQR

  class Calculator
    attr_reader :total_kw_generated, :total_kw_required_for_heating

    def initialize( opts = {}  )
      @total_kw_generated = 0
      @total_kw_required_for_heating = 0

      @samples = opts.fetch( :samples )
    end

    def run
      result = OpenStruct.new
      result.kw_generated = 0
      total_kw_generated = 0

      @samples.each do |sample|
        total_kw_generated += sample.generated_kilowatts
        result.kw_generated = sample.generated_kilowatts
      end

      @total_kw_generated = total_kw_generated
    end

  end

end
