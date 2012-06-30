require File.join(File.dirname(__FILE__), 'rake/version')

# :stopdoc:
RAKEVERSION = Rake::VERSION
# :startdoc:

require 'rbconfig'
require 'fileutils'
require 'singleton'
require 'monitor'
require 'optparse'
require 'ostruct'

module Rake
  module RequiredFiles

   FILES = [
     'ext/core',
'ext/module',
'ext/string',
'ext/time',

     'alt_system',
'win32',
     'cloneable',
     'pathmap',
'file_utils_ext',
'file_list',
'task_argument_error',
'rule_recursion_overflow_error',
     'invocation_exception_mixin',
'rake_module',
'pseudo_status',
'task_arguments',
'invocation_chain',
'task',
'file_task',
'file_creation_task',
'multi_task',
'dsl_definition',
'default_loader',
'early_time',
'name_space',
'task_manager',
'application',
   'clean'
    ]
  end
end
