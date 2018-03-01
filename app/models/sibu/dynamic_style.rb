module Sibu
  class DynamicStyle

    attr_reader :site, :body, :env, :filename, :scss_file

    def initialize(site_id)
      @site = Sibu::Site.find(site_id)
      @filename = "_variables"
      @scss_file = File.new(scss_file_path, 'w')
      vars_binding = OpenStruct.new(site: @site).instance_eval { binding }
      @body = ERB.new(File.read(template_file_path)).result(vars_binding)
      @env = Rails.application.assets
    end

    # Todo : la compilation semble marcher
    # Modifier le fichier cible scss pour que les variables soient directement renseignées (detente.scss.erb)
    # Tester la compilation SASS puis mettre en place upload du fichier compilé dans Sibu::Site si ça marche
    def compile
      find_or_create_scss

      begin
        scss_file.write generate_css
        scss_file.flush
        # site.update(style_url: File.join(site.site_template.path, "#{filename}.css"))
      ensure
        scss_file.close
        # File.delete(scss_file)
      end
    end

    private

    def template_file_path
      @template_file_path ||= File.join(Rails.root, 'app', 'assets', 'stylesheets', site.site_template.path, '_template.scss.erb')
    end

    def scss_tmpfile_path
      @scss_file_path ||= File.join(Rails.root, 'app', 'assets', 'stylesheets', site.site_template.path)
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