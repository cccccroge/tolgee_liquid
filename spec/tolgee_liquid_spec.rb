require 'ostruct'

RSpec.describe TolgeeLiquid do
  it "has a version number" do
    expect(TolgeeLiquid::VERSION).not_to be nil
  end

  context "Tolgee Liquid Integration" do
    before(:all) do
      TolgeeLiquid.configure do |config|
        config.api_url = 'https://testingurl.com'
        config.api_key = 'test-key'
        config.project_id = '1'
      end
      class MyFilterClass
        include TolgeeFilter

        def initialize(context)
          @context = context
        end
      end
    end

    context 'production' do
      before(:each) do
        registers = TolgeeLiquid.registers({
          locale: 'en',
          mode: 'production',
          static_data: {
            en: {
              "hello"=>'Hello',
              "hello_with_params"=>'Hello, {name}',
              "namespace"=>{
                "morning"=>'Good morning.',
              }
            },
          },
        })
        context = OpenStruct.new(registers: registers)
        @filter_obj = MyFilterClass.new(context)
      end

      it 'plain text' do
        expect(@filter_obj.t('hello')).to eq('Hello')
      end

      it 'interpolation' do
        expect(@filter_obj.t('hello_with_params', { name: 'Bella' })).to eq('Hello, Bella')
      end

      it 'interpolation without providing variables' do
        expect(@filter_obj.t('hello_with_params')).to eq('Hello, ')
      end

      it 'nested namespace' do
        expect(@filter_obj.t('namespace.morning')).to eq('Good morning.')
      end

      it 'missing_keys' do
        expect(@filter_obj.t('namespace.not_there')).to eq('namespace.not_there')
      end
    end

    context 'development' do
      before(:each) do
        registers = TolgeeLiquid.registers({
          locale: 'en',
          mode: 'development',
        })
        context = OpenStruct.new(registers: registers)
        @filter_obj = MyFilterClass.new(context)

        stub_request(:get, "https://testingurl.com/v2/projects/1/translations/en")
          .to_return(status: 200, body: {
            en: {
              hello: 'Hello',
              hello_with_params: 'Hello, {name}',
              namespace: {
                morning: 'Good morning.',
              }
            }
          }.to_json)
      end

      it 'plain text' do
        res = @filter_obj.t('hello')
        expect(res).to start_with('Hello')
        expect(res.bytes).to eq([72, 101, 108, 108, 111, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 140, 226, 128, 140, 226, 128, 140, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 141, 226, 128, 140, 226, 128, 141, 226, 128, 140])
      end
    end
  end
end
