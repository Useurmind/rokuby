module RakeBuilder
  module Gpp
    module Configuration
      module TargetExt
        APPLICATION = ""
        SHARED_LIB = ".so"
        STATIC_LIB = ".a"
      end
    end
    
    module CommandLine
      module Options
        INCLUDE_DIRECTORY = "-I"
        DEFINE = "-D"
        LIB_NAME = "-l"
        LIB_DIRECTORY = "-L"
      end
    end
  end
end
