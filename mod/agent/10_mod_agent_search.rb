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

