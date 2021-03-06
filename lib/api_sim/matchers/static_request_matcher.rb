require 'api_sim/recorded_request'
require 'api_sim/matchers/base_matcher'

module ApiSim
  module Matchers
    class StaticRequestMatcher < BaseMatcher
      attr_reader :http_method, :route, :headers, :response_code, :matcher, :response_body, :default, :schema

      def initialize(http_method:, route:, response_code: 200, response_body: '', headers: {}, default: false, matcher: ALWAYS_TRUE_MATCHER, schema: nil)
        @default = default
        @matcher = matcher
        @headers = headers
        @response_body = response_body
        @response_code = response_code
        @route = route
        @http_method = http_method
        @schema = schema
      end

      def matches?(request)
        matches_dynamic_path?(request) && request.request_method == http_method && matcher.call(request)
      end

      def custom_matcher?
        matcher != ALWAYS_TRUE_MATCHER
      end

      def overridden!
        @overridden = true
      end

      def overridden?
        !!@overridden
      end

      def requests
        @requests ||= []
      end

      def to_s
        <<-DOC.gsub(/^\s+/, '')
          #{http_method} #{route} -> (#{response_code}) #{response_body[0..20]}...
        DOC
      end

      def matches_dynamic_path?(request)
        route_tokens = route.split('/')
        request_tokens = request.path.split('/')

        return false unless route_tokens.count == request_tokens.count
        route_tokens.zip(request_tokens).all? do |matcher_part, request_part|
          matcher_part == request_part || matcher_part.start_with?(':')
        end
      end
    end
  end
end