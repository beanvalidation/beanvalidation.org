require 'pathname'

module Awestruct
  module Extensions
    module Relative

      def relative(href, p = page)
        begin
          # Ignore absolute links
          if href.start_with?("http://") || href.start_with?("https://")
            result = href
          else
            output_path = p.output_path
            # for some reason, the href is sometimes passed as ./somefile
            # remove leading .
            output_path.gsub!(/^\.+/,'')
            result = Pathname.new(href).relative_path_from(Pathname.new(File.dirname(output_path))).to_s
          end
          result
        rescue Exception => e
          $LOG.error "#{e}" if $LOG.error?
          $LOG.error "#{e.backtrace.join("\n")}" if $LOG.error?
        end
      end

    end
  end
end

# vim: softtabstop=2 shiftwidth=2 expandtab
