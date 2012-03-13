# define the contents of the project
ProjDescr "TestProject", {
  name: "TestProject",
  version: "0.1",
  binaryName: "TestProjectBinary",
  binaryType: :Application,
  projPath: ProjPath("."),
  compPath: ProjPath("bin"),
  buildPath: ProjPath("build")
}

SrcSpec "TestProjectSource", {
  srcSpec: FileSpec({
    inPaths: [".*\.cpp$"],
    sPaths: [ProjPath("src")]
  }),
  inclSpec: FileSpec({
    inPaths: [".*\.hpp$"],
    sPaths: [ProjPath("include")]
  })
}

lib1Path = ProjPath("libs/lib1")

LibSpec "lib1_win32_debug", {
  name: "lib1_win32_debug",
  plat: PLATFORM_WIN_X86_DEBUG,
  loc: LibLoc({
    libSpec: FileSpec({ inPaths: ["lib1_win32_debug.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPaths: ["lib1_win32_debug.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPaths: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_win32_release", {
  name: "lib1_win32_release",
  plat: PLATFORM_WIN_X86_RELEASE,
  loc: LibLoc({
    libSpec: FileSpec({ inPaths: ["lib1_win32_release.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPaths: ["lib1_win32_release.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPaths: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_x64_debug", {
  name: "lib1_x64_debug",
  plat: PLATFORM_WIN_X64_DEBUG,
  loc: LibLoc({
    libSpec: FileSpec({ inPaths: ["lib1_x64_debug.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPaths: ["lib1_x64_debug.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPaths: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_x64_release", {
  name: "lib1_x64_release",
  plat: PLATFORM_WIN_X64_RELEASE,
  loc: LibLoc({
    libSpec: FileSpec({ inPaths: ["lib1_x64_release.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPaths: ["lib1_x64_release.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPaths: [".*\.hpp$"], sPaths: lib1Path })
  })
}

ProjSpec "TestProject", {
  srcSpecs: [SrcSpec("TestProjectSource")],
  libSpecs: [LibSpec("lib1_win32_debug"), LibSpec("lib1_win32_release"), LibSpec("lib1_x64_debug"), LibSpec("lib1_x64_release")]
}


#define the processing chain for the project

proc = Processor RakeBuilder::ProjectFinder
proc.AddInput( ProjSpec("TestProject") )

task :default do
  proc.Process()
  
  puts proc.Outputs
end
