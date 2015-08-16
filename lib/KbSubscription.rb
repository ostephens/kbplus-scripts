class KbSubscription
    def initialize()
    	@ies = Array.new()
        @packages = Array.new()
    end
    attr_accessor :name, :id, :sdate, :edate, :sidentifier, :ies, :packages, :url

    def printIEs
    	ies.each do |ie|
    		puts ie.to_s
    	end
    end

    def printPackages
        packages.each do |p|
            puts p.to_s
        end
    end

    def addPackage(packageid)
        @packages.push(packageid)
        @packages.uniq!
    end

end