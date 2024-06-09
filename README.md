# TolgeeLiquid

A Ruby gem that integrates the [Tolgee Platform](https://tolgee.io/integrations) with Shopify's [Liquid template language](https://github.com/Shopify/liquid).

If you are developing a multilingual web application using the Liquid template language, check out the Tolgee Platform (translation as a service). It enhances your translation workflow, making it more efficient and accurate.

This gem focuses on the "In-Context" translation integration. See the example project at https://github.com/cccccroge/tolgee-rails-liquid.

## Installation

### Prerequisite
Make sure you have liquid installed.

### Install

Add this line to your application's Gemfile:

```ruby
gem 'tolgee_liquid'
```

And then execute:

    $ bundle

## Usage

### Setup Credentials
Add the following block to your application initialization. If you are using Rails, place it in config/initializers/tolgee.rb:

```.rb
TolgeeLiquid.configure do |config|
  config.api_url = 'https://example.tolgee.io'
  config.api_key = <TOLGEE_API_KEY>
  config.project_id = <TOLGEE_PROJECT_ID>
end
```
This allows the gem to fetch data from the corresponding Tolgee project in development mode.

### Register `t` method for Liquid
There are two ways to setup.

#### Use Decorator
If you already have your own translation method `t` defined.
```.rb
module MyFilterContainsTranslationMethod
  def t(name, vars = {})
    # Own implementation
  end    
end

Liquid::Template.register_filter(MyFilterContainsTranslationMethod)
```

Add the prefix `with_tolgee` on translation method:
```.rb
module MyFilterContainsTranslationMethod
  with_tolgee def t(name, vars = {})
    # Own implementation
  end    
end
```

Note that the arguments of the original t method must match the format above (the first argument being the translation key, and an optional hash argument providing variables for string interpolation). Otherwise, it won't work correctly.

#### Use gem's `t` method
You can use the t method provided by the gem, which utilizes ICU MessageFormat patterns under the hood.

```.rb
Liquid::Template.register_filter(TolgeeFilter)
```

### Use `t` filter in Liquid template

Example Liquid snippet:
```.html
<div>{{ 'key.nested_key' | t: fruit: 'Pitaya' }}</div>
```

Example application's controller code for Rails project:
```.rb
class PagesController < ApplicationController
  def index
    # get liquid template file...
    template = Liquid::Template.parse(liquid)

    # provide translations and meta data 
    tolgee_registers = TolgeeLiquid.registers({
      locale: 'en',
      mode: 'development',
      static_data: {
        en: YAML.load_file(Rails.root.join('config', 'locales', 'en.yml')),
      },
    })
    
    html = template.render({}, registers: tolgee_registers)
    # put html to view...
  end
end
```

Example translation yaml file:
```.yml
key:
  nested_key: "I like {fruit}!"
```

## Development

- Run `install dependencies` to install dependencies.
- Run `rake spec` to run the tests.
- Run `bin/console` for an interactive prompt that will allow you to experiment.
- Run `rubocop` to find code smells.
- Run `bin/deploy` to release a new version

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
