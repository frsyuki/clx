
mgr_addr  = CONFIG[:mgr_addr]
mgr_host, mgr_port = *mgr_addr.unpack

s = TCPSocket.open(mgr_host, mgr_port)
begin
	_, _, self_hostname, self_ip = s.addr
ensure
	s.close
end

self_addr = Address.new(self_ip, CONFIG[:port])

core_timer(CONFIG[:keepalive_interval]) do
	begin
		c = MessagePack::RPC::Client.new(mgr_host, mgr_port)
		c.timeout = 1.0
		c.call(:keepalive, self_addr, MOD.info['host'])
		c.close
	rescue
		p $!
	end
end

info['ip'] = self_ip

