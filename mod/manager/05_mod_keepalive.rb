#
# clx
#
# Copyright (C) 2009 FURUHASHI Sadayuki
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

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

