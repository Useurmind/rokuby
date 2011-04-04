module RakeBuilder
  
  class Subproject
    
    attr_accessor :Name
    attr_accessor :Folder
    attr_accessor :BuildCommand
    attr_accessor :CleanCommand
    
    def initialize(name=nil, folder=nil, buildCommand="rake", cleanCommand="rake clean")
      @Name = name
      @Folder = folder
      @BuildCommand = buildCommand
      @CleanCommand = cleanCommand
    end
    
  end
  
end