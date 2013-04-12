module Rokuby
  module Vs
    module Configuration
      module Platform
        WIN32 = "Win32"
        X64 = "x64"
      end
      
      module ConfigurationType
        APPLICATION = "Application"
        SHARED = "DynamicLibrary"
        STATIC = "StaticLibrary"
      end
      
      module TargetExt
        APPLICATION = ".exe"
        SHARED = ".dll"
        STATIC = ".lib"
      end
      
      module ClrSupport
        FALSE = 'false'
        TRUE = 'true'
        OLD_SYNTAX = 'OldSyntax'
        PURE = 'Pure'
        SAFE = 'Safe'
      end
      
      module CharacterSet
        MULTI_BYTE = 'MultiByte'
        UNICODE = 'Unicode'
        NOT_SET = 'NotSet'
      end
      
      module WarningLevel
        LEVEL3 = "Level3"
      end
      
      module Optimization
        DISABLED = "disabled"
        MAX_SPEED = "MaxSpeed"
      end
      
      module AssemblerOutput
        NO_LISTING = "NoListing"
        ASSEMBLY_AND_SOURCE_CODE = "AssemblyAndSourceCode"
      end
      
      module RuntimeLibrary
        MULTITHREADED = 'MultiThreaded'
        MULTITHREADED_DLL = 'MultiThreadedDll'
        MULTITHREADED_DEBUG = 'MultiThreadedDebug'
        MULTITHREADED_DEBUG_DLL = 'MultiThreadedDebugDll'
      end
      
      module ExceptionHandling
        SYNC = "Sync"
        ASYNC = "Async"
        SYNCCTHROW = "SyncCThrow"
        FALSE = "false"
      end
      
      module DebugInformationFormat
        OLD_STYLE = "OldStyle"
        PROGRAM_DATABASE = "ProgramDatabase"
        EDIT_AND_CONTINUE = "EditAndContinue"
      end
      
      module InlineFunctionExpansion
        ANY_SUITABLE = "AnySuitable"
        DISABLED = "Disabled"
        DEFAULT = "Default"
      end
      
      # visual studio variables
      module Variables
        PROJECT_NAME = "$(ProjectName)"
        SOLUTION_DIR = "$(SolutionDir)"
        PROJECT_DIR = "$(ProjectDir)"
        INTERMEDIATE_DIR = "$(IntDir)"
        OUTPUT_DIR = "$(OutDir)"
        CONFIGURATION_NAME = "$(Configuration)"        
      end
    end
  end
end
