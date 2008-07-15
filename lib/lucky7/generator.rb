require 'basis'
require 'pathname'
require 'basis/installer'

module Lucky7
  class Generator
    TemplatePath =    Lucky7Root   + "templates"
    SkeletonPath =    TemplatePath + "skeleton"
    EnvironmentPath = TemplatePath + "environment"
    JavascriptSpecPath = TemplatePath + "javascript_spec"
    RubySpecPath       = TemplatePath + "ruby_spec"

    FlagName = ".lucky7"

    attr_reader :root

    def initialize path
      @root = Pathname.new path
    end

    def skeleton name
      install_to_path SkeletonPath, {:application => name}
      flag_skeleton name
    end

    def flag_skeleton name
      FileUtils.touch(root + name + FlagName)
    end

    def flagged_dir path
      dir = Pathname.glob(root + '**' + FlagName).first
      dir.nil? ? "" : dir.dirname + path
    end

    def environment name
      install_to_path EnvironmentPath, {:environment => name}, "environment"
    end

    def ruby_spec mod, name
      install_to_path RubySpecPath, {:spec => name}, "spec/ruby/#{mod}"
    end

    def javascript_spec mod, name
      install_to_path JavascriptSpecPath, {:spec => name}, "spec/javascript/jass/#{mod}"
    end

    def install_to_path source, options=nil, target=""
      Basis::Installer.new(source, root+flagged_dir(target)).install(options)
# p "TARGET: #{root+target}"
    end
  end
end