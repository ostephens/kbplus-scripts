class KbPackage
    def initialize()
    	@tipps = Array.new()
    end
    attr_accessor :name, :id, :provider, :consortium, :sdate, :edate, :pidentifier, :tipps

    def printTIPPs
    	tipps.each do |tipp|
    		puts tipps.to_s
    	end
    end

    def idlessTIPPcount
    	i=0
    	tipps.each do |tipp|
    		if (!tipp.id)
    			i+=1
    		end
    	end
    	return i
    end

    def kbplusimpCSV(file_name)
    	CSV.open(file_name, 'w') do |csv_write|
	    	csv_write << ["Provider",@provider]
	        csv_write << ["Package Identifier",@pidentifier]
	        csv_write << ["Package Name",@name]
	        csv_write << ["Agreement Term Start Year",@sdate]
	        csv_write << ["Agreement Term End Year",@edate]
	        csv_write << ["Consortium",""]
	        csv_write << ["publication_title","ID.issn","ID.eissn","date_first_issue_online","num_first_vol_online","num_first_issue_online","date_last_issue_online","num_last_vol_online","num_last_issue_online","embargo_info","coverage_depth","coverage_notes","publisher_name","ID.doi","platform.host.name","platform.host.url","platform.administrative.name","platform.administrative.url","hybrid_oa","access_start_date","access_end_date"]
	        @tipps.each do |tipp|
	        	if (!tipp.id)
		            csv_write << tipp.rowTIPP
		        end
	        end
	    end
    end
end