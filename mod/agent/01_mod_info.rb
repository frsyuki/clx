
class ModInfo

	def initialize
		@info = {}
		if info = CONFIG[:info]
			@info.merge!(info)
		end
	end

	def info(key = nil)
		return @info unless key
		return @info[key]
	end

	def match(key, match)
		case value = @info[key]
		when NilClass
			nil
		when Array
			value.include?(match)
		when String
			value == match
		else
			false
		end
	end
end

m = ModInfo.new
core_method :info,  &m.method(:info)
core_method :match, &m.method(:match)

core_def :info, m.method(:info)

