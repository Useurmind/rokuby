module RakeBuilder
  # This class is responsible for managing information units that are needed for
  # for a project build.
  # [CurrentInformationUnit] The information unit that is currently being worked on.
  # [InformationUnits] The file specifications that were defined in this project manager.
  module InformationUnitManager
    
    attr_accessor :CurrentInformationUnit
    attr_accessor :InformationUnits
    
    def initialize
      super
      @CurrentInformationUnit = nil
      
      @InformationUnits = {}
    end
    
    # Get the specified information unit (create and insert it if needed).
    def GetInformationUnit(iuClass, name)
      if(@InformationUnits[iuClass] == nil)
        @InformationUnits[iuClass] = {}
      end
      
      if(@InformationUnits[iuClass][name] == nil)
        @InformationUnits[iuClass][name] = iuClass.new({})
      end
      
      return @InformationUnits[iuClass][name]
    end
    
    # You can input several combinations of values as arguments here.
    # [name] The name/id of the information unit, can be anything except a hash.
    # [valueMap] A hash that is used to extend the values of the unit.
    #
    # name, valueMap : A class object is created(or taken from the registered units)
    #                  with the given name and valueMap and entered into the registered
    #                  informations units.
    # name : A class object is created with the given name and entered into the
    #        registered information units.
    # valueMap : A class object is created with the given valueMap but is NOT
    #            entered into the registered information units.
    def DefineInformationUnit(iuClass, *args, &block)
      _CheckCurrentInformationUnit()
      
      name, valueMap = _ParseArguments(args)
      
      returnIU = nil
      if(name) 
        @CurrentInformationUnit = GetInformationUnit(iuClass, name)
        
        if(valueMap)
          @CurrentInformationUnit.Extend(valueMap)
        end
        
        if(block_given?)
          block.call()
        end
      
        returnIU = @CurrentInformationUnit  
        @CurrentInformationUnit = nil
      else
        returnIU = iuClass.new(valueMap || {})
      end
      return returnIU
    end
    
    def _CheckCurrentInformationUnit
      if(@CurrentInformationUnit != nil)
        raise "Trying to define information unit during definition of other information unit"
      end
    end
    
    def _ParseArguments(*args)      
      name = nil
      valueMap = nil
      
      if(args.length < 1)
        return name, valueMap
      end
      
      if(args.length >= 1)
        firstArgClass = args[0].class
        if(firstArgClass == Hash) # first arg is valueMap
          valueMap = args[0]
        else # first arg is name
          name = args[0]
        end
      end
            
      if(args.length >= 2)
        secArgClass = args[1].class
        if(valueMap == nil && secArgClass) # second argument is valueMap
          valueMap = args[1]
        end
      end
    
      return name, valueMap
    end
  end
end
