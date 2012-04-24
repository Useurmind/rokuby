module RakeBuilder
   # This processor processes VSProjectSpecifications to produce corresponding instances.
   class VsProjectFinder < Processor
      include FindFile
      
      def _InitProc
         @knownInputClasses.push(RakeBuilder::VsProjectInstance)
         @knownInputClasses.push(RakeBuilder::VsProjectSpecification)
      end
    
      def _ProcessInputs(taskArgs=nil)
         vsProjectInstance = VsProjectInstance.new()
         @inputs.each() do |input|
            if(input.is_a?(RakeBuilder::VsProjectSpecification))
               resFileSet = FindFile(input.ResourceFileSpec)
               idlFileSet = FindFile(input.IdlFileSpec)
               vsProjectInstance.ResourceFileSet = vsProjectInstance.ResourceFileSet + resFileSet
               vsProjectInstance.IdlFileSet = vsProjectInstance.IdlFileSet + idlFileSet
               #if(input.IdlFileSpec.IncludePatterns.length > 0)
               #   puts "Tried to find idl files:"
               #   puts "File spec: #{[input.IdlFileSpec]}"
               #   puts "File set: #{[idlFileSet]}"
               #end
            elsif(input.is_a?(RakeBuilder::VsProjectInstance))
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
