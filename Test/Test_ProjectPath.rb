require File.join(File.dirname(__FILE__), "unit_tests")
require File.join(File.dirname(__FILE__), "task_descriptor")

include Rokuby
include UnitTests

desc "Execute some tests that check the ProjectPath class for errors"
task :TestProjectPath => [
                          :Test_AbsolutePath_EqualsWorkDirPlusArgument,
                          :Test_RelativePath_EqualsArgument,
                          :Test_BasePath_EqualsWorkDir,
                          :Test_ObjectInputBaseRelative_EqualsInput,
                          
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
                          :Test_RelativeDirectory_WorksForAbsoluteLinuxPath
                          ] do |task|
  taskDescriptor task
end

task :Test_AbsolutePath_EqualsWorkDirPlusArgument do
  puts "Test_AbsolutePath_EqualsWorkDirPlusArgument"
  
  pp = ProjectPath.new("any_path")
  expected = Dir.pwd + "/any_path"
  TestEqual(pp.AbsolutePath(), expected)
end

task :Test_RelativePath_EqualsArgument do
  puts "Test_RelativePath_EqualsArgument"
  
  pp = ProjectPath.new("any_path")
  expected = "any_path"
  TestEqual(pp.RelativePath, expected)
end

task :Test_BasePath_EqualsWorkDir do
  puts "Test_BasePath_EqualsWorkDir"
  
  pp = ProjectPath.new("any_path")
  expected = Dir.pwd
  TestEqual(pp.BasePath, expected)
end

task :Test_ObjectInputBaseRelative_EqualsInput do
  puts "Test_ObjectInputBaseRelative_EqualsInput"
  
  basePath = "C:/some/arbitraty/path"
  relativePath = "some/more/arbitrary/path"
  pp = ProjectPath.new({base: basePath, relative: relativePath})
  expected = basePath + "/" + relativePath
  
  TestEqual(pp.AbsolutePath(), expected)
  TestEqual(pp.BasePath, basePath)
  TestEqual(pp.RelativePath, relativePath)
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
  
  puts "Test_RelativeDirectory_WorksForAbsoluteWindowsPath"
  
  path = "/home/user/arbitrary/path/to/some/place/file.txt"
  expectedDirectory = "/home/user/arbitrary/path/to/some/place"
  
  pathPath = ProjectPath.new(path)
  
  relativeDirectory = pathPath.RelativeDirectory()
  
  TestEqual(relativeDirectory, expectedDirectory)
end
