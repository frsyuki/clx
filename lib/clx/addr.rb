
class Address
	def initialize(host, port)
		raw = Socket.pack_sockaddr_in(port, host)
		if raw[0] == 0 || raw[1] == 0
			# Linux
			family = raw.unpack('S')[0]
		else
			# BSD
			family = raw[1]
		end
		if family == Socket::AF_INET
			@serial = raw[2,6]
		elsif family == Socket::AF_INET6
			@serial = raw[2,2] + raw[8,20]
		end
	end

	def sockaddr
		Address.parse_sockaddr(@serial)
	end

	def unpack
		Address.parse(@serial)
	end

	def self.parse_sockaddr(raw)
		if raw.length == 6
			addr = Socket.pack_sockaddr_in(0, '0.0.0.0')
			addr[2,6] = raw[0,6]
		else
			addr = Socket.pack_sockaddr_in(0, '::')
			addr[2,2]  = raw[0,2]
			addr[8,20] = raw[2,20]
		end
		addr
	end

	def self.parse(raw)
		Socket.unpack_sockaddr_in(parse_sockaddr(raw)).reverse
	end

	def self.load(raw)
		Address.new *parse(raw)
	end

	def to_msgpack(out = '')
		@serial.to_msgpack(out)
	end
end

