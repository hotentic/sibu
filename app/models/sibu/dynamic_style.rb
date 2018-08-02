module Sibu
  class DynamicStyle

    attr_reader :site, :body, :env, :filename, :scss_file

    def initialize(site_id)
      @site = Sibu::Site.find(site_id)
      @filename = "#{site_id}_#{Time.current.to_i}"
      @scss_file = File.new(scss_file_path, 'w')
      @body = ERB.new(File.read(template_file_path)).result(binding)
      @env = Rails.application.assets
    end

    def compile
      find_or_create_scss

      begin
        scss_file.write generate_css
        scss_file.flush
        scss_file.close
        css_file_path = scss_file_path.gsub('scss', 'css')
        File.rename(scss_file_path, css_file_path)
        site.update(style: File.new(css_file_path))
      rescue Exception => ex
          Rails.logger.error(ex)
      ensure
        File.delete(scss_file_path) if scss_file_path && File.exist?(scss_file_path)
        File.delete(css_file_path) if css_file_path && File.exist?(css_file_path)
      end
    end

    def self.refresh_styles
      Sibu::Site.all.each do |s|
        Sibu::DynamicStyle.new(s.id).compile
      end
    end

    private

    def template_file_path
      @template_file_path ||= File.join(Rails.root, 'lib', 'assets', '_default_template.scss.erb')
    end

    def scss_tmpfile_path
      @scss_file_path ||= File.join(Rails.root, 'app', 'assets', 'stylesheets', 'templates')
      FileUtils.mkdir_p(@scss_file_path) unless File.exists?(@scss_file_path)
      @scss_file_path
    end

    def scss_file_path
      @scss_file_path ||= File.join(scss_tmpfile_path, "#{filename}.scss")
    end

    def find_or_create_scss
      File.open(scss_file_path, 'w') {|f| f.write(body)}
    end

    def generate_css
      Sass::Engine.new(asset_source, {
          syntax: :scss,
          cache: false,
          read_cache: false,
          style: :compressed
      }).render
    end

    def asset_source
      if env.find_asset(filename)
        env.find_asset(filename).source
      else
        uri = Sprockets::URIUtils.build_asset_uri(scss_file.path, type: "text/css")
        asset = Sprockets::UnloadedAsset.new(uri, env)
        env.load(asset.uri).source
      end
    end
  end
end