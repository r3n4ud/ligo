# -*- coding: utf-8; fill-column: 80 -*-
#
# Copyright (c) 2012 Renaud AUBIN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Ligo

  class Accessory
    include Logging

    # http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument
    attr_reader :id, :manufacturer, :model, :description, :version, :uri, :serial

    DEFAULT_ID = {
      manufacturer: 'ligō',
      model:        'Demo',
      description:  'ligō virtual accessory',
      version:      '1.0',
      uri:          'https://github.com/nibua-r/ligo#readme',
      serial:       '6c6967c58d20312e30' # 'ligō 1.0'.each_byte {|c| print c.to_i.to_s(16), '' }
    }

    def initialize(id = DEFAULT_ID)

      required_ids = [:manufacturer, :model, :description, :version, :uri, :serial]
      required_ids.each do |sym|
        raise ArgumentError, "Missing argument: #{sym}" unless id.include? sym
      end

      id.each do |k, v|
        raise ArgumentError, "#{k} is not a String" unless v.is_a? String
        raise ArgumentError, "#{k} must not be empty" if v.empty?
        raise ArgumentError, "#{k} must contain at most 255 bytes" if v.bytesize > 255
        instance_variable_set "@#{k}", v unless v.nil?
      end

      @id = id
      logger.debug self.inspect
    end

    def each(&block)
      @id.each(&block)
    end

    def keys
      @id.keys
    end
  end

end
