require "XML/XmlHelper"


module RakeBuilder

    class XmlTag
        include XmlHelper
        
        attr_accessor :Name
        attr_accessor :Attributes
        attr_accessor :Value
        attr_accessor :Children
        attr_accessor :IndentDepth
        
        # [name] The name for the tag.
        # [attributes] A hash representing the attributes for the tag.
        # [value] A string for the value of the tag.
        # [children] A list with XmlTags representing the children of the tag.
        def initialize(paramBag = {})
            @Name = (paramBag[:name] or "")
            @Attributes = (paramBag[:attributes] or {})
            @Value = paramBag[:value]
            @Children = (paramBag[:children] or [])
            @IndentDepth = 0
        end
        
        def ToXml
            attributeString = BuildAttributeString(@Attributes)
            indent = GetIndentationString()
            
            xml = "#{indent}<#{@Name}"
            
            if(attributeString != "")
                 xml += " #{attributeString}"
            end
            
            if(@Value != nil)
                xml += ">#{@Value}</#{@Name}>\n"
            elsif(@Children.length == 0)
                xml += "/>\n"
            else
                childrenStrings = []
                @Children.each do |child|
                    child.IndentDepth = @IndentDepth + 2
                    childrenStrings.push(child.ToXml())
                end
                childrenString = childrenStrings.join("")
                xml += ">\n#{childrenString}#{indent}</#{@Name}>\n"
            end
            
            return xml;
        end
        
        def GetIndentationString
            indent = ""
            for i in 0..@IndentDepth-1
                indent += " "
            end
            return indent
        end
    end
    
end