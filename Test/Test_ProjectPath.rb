include Rokuby
include Rokuby::UnitTests
include Rokuby::DSL::Test

expectedWorkingDir = projPath(".")
expectedProjectFile = projPath("Test_ProjectPath.rb")

task :default => [:TestProjectPath]

desc "Execute some tests that check the ProjectPath class for errors"
task :TestProjectPath => [
                          :Test_InitAbsolutePath_EqualsWorkDirPlusArgument,
                          :Test_InitRelativePath_EqualsArgument,
                          :Test_InitBasePath_EqualsWorkDir,
                          :Test_InitObjectInputBaseRelative_EqualsInput,
                          :Test_InitEmptyLocalPath_EqualWorkingDir,
                          :Test_InitPointLocalPath_EqualWorkingDir,
                          
                          :Test_MixedSlashesPath_IsCorrected,
                          :Test_LocalPath_IsOmmitted,
                          :Test_ParentPath_IsOmmitted,
                          
                          :Test_WindowsDrivePath_IsAbsolute,
                          :Test_LinuxRootPath_IsAbsolute,
                          :Test_RelativePath_IsNotAbsolute,
                          :Test_AbsoluteConstructedPath_IsAbsolute,
                          
                          :Test_MakeRelative_WorksForPartOfPath,
                          :Test_MakeRelative_WorksForDifferentRelativePaths,
                          :Test_MakeRelative_WorksForPathsWithLocalPaths,
                          :Test_MakeRelative_WorksForPathsWithParentPaths,
                          :Test_MakeRelative_WorksForAbsoluteLinuxPath,
                          
                          :Test_RelativeDirectory_WorksForAbsoluteWindowsPath,
                          :Test_RelativeDirectory_WorksForAbsoluteLinuxPath,
                          
                          :Test_Join_AddsToPathes,
                          :Test_Join_OmmitsFileIfDetected
                          ] do |task|
                          
  taskTest task, :TestProjectPath, expectedWorkingDir, expectedProjectFile
end

task :Test_InitAbsolutePath_EqualsWorkDirPlusArgument do
  puts "Test_InitAbsolutePath_EqualsWorkDirPlusArgument"
  
  pp = ProjectPath.new("any_path")
  expected = Dir.pwd + "/any_path"
  TestEqual(pp.AbsolutePath(), expected)
end

task :Test_InitRelativePath_EqualsArgument do
  puts "Test_InitRelativePath_EqualsArgument"
  
  pp = ProjectPath.new("any_path")
  expected = "any_path"
  TestEqual(pp.RelativePath, expected)
end

task :Test_InitBasePath_EqualsWorkDir do
  puts "Test_BasePath_EqualsWorkDir"
  
  pp = ProjectPath.new("any_path")
  expected = Dir.pwd
  TestEqual(pp.BasePath, expected)
end

task :Test_InitObjectInputBaseRelative_EqualsInput do
  puts "Test_InitObjectInputBaseRelative_EqualsInput"
  
  basePath = "C:/some/arbitraty/path"
  relativePath = "some/more/arbitrary/path"
  pp = ProjectPath.new({base: basePath, relative: relativePath})
  expected = basePath + "/" + relativePath
  
  TestEqual(pp.AbsolutePath(), expected)
  TestEqual(pp.BasePath, basePath)
  TestEqual(pp.RelativePath, relativePath)
end

task :Test_InitEmptyLocalPath_EqualWorkingDir do
  puts "Test_InitEmptyLocalPath_EqualWorkingDir"
  
  expectedBase = Dir.pwd
  expectedRelative = ""
  expectedAbsolute = Dir.pwd
  
  pp = ProjectPath.new()  
  
  TestEqual(pp.AbsolutePath(), expectedAbsolute)
  TestEqual(pp.BasePath, expectedBase)
  TestEqual(pp.RelativePath, expectedRelative)                        
end

task :Test_InitPointLocalPath_EqualWorkingDir do
  puts "Test_InitPointLocalPath_EqualWorkingDir"
  
  expectedBase = Dir.pwd
  expectedRelative = ""
  expectedAbsolute = Dir.pwd
  
  pp = ProjectPath.new(".")  
  
  TestEqual(pp.AbsolutePath(), expectedAbsolute)
  TestEqual(pp.BasePath, expectedBase)
  TestEqual(pp.RelativePath, expectedRelative)                        
end

task :Test_MixedSlashesPath_IsCorrected do
  puts "Test_MixedSlashesPath_IsCorrected"
  
  basePath = "C:\\some/arbitraty\\path"
  relativePath = "some/more\\arbitrary/path"
  pp = ProjectPath.new({base: basePath, relative: relativePath})
  expected = "C:/some/arbitraty/path/some/more/arbitrary/path"
  
  TestEqual(pp.AbsolutePath(), expected)
end

task :Test_LocalPath_IsOmmitted do
  puts "Test_LocalPath_IsOmmitted"
  
  basePath = "./some/arbitraty/./path"
  relativePath = "./some/./more/arbitrary/path"
  pp = ProjectPath.new({base: basePath, relative: relativePath})
  expected = "some/arbitraty/path/some/more/arbitrary/path"
  
  TestEqual(pp.AbsolutePath(), expected)
end

task :Test_ParentPath_IsOmmitted do
  puts "Test_ParentPath_IsOmmitted"
  
  basePath = "some/arbitrary/parent/../path"
  relativePath = "some/parent/../more/arbitrary/path"
  pp = ProjectPath.new({base: basePath, relative: relativePath})
  expected = "some/arbitrary/path/some/more/arbitrary/path"
  
  TestEqual(pp.AbsolutePath(), expected)
end

task :Test_WindowsDrivePath_IsAbsolute do
  puts "Test_WindowsDrivePath_IsAbsolute"
  
  path = "C:\\some\\arbitrary\\path"
  pp = ProjectPath.new(path)
  
  TestEqual(pp.AbsolutePath(), "C:/some/arbitrary/path")
  TestTrue(pp.absolute?())
end

task :Test_LinuxRootPath_IsAbsolute do
  puts "Test_LinuxRootPath_IsAbsolute"
  
  path = "/some/arbitraty/parent/path"
  pp = ProjectPath.new(path)
  
  TestEqual(pp.AbsolutePath(), path)
  TestTrue(pp.absolute?())
end

task :Test_RelativePath_IsNotAbsolute do
  puts "Test_RelativePath_IsNotAbsolute"
  
  base = "some/arbitraty/parent/path"
  relative = "some/arbitraty/parent/path"
  pp = ProjectPath.new({base: base, relative: relative})
  
  TestFalse(pp.absolute?())
end

task :Test_AbsoluteConstructedPath_IsAbsolute do
  puts "Test_AbsoluteConstructedPath_IsAbsolute"
  
  base = "some/arbitraty/parent/path"
  relative = "some/arbitraty/parent/path"
  pp = ProjectPath.new({base: base, relative: relative, absolute: true})
  
  TestEqual(pp.AbsolutePath, base + "/" + relative)
  TestTrue(pp.absolute?())
end

task :Test_MakeRelative_WorksForPartOfPath do
  puts "Test_MakeRelative_WorksForPartOfPath"
  
  relativeTarget = "C:/some/arbitrary/path"
  path = "C:/some/arbitrary/path/relative/path"
  
  relativeTargetPath = ProjectPath.new(relativeTarget)
  pathPath = ProjectPath.new(path)
  
  relativatedPath = pathPath.MakeRelativeTo(relativeTargetPath)
    
  TestEqual(relativatedPath.AbsolutePath(), path)
  TestEqual(relativatedPath.AbsolutePath(), pathPath.AbsolutePath())
  TestEqual(relativatedPath.BasePath, "C:/some/arbitrary/path")
  TestEqual(relativatedPath.RelativePath, "relative/path")
  TestEqual(pathPath.RelativePath, path)
end

task :Test_MakeRelative_WorksForDifferentRelativePaths do
  puts "Test_MakeRelative_WorksForDifferentRelativePaths"
  
  relativeTarget = "C:/some/arbitrary/path/relative2/path2"
  path = "C:/some/arbitrary/path/relative/path"
  
  relativeTargetPath = ProjectPath.new(relativeTarget)
  pathPath = ProjectPath.new(path)
  
  relativatedPath = pathPath.MakeRelativeTo(relativeTargetPath)
    
  puts "Relativated path: #{relativatedPath.to_s}"
    
  TestEqual(relativatedPath.AbsolutePath(), path)
  TestEqual(relativatedPath.BasePath, "C:/some/arbitrary/path/relative2/path2")
  TestEqual(relativatedPath.RelativePath, "../../relative/path")
end

task :Test_MakeRelative_WorksForPathsWithLocalPaths do
  puts "Test_MakeRelative_WorksForPathsWithLocalPaths"
  
  relativeTarget = "C:/some/./arbitrary/path"
  cleanRelativeTarget = "C:/some/arbitrary/path"
  path = "C:/./some/arbitrary/./path/relative/./path"
  cleanPath = "C:/some/arbitrary/path/relative/path"
  
  relativeTargetPath = ProjectPath.new(relativeTarget)
  pathPath = ProjectPath.new(path)
  
  relativatedPath = pathPath.MakeRelativeTo(relativeTargetPath)
    
  TestEqual(relativatedPath.AbsolutePath(), cleanPath)
  TestEqual(relativatedPath.AbsolutePath(), pathPath.AbsolutePath())
  TestEqual(relativatedPath.BasePath, cleanRelativeTarget)
  TestEqual(relativatedPath.RelativePath, "relative/path")
  TestEqual(pathPath.RelativePath, cleanPath)
end

task :Test_MakeRelative_WorksForPathsWithParentPaths do
  puts "Test_MakeRelative_WorksForPathsWithParentPaths"
  
  relativeTarget = "C:/some/../arbitrary/path"
  clearRelativeTarget = "C:/arbitrary/path"
  path = "C:/some/arbitrary/../path/relative/../path"
  clearPath = "C:/some/path/path"
  
  relativeTargetPath = ProjectPath.new(relativeTarget)
  pathPath = ProjectPath.new(path)
  
  relativatedPath = pathPath.MakeRelativeTo(relativeTargetPath)
  
  puts "Relativated path: #{relativatedPath.to_s}"
  
  TestEqual(relativatedPath.AbsolutePath(), clearPath)
  TestEqual(relativatedPath.BasePath, clearRelativeTarget)
  TestEqual(relativatedPath.RelativePath, "../../some/path/path")
end

task :Test_MakeRelative_WorksForAbsoluteLinuxPath do
  puts "Test_MakeRelative_WorksForAbsoluteLinuxPath"
  
  relativeTarget = "/home/user/arbitrary/path"
  clearRelativeTarget = "/home/user/arbitrary/path"
  path = "/home/user/some/other/arbitrary/path"
  clearPath = "/home/user/some/other/arbitrary/path"
  
  relativeTargetPath = ProjectPath.new(relativeTarget)
  pathPath = ProjectPath.new(path)
  
  relativatedPath = pathPath.MakeRelativeTo(relativeTargetPath)
  
  puts "Relativated path: #{relativatedPath.to_s}"
  
  TestEqual(relativatedPath.AbsolutePath(), clearPath)
  TestEqual(relativatedPath.BasePath, clearRelativeTarget)
  TestEqual(relativatedPath.RelativePath, "../../some/other/arbitrary/path")
end

task :Test_RelativeDirectory_WorksForAbsoluteWindowsPath do
  puts "Test_RelativeDirectory_WorksForAbsoluteWindowsPath"
  
  path = "C:/arbitrary/path/to/some/place/file.txt"
  expectedDirectory = "C:/arbitrary/path/to/some/place"
  
  pathPath = ProjectPath.new(path)
  
  relativeDirectory = pathPath.RelativeDirectory()
  
  TestEqual(relativeDirectory, expectedDirectory)
end

task :Test_RelativeDirectory_WorksForAbsoluteLinuxPath do
  puts "Test_RelativeDirectory_WorksForAbsoluteLinuxPath"
  
  path = "/home/user/arbitrary/path/to/some/place/file.txt"
  expectedDirectory = "/home/user/arbitrary/path/to/some/place"
  
  pathPath = ProjectPath.new(path)
  
  relativeDirectory = pathPath.RelativeDirectory()
  
  TestEqual(relativeDirectory, expectedDirectory)
end

task :Test_Join_AddsToPathes do  
  puts "Test_Join_AddsToPathes"
  
  base1 = "some/arbitrary/path1"
  base2 = "some/other/arbitrary/path2"
  relative1 = "relative/path1"
  relative2 = "relative/path2"
  
  path1 = ProjectPath.new({base: base1, relative: relative1})
  path2 = ProjectPath.new({base: base2, relative: relative2})
  joinedPath = path1 + path2
  
  TestEqual(joinedPath.BasePath, base1)
  TestEqual(joinedPath.RelativePath, relative1 + "/" + relative2)
end

task :Test_Join_OmmitsFileIfDetected do                          
  puts "Test_Join_OmmitsFileIfDetected"
  puts "Would be unexpected behaviour"
  
  #base1 = "some/arbitrary/path1"
  #base2 = "some/other/arbitrary/path2"
  #relative1 = "relative/path1/file_should_not_be_used_in_join.txt"
  #relative1_no_file = "relative/path1"
  #relative2 = "relative/path2"
  
 # path1 = ProjectPath.new({base: base1, relative: relative1})
 # path2 = ProjectPath.new({base: base2, relative: relative2})
 # joinedPath = path1 + path2
  
 # TestEqual(joinedPath.BasePath, base1)
 # TestEqual(joinedPath.RelativePath, relative1_no_file + "/" + relative2)
end
