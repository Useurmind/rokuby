module Rokuby
  # Included into tasks to create more advanced descriptions for their arguments.
  module TaskDescription
    attr_accessor :TaskDescriptions
    attr_accessor :KnownArgNames
    attr_accessor :ArgDescriptions
    
    def ResetTaskDescription(ignoreUnknownArgs=true)
      @TaskDescriptions = []
      @KnownArgNames = []
      @ArgDescriptions = {}
      @ignoreUnknownArguments = ignoreUnknownArgs
    end
    
    def IsTaskDescriptionEmpty?
      return @TaskDescriptions.length == 0
    end
    
    # Add a text line as description for the task.
    def AddTaskDescriptions(description)
      if(description.is_a?(Array))
        @TaskDescriptions |= description
      else 
        @TaskDescriptions.push(description)
      end
    end
    
    # Add a text line as description for a specific argument of the task.
    def AddTaskArgumentDescriptions(argDescriptionMap)
      
      argDescriptionMap.each() do |argName, descriptions|
        argNameSym = argName.to_sym()
        
        # ignore unknown arguments
        if(@ignoreUnknownArguments && !@KnownArgNames.include?(argNameSym))
          next
        end
        
        #puts "Adding argument descriptions for arg #{argNameSym} : #{descriptions}"
        
        if(@ArgDescriptions[argNameSym] != nil)
          if(descriptions.is_a?(Array))
            @ArgDescriptions[argNameSym] |= (descriptions)
          else
            @ArgDescriptions[argNameSym].push(descriptions)
          end
        else
          if(descriptions.is_a?(Array))
            @ArgDescriptions[argNameSym] = descriptions
          else
            @ArgDescriptions[argNameSym] = [descriptions]
          end
        end
      end
      
      #puts "Arg descriptions are: #{@ArgDescriptions}"
    end
  end
end
