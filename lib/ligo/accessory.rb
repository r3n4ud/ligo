# -*- coding: utf-8; fill-column: 80 -*-
#
# Copyright (c) 2012, 2013 Renaud AUBIN
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

  # A virtual accessory to interact via usb with an android device according
  # to the Android Open Accessory Protocol.
  #
  # @see http://source.android.com/tech/accessories/index.html
  # @see http://source.android.com/tech/accessories/aoap/aoa.html
  # @see
  #  http://developer.android.com/guide/topics/connectivity/usb/accessory.html
  #
  # @author Renaud AUBIN
  # @api public
  class Accessory
    include Logging

    # The default id used to initialize a new accessory if none is provided to
    # the constructor
    DEFAULT_ID = {
      manufacturer: 'ligō',
      model:        'Demo',
      description:  'ligō virtual accessory',
      version:      '1.0',
      uri:          'https://github.com/nibua-r/ligo#readme',
      # 'ligō 1.0'.each_byte {|c| print c.to_i.to_s(16), '' }
      serial:       '6c6967c58d20312e30'
    }

    # Returns the full identifying information hash
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.id
    #   # => {:manufacturer=>"ligō",
    #   #     :model=>"Demo",
    #   #     :description=>"ligō virtual accessory",
    #   #     :version=>"1.0",
    #   #     :uri=>"https://github.com/nibua-r/ligo#readme",
    #   #     :serial=>"6c6967c58d20312e30"}
    # @return [Hash<Symbol, String>] the full identifying information hash.
    attr_reader :id

    # Returns the `manufacturer name` identifying string
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.manufacturer
    #   # => "ligō"
    # @return [String] the `manufacturer name` identifying string.
    attr_reader :manufacturer

    # Returns the `model name` identifying string
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.model
    #   # => "Demo"
    # @return [String] the `model name` identifying string.
    attr_reader :model

    # Returns the `description` identifying string
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.description
    #   # => "ligō virtual accessory"
    # @return [String] the `description` identifying string.
    attr_reader :description

    # Returns the `version` identifying string
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.version
    #   # => "1.0"
    # @return [String] the `version` identifying string.
    attr_reader :version

    # Returns the `uri` identifying string
    # @example
    #   acc = Ligo::Accessory.new
    #   acc.uri
    #   # => "https://github.com/nibua-r/ligo#readme"
    # @return [String] the `uri` identifying string.
    attr_reader :uri

    # Returns the `serial` identifying string
    # @example
    #   accessory = Ligo::Accessory.new
    #   accessory.serial
    #   # => "6c6967c58d20312e30"
    # @return [String] the `serial` identifying string.
    attr_reader :serial

    # Returns a new {Accessory} initialized with the provided identification
    #
    # @param [Hash<Symbol, String>] id
    #   The accessory identifying information as a hash.
    # @raise [ArgumentError] if the provided id is not a Hash or if one of the
    #   identifying string is missing.
    # @example
    #   new_id =
    #   {
    #     manufacturer: 'MyVeryBigCompany Corp.',
    #     model:        'AwesomeProduct',
    #     description:  'Who cares about description! ← 😠',
    #     version:      '0.0',
    #     uri:          'http://www.foo.bar/awesome_product',
    #     serial:       '⚀⚁⚂⚃⚄⚅012345678'
    #   }
    #   accessory = Ligo::Accessory.new(new_id)
    def initialize(id = DEFAULT_ID)

      unless id.is_a? Hash
        raise ArgumentError, '#new must be called with a Hash'
      end

      required_ids = [:manufacturer,
                      :model, :description,
                      :version,
                      :uri,
                      :serial]

      required_ids.each do |sym|
        raise ArgumentError, "Missing argument: #{sym}" unless id.include? sym
      end

      id.each do |k, v|
        raise ArgumentError, "#{k} is not a String" unless v.is_a? String
        raise ArgumentError, "#{k} must not be empty" if v.empty?
        if v.bytesize > 255
          raise ArgumentError, "#{k} must contain at most 255 bytes"
        end
        instance_variable_set "@#{k}", v unless v.nil?
      end

      @id = id
      logger.debug self.inspect
    end

    # Returns {#id}.each
    # @return block execution.
    # @example
    #   accessory.each do |k,v|
    #     puts "#{k} = #{v}"
    #   end
    #   # manufacturer = ligō
    #   # model = Demo
    #   # description = ligō virtual accessory
    #   # version = 1.0
    #   # uri = https://github.com/nibua-r/ligo#readme
    #   # serial = 6c6967c58d20312e30
    def each(&block)
      @id.each(&block)
    end

    # Returns {#id}.keys
    # @return [Array] {#id}.keys.
    # @example
    #   accessory.keys.inspect
    #   # => "[:manufacturer, :model, :description, :version, :uri, :serial]"
    def keys
      @id.keys
    end
  end

end
