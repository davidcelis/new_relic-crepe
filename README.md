# NewRelic::Crepe

New Relic Instrumentation for [Crepe][crepe], the thin API stack.

## Installation

In your application's Gemfile:

```ruby
gem 'new_relic-crepe'
```

## Usage

That's it. Any class that subclasses `Crepe::API` will automatically
receive the `NewRelic::Agent::Instrumentation::Crepe` middleware and
will report data to New Relic in the production environment.

For more information on how to use New Relic, see their
[Ruby documentation][new_relic]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a Pull Request

[crepe]: https://github.com/crepe/crepe
[new_relic]: http://docs.newrelic.com/docs/ruby/
