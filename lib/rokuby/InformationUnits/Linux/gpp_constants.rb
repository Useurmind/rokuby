module Rokuby
  module Gpp
    module Configuration
      module TargetExt
        APPLICATION = ""
        SHARED_LIB = ".so"
        STATIC_LIB = ".a"
      end

      module LinkOptions
        CREATE_DEBUG_INFORMATION = "-g"
      end

      module CompileOptions
        USE_CPP0X = "-std=c++0x"
        CREATE_DEBUG_INFORMATION = "-g"
        OPTIMIZE_LEVEL_0 = "-O0"
        OPTIMIZE_LEVEL_1 = "-O"
        OPTIMIZE_LEVEL_2 = "-O2"
        OPTIMIZE_LEVEL_3 = "-O3"
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
