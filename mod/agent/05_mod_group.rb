
class ModGroup
	def initialize
		@groups = []
		@on_group_change = []
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
						@on_group_change.each {|block| block.call(match) }
					end
				end

			elsif match[0] == ?-
				procs << Proc.new do
					if @groups.include?(name)
						@groups.delete(name)
						@on_group_change.each {|block| block.call(match) }
					end
				end

			else
				raise "invalid argument: #{match.to_s.dump}"
			end
		}

		procs.each {|pr| pr.call }

		@groups
	end

	def on_group_change(&block)
		@on_group_change.push block
		MOD.info['group'] = @groups
	end
end

MOD.info['group'] = []

m = ModGroup.new
core_method :group, m

core_def :on_group_change do |&block|
	m.on_group_change(&block)
end

