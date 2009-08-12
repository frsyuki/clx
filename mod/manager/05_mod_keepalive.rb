
class ModKeepalive
	class Entry
		attr_accessor :timeout, :hostname
		def to_msgpack(out = '')
			hostname.to_msgpack(out)
		end
	end

	def initialize
		@agents = {}
	end

	def keepalive(addr_raw, hostname)
		entry = @agents[addr_raw]
		unless entry
			entry = @agents[addr_raw] = Entry.new
		end
		entry.timeout = 0
		entry.hostname = hostname
		nil
	end

	def timeout_timer
		dead = []
		@agents.each do |addr_raw, entry|
			entry.timeout += 1
			if entry.timeout > CONFIG[:timeout_limit]
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
		@agents
	end
end

m = ModKeepalive.new
core_timer CONFIG[:timer_interval], m.method(:timeout_timer)
core_method :keepalive, m.method(:keepalive)
core_method :agents, m.method(:agents)

