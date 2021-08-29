module DefaultConstants
  ENCODING = "utf-8".freeze
  EXTENSION = "csv".freeze
  COL_SEPS = ["\t", ",", ";", " ", "|", ":"]
  FILE_PATTERN = "cutsom_csv_output_#{Time.now.to_i.to_s}.csv".freeze
  COL_SEP = "\t".freeze
end