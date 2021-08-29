require "csvn/version"
require 'colorize'
require 'constants'
require 'csv'

# That class helps to work with csv in pry or irb with some useful methods already defined. (Gem created just as a part of practice)
# PS: Stupid idea? if you think about it seriously more than 10 seconds? because almost everything work via CSV gem as you can see in require section
class CSVFile
  attr_accessor :data, :file_headers, :output, :file_name
  attr_reader :file_col_sep, :file_extension

  # initializer method for CSVFile
  def initialize(file_name: nil, file_extension: DefaultConstants::EXTENSION, convert: false, output: DefaultConstants::FILE_PATTERN)
    @file_name = file_name                ### source file name (full path should be provided)
    @file_extension = file_extension      ### file extension
    @data = []                            ### file rows data
    @smart_convert = convert              ### convert readed data in array of hashes with file headers keys - false by default
    @file_headers = nil                   ### file headers array
    @read_flag = false                    ### service flag
    @output = output            ### write file name with extension
  end

  # Show some useful info about working file
  def info
    @encoding = find_enoding
    puts "INFO:"
    print 'File name         '; print "#{@file_name}\n".colorize(:green)
    print 'File headers      '; print "#{@file_headers}\n".colorize(:green)
    print 'File rows number  '; print "#{@data.size}\n".colorize(:green)
    print 'File encoding     '; print "#{@encoding}\n".colorize(:green)

    ## temp decision
    if @output_file_name
      print 'Output File   '; print "#{@output_file_name || 'nil'}\n".colorize(:green)
    end
  end

  # Read dta from file
  # Param :only can define limit of readed lines from file - not implemented yet
  def read
    return if @read_flag

    process_reading
  end

  # Write data in file (named by pattern - may be found in DefaultConstants::FILE_PATTERN)
  # Will write data every time it calles to ensure that all current data writed in file - may occurs duplicate if used more than once
  # If data_to_write - is array of hashes - will use first hash keys as headers, else - headers that provided by :header key in method call
  def write(data_to_write:, headers: [], encoding: DefaultConstants::ENCODING)
    data_prepared, headers_prepared = prepare_data_for_writing(data_to_write, headers)
    begin
      process_writing(data_prepared, headers_prepared, encoding)
      puts "Writed in #{@output}".colorize(:cyan)
    rescue StandardError => e2
      e2.message
    end
  end

  # Only for string row values
  # will be improved to be able to handle more complex selecting like SQL does ----> multiple select
  def select(opts = {})
    return @data.select { |row| row[opts[:where]] =~ /#{opts[:like]}/ } if opts[:like]
    return @data.select { |row| row[opts[:where]] !~ /#{opts[:not_like]}/ } if opts[:not_like]

    @data.select { |row| row[opts[:where]] == opts[:equals] }
  end

  # Convert readed data to hash with headers keys
  # Need to prevent reading only in one format and to give opportunity to choose data presentation
  def smart_convert!
    if @file_headers.any?
      @data = @data.map { |d_arr| @file_headers.each_with_object({}).with_index { |(h_name, h_hash), ind| h_hash[h_name] = d_arr[ind] } }
      @smart_convert = true
    end
  end

  def sort(opts={})
    return nil unless @data

    raise_exceptions(__method__)
    compare_statement = opts[:apply] ? "data_h[opts[:by]].#{opts[:apply]}" : "data_h[opts[:by]]"

    sort_statement = <<-SORT_STATEMENT
      @data.sort_by do |data_h|
        begin
          eval(compare_statement)
        rescue NoMethodError => err
          puts err.message
          break
        end
      end#{opts[:desc] ? ".reverse" : ""}
    SORT_STATEMENT
    eval(sort_statement)
  end

  def max(opts={})
    return ":by key must be provided for that method." unless opts[:by]

    raise_exceptions(__method__)

    value_statement = opts[:apply] ? "data_h[opts[:by]].#{opts[:apply]}" : "data_h[opts[:by]]"
    @data.max_by do |data_h|
      begin
        eval(value_statement)
      rescue NoMethodError => err
        puts err.message
        break
      end
    end
  end

  def min(opts={})
    return ":by key must be provided for that method." unless opts[:by]
    raise_exceptions(__method__)

    value_statement = opts[:apply] ? "data_h[opts[:by]].#{opts[:apply]}" : "data_h[opts[:by]]"
    @data.min_by do |data_h|
      begin
        eval(value_statement)
      rescue NoMethodError => err
        puts err.message
        break
      end
    end
  end

  def mean(opts={})
    return ":by key must be provided for that method." unless opts[:by]
    raise_exceptions(__method__)

    mean_statement = opts[:apply] ? "data_h[opts[:by]].#{opts[:apply]}" : "data_h[opts[:by]]"
    @data.map { |data_h| eval(mean_statement) }.sum.to_f / @data.size
  end

  def delete(opts={})
    # opts - condition hash where :key is column value and :value - row value to chech for eql? with what you needed
  end

  private

  # service methods that not need to be opened for usage outside
  # if need more - contact please me or contribute yourself by merge request

  def prepare_data_for_writing(data_to_write, headers)
    if data_to_write.first.class.to_s.downcase =~ /hash/
      prepared_headers = data_to_write.first.keys.map(&:to_s)
      prepared_data_to_write = data_to_write.map { |data_h| data_h.values }
      return prepared_data_to_write, prepared_headers
    elsif data_to_write.first.class.to_s.downcase =~ /array/
      raise "No headers provided for writing" if !headers or headers.empty?

      return data_to_write, headers
    end
  end

  def raise_exceptions(called_method)
    raise "Need to <CSVFile instance>.smart_convert! your file data first to proceed #{called_method}." unless @smart_convert
    raise "No data readed. Check these please before calling #{called_method}" unless @data
  end

  # find out file encoding
  def find_enoding
    scmdlog = `file -I #{@file_name}`.strip
    scmdlog[/charset=(.+?)$/, 1]
  end

  # read data from file
  def process_reading
    begin
      open_and_read_file
      @read_flag = true
      puts 'Success. Check instance fields'.colorize(:green)
    rescue StandardError => e
      puts e.message
    end
  end

  # write data into file (upstream in <class>#write method)
  def process_writing(data_to_write, headers, encoding)
    begin
      open_and_write_data(data_to_write, headers, encoding)
      @write_flag = true
      puts 'Success. Check file with new data'
    rescue StandardError => e
      puts e.message
    rescue CSV::MalformedCSVError => e2
      puts e2.message
    end
  end

  def open_and_read_file
    raise "No file name specified for reading data. Set file name with #{self.class}.file_name = <value>" unless @file_name
    DefaultConstants::COL_SEPS.each do |separator|
      begin
        @file_col_sep = separator
        @file_headers = nil
        CSV.foreach(@file_name, col_sep: separator).with_index do |row_csv, row_index|
          if row_index.zero?
            @file_headers = row_csv
            next
          end
          @data << row_csv
        end

        break
      rescue CSV::MalformedCSVError => e
        @file_headers = nil
        next
      rescue StandardError => e2
        @file_headers = nil
        next
      end
    end
  end

  def open_and_write_data(data, headers, encoding)
    CSV.open(@output, 'w+', col_sep: DefaultConstants::COL_SEP, write_headers: true, headers: headers, encoding: encoding) do |csv_element|
      data.each do |data_sample|
        csv_element << data_sample
      end
    end
  end
end
