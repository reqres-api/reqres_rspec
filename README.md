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

PDF generator is based on `wkhtmltopdf`. For Mac OS please use older 0.9.9 version to produce textual PDF files. Later versions will produce PDF that consists from images, so you could not search text in your docs.

```
cd ~/Downloads
wget http://code.google.com/p/wkhtmltopdf/downloads/detail?name=wkhtmltopdf-0.9.9-OS-X.i368
cp ~/Downloads/wkhtmltopdf-0.9.9-OS-X.i368 /Applications
chmod +x /Applications/wkhtmltopdf-0.9.9-OS-X.i368
`

You can configure path to wkhtmltopdf in reqres_rspec.yml if you use other OS. Please check http://code.google.com/p/wkhtmltopdf for your OS version

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
