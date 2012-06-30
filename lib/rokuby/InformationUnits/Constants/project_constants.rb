module Rokuby
  BINARY_TYPES = [
    :Application,  # an executable application
    :Shared,      # a shared dynamically linked library
    :Static       # a statically linked library
  ]
  
  PROJECT_SUBDIR = "projects"
  COMPILE_SUBDIR = "bin"
  BUILD_SUBDIR = "build"
end
