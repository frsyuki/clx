
core_method :run do |*argv|
	`#{argv.join(' ')}`
end

