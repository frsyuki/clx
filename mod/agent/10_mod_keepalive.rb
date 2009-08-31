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

