# frozen_string_literal: true

require "json"

module JSON
  class << self
    unless method_defined?(:_original_parse_for_kw_compat)
      alias_method :_original_parse_for_kw_compat, :parse

      def parse(source, opts = nil, **kwargs)
        if opts.is_a?(Hash)
          merged = opts.merge(kwargs).transform_keys(&:to_sym)
          merged.empty? ? _original_parse_for_kw_compat(source) : _original_parse_for_kw_compat(source, **merged)
        elsif opts.nil?
          kwargs.empty? ? _original_parse_for_kw_compat(source) : _original_parse_for_kw_compat(source, **kwargs)
        else
          _original_parse_for_kw_compat(source, opts, **kwargs)
        end
      end
    end
  end
end
