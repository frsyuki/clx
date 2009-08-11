
self_addr = CONFIG[:self_addr]
mgr_addr  = CONFIG[:mgr_addr]

if !self_addr || !mgr_addr
	raise "self_addr and mgr_addr is required"
end

mgr_host, mgr_port = *mgr_addr.unpack

core_timer(0.1) do
	begin
		sock = MessagePack::RPC::Client.new(mgr_host, mgr_port)
		sock.timeout = 1.0
		sock.call(:keepalive, self_addr)
		sock.close
	rescue
		p $!
	end
end

