require 'shellwords'

class ModServe
	def initialize
		@cmd_serve = CONFIG[:cmd_serve] || "serve"
	end

	def serve(name, cmd, *args)
		case cmd
		when "start"
			run_serve name, "start"
		when "stop"
			run_serve name, "stop"
		when "status"
			run_serve name, "stat"
		when "stat"
			run_serve name, "stat"
		when "term"
			run_serve name, "term"
		when "kill"
			run_serve name, "kill"
		end
	end

	def run_serve(*args)
		out = `#{shell_line(@cmd_serve, *args)} 2>&1`
		out = "ok" if out.empty?
		out
	end

	private
	def shell_line(*args)
		args.map {|x| Shellwords.escape(x) }.join(' ')
	end
end

m = ModServe.new

core_method :serve, m.method(:serve)
core_def    :serve, m.method(:serve)
core_method :service, m.method(:serve)
core_def    :service, m.method(:serve)

