# ReqresRspec
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/reqres-api/reqres_rspec?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Gem generates API documentation from your integration tests written with `rspec`.

No additional DSL needed. Beside covering rspec tests, documentation may be extended with API controller action comments in `yardoc` style.

Documentation is generated in JSON, YAML, HTML, PDF formats.

## Installation

### 1) Gem

Just add this gem to `Gemfile` of your API Application

    gem 'reqres_rspec', group: :test

And then execute:

    $ bundle install
    
If necessary, add `require "reqres_rspec"` to your `spec/spec_helper.rb` file

### 2) PDF generator

Install `prince` http://www.princexml.com/download/ . For MacOS installation commands are

```
wget http://www.princexml.com/download/prince-10r3-macosx.tar.gz
tar -xvf prince-10r3-macosx.tar.gz
cd prince-10r3-macosx
./install.sh
```

## Usage

by default `reqres_rspec` is not active (this may be configured!). To activate it, run `rspec` with

`REQRES_RSPEC=1 bundle exec rspec --order=defined`

Documentation will be put into your application's `/doc` folder

## Upload to S3

By default ReqRes will use `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` and `AWS_REQRES_BUCKET` environment variables. But you can alter that in configuration, see below.

Update .env fields with your data:
```
AWS_ACCESS_KEY_ID='--your access key id--'
AWS_SECRET_ACCESS_KEY='--your secret access key--'
AWS_REQRES_BUCKET='--your bucket name--'
```

Then run

`REQRES_UPLOAD=1 REQRES_RSPEC=AmazonS3 bundle exec rspec --order=defined`

Also you can run

`REQRES_UPLOAD=1 REQRES_RSPEC=AmazonS3 AWS_ACCESS_KEY_ID='--your access key id--' AWS_SECRET_ACCESS_KEY='--your secret access key--' AWS_REQRES_BUCKET='--your bucket name--'  bundle exec rspec --order=defined`

## Upload to Goorle Drive

First, follow “Create a client ID and client secret” in [this page](https://developers.google.com/drive/web/auth/web-server) to get OAuth credentials. Update `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in your .env file.

`REQRES_RSPEC=1 REQRES_UPLOAD=GoogleDrive bundle exec rspec --order=defined`
Follow instractions in console

### Sample controller action

```ruby
  # @description creates Category from given parameters
  # description text may be multiline
  # @param category[title] required String Category title
  # @param category[weight] in which order Category will be shown
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

Description param text is started with `@description` and may be multiline.
Each param text is started with `@param` and first word will be param name, then optionally `required`, then optionally type (`Integer`, `String` etc), and finally param description, which may be multiline as well.

### Sample rspec test

```ruby
  it 'validates params', :skip_reqres do
    ...
  end

  context 'With valid params' do
    it 'bakes pie' do
      ...
    end
  end

  context 'With invalid params', :skip_reqres do
    it 'returns errors' do
      ...
    end
  end
```

 By default all examples will be added to docs. A context of examples (`context` and `describe` blocks) or any particular examples may be excluded from docs with option `:skip_reqres`

 Doc will use full example description, as a title for each separate spec

If you want to group examples in another way, you can do something like:

```ruby
describe 'Something', reqres_section: 'Foo' do
  context 'valid params', reqres_title: 'Bakes Pie' do
    it 'works' do
      ...
    end

    it 'tires baker', reqres_title: 'Tires baker' do
      ...
    end
  end
end
```

In this case all the `reqres_sections` can be used for grouping colleced data into section, and `reqres_title` will become human readable titles:
[![Cusomized titles](http://i57.tinypic.com/2581lw9.jpg)](http://i57.tinypic.com/2581lw9.jpg)

### Generates documentation example

[![Generated Doc](http://i44.tinypic.com/kda1pw.png)](http://i44.tinypic.com/kda1pw.png)
[![Generated Doc](http://i39.tinypic.com/2w3p6vl.png)](http://i39.tinypic.com/2w3p6vl.png)

Documentation is written in HTML format, which then converted to PDF. PDF files are textual, support search and have internal navigation links

## Configuration

```ruby
ReqresRspec.configure do |c|
  c.templates_path = Rails.root.join('spec/support/reqres/templates') # Path to custom templates
  c.output_path = 'some path' # by default it will use doc/reqres
  c.formatters = %w(MyCustomFormatter) # List of custom formatters, these can be inherited from ReqresRspec::Formatters::HTML
  c.title = 'My API Documentation' # Title for your documentation
  c.amazon_s3 = {
    credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'], # by default it will use AWS_ACCESS_KEY_ID env var
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], # by default it will use AWS_SECRET_ACCESS_KEY env var
      region: (ENV['AWS_REGION'] || 'us-east-1'),
    },
    bucket: ENV['AWS_REQRES_BUCKET'], # by default it will use AWS_REQRES_BUCKET env for bucket name
    enabled: false # Enable upload (only with REQRES_UPLOAD env var set)
  }
end
```

## Custom Formatter example

```ruby
class CustomAPIDoc < ReqresRspec::Formatters::HTML
  private
  def write
    # Copy assets
    %w(styles images components scripts).each do |folder|
      FileUtils.cp_r(path(folder), output_path)
    end

    # Generate general pages
    @pages = {
      'index.html'          => 'Introduction',
      'authentication.html' => 'Authentication',
      'filtering.html'      => 'Filtering, Sorting and Pagination',
      'locations.html'      => 'Locations',
      'files.html'          => 'Files',
      'external-ids.html'   => 'External IDs',
    }

    @pages.each do |filename, _|
      @current_page = filename
      save filename, render("pages/#{filename}")
    end

    # Generate API pages
    @records.each do |record|
      @record       = record
      @current_page = @record[:filename]
      save "#{record[:filename]}.html", render('spec.html.erb')
    end
  end
end
```

## Future plans

1) Write documentation in YAML, JSON formats

2) Add configuration (folders with API specs, default generate spec for all examples, or opt-in generation)

3) Cover with tests

4) Remove dependency on `rails`

5) Add demo for `Rails`, `Rails API`, `Sinatra`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
