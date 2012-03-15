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
    inPats: [".*\.cpp$"],
    sPaths: [ProjPath("src")]
  }),
  inclSpec: FileSpec({
    inPats: [".*\.hpp$"],
    sPaths: [ProjPath("include")]
  })
}

FileSpec "TestProjectVsResource", :inPats => [".*\.rc$"],
                                  :sPaths => [ProjPath("resource")]

lib1Path = [ProjPath("libs/lib1")]

ProjConf "win32_debug", :plat =>  PLATFORM_WIN_X86_DEBUG
ProjConf "win32_release", :plat =>  PLATFORM_WIN_X86_RELEASE
ProjConf "x64_debug", :plat =>  PLATFORM_WIN_X64_DEBUG
ProjConf "x64_release", :plat =>  PLATFORM_WIN_X64_RELEASE

LibSpec "lib1_win32_debug", {
  name: "lib1",
  plat: PLATFORM_WIN_X86_DEBUG,
  loc: LibLoc({
    libSpec: FileSpec({ inPats: ["lib1_win32_debug.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPats: ["lib1_win32_debug.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_win32_release", {
  name: "lib1",
  plat: PLATFORM_WIN_X86_RELEASE,
  loc: LibLoc({
    libSpec: FileSpec({ inPats: ["lib1_win32_release.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPats: ["lib1_win32_release.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_x64_debug", {
  name: "lib1",
  plat: PLATFORM_WIN_X64_DEBUG,
  loc: LibLoc({
    libSpec: FileSpec({ inPats: ["lib1_x64_debug.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPats: ["lib1_x64_debug.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

LibSpec "lib1_x64_release", {
  name: "lib1",
  plat: PLATFORM_WIN_X64_RELEASE,
  loc: LibLoc({
    libSpec: FileSpec({ inPats: ["lib1_x64_release.lib"], sPaths: lib1Path  }),
    linkSpec: FileSpec({ inPats: ["lib1_x64_release.dll"], sPaths: lib1Path }),
    inclSpec: FileSpec({ inPats: [".*\.hpp$"], sPaths: lib1Path })
  })
}

ProjSpec "TestProject", {
  srcSpecs: [SrcSpec("TestProjectSource")],
  libSpecs: [LibSpec("lib1_win32_debug"), LibSpec("lib1_win32_release"), LibSpec("lib1_x64_debug"), LibSpec("lib1_x64_release")]
}

VsProjSpec "TestProject", :resSpec => FileSpec("TestProjectVsResource")

puts "resource file spec: #{[VsProjSpec("TestProject")]}"

VsProjConf "TestProject_X64_Release", :plat => PLATFORM_WIN_X64_RELEASE,
                                      :PlatformName => "Win32",
                                      :defines => ["X64"],
                                      :useDebugLibraries => false

VsProjConf "TestProject_X64_Debug", :plat => PLATFORM_WIN_X64_DEBUG,
                                    :PlatformName => "Win32",
                                    :defines => ["X64"],
                                    :useDebugLibraries => true

VsProjConf "TestProject_WIN32_Release", :plat => PLATFORM_WIN_X86_RELEASE,
                                        :PlatformName => "Win32",
                                        :defines => ["WIN32"],
                                        :useDebugLibraries => false

VsProjConf "TestProject_WIN32_Debug", :plat => PLATFORM_WIN_X86_DEBUG,
                                      :PlatformName => "Win32",
                                      :defines => ["WIN32"],
                                      :useDebugLibraries => true

generalInputs = [ProjDescr("TestProject"), ProjSpec("TestProject"), ProjConf("win32_debug"), ProjConf("win32_release"), ProjConf("x64_debug"), ProjConf("x64_release")]

vsInputs = [VsProjSpec("TestProject"), VsProjConf("TestProject_X64_Release"), VsProjConf("TestProject_X64_Debug"), VsProjConf("TestProject_WIN32_Release"), VsProjConf("TestProject_WIN32_Debug")]

#define the processing chain for the project

DefineProc RakeBuilder::ProjectFinder, "ProjectFinderProcessor"
DefineProc RakeBuilder::VsProjectBuilder, "VisualStudioProjectBuilder"

DefineChain RakeBuilder::ProcessChain, "SolutionChain"
Chain "SolutionChain", :in, "VisualStudioProjectBuilder", :out
Chain "SolutionChain", :in, "ProjectFinderProcessor", "VisualStudioProjectBuilder", :out

desc "Build the visual studio solution"
Chain "SolutionChain", :procIns => generalInputs + vsInputs do |task|
  puts "After executing #{task}"
  puts "Outputs are: #{task.Outputs}"
end
