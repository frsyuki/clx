
class ModInfo
	def initialize
		@info = {}
		if info = CONFIG[:info]
			@info.merge!(info)
		end
	end
	attr_reader :info

	def set(key, value)
		@info[key] = value
		value
	end

	def get(key)
		@info[key]
	end
end

m = ModInfo.new
core_method :get,  &m.method(:get)
core_method :set,  &m.method(:set)
core_def :info, &m.method(:info)

