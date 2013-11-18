# ReqresRspec

Gem generates API documentation from your integration tests written with `rspec`. No additional DSL needed. Beside covering rspec tests, documentation may be extended with API controller action comments win `yardoc` style. Documentation is generated in JSON, YAML, HTML, PDF formats.

## Installation

### Gem

Add this line to your application's Gemfile:

    gem 'reqres_rspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reqres_rspec

### PDF generator

Install `prince` http://www.princexml.com/download/

For MacOS this will be

```
wget http://www.princexml.com/download/prince-9.0r2-macosx.tar.gz
tar -xvf prince-9.0r2-macosx.tar.gz
cd prince-9.0r2-macosx
./install.sh
```

## Usage

### Sample controller action

TODO: Write usage instructions here

### Sample rspec test

TODO: Write usage instructions here

### Generates documentation example

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
