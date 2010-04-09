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
require 'shellwords'

class ModServe
	def initialize
		@cmd_serve = CONFIG[:cmd_serve] || "serve"
		@cmd_serve_opt = CONFIG[:cmd_serve_opt] || ""
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
		else
			raise "unknown command: #{cmd.inspect}"
		end
	end

	def run_serve(*args)
		out = `#{shell_line(@cmd_serve, *args)} #{@cmd_serve_opt} 2>&1`
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

%w[start stop status stat term kill].each do |cmd|
	core_def cmd do |name|
		m.serve(name, cmd)
	end
end

