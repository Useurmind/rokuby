module RakeBuilder
  
  class Subproject
    
    attr_accessor :Name
    attr_accessor :Folder
    attr_accessor :BuildCommand
    
    def initialize(name=nil, folder=nil, buildCommand="rake")
      @Name = name
      @Folder = folder
      @BuildCommand = buildCommand
    end
    
  end
  
end