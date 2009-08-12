
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
end

m = ModInfo.new
core_method :info,  &m.method(:info)
core_def :info, &m.method(:info)

