module Rokuby
   # This processor processes VSProjectSpecifications to produce corresponding instances.
   class VsProjectFinder < Processor
      include FindFile
      
      def _InitProc
         @knownInputClasses.push(Rokuby::VsProjectInstance)
         @knownInputClasses.push(Rokuby::VsProjectSpecification)
      end
    
      def _ProcessInputs(taskArgs=nil)
         vsProjectInstance = VsProjectInstance.new()
         @inputs.each() do |input|
            if(input.is_a?(Rokuby::VsProjectSpecification))
               resFileSet = FindFile(input.ResourceFileSpec)
               idlFileSet = FindFile(input.IdlFileSpec)
               vsProjectInstance.ResourceFileSet = vsProjectInstance.ResourceFileSet + resFileSet
               vsProjectInstance.IdlFileSet = vsProjectInstance.IdlFileSet + idlFileSet
               #if(input.IdlFileSpec.IncludePatterns.length > 0)
               #   puts "Tried to find idl files:"
               #   puts "File spec: #{[input.IdlFileSpec]}"
               #   puts "File set: #{[idlFileSet]}"
               #end
            elsif(input.is_a?(Rokuby::VsProjectInstance))
               vsProjectInstance.ResourceFileSet = vsProjectInstance.ResourceFileSet + input.ResourceFileSet
               vsProjectInstance.IdlFileSet = vsProjectInstance.IdlFileSet + input.IdlFileSet
            end
         end
         
         #puts "searched: #{@inputs}"
         #puts "rsources found: #{[vsProjectInstance.ResourceFileSet]}"
         
         @outputs = [vsProjectInstance]
      end
   end
end
