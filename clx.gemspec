Gem::Specification.new do |s|
  #s.platform = Gem::Platform::CURRENT
  s.name = "clx"
  s.version = "0.0.5"
  s.summary = "clx"
  s.author = "FURUHASHI Sadayuki"
  s.email = "frsyuki@users.sourceforge.jp"
  #s.homepage = "http://.../"
  #s.rubyforge_project = "clx"
  s.require_paths = ["lib"]
  s.executables << "clx" << "clx-agent" << "clx-manager"
  s.add_dependency "msgpack", ">= 0.3.1"
  s.add_dependency "rev", ">= 0.2.4"
	s.files = ["bin/**/*", "lib/**/*", "mod/**/*"].map {|g| Dir.glob(g) }.flatten +
		%w[NOTICE README.md]
end
