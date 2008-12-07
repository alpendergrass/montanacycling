# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# Version 2.2.0 breaks file import.
RAILS_GEM_VERSION = '2.1.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :action_web_service ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/models/sweepers #{RAILS_ROOT}/app/models/competitions )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  config.action_controller.session = {
    :session_key => '_montanacycling_session',
    :secret      => '9998d23d32c59a8161aba78b03630a93'
  }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  #
  # Racing on Rails has many foreign key constraints, so :sql is required
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :bar_sweeper, :home_sweeper, :results_sweeper, :schedule_sweeper

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # alphere: 11/15/08 does not work currently: 
  # config.gem "spreadsheet"
  
  # Ugh. Make config accessible to overrides
  @config = config
  
  if File.exist?("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb")
    load("#{RAILS_ROOT}/local/config/environments/#{RAILS_ENV}.rb")
  end
  
  # See Rails::Configuration for more options
  if File.exists?("#{RAILS_ROOT}/local/config/database.yml")
    config.database_configuration_file = "#{RAILS_ROOT}/local/config/database.yml"
  end
end

# Local config customization
load("#{RAILS_ROOT}/local/config/environment.rb") if File.exist?("#{RAILS_ROOT}/local/config/environment.rb")

# Prefer local templates, partials etc. if they exist.  Otherwise, use the base
# application's generic files.
ActionController::Base.prepend_view_path(File.expand_path("#{RAILS_ROOT}/local/app/views"))

require "action_view/template_handlers/pdf_writer"
ActionView::Template.register_template_handler :pdf_writer, ActionView::TemplateHandlers::PDFWriter
PDF::Writer::FONT_PATH << "#{RAILS_ROOT}/app/views/fonts"
PDF::Writer::FONT_PATH << "#{RAILS_ROOT}/local/app/views/fonts"
PDF::Writer::FontMetrics::METRICS_PATH << "#{RAILS_ROOT}/app/views/fonts"
PDF::Writer::FontMetrics::METRICS_PATH << "#{RAILS_ROOT}/local/app/views/fonts"

require 'array'
require 'nil_class'
require 'string'

RACING_ON_RAILS_DEFAULT_LOGGER = RAILS_DEFAULT_LOGGER unless defined?(RACING_ON_RAILS_DEFAULT_LOGGER)

unless defined?(ASSOCIATION)
  ASSOCIATION = RacingAssociation.new
  ASSOCIATION.name = 'Montana Bicycle Racing Association'
  ASSOCIATION.short_name = 'MBRA'
  ASSOCIATION.state = 'MT'
  ASSOCIATION.rental_numbers = 51..99 if RAILS_ENV == 'test'
  
  SANCTIONING_ORGANIZATIONS = ["UCI", "USA Cycling"] unless defined?(SANCTIONING_ORGANIZATIONS)
  DEFAULT_SANCTIONING_ORGANIZATION = "USA Cycling" unless defined?(DEFAULT_SANCTIONING_ORGANIZATION)
end

RAILS_HOST = 'localhost:3000' unless defined?(RAILS_HOST)
STATIC_HOST = 'localhost' unless defined?(STATIC_HOST)
