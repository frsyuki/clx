require 'yaml/store'

class ModConfig
	def initialize
		@config = {}
		@store = YAML::Store.new(CONFIG[:store])
	end

	def getconfig(key)
		@store.transaction(true) do
			@store[key]
		end
	end

	def setconfig(key, value)
		@store.transaction do
			@store[key] = value
		end
	end
end

m = ModConfig.new
core_method :getconfig, m.method(:getconfig)
core_method :setconfig, m.method(:setconfig)

