
service :nc do
	cmd *%w[nc -l 6123]
	before do
		puts "before nc start: #{self.inspect}"
	end
	after do
		puts "after nc start: #{self.inspect}"
	end

	on "+gnc" do
		puts "nc group added"
	end

	on "-gnc" do
		puts "nc group removed"
	end
end

