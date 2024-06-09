# frozen_string_literal: true

require 'tolgee_liquid/version'
require 'tolgee_liquid/translate'
require 'tolgee_liquid/zero_width_character_encoder'

# This allow user to configure Tolgee credentials
module TolgeeLiquid
  class << self
    attr_accessor :configuration

    # rubocop:disable Style/Documentation
    class Configuration
      attr_accessor :api_url, :api_key, :project_id
    end
    # rubocop:enable Style/Documentation

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def registers(options)
      options.slice(:locale, :static_data, :mode)
    end
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def with_tolgee(method_name)
  original_method = instance_method(method_name)
  define_method(method_name) do |*args, &fn|
    mode = @context.registers[:mode] || 'production'
    locale = @context.registers[:locale] || I18n.default_locale

    if mode == 'development'
      message = { k: args.first }.to_json
      hidden_message = ZeroWidthCharacterEncoder.new.execute(message)

      t = Translate.new
      dict = t.remote_dict(locale)
      value = t.fetch_translation(dict, args.first)
      return args.first if value.nil?

      translation = MessageFormat.new(value, locale.to_s).format(args.second&.transform_keys(&:to_sym))
      "#{translation}#{hidden_message}"
    else
      original_method.bind(self).call(*args, &fn)
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

# Expose translation method that used in Liquid filters
module TolgeeFilter
  def t(name, vars = {})
    opts = {
      locale: @context.registers[:locale] || I18n.default_locale,
      mode: @context.registers[:mode] || 'production',
      static_data: @context.registers[:static_data] || {}
    }
    Translate.new.execute(name, vars, opts)
  end
end
