module RakeBuilder
    class XmlDocument
        include XmlHelper
        
        attr_accessor :Attributes
        attr_accessor :RootChild
        
        def initialize(attributes={}, rootChild=nil)
            @Attributes = attributes
            @RootChild = rootChild
        end
        
        def ToXml
            attributeString = BuildAttributeString(@Attributes)
            
            xml = "<?xml #{attributeString}?>\n#{@RootChild.ToXml()}\n"
            
            return xml
        end
        
        def SaveToFile(filePath)
            file = File.open(filePath, 'w')
            file.write(ToXml())
        end
    end
end
