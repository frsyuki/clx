require 'msgpack/rpc'

module CLX

class Core

	def initialize(host, port, config, loop = Rev::Loop.new)
		@methods = {}
		@svr = MessagePack::RPC::Server.new(loop)

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
		@modspace.module_eval(str, fname)
	end

	def run
		@svr.run
	end


	# MessagePack::RPC::Server
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
