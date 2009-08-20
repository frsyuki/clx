
class Service
	def initialize(name, &block)
		@name = name
		@pidfile = (CONFIG[:var_dir]||"/var/tmp")+"/#{name}.pid"
		@cmd = nil
		@user = nil
		@group = nil
		@chdir = nil
		@umask = 0
		@auto_restart = false
		@on = []
		@before = []
		@after  = []
		@pid = nil
		instance_eval(&block)
	end

	def cmd(*args)
		@cmd = args
	end

	def user(name)
		@user = name
	end

	def group(name)
		@group = name
	end

	def chdir(dir)
		@chdir = dir
	end

	def chroot(dir)
		@chdir ||= "/"
		@chroot = dir
	end

	def umask(mask)
		@umask = mask
	end

	def auto_restart(bool)
		@auto_restart = bool
	end

	def on(match, &block)
		return unless block
		name = match[1..-1]
		if match[0] == ?+
			@on.push [true,  name, block]
		elsif match[0] == ?-
			@on.push [false, name, block]
		else
			raise "invalid argument #{match.dump}"
		end
		self
	end

	def before(&block)
		@before << block if block
	end

	def after(&block)
		@after << block if block
	end

	def start
		begin
			return status['pid']
		rescue
		end

		@before.each {|block| block.call }

		rpipe, wpipe = IO.pipe

		pid = fork
		unless pid
			begin
				Process.setsid rescue nil
				exit! 0 if fork
				wpipe.write [Process.pid].pack('N')
				rpipe.close
				wpipe.close
				ex = 0
				3.upto(200) {|fd|
					begin
						# FIXME 本当は FD_CLOEXEC を付けておくべき
						IO.new(fd).close
					rescue Exception
						ex += 1
						break if ex > 5
					end
				}
				STDIN.reopen '/dev/null', 'r'
				STDOUT.reopen '/dev/null', 'a'
				STDERR.reopen '/dev/null', 'a'
				Dir.chroot(@chroot) if @chroot
				Dir.chdir(@chdir) if @chdir
				File.umask(@umask) if @umask
				Process::Sys.setresuid @user if @user
				Process::Sys.setresgid @group if @group
				exec *@cmd
			rescue
				p $!
				p $!.backtrace
			end
			exit! 127
		end
		Process.waitpid(pid) rescue nil

		real_pid = rpipe.read(4).unpack('N')[0]
		File.open(@pidfile, "w") {|f| f.puts(real_pid.to_s) }

		wpipe.close
		rpipe.close

		@after.each {|block| block.call }

		real_pid
	end

	def kill(sig = "TERM")
		pid = get_pid
		Process.kill(sig, pid)
		true
	end

	alias stop kill

	def status
		pid = get_pid
		Process.getpgid(pid)
		{'pid' => pid}
	end

	def group_change(match)
		name = match[1..-1]
		if match[0] == ?+
			mode = true
		elsif match[0] == ?-
			mode = false
		else
			raise "invalid argument: #{match.to_s.dump}"
		end
		@on.each {|smode, sname, block|
			if sname == name && mode == smode
				block.call
			end
		}
		nil
	end

	private
	def get_pid
		pid = File.open(@pidfile) {|f| f.gets.to_i }
		raise "process not runnign" if pid == 0
		pid
	end
end


class ModService
	def initialize
		@svcs = {}
	end

	def call(name, *args)
		if svcs = @svcs[name.to_sym]
			svcs.send(*args)
		else
			raise "no such service: #{name.to_s.dump}"
		end
	end

	def add(name, svc)
		@svcs[name.to_sym] = svc
	end

	def on_all(match)
		@svcs.each_pair {|name, svc|
			svc.group_change(match)
		}
	end
end

#m = ModService.new
#core_method :service, m
#core_method :svc, m
#
#core_def :service do |name, &mod|
#	svc = Service.new(name, &mod)
#	m.add(name, svc)
#end
#
#on_all do |match|
#	m.on_all(match)
#end

