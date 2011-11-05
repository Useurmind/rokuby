module RakeBuilder
    module XmlHelper
        def BuildAttributeString(hash)
            attributeStrings = []
            hash.each do |name, value|
                attributeStrings.push("#{name}=\"#{value}\"")
            end
            return attributeStrings.join(" ")
        end
    end
end
