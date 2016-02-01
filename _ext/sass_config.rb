module BeanVal
  class SassConfig
    def execute(site)
      # We need to manually setup the load paths for sassc for patternfly and also bootstrap
      patternfly_base = File.join(File.dirname(Patternfly.method('load!').source_location.first), '..', 'assets')
      bootstrap_base = File.join(File.dirname(Bootstrap.method('load!').source_location.first), '..', 'assets')
      font_awesome_base = File.join(File.dirname(FontAwesome::Sass.method('load!').source_location.first), '..', 'assets')
      site.send('scsssassc=', {:load_paths => [File.join(patternfly_base, 'stylesheets'),
                                               File.join(patternfly_base, 'fonts'),
                                               File.join(patternfly_base, 'javascripts'),
                                               File.join(patternfly_base, 'images'),
                                               File.join(bootstrap_base, 'stylesheets'),
                                               File.join(bootstrap_base, 'fonts'),
                                               File.join(bootstrap_base, 'javascripts'),
                                               File.join(bootstrap_base, 'images'),
                                               File.join(font_awesome_base, 'fonts'),
                                               File.join(font_awesome_base, 'stylesheets')
                                              ]})
    end
  end
end
