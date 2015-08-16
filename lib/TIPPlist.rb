class TIPPlist
   def initialize
       @tipps = Array.new
   end
   
   def addTipp(aTIPP)
       @tipps.push(aTIPP)
       self
   end
   
   def to_s
        @tipps.each do |tipp|
            tipp.to_s
        end
    end
    
    def length
        @tipps.length
    end
    
    def tipps
        @tipps
    end
    
    def printTIPPlist
        list = ""
        @tipps.each do |tipp|
            list += tipp.printTIPP.to_s
        end
        return list
    end
end