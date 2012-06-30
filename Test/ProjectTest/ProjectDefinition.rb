#########################################################################################################
# General Information Units

projDescr "TestProject", {
  name: "TestProject",
  version: "0.1",
  binaryName: "TestProjectBinary",
  binaryType: :Application,
  projPath: projPath("."),
  compPath: projPath("bin"),
  buildPath: projPath("build")
}

srcSpec "TestProjectSource", {
  srcSpec: fileSpec({
    inPats: [".*\.cpp$"],
    sPaths: [projPath("src")]
  }),
  inclSpec: fileSpec({
    inPats: [".*\.hpp$"],
    sPaths: [projPath("include")]
  })
}

fileSpec "TestProjectVsResource", :inPats => [".*\.rc$"],
                                  :sPaths => [projPath("resource")]

lib1Path = [projPath("libs/lib1")]

libSpec "lib1_win32_debug", {
  name: "lib1",
  plats: [PLATFORM_WIN_X86_DEBUG],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_win32_debug.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_win32_debug.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

libSpec "lib1_win32_release", {
  name: "lib1",
  plats: [PLATFORM_WIN_X86_RELEASE],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_win32_release.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_win32_release.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

libSpec "lib1_x64_debug", {
  name: "lib1",
  plats: [PLATFORM_WIN_X64_DEBUG],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_x64_debug.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_x64_debug.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

libSpec "lib1_x64_release", {
  name: "lib1",
  plats: [PLATFORM_WIN_X64_RELEASE],
  loc: libLoc({
    libSpec: fileSpec({ inPats: ["lib1_x64_release.lib"], sPaths: lib1Path  }),
    linkSpec: fileSpec({ inPats: ["lib1_x64_release.dll"], sPaths: lib1Path }),
    inclSpec: fileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

projSpec "TestProject", {
  srcSpecs: [srcSpec("TestProjectSource")],
  libSpecs: [libSpec("lib1_win32_debug"), libSpec("lib1_win32_release"), libSpec("lib1_x64_debug"), libSpec("lib1_x64_release")]
}

generalInputs = [projDescr("TestProject"), projSpec("TestProject")] + defaultProjectConfigurations()

####################################################################################################
# Visual Studio Information Units

vsProjSpec "TestProject", :resSpec => fileSpec("TestProjectVsResource")

vsSlnDescr "TestProject", :name => "TestSolution"

vsInputs = [vsProjSpec("TestProject"), ] + defaultVsProjectConfigurations()

####################################################################################################
# GPP Information Units

gppProjDescr "TestProject"

gppInputs = [gppProjDescr("TestProject")] + defaultGppProjectConfigurations()

####################################################################################################
# Visual Studio Process Chain

vsProjBuild "VisualStudioProjectBuilder", :ins => generalInputs + vsInputs
vsSlnBuild "VisualStudioSolutionBuilder", :ins => [vsSlnDescr("TestProject")]

chain "SolutionChain"
chain "SolutionChain", "VisualStudioProjectBuilder", "VisualStudioSolutionBuilder"

desc "Build VS Solution"
vsSlnBuild "VisualStudioSolutionBuilder"

####################################################################################################
# GPP Process Chain

desc "Build the proiject with GPP"
gppProjBuild "GppProjectBuilder", :ins => generalInputs + gppInputs
