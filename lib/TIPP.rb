class TIPP
    def initialize()
       
    end
    
    attr_accessor :id, :title, :pissn, :eissn, :svol, :siss, :edate, :evol, :eiss, :embargo, :coverage_depth, :coverage_notes, :publisher, :doi, :platform_host_name, :platform_host_url, :platform_admin_name, :platform_admin_url, :hybrid_oa, :access_start, :access_end


    def to_s
        
    end
    
    def rowTIPP
        r = [@title,@pissn,@eissn,@sdate,@svol,@siss,@edate,@evol,@eiss,@embargo,@coverage_depth,@coverage_notes,@publisher,@doi,@platform_host_name,@platform_host_url,@platform_admin_name,@platform_admin_url,@hybrid_oa,@access_start,@access_end]
    end
    
end