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
require 'clx/rpc'

module CLX

class Core

	def initialize(host, port, config, loop = Rev::Loop.new)
		@methods = {}
		@svr = CLX::RPC::Server.new(loop)

		core = self
		svr  = @svr
		@modspace = Class.new(Mod) do
			const_set(:MOD, self)
			const_set(:CORE, core)
			const_set(:SVR, svr)
			const_set(:CONFIG, config)
		end

		@svr.listen(host, port, self)
	end

	def scan_module(glob)
		Dir.glob(glob).sort.each do |file|
			load_module(File.read(file), file)
		end
	end

	def load_module(str, fname = "(mod)")
		begin
			@modspace.module_eval(str, fname)
		rescue
			$stderr.puts $!.to_s
			$!.backtrace.each do |line|
				$stderr.puts "  #{line}"
			end
		end
	end

	def run
		@svr.run
	end


	# CLX::RPC::Server
	def send(name, *args)
		if block = @methods[name.to_sym]
			block.call(*args)
		else
			raise "no such module: #{name.to_s.dump}"
		end
	end

	def add_method(name, block)
		@methods[name.to_sym] = block
	end

	attr_reader :methods


	class Mod
	class << self
		def core_method(name, proc=nil, &block)
			proc ||= block
			const_get(:CORE).add_method(name, proc)
		end

		def core_def(name, proc=nil, &block)
			proc ||= block
			self.class.module_eval do
				define_method(name, &proc)
			end
		end

		def core_timer(interval, proc=nil, &block)
			proc ||= block
			const_get(:SVR).start_timer(interval, true, &proc)
		end

		def core_do_after(sec, proc=nil, &block)
			proc ||= block
			const_get(:SVR).start_timer(sec, false, &method(:on_timeout_timer))
		end
	end
	end  # class Mod

end

end  # module CLX
