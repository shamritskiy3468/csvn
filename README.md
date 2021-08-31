# csvn (CFilesHelper)

This is my first gem for simple and more convinient work with csv files (especially for csv exports from DB). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csvn'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install csvn

## Usage


### Base description of instance variables

`file_name` - source file name for reading (absolute or relative path should be provided)

`file_extension` - file extension

`data` - file data rows (as array when readed and array of hashes after .smart_convert! method)

`smart_convert` - convert readed data in array of hashes with file headers keys - false by default

`file_headers` - file headers array

`read_flag` - service flag to see if data already readed

`output` - output file name with extension to use .write method


### read data

Can read data with all standart separators (iterating over DefaultConstants::COL_SEPS - `["\t", ",", ";", " ", "|", ":"]`)

```
csv_instance = CSVFile.new(file_name: "export_for_saller.csv") # create new instance
csv_instance.info # show stat about file
csv_instance.read # read file data - return array of arrays - allow to read file 
csv_instance.smart_convert! - convert readed data into array of hashes with file headers keys
```

### write data

```
csv_instance.write(data_to_write: data, headers: headers) # write data in file with name provided with @destination instance variables
```

`data` - may be array of arrays or array of hashes -> will be automaticly converted while writing. If data is array of hashes - headers will be extracted from first data hash. Else - headers must be provided mannually.

### processing data

Help to select data rows by condition

#### .select
```
csv_instance.select(where: "name", like: "mary") # return array of hashes matched by condition
```
Will be improved soon - need to implement ability to select by several conditions with AND | OR constructions

#### .sort
```
csv_instance.sort(by: "number", apply: :to_i) # (:apply - optional) - sort array of hashes by number key and with .to_i applied to current value
```

#### .min
```
csv_instance.min(by: "dest_value", apply: :to_f) # (:apply - optional) search min value with .to_f applied to current value
```

#### .max
```
csv_instance.max(by: "dest_value", apply: :to_f) # (:apply - optional) search max value with .to_f applied to current value
```

#### .mean
```
csv_instance.mean(by: "dest_value", apply: :to_f) # s(:apply - optional) earch mean value with .to_f applied to current value
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shamritskiy3468/csvn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shamritskiy3468/csvn/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Csvn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shamritskiy3468/csvn/blob/master/CODE_OF_CONDUCT.md).
