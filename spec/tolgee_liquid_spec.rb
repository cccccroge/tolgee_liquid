# frozen_string_literal: true

require 'ostruct'
require 'i18n'

# native liquid filter
class LiquidFilter
  include TolgeeFilter

  def initialize(context)
    @context = context
  end
end

# custom liquid filter
I18n.load_path += Dir["#{File.expand_path('spec/config/locales')}/*.yml"]
class CustomLiquidFilter
  def initialize(context)
    @context = context
  end

  with_tolgee def t(name, vars = {})
    I18n.t(name, vars)
  end
end

RSpec.describe TolgeeLiquid do
  it 'has a version number' do
    expect(TolgeeLiquid::VERSION).not_to be nil
  end

  context 'Tolgee Liquid Integration' do
    before(:all) do
      TolgeeLiquid.configure do |config|
        config.api_url = 'https://testingurl.com'
        config.api_key = 'test-key'
        config.project_id = '1'
      end
    end

    context 'production' do
      before(:each) do
        registers = TolgeeLiquid.registers({
                                             locale: 'en',
                                             mode: 'production',
                                             static_data: {
                                               en: {
                                                 'hello' => 'Hello',
                                                 'hello_with_params' => 'Hello, {name}',
                                                 'namespace' => {
                                                   'morning' => 'Good morning.'
                                                 }
                                               }
                                             }
                                           })
        context = OpenStruct.new(registers: registers)
        @filter_obj = LiquidFilter.new(context)
        @filter_obj2 = CustomLiquidFilter.new(context)
      end

      it 'plain text' do
        expect(@filter_obj.t('hello')).to eq('Hello')
        expect(@filter_obj2.t('hello')).to eq('Hello')
      end

      it 'interpolation' do
        expect(@filter_obj.t('hello_with_params', { name: 'Bella' })).to eq('Hello, Bella')
        expect(@filter_obj2.t('hello_with_params', { name: 'Bella' })).to eq('Hello, Bella')
      end

      it 'interpolation without providing variables' do
        expect(@filter_obj.t('hello_with_params')).to eq('Hello, ')
        # rubocop:disable Style/FormatStringToken
        expect(@filter_obj2.t('hello_with_params')).to eq('Hello, %{name}')
        # rubocop:enable Style/FormatStringToken
      end

      it 'nested namespace' do
        expect(@filter_obj.t('namespace.morning')).to eq('Good morning.')
        expect(@filter_obj2.t('namespace.morning')).to eq('Good morning.')
      end

      it 'missing_keys' do
        expect(@filter_obj.t('namespace.not_there')).to eq('namespace.not_there')
        expect(@filter_obj2.t('namespace.not_there')).to eq('Translation missing: en.namespace.not_there')
      end
    end

    context 'development' do
      before(:each) do
        registers = TolgeeLiquid.registers({
                                             locale: 'en',
                                             mode: 'development'
                                           })
        context = OpenStruct.new(registers: registers)
        @filter_obj = LiquidFilter.new(context)
        @filter_obj2 = CustomLiquidFilter.new(context)

        stub_request(:get, 'https://testingurl.com/v2/projects/1/translations/en')
          .to_return(status: 200, body: {
            en: {
              hello: 'Hello',
              hello_with_params: 'Hello, {name}',
              namespace: {
                morning: 'Good morning.'
              }
            }
          }.to_json)
      end

      it 'plain text' do
        res = @filter_obj.t('hello')
        res2 = @filter_obj2.t('hello')

        expect(res).to start_with('Hello')
        expect(res2).to start_with('Hello')
        # rubocop:disable Layout/LineLength
        expect(res.bytes).to eq([72, 101, 108, 108, 111, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141,
                                 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140])
        expect(res2.bytes).to eq([72, 101, 108, 108, 111, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141,
                                  226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140])
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
