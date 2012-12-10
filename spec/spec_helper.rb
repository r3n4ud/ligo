gem 'rspec', '~> 2.4'
require 'rspec'
require 'ligo'

include Ligo
Ligo::Logging.configure_logger_output('/tmp/ligo-spec.log')
