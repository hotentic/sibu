# Sibu
Sibu is an engine to build websites. It focuses on :
- Maintaining a simple data model, so it can be exported & imported in many formats
- Increasing the productivity of web developers by using a Domain Specific Language for page edition
- Providing non-technical users with a simple and accessible site administration interface

## Usage
Sibu is currently implemented as a Ruby on Rails engine. Therefore its setup requires a host Ruby on Rails application, that can be created via :

`rails new my_app`

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'sibu'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install sibu
```

Once the installation is complete, make sure that you copy the database migrations to your application :
```bash
rake sibu:install:migrations
```

And finally run the migrations to update your database model :
```bash
rake db:migrate
```

## Configuration
Configuration is provided via the `sibu` key of the Rails application configuration. Typically, this would be done in a `sibu.rb` file in the `config/initializers` folder of your Rails application.
The example below lists the configuration options available :
```ruby
Rails.application.config.sibu = {

  # Title metatag of the admin interface
  title: 'My website administration',

  # Stylesheet to use to style the admin interface
  stylesheet: 'my_user_css',

  # Javascript to include in the admin interface
  javascript: 'my_user_js',

  # Path to the admin interface header partial
  top_panel: 'shared/user/top_panel',

  # Path to the main content edition partial - must include a yield to delegate content display to the Sibu engine
  content_panel: 'shared/user/content_panel',

  # Path to the admin interface footer partial
  bottom_panel: 'shared/user/bottom_panel',

  # Name of the method that will be used to authenticate admin users - this method must be available to Sibu controllers
  auth_filter: :authenticate_user!,

  # Name of the method that will retrieve the current user - this method must be available to Sibu controllers
  current_user: 'current_user',

  # A flag to indicate that the Sibu instance should offer a separate environment for each user
  multi_user: true,

  # A proc to identify super-admin users in a multi-users setup (optional)
  admin_filter: Proc.new {|usr| usr.is_admin},

  # When active, users will be able to override the colors and fonts of the sites templates (optional)
  custom_styles: true,

  # Lists of colors and fonts available for sites templates customization - Only used when custom_styles is set to true (optional)
  primary_colors: ['#23527c', '#00B1BF', '#BECD00'],
  secondary_colors: ['#E2007A', '#aaaaa1', '#be6432'],
  primary_fonts: ['Intro', 'Lato', 'SourceSansPro'],
  secondary_fonts: ['Aleo', 'Bodoni', 'Cinzel'],

  # The domain name that will host the admin interface (should be different from the website domain name)
  host: 'localhost',

  # A partial for 404 error pages
  not_found: 'shared/templates/not_found',

  # Dimensions of the images to use in the website - Uploaded images will be automatically resized in the provided formats
  images: {large: 1600, medium: 800, small: 320},

  # Versions available for the created websites
  versions: [['Français', 'fr'], ['Anglais', 'en']],

  # A proc to override the default ordering of the sections when editing content (optional)
  sections_ordering: Proc.new {|sections| sections.sort_by {|s| SECTIONS_TABS.index(s['category'])}}
}
```


## Improvements
  - Use a specific controller & helper for site display
  - Move page templates to SiteTemplate model

## Dependencies & inspiration
jQuery (for now)
Shrine
https://github.com/BLauris/custom-css-for-user (dynamic custom styles)

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
