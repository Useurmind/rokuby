module RakeBuilder
  # Gathers all information to specify a certain platform.
  # See configuration_constants.rb for values that can be filled into this class.
  # [Name] The name for the configuration.
  # [Os] The operating system.
  # [Architecture] The cpu archtitecture.
  # [Type] Is this a debug or release type configuration.
  # [BinaryExtension] The extension that should be appended to the binary name.
  class PlatformConfiguration < InformationUnit
    attr_accessor :Name
    attr_accessor :Os
    attr_accessor :Architecture
    attr_accessor :Type
    
    def BinaryExtension=(value)
      @binaryExtension = value
    end
    
    def BinaryExtension()
      if(@binaryExtension)
        return @binaryExtension
      end
      
      return "#{@Os}_#{@Architecture}_#{@Type}"
    end
    
    
     # All the attributes stated above.
    # [name] The name for this configuration.
    # [os] The os this library is for.
    # [arch] The cpu architecture this library is for.
    # [type] The configuration this library is for.
    def initialize(paramBag)
      paramBag = paramBag || {}
      @Name = paramBag[:name] || ""
      @Os = paramBag[:os] || ""
      @Architecture = paramBag[:arch] || ""
      @Type = paramBag[:type] || ""
    end   
    
    def initialize_copy(original)
      @Name = Clone(original.Name)
      @Os = Clone(original.Os)
      @Architecture = Clone(original.Architecture)
      @Type = Clone(original.Type)
    end
    
    def ==(other)
      if(@Name == other.Name and
         @Os == other.Os and
         @Architecture = other.Architecture and
         @Type == other.Type)
        return true
      end
      return false
    end
  end
end
