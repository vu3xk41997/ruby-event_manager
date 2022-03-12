require "csv"
require "google/apis/civicinfo_v2"
require "erb"

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


# import template letter
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter


# open with csv
contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)
contents.each do |row|
	id = row[0]
	first_names = row[:first_name]
	zipcode = clean_zipcode(row[:zipcode])
	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)
	
	save_thank_you_letter(id, form_letter)
	# puts form_letter
end

