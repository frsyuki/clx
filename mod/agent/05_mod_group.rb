
class ModGroup
	def initialize
		@groups = []
		@on_all = []
		@on = []
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
						@on_all.each {|block| block.call(match) }
					end
				end

			elsif match[0] == ?-
				procs << Proc.new do
					if @groups.include?(name)
						@groups.delete(name)
						@on_all.each {|block| block.call(match) }
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
		MOD.info['group'] = @groups
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
	end

	def do_on(match)
		(@on[match] || []).each {|block| block.call }
	end
end

MOD.info['group'] = []

m = ModGroup.new
core_method :group, m

core_def :on_all, m.method(:on_all)
core_def :on, m.method(:on)

