module BeanVal
  class JsConfig
    def execute(site)
      # We need to manually setup the load paths
      patternfly_js = File.join(File.dirname(Patternfly.method('load!').source_location.first), '..', 'assets', 'javascripts')
      bootstrap_js = File.join(File.dirname(Bootstrap.method('load!').source_location.first), '..', 'assets', 'javascripts')
      $LOG.debug "Site info: #{site.output_dir}"
      copy_js_files(patternfly_js, File.join(site.output_dir, "javascripts"))
      copy_js_files(bootstrap_js, File.join(site.output_dir, "javascripts"))
    end

    def copy_js_files(source, target)
      if !Dir.exists?(target)
        $LOG.debug "Mkdir #{target}"
        Dir.mkdir(target)
      end
      $LOG.debug "Copying .js files from #{source} into #{target}"
      Dir.entries(source).select{|entry|
        File.extname(entry) == ".js"
      }.each{|entry|
        src = File.join(source, entry)
        dest = File.join(target, entry)
        $LOG.debug " copying #{src} to #{dest} "
        FileUtils.copy_file(src, dest)
      }
    end

  end
end
