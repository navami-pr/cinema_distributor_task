require 'csv'

class Distributor
	$distributors = []
	@@id = 0
	@@cities = []
	csv_data = CSV.read 'cities.csv'
	headers = csv_data.shift.map {|i| i.to_s }
	string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
	@@cities = string_data.map {|row| Hash[*headers.zip(row).flatten] }

	attr_accessor :id, :name, :included, :excluded, :parent_id 
	def initialize args
	  @name =args[:name]
	  @included = args[:excluded] || []
	  @excluded = args[:included] || []
	  @parent_id = args[:parent_id]
	  @id = (@@id +=1)
	end

	def self.run_test
		puts "Enter distributor name"
		distributor_name = gets
		puts "#{distributor_name.chomp} has permission to distribute in (country-province-city)"
		place  = gets
		distributor = $distributors.select { |d| d.name.downcase == distributor_name.chomp.downcase }.last
		if distributor.parent_id.nil?
			if (distributor.included.any? { |e| e.include? place.chomp.split('-')[0]}) && !(distributor.excluded.any? { |e| e.include? place.chomp.split('-')[1] || place.chomp.split('-').last } || distributor.excluded.any? { |e| e.include? place.chomp.split('-').last})
				result = true 
			else
				result = false 
			end
		else
			parent_distributor = $distributors.select { |d| d.id == distributor.parent_id }.last
			excluded_area = (parent_distributor.excluded + distributor.excluded).uniq
			included_area = (parent_distributor.included + distributor.included).uniq
			if (included_area.any? { |e| e.include? place.chomp.split('-')[0]}) && !(excluded_area.any? { |e| e.include? place.chomp.split('-').last} || excluded_area.any? { |e| e.include? place.chomp.split('-')[1] || place.chomp.split('-').last })
				result = true
			else
				result = false
			end
		end
		puts (result ? "YES" : "NO")
	end

	def add_parent_distributer()
		puts "Enter parent distributor name"
		parent_name = gets
		$distributors.any? {|h| h.name.downcase == parent_name.chomp.downcase; self.parent_id = h.id}
	end

	def add_data(is_exclude,count)
		count.chomp.to_i.times{
					data = []
				loop do 
					puts 'Enter Country Name'
					country = gets
					if country.chomp.empty?
						break
					elsif !@@cities.map{|x| x["Country Name"].downcase}.include? country.chomp.downcase
						puts 'Given details was not exist in our directory. Try agian.'
					else
						data << country.chomp.downcase
						break
					end
				end
				loop do
					puts 'Enter Province Name'
					province = gets
					if province.chomp.empty?
						break
					elsif !@@cities.map{|x| x["Province Name"].downcase}.include? province.chomp.downcase
						puts 'Given details was not exist in our directory. Try agian.'
					else
						data << province.chomp.downcase
						break
					end
				end
				loop do
					puts 'Enter City Name'
					city = gets
					if city.chomp.empty?
						break
					elsif !@@cities.map{|x| x["City Name"].downcase}.include? city.chomp.downcase
						puts 'Given details was not exist in our directory. Try agian.'
					else
						data << city.chomp.downcase
						break
					end
				end
			is_exclude ? (self.excluded << data.join('-')) : (self.included << data.join('-'))
		}
	end

	def add_includes_excludes
		puts 'No of includes'
		includes_count = gets
		self.add_data(false,includes_count)
 		puts 'No of excludes'
		excludes_count = gets
		add_data(true,excludes_count)
		self.included.flatten!	
		self.excluded.flatten!	
	end

	def self.add_distributor
		puts 'Enter distributor name'
		name = gets
		@distributor_obj = Distributor.new(name: name.chomp)
		@distributor_obj.add_parent_distributer if @distributor_obj.id > 1
		@distributor_obj.add_includes_excludes
  end

	puts "Enter Total distributors"
	distributor_count = gets
 	distributor_count.chomp.to_i.times{
 		add_distributor
  	$distributors << @distributor_obj
 	}	
 	puts "Enter no of times you want run the test"
 	test_count = gets
 	p $distributors
 	test_count.chomp.to_i.times{
 		run_test
 	}	
 	p "Test Completed !!!"
end