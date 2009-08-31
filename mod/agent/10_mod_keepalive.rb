
manager  = CONFIG[:manager]
if manager
	mgr_host, mgr_port = manager.to_s.split(':',2)
	mgr_port ||= CLX::MANAGER_DEFAULT_PORT

	s = TCPSocket.open(mgr_host, mgr_port)
	begin
		_, _, _, self_ip = s.addr
	ensure
		s.close
	end

	self_addr = Address.new(self_ip, CONFIG[:port])

	core_timer(CONFIG[:keepalive_interval]) do
		begin
			c = CLX::RPC::Client.new(mgr_host, mgr_port)
			begin
				c.timeout = 1.0
				c.call(:keepalive, self_addr, MOD.info['host'])
			ensure
				c.close
			end
		rescue
			p $!
		end
	end

	MOD.info['ip'] = self_ip
end

