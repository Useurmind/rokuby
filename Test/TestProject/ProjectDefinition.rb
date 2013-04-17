#########################################################################################################
# General Information Units
#########################################################################################################

# This is a ProjectDescription stating meta information about the project.
projDescr "TestProject", {
  # The human readable name of the project.
  name: "TestProject",
  # A human readable version of the project.
  version: "0.1",
  # The name which will make up a part of the resulting binary.
  binaryName: "TestProjectBinary",
  # The type of binary that should be build, either :Application, :Shared, or :Static
  binaryType: :Application,
  # This is the path into which the meta files of this project will be put (e.g. IDE files)
  projPath: projPath("."),
  # This is the path where the the intermediate results of the build will be put.
  compPath: projPath("intermediate"),
  # This is the path where the final results of the build will be put.
  buildPath: projPath("bin")
}

# Source Code Specification
###########################

# Here we state the specification for the source code that should go into the project.
# Currently, the source is made up of three source '.cpp' files under 'src' and two header '.hpp' files
# under 'include'. One of them is in a subpath to see that recursive inclusion works.
srcSpec "TestProjectSource", {
  # A file specification for the set of source files.
  srcSpec: fileSpec({
    inPats: [".*\.cpp$"],
    sPaths: [projPath("src")]
  }),
  # A file specification for the set of header files.
  inclSpec: fileSpec({
    inPats: [".*\.hpp$"],
    sPaths: [projPath("include")]
  })
}

# Windows Library Specification
##############################

# This is the path where the binaries of lib1 are located.
lib1Path = [projPath("libs/lib1")]

# In this part we create library specifications for different binaries of the library.
# Each binary can be assigned to a certain platform environment.

# This is the binary that is used on 32 bit windows platforms for debug builds.
libSpec "lib1_win32_debug", {
  # The name of the lib whose binary is contained in this specification.
  # Used to match different specifications to one library.
  name: "lib1",
  # The platform for which this library should be used.
  plats: [PLATFORM_WIN_X86_DEBUG],
  # The specification for the location of the libary files.
  loc: libLoc({
    # The specification for the file to which should be linked in the build.
    libSpec: fileSpec({ inPats: ["lib1_win32_debug.lib"], sPaths: lib1Path  }),
    # The specification for the file that is used during execution.
    linkSpec: fileSpec({ inPats: ["lib1_win32_debug.dll"], sPaths: lib1Path }),
    # The specification for the header files of the library that are required during compilation.
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

# This is the binary that is used on 32 bit windows platforms for release builds.
libSpec "lib1_win32_release", {
  name: "lib1",
  plats: [PLATFORM_WIN_X86_RELEASE],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_win32_release.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_win32_release.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

# This is the binary that is used on 64 bit windows platforms for debug builds.
libSpec "lib1_x64_debug", {
  name: "lib1",
  plats: [PLATFORM_WIN_X64_DEBUG],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_x64_debug.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_x64_debug.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

# This is the binary that is used on 64 bit windows platforms for release builds.
libSpec "lib1_x64_release", {
  name: "lib1",
  plats: [PLATFORM_WIN_X64_RELEASE],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_x64_release.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_x64_release.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

# Project Specification
#######################

# Here we put together all the file specifications into one project specification.
projSpec "TestProject", {
  # The source code that we specified above.
  srcSpecs: [srcSpec("TestProjectSource")],
  # The libraries that we specified above.
  libSpecs: [libSpec("lib1_win32_debug"), libSpec("lib1_win32_release"), libSpec("lib1_x64_debug"), libSpec("lib1_x64_release")]
}

# All information units that are used for all project builds.
generalInputs = [projDescr("TestProject"), projSpec("TestProject")] + defaultProjectConfigurations()

####################################################################################################
# Visual Studio Information Units
####################################################################################################

# This information unit is a specification for the resource file which lies in 'resource' and is required
# for the windows build.
fileSpec "TestProjectVsResource", :inPats => [".*\.rc$"],
                                  :sPaths => [projPath("resources")]

# The specification for the part of the project which is only required for Visual Studio.
# It includes the resource files specification which is only used under windows.
vsProjSpec "TestProject", :resSpec => fileSpec("TestProjectVsResource")

# This is the specification for the solution that should be build.
# Just stating the name at the moment.
vsSlnDescr "TestProject", :name => "TestSolution"

# All the inputs that are required for the build of the Visual Studio project.
vsInputs = generalInputs + [vsProjSpec("TestProject")] + defaultVsProjectConfigurations()

####################################################################################################
# GPP Information Units
####################################################################################################

# A description with meta information for the GPP project build.
gppProjDescr "TestProject"

# The inputs for the GPP project build
gppInputs = generalInputs + [gppProjDescr("TestProject")] + defaultGppProjectConfigurations()

####################################################################################################
# Visual Studio Process Chain
####################################################################################################

# Create a VsProjectBuilder which will create the Visual Studio project.
# It receives the inputs that belong to this project.
vsProjBuild "VisualStudioProjectBuilder", :ins => vsInputs

# Create a VsSolutionBuilder that will create the Visual Studio solution which will contain the test project.
# It receives the solution description.
vsSlnBuild "VisualStudioSolutionBuilder", :ins => [vsSlnDescr("TestProject")]

# Create a chain for the Visual studio solution.
chain "SolutionChain"
# The VsProjectBuilder will input its output to the VsSolutionBuilder.
# This is because the project should be part of the solution.
chain "SolutionChain", "VisualStudioProjectBuilder", "VisualStudioSolutionBuilder"

# To build the solution execute the VsSolutionBuilder (which is a task and can be treated equally).
desc "Build VS Solution"
vsSlnBuild "VisualStudioSolutionBuilder"

####################################################################################################
# GPP Process Chain
####################################################################################################

# Create a GppProjectBuilder that will offer tasks to create the different configurations of the project.
# This task won't actually compile the project with GPP, it only creates a project instance that can be used by other processors.
gppProjBuild "GppProjectBuilder", :ins => gppInputs
