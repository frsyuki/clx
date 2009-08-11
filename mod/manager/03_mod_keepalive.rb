
class ModKeepalive
	class Entry
		def initialize(addr_raw)
			@addr = Address.load(addr_raw)
			@timeout = 0
		end
		attr_accessor :timeout
	end


	def initialize
		@agents = {}
	end

	def keepalive(addr_raw)
		@agents[addr_raw] = Entry.new(addr_raw)
		nil
	end

	def timeout_timer
		dead = []
		@agents.each do |addr_raw, agent|
			agent.timeout += 1
			if agent.timeout > CONFIG[:timeout_linit]
				dead << addr_raw
			end
		end
		dead.each {|addr_raw| remove(addr_raw) }
	end

	def remove(addr_raw)
		puts "remove #{Address.parse(addr_raw)}"
		@agents.delete(addr_raw)
		nil
	end

	def agents
		@agents.keys
	end
end

m = ModKeepalive.new
core_timer CONFIG[:timer_interval], m.method(:timeout_timer)
core_method :keepalive, m.method(:keepalive)
core_method :agents, m.method(:agents)

