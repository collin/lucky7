require 'haml'
require 'sass'

module Lucky7
  module Builder
    SrcRegex=  /src/
    BuildDirectory= "build"
  
    class << self
      def haml_glob
        "#{Lucky7Root}/**/*.html.haml"
      end

      def sass_glob
        "#{Lucky7Root}/**/*.css.sass"
      end

      def jabs_glob
        "#{Lucky7Root}/**/*.js.jabs"
      end
      
      def spec_glob
        "#{Lucky7Root}/**/*.html.jass"
      end

      def files
        {:haml=>haml_glob, 
        :sass=>sass_glob,
        :jabs=>jabs_glob,
        :spec=>spec_glob}.inject({}) do |hash, pair|
          hash[pair.first]= Dir.glob(pair.last)
          hash
        end
      end
      
      def files_flattened
        files.map{|pair| pair.last}.flatten
      end

      def mtimes
        files_flattened.inject({}) do |hash, filename|
          hash[filename] = File.stat(filename).mtime
          hash
        end
      end

      def cache_mtimes!
        @cached_mtimes = mtimes
      end

      def cached_mtimes
        @cached_mtimes
      end

      def modified_files
        files.inject({}) do |hash, pair|
          hash[pair.first] = pair.last.select do |file|
            File.stat(file).mtime.to_i > cached_mtimes[file].to_i
          end
          hash
        end 
      end

      def build_continuously loop=true
        cache_mtimes!
        begin
          build
          sleep 1 if loop
        end while loop
      end
      
      def build
        m = modified_files

        build_sass m[:sass]
        build_haml m[:haml]
        build_jabs m[:jabs]
        build_spec m[:spec]
        pack
      end
  
      def haml_render_context
        Lucky7::Renders
      end
      
      def build_haml paths
        paths.each do |path|
          file= File.new build_path_for(:html, path), 'w'
          haml= File.read(path)
          en= Haml::Engine.new(haml)
          html= en.render haml_render_context
          file.write(html)
          file.close
        end
      end
      
      def build_sass paths
        paths.each do |path|
          file= File.new build_path_for(:css, path), 'w'
          sass= File.read(path)
          en= Sass::Engine.new(sass)
          css= en.render
          file.write(css)
          file.close
        end        
      end
      
      def build_spec paths
        paths.each do |path|
          file= File.new build_path_for('spec.html', path), 'w'
          jass= File.read(path)
          en= Jass::Engine.new(jass)
          js_spec= en.render
          file.write js_spec
          file.close 
        end
      end
      
      def build_jabs files
        
      end
      
      def pack
        
      end
      
      def ensure_build_path! path
        FileUtils.mkdir_p File.dirname(path)
      end
      
      def build_path_for extension, src_path
        path= File.dirname(src_path).gsub(SrcRegex, BuildDirectory)
        src_path= src_path.split('.').first
        path+= "/#{File.basename(src_path)}.#{extension}"
        ensure_build_path! path
        path
      end
    end
  end
end