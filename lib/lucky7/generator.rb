require 'basis'
require 'pathname'
require 'basis/installer'

module Lucky7
  class Generator
    TemplatePath = "#{Lucky7Root}/templates"
    SkeletonPath = "#{TemplatePath}/skeleton"
    EnvironmentPath = "#{TemplatePath}/environment"

    attr_reader :root

    def initialize path
      @root = Pathname.new path
    end

    def skeleton name
      install_to_path SkeletonPath, {:application => name}
    end

    def environment name
      install_to_path EnvironmentPath, {:environment => name}, "environment"
    end

    def install_to_path source, options=nil, target=""
      Basis::Installer.new(source, root+target).install(options)
    end
  end
end