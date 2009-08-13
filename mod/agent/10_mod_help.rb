
core_method :help do
	CORE.methods.keys.map {|k| k.to_s }
end

