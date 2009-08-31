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

