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

class ModInfo
	def initialize
		@info = {}
		if info = CONFIG[:info]
			@info.merge!(info)
		end
	end
	attr_reader :info

	def set(key, value)
		@info[key] = value
		value
	end

	def get(key)
		@info[key]
	end

	def getall
		@info
	end
end

m = ModInfo.new
core_method :get, m.method(:get)
core_method :set, m.method(:set)
core_method :getall, m.method(:getall)
core_def :info, m.method(:info)

