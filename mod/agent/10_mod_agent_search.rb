
sock = UDPSocket.new
sock.bind(CONFIG[:listen_host], CONFIG[:listen_port])

Thread.start do
	begin
		while true
			msg, addr = sock.recvfrom(2048)
			_, port, _, ip = *addr

			s = UDPSocket.new
			begin
				s.connect(ip, port)
				_, _, _, self_ip = s.addr
			ensure
				s.close
			end

			MOD.info['ip'] = self_ip
			self_addr = Address.new(self_ip, CONFIG[:port])

			msg = [self_addr, MOD.info['host']].to_msgpack
			sock.send(msg, 0, ip, port)
		end
	rescue
	end
end

