module ApplicationHelper
  KW_TO_MW=BigDecimal.new( '1000.0' )

  def kwh2mwh( kw ) 
    (kw / KW_TO_MW).round
  end
end
