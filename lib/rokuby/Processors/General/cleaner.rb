module Rokuby
  # Basic processor that can be used to clean projects.
  # There are more elaborate cleaners for each kind of project type.
  class Cleaner < Processor
    include ProcessorUtility
    
    def initialize
      clean => [@BackTask.to_s]
    end
    
    def 
    end
  end
end
