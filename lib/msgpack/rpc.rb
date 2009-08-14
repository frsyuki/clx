require 'msgpack'
require 'rev'

# FIXME timeout
require 'timeout'

module MessagePack
module RPC


class Responder
	def initialize(socket, msgid)
		@socket = socket
		@msgid = msgid
	end

	def result(retval, err = nil)
		@socket.send_response(@msgid, retval, err)
	end

	def error(err)
		result(nil, err)
	end
end


module RPCSocket
	def session=(s)
		@session = s
		s.add_socket(self)
	end

	def on_message(msg)
		if msg[0] == 0
			on_request(msg[1], msg[2], msg[3])
		elsif msg[0] == 1
			on_response(msg[1], msg[3], msg[2])
		else
			raise "unknown message type #{msg[0]}"
		end
	end

	def on_close
		return unless @session
		@session.on_close(self)
	rescue
		nil
	end

	def on_request(msgid, method, param)
		return unless @session
		@session.on_request(method, param, Responder.new(self,msgid))
	end

	def on_response(msgid, res, err)
		return unless @session
		@session.on_response(msgid, res, err)
	end

	def send_request(msgid, method, param)
		send_message [0, msgid, method, param]
	end

	def send_response(msgid, retval, err)
		send_message [1, msgid, err, retval]
	end
end


class RevSocket < ::Rev::TCPSocket
	include RPCSocket

	def initialize(*args)
		@buffer = ''
		@nread = 0
		@mpac = MessagePack::Unpacker.new
		super
	end

	def on_read(data)
		@buffer << data

		while true
			@nread = @mpac.execute(@buffer, @nread)

			if @mpac.finished?
				msg = @mpac.data

				@mpac.reset
				@buffer.slice!(0, @nread)
				@nread = 0

				on_message(msg)  # RPCSocket#on_message
			end

			break if @buffer.length <= @nread
		end
	end

	def send_message(msg)
		write msg.to_msgpack
	end
end


class ClientSession

	class BasicRequest
		def initialize(session, loop)
			@error  = nil
			@result = nil
			@session = session
			@timeout = session.timeout
			@loop = loop
		end
		attr_reader :loop
		attr_accessor :result, :error

		def call(err, res)
			@error  = err
			@result = res
			@session = nil
		end

		def join
			if @session
				time = @session.timeout
				if time > 0
					begin
						Timeout.timeout(time) {
							join_real
						}
					rescue TimeoutError
						raise "timeout"  # FIXME
					end
				else
					join_real
				end
			end
			self
		end

		private
		def join_real
			while @session
				@loop.run_once
			end
		end
	end


	def initialize(loop)
		@sock = nil
		@reqtable = {}
		@seqid = 0
		@loop = loop
		@timeout = 0
	end
	attr_accessor :timeout

	def add_socket(sock)
		@sock = sock
	end

	def send(method, *args)
		send_real(method, args, BasicRequest.new(self,@loop))
	end

	def send_callback(method, *args, &block)
		send_real(method, args, block)
	end

	def call(method, *args)
		req = send(method, *args)
		req.join
		if req.error
			raise req.error
		end
		req.result
	end


	def on_response(msgid, result, error)
		if req = @reqtable.delete(msgid)
			req.call error, result
		end
	end

	def on_request(method, param, res)
		raise "unexpected response message"
	end

	def on_close
		# FIXME
	end

	def close
		@sock.close if @sock
	end

	private
	def send_real(method, param, req)
		method = method.to_s
		msgid = @seqid
		@seqid += 1; if @seqid >= 1<<16 then @seqid = 0 end
		@sock.send_request msgid, method, param
		@reqtable[msgid] = req
	end
end


class ServerSession
	def initialize(obj)
		@obj = obj
	end

	def add_socket(sock)
		# do nothing
	end

	def on_request(method, param, res)
		begin
			ret = @obj.send(method, *param)
		rescue
			res.error($!.to_s)
			return
		end
		res.result(ret)
	end

	def on_response(msgid, error, result)
		raise "unexpected response message"
	end

	def on_close
		# do nothing
	end
end

Loop = ::Rev::Loop

module LoopUtil
	class Timer < Rev::TimerWatcher
		def initialize(interval, repeating, &block)
			@block = block
			super(interval, repeating)
		end
		def on_timer
			@block.call
		end
	end

	def start_timer(interval, repeating, &block)
		@loop.attach Timer.new(interval, repeating, &block)
	end
end


class Client
	def initialize(host, port, loop = Loop.new)
		@loop = loop
		@host = host
		@port = port
		rs = RevSocket.connect(host, port)
		@s = ClientSession.new(loop)
		rs.session = @s
		loop.attach(rs)
	end
	attr_reader :loop, :host, :port

	def send(method, *args)
		@s.send(method, *args)
	end

	def send_callback(method, *args, &block)
		@s.send_callback(method, *args, &block)
	end

	def call(method, *args)
		@s.call(method, *args)
	end

	def close
		@s.close
	end

	def timeout
		@s.timeout
	end

	def timeout=(time)
		@s.timeout = time
	end

	include LoopUtil
end


class Server
	class Socket < RevSocket
		def initialize(*args)
			obj = args.pop
			self.session = ServerSession.new(obj)
			super(*args)
		end
	end

	def initialize(loop = Loop.new)
		@loop = loop
	end
	attr_reader :loop

	def listen(host, port, obj)
		lsock = ::Rev::TCPServer.new(host, port, Server::Socket, obj)

		@loop.attach(lsock)
	end

	def run
		@loop.run
	end

	include LoopUtil
end


end  # module RPC
end  # module MessagePack

