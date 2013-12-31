require 'new_relic/agent/instrumentation/controller_instrumentation'
require 'new_relic/crepe/version'

module NewRelic
  module Agent
    module Instrumentation
      class Crepe
        include ControllerInstrumentation

        def initialize(app)
          @app = app
        end

        def call(env)
          @env = env
          @newrelic_request = ::Rack::Request.new(@env)

          trace_options = {
            :category => :sinatra,
            :request  => @newrelic_request,
            :params   => @newrelic_request.params
          }

          perform_action_with_newrelic_trace(trace_options) do
            @app_response = @app.call(@env)
            NewRelic::Agent.set_transaction_name(transaction_name)
            return @app_response
          end
        end

        def request_method
          @env['REQUEST_METHOD']
        end

        def request_path
          @env['REQUEST_PATH'].dup.tap do |path|
            @env['rack.routing_args'].except(:format, :version).each do |param, arg|
              path.sub!(arg, ":#{param}")
            end
          end
        end

        def request_format
          if format = @env['rack.routing_args'][:format]
            ".#{format}"
          end
        end

        def request_version
          if version = @env['rack.routing_args'][:version]
            "/#{version[:level]}" unless version[:with] == :path
          end
        end

        def transaction_name
          "#{request_method} #{request_version}#{request_path}#{request_format}"
        end
      end
    end
  end
end

DependencyDetection.defer do
  @name = :crepe

  depends_on do
    defined?(::Crepe) && !::NewRelic::Agent.config[:disable_crepe]
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Crepe instrumentation'
  end

  executes do
    ::Crepe::API.class_eval do
      class << self
        alias_method :old_inherited, :inherited

        def inherited(subclass)
          old_inherited(subclass)
          middleware = ::NewRelic::Agent::Instrumentation::Crepe

          used = subclass.ancestors.any? do |klass|
            next unless klass.ancestors.include?(Crepe::API)
            klass.config[:middleware].flatten.include? middleware
          end

          subclass.use(middleware) unless used
        end
      end
    end
  end
end

DependencyDetection.detect!