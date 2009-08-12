
mgr_addr  = CONFIG[:mgr_addr]
mgr_host, mgr_port = *mgr_addr.unpack

s = TCPSocket.open(mgr_host, mgr_port)
begin
	_, _, self_hostname, self_host = s.addr
ensure
	s.close
end

self_addr = Address.new(self_host, CONFIG[:port])

core_timer(0.1) do
	begin
		sock = MessagePack::RPC::Client.new(mgr_host, mgr_port)
		sock.timeout = 1.0
		sock.call(:keepalive, self_addr, MOD.info['host'])
		sock.close
	rescue
		p $!
	end
end

