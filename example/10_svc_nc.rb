
service :nc do
	cmd *%w[nc -l 6123]

	before do
		puts "start nc service"
	end

	after do
	end

	on "+gnc" do
		puts "nc group added"
		start
	end

	on "-gnc" do
		puts "nc group removed"
		stop
	end
end

