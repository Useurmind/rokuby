module RakeBuilder
  # This class is responsible for managing information units that are needed for
  # for a project build.
  # [CurrentInformationUnit] The information unit that is currently being worked on.
  # [InformationUnits] The file specifications that were defined in this project manager.
  module InformationUnitManager
    
    attr_accessor :CurrentInformationUnit
    attr_accessor :InformationUnits
    attr_accessor :DefaultProjectConfigurations
    attr_accessor :DefaultVsProjectConfigurations
    
    def initialize
      super
      @CurrentInformationUnit = nil
      
      @InformationUnits = {}
    end
    
    # Get the specified information unit (create and insert it if needed).
    def GetInformationUnit(iuClass, name, copyUnit=nil)
      if(@InformationUnits[iuClass] == nil)
        @InformationUnits[iuClass] = {}
      end
      
      if(copyUnit != nil && @InformationUnits[iuClass][name] != nil)
        raise "Cannot copy #{copyUnit} into existing unit #{iuClass}:#{name}"
      end
      
      if(copyUnit != nil)
        @InformationUnits[iuClass][name] = Clone(copyUnit)
      elsif(@InformationUnits[iuClass][name] == nil)
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
      #_CheckCurrentInformationUnit()
      
      name, copyUnit, valueMap = _ParseArguments(iuClass, *args)
      
      returnIU = nil
      if(name) 
        returnIU = GetInformationUnit(iuClass, name, copyUnit)
      else
        if(copyUnit)
          returnIU = Clone(copyUnit)
        else
          returnIU = iuClass.new()
        end
        
      end
      
      #puts "value map for information unit is #{valueMap}"
      if(valueMap)
        returnIU.Extend(valueMap)
      end
      
      if(block_given?)
        block.call(returnIU)
      end
      
      return returnIU
    end
    
    def _CheckCurrentInformationUnit
      if(@CurrentInformationUnit != nil)
        raise "Trying to define information unit during definition of other information unit"
      end
    end
    
    def _ParseArguments(iuClass, *args)      
      name = nil
      copyUnit = nil
      valueMap = nil

      if(args.length < 1)
        return name, copyUnit, valueMap
      end
      
      for i in 0..args.length-1
        if(args[i].class == Hash) # first arg is valueMap
          valueMap = args[i]
        elsif(args[i].is_a?(iuClass))  # this is the information unit that should be copied
          copyUnit = args[i]
        elsif(!name) # first string arg is name
          name = args[i]
        else # last string arg is the information unit to copy
          copyName = args[i]
          copyUnit = GetInformationUnit(iuClass, copyName)
        end
      end
    
      return name, copyUnit, valueMap
    end
  end
end
