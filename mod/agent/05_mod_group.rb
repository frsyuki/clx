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

class ModGroup
	def initialize
		@groups = []
		@on_all = []
		@on = {}
		MOD.info['group'] = @groups
	end

	def call(*args)
		if args.empty?
			return @groups
		end

		procs = []
		args.each {|match|
			name = match[1..-1]

			if match[0] == ?+
				procs << Proc.new do
					unless @groups.include?(name)
						@groups.push(name)
						do_on_all(match)
					end
				end

			elsif match[0] == ?-
				procs << Proc.new do
					if @groups.include?(name)
						@groups.delete(name)
						do_on_all(match)
					end
				end

			else
				raise "invalid argument: #{match.to_s.dump}"
			end
		}

		procs.each {|pr| pr.call }

		@groups
	end

	def on_all(&block)
		@on_all.push(block)
	end

	def on(match, &block)
		return unless block
		if match[0] != ?+ && match[0] != ?-
			raise "invalid argument #{match.dump}"
		end
		(@on[match] ||= []).push(block)
	end

	private
	def do_on_all(match)
		@on_all.each {|block| block.call(match) }
		do_on(match)
	end

	def do_on(match)
		(@on[match] || []).each {|block| block.call }
	end
end

m = ModGroup.new
core_method :group, m

core_def :on_all do |&block|
	m.on(&block)
end

core_def :on do |match, &block|
	m.on(match, &block)
end

