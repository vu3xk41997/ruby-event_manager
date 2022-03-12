require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"
require "time"

puts "Event Manager Initialized!"


# read entire file
# contents = File.read("event_attendees.csv")
# puts contents


# # read line by line
# lines = File.readlines("event_attendees.csv")
# lines.each_with_index do |line, index|
# 	# skip first line
# 	next if index = 0
# 	# turn string into array
# 	columns = line.split(",")
# 	# access to first name column
# 	first_names = columns[2]
# 	puts first_names
# end


# method to fix zipcode
def clean_zipcode(zipcode)
  # if zipcode.nil?
  #   '00000'
  # elsif zipcode.length < 5
  #   zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode[0..4]
  # else
  #   zipcode
  # end
  zipcode.to_s.rjust(5, '0')[0..4]
end

# method to clean phone number
# If the phone number is less than 10 digits, assume that it is a bad number
# If the phone number is 10 digits, assume that it is good
# If the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
# If the phone number is 11 digits and the first number is not 1, then it is a bad number
# If the phone number is more than 11 digits, assume that it is a bad number
def clean_phone_number(phone)
	formatted_number = phone.to_s.gsub(/[^0-9]/, '')
	if formatted_number.length == 10
		formatted_number
  elsif formatted_number.length == 11 && formatted_number[0] == "1"
      return formatted_number[1..-1]
	else
		"Invalid Number"
	end
end


# method to format timestamp
def format_timestamp(timestamp)
	date = timestamp.split(" ")[0]
  	time = timestamp.split(" ")[1]
  	month = date.split("/")[0]
  	day = date.split("/")[1]
  	year = date.split("/")[2]
  	formatted_timestamp = "#{year}/#{month}/#{day} #{time}"
  	formatted_timestamp
end

# method to get all register hour
def get_hour(timestamp)
	Time.parse(format_timestamp(timestamp)).hour
end

# method to get target hour
def get_target_hour(array)
	hour_hash = Hash.new(0)
	array.map {|hour| hour_hash[hour] += 1}
  	hour_hash.key(hour_hash.values.max)
end

# method to get all register day
def get_day(timestamp)
  Time.parse(format_timestamp(timestamp)).strftime("%A")
end

# method to get target day
def get_target_day(array)
	day_hash = Hash.new(0)
	array.map {|day| day_hash[day] += 1}
  	day_hash.key(day_hash.values.max)
end



# method to extract legislator's names
def legislators_by_zipcode(zipcode)
	# access to google api legislators
	civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
	civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

	# access to google api legislators
	begin
		civic_info.representative_info_by_address(
      		address: zipcode,
      		levels: 'country',
      		roles: ['legislatorUpperBody', 'legislatorLowerBody']
    	).officials
    	# find legislator's name
  		# legislator_names = legislators.map do |legislator|
   		#	legislator.name
  		# end
  		# legislator_names = legislators.map(&:name)
  		# legislators_string = legislator_names.join(", ")
  	rescue
    	'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  	end
end


# method for outputing each letter with id to the "output" folder
def save_thank_you_letter(id, form_letter)
	Dir.mkdir('output') unless Dir.exist?('output')
	filename = "output/thanks_#{id}.html"
	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end


# # import template letter
# template_letter = File.read('form_letter.erb')
# erb_template = ERB.new template_letter


# # open with csv
# contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)
# contents.each do |row|
# 	id = row[0]
# 	first_names = row[:first_name]
# 	zipcode = clean_zipcode(row[:zipcode])
# 	legislators = legislators_by_zipcode(zipcode)

# 	form_letter = erb_template.result(binding)
	
# 	save_thank_you_letter(id, form_letter)
# 	# puts form_letter
# end

hour_array = []
day_array = []
contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)
contents.each do |row|
	first_names = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])
	legislators = legislators_by_zipcode(zipcode)
	phone_number = clean_phone_number(row[:homephone])

	# get target hour
	reg_hour = get_hour(row[:regdate])
	hour_array.push(reg_hour)

	# get target day
	reg_day = get_day(row[:regdate])
	day_array.push(reg_day)
end

puts get_target_hour(hour_array)

puts get_target_day(day_array)



