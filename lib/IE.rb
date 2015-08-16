class IE
    def initialize()
       
    end
    
    attr_accessor :id, :ti_id, :tipp_id, :sdate, :svol, :siss, :edate, :evol, :eiss, :embargo, :coverage_depth, :coverage_notes


    def to_s
        return @ti_id.to_s + "," + @tipp_id.to_s + "," + @sdate.to_s
    end
    
    def rowIE
        r = []
    end
    
end