module Rokuby
  # Gathers all information to specify a certain platform.
  # See configuration_constants.rb for values that can be filled into this class.
  # [Name] The name for the configuration.
  # [Os] The operating system.
  # [Architecture] The cpu archtitecture.
  # [Type] A shortcut that is appended to the binary extension (if it is not set).
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
      
      parts = []
      if(@Os)
        parts.push @Os
      end
      if(@Architecture)
        parts.push @Architecture
      end
      if(@Type)
        parts.push @Type
      end
      
      return parts.join("_")
    end   
    
     # All the attributes stated above.
    # [name] The name for this configuration.
    # [os] The os this library is for.
    # [arch] The cpu architecture this library is for.
    # [type] The configuration this library is for.
    def initialize(valueMap=nil)
      super(valueMap)
      @Name = nil
      @Os = nil
      @Architecture = nil
      @Type = nil
      @binaryExtension = nil
      Extend(valueMap, false)
    end   
    
    def initialize_copy(original)
      super(original)
      @Name = Clone(original.Name)
      @Os = Clone(original.Os)
      @Architecture = Clone(original.Architecture)
      @Type = Clone(original.Type)
    end
    
    # All set values in the first spec are equal to the value in the second spec.
    def <=(other)
      if(other.class != PlatformConfiguration)
        return false
      end
      
      if(#(@Name == nil || @Name == other.Name) and # name can be anything
         (@Os == nil || @Os == other.Os) and
         (@Architecture ==  nil || @Architecture == other.Architecture) and
         (@Type == nil || @Type == other.Type))
        #puts "Testing <= in platform configuration #{[self]} <= #{[other]} ... true"
        return true
      end
      #puts "Testing <= in platform configuration #{[self]} <= #{[other]} ... false"
      return false
    end
    
    def ==(other)
      if(other.class != PlatformConfiguration)
        return false
      end
      
      if(@Name == other.Name and
         @Os == other.Os and
         @Architecture == other.Architecture and
         @Type == other.Type)
        return true
      end
      return false
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      name = valueMap[:Name] || valueMap[:name]
      if(name)
        @Name = name
      end
      
      os = valueMap[:Os] || valueMap[:os]
      if(os)
        @Os = os
      end
      
      architecture = valueMap[:Architecture] || valueMap[:arch]
      if(architecture)
        @Architecture = architecture
      end
      
      type = valueMap[:Type] || valueMap[:type]
      if(type)
        @Type = type
      end
    end
  end
end
