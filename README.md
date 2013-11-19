# ReqresRspec

Gem generates API documentation from your integration tests written with `rspec`. No additional DSL needed. Beside covering rspec tests, documentation may be extended with API controller action comments in `yardoc` style. Documentation is generated in JSON, YAML, HTML, PDF formats.

## Installation

### Gem

Add this line to your application's Gemfile:

    gem 'reqres_rspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reqres_rspec

### PDF generator

Install `prince` http://www.princexml.com/download/ . For MacOS this will be

```
wget http://www.princexml.com/download/prince-9.0r2-macosx.tar.gz
tar -xvf prince-9.0r2-macosx.tar.gz
cd prince-9.0r2-macosx
./install.sh
```

## Usage

### Sample controller action

```ruby
  # @description creates Category from given parameters
  # description text may be multiline
  # @params category[title] required String Category title
  # @params category[weight] in which order Category will be shown
  # param text may also be multiline
  def create
    category = Category.new(create_category_params)

    if category.save
      render json: { category: category }.to_json, status: 201
    else
      render json: { errors: category.errors.full_messages }, status: 422
    end
  end
```

### Sample rspec test

```ruby
  describe 'Create' do
    it 'creates category' do
      post :create, category: { name: 'Cookies' }
      expect(response.status).to eq 201
      expect(JSON.parse(response.body)['category']['name']).to eq 'Cookies'
      expect(Category.count).to eq 1
    end
  end
```

### Generates documentation example

[![Generated Doc](http://i44.tinypic.com/kda1pw.png)](http://i44.tinypic.com/kda1pw.png)

[![Generated Doc](http://i39.tinypic.com/2w3p6vl.png)](http://i39.tinypic.com/2w3p6vl.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
