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



  # # Accessory class.
  # #
  # # A virtual accessory to interact via usb with an android device according
  # # to the Android Open Accessory Protocol.
  # #
  # # @see http://source.android.com/tech/accessories/aoap/aoa.html
  # # @see http://source.android.com/tech/accessories/index.html
  # # @see
  # #  http://developer.android.com/guide/topics/connectivity/usb/accessory.html
  # class Accessory

  #   # The default identification hash used to initialize the virtual accessory
  #   #   if none is provided.
  #   DEFAULT_ACCESSORY_ID = {
  #     manufacturer: 'Google, Inc.',
  #     model:        'DemoKit',
  #     description:  'DemoKit Arduino Board',
  #     version:      '1.0',
  #     uri:          'http://www.android.com',
  #     serial:       '0000000012345678'
  #   }

  #   # @!attribute logger
  #   #   @return [Logger] the logger used internally to handle log messages.
  #   attr_accessor :logger

  #   # @!attribute context
  #   #   @return [Context] the context used internally to handle log
  #   #     messages.
  #   attr_accessor :context

  #   # @!attribute accessory_id
  #   #   @example The default DemoKit id
  #   #     {
  #   #       manufacturer: 'Google, Inc.',
  #   #       model:        'DemoKit',
  #   #       description:  'DemoKit Arduino Board',
  #   #       version:      '1.0',
  #   #       uri:          'http://www.android.com',
  #   #       serial:       '0000000012345678'
  #   #     }
  #   #   @return [Hash] the hash identifying the virtual accessory.
  #   attr_accessor :accessory_id

  #   # @!attribute device
  #   #   @return [LIBUSB::Device] the current device currently interacting with
  #   #     the virtual accessory.
  #   attr_accessor :device

  #   # @!attribute in
  #   #   @return [LIBUSB::Endpoint] the input endpoint.
  #   attr_accessor :in

  #   # @!attribute out
  #   #   @return [LIBUSB::Endpoint] the output endpoint.
  #   attr_accessor :out

  #   # @!attribute handle
  #   #   @return [LIBUSB::DevHandle] the handle used to perform I/O on the OAP
  #   #     compatible device.
  #   attr_accessor :handle

  #   # Initializes the virtual accessory.
  #   #
  #   # @param [Hash, nil] accessory_id
  #   #   The virtual device identification hash.
  #   # @param [Logger, nil] logger
  #   #   The logger to be used to handle log messages.
  #   #
  #   # @example accessory_id
  #   #   {
  #   #     manufacturer: 'MyVeryBigCompany Corp.',
  #   #     model:        'AwesomeProduct',
  #   #     description:  'Who cares about description! ← 😠',
  #   #     version:      '0.0',
  #   #     uri:          'http://www.foo.bar/awesome_product',
  #   #     serial:       '⚀⚁⚂⚃⚄⚅012345678'
  #   #   }
  #   def initialize(accessory_id = DEFAULT_ACCESSORY_ID,
  #                  logger = ::Logger.new('/tmp/ligo.log'))
  #     @logger = logger
  #     @accessory_id = accessory_id
  #     @context, @device, @handle, @in, @out = nil, nil, nil, nil, nil
  #   end

  #   # Scans the USB bus to get the OAP compatible devices.
  #   # @return [Array<LIBUSB::Device>, nil] the list of compatible devices
  #   #   currently connected on the USB bus or `nil` if none was found.
  #   # TODO: implement detach/attach kernel as an option
  #   def compatible_devices
  #     # Open a libusb session if needed
  #     @context = Context.new if @context.nil?

  #     # Check for each usb device if:
  #     # - its vendor id matches one the VENDOR_IDS
  #     # - it supports OAP

  #     devices = @context.devices.collect do |d|
  #       d.open do |h|

  #         # 0x08 is for UMS
  #         # Add 0x06 for the subClass?
  #         condition = (d.settings[0].bInterfaceClass == 0x08 ) &&
  #           h.kernel_driver_active?(0) &&
  #           RUBY_PLATFORM=~/linux/i

  #         if condition
  #           @logger.debug [d.inspect, ' seems to be an android device but is ',
  #                          'claimed by the uas kernel module. We will try to ',
  #                          'detach the kernel driver from the interface.'
  #                         ].join

  #           h.detach_kernel_driver(0)
  #           if oap_supported h
  #             d
  #           else
  #             h.attach_kernel_driver(0)
  #             nil
  #           end
  #         else # the device is not claimed
  #           d if oap_supported h
  #         end

  #       end
  #     end.compact

  #     # returns devices or nil if the list is empty
  #     devices.empty? ? nil : devices
  #   end

  #   # Switches an OAP compatible device to Accessory Mode.
  #   #
  #   # Prepare an OAP compatible device to interact with the virtual accessory:
  #   # * Propose to select a device in no one has already been selected
  #   # * Switch the current assigned device to accessory mode
  #   # * Set the I/O endpoints
  #   def switch_to_accessory_mode
  #     @logger.debug 'switch_to_accessory_mode'

  #     # If no device has already been selected, ask for a selection among the
  #     # compatible connected devices
  #     @device = select_device unless @device

  #     if @device
  #       @logger.debug "  device #{@device.serial_number}"

  #       # WIP
  #       if @device.idVendor == GOOGLE_VID
  #         # if the device is already in accessory mode, we send
  #         # set_configuration to force an usb attached event on the device
  #         begin
  #           set_configuration
  #         rescue LIBUSB::ERROR_NO_DEVICE
  #           @logger.debug '  set_configuration raises LIBUSB::ERROR_NO_DEVICE - Retry'
  #           sleep REENUMERATION_DELAY
  #           # Set configuration may fail
  #           retry
  #         end
  #       else
  #         # the device is not in accessory mode, start_accessory_mode is
  #         # sufficient to get an usb attached event on the device
  #         return false unless start_accessory_mode
  #       end
  #       ## END OF WIP

  #       # Find the in/out endpoints
  #       @device.interfaces.first.endpoints.each do |ep|
  #         if ep.bEndpointAddress & 0b10000000 == 0
  #           @out = ep if @out.nil?
  #         else
  #           @in = ep if @in.nil?
  #         end
  #       end
  #       true
  #     else
  #       @logger.debug 'No compatible device found'
  #       false
  #     end

  #   end

  #   # Non-blocking read method.
  #   #
  #   # To achieve the non-blocking behaviour, we ignore the `ERROR_TIMEOUT`
  #   # exception.
  #   #
  #   # @param [Fixnum] buffer_size
  #   #   The input data buffer size in bytes.
  #   # @param [Fixnum] timeout
  #   #   The timeout in ms.
  #   # @return [Fixnum, nil] The number of received bytes or nil.
  #   def read_nonblock(buffer_size, timeout = 100)
  #     begin
  #       out = handle.bulk_transfer(endpoint: @in,
  #                                  dataIn: buffer_size,
  #                                  timeout: timeout)
  #     rescue LIBUSB::ERROR_TIMEOUT
  #       nil
  #       # maybe we should implement a internal thread, a sleep and a retry
  #     end
  #   end

  #   # Simple read method.
  #   # @param [Fixnum] buffer_size
  #   #   The input data buffer size in bytes.
  #   # @param [Fixnum] timeout
  #   #   The timeout in ms.
  #   # @return [Fixnum, nil] The number of received bytes.
  #   def read(buffer_size, timeout = 1000)
  #     handle.bulk_transfer(endpoint: @in,
  #                          dataIn: buffer_size,
  #                          timeout: timeout)
  #   end

  #   # Simple write method.
  #   # @param [String] data
  #   #   The data to be sent.
  #   def write(data)
  #     # TODO: Add timeout param?
  #     handle.bulk_transfer(endpoint: @out, dataOut: data)
  #   end

  #   # All-in-One helper method to perform I/O.
  #   #
  #   # The setup and cleanup phases are automatically performed.
  #   #
  #   # @param [Proc] block
  #   #   A block containing I/O operations.
  #   # @yieldparam [LIBUSB::DevHandle] handle
  #   #   The handle onto perform I/O operations.
  #   #
  #   # @example Sample usage
  #   #
  #   #   begin
  #   #     m = Ligo::Accessory.new(fictitious_id)
  #   #
  #   #     m.discover_and_process do |handle|
  #   #       m.context.debug=3
  #   #
  #   #       puts <<-eof
  #   #
  #   #   The selected android device should now ask to switch to Accessory Mode.
  #   #   The default log file is /tmp/ligo.log.
  #   #   Once you have accepted: type some strings and send them to the selected device by hitting Enter
  #   #   (use Ctrl-C to quit):
  #   #
  #   #   eof
  #   #
  #   #       mutex = Mutex.new
  #   #
  #   #       reader_t = Thread.new do
  #   #         loop do
  #   #           res = nil
  #   #           mutex.synchronize do
  #   #             output_string = m.read_nonblock(500000)
  #   #             unless output_string.nil?
  #   #               puts "IN  -- String received: #{output_string}"
  #   #             end
  #   #           end
  #   #           sleep 0.2
  #   #         end
  #   #       end
  #   #
  #   #       writer_t = Thread.new do
  #   #         loop do
  #   #           if s = gets
  #   #             mutex.synchronize do
  #   #               bytes_sent = m.write(s)
  #   #               if bytes_sent == s.bytesize
  #   #                 puts "OUT -- String '#{s.chomp}' of size #{bytes_sent} bytes successfully sent"
  #   #               else
  #   #                 puts "OUT -- Error / String '#{s.chomp}' of size #{bytes_sent} bytes not successfully sent"
  #   #               end
  #   #             end
  #   #           end
  #   #         end
  #   #       end
  #   #
  #   #       reader_t.join
  #   #       writer_t.join
  #   #     end
  #   #
  #   #   rescue SystemExit, Interrupt => e
  #   #     puts "#{e.message} ⇒ Exit"
  #   #     Thread.list.each { |t| t.exit }
  #   #   end
  #   def discover_and_process(&block)
  #     if switch_to_accessory_mode
  #       begin
  #         @device.open_interface(0) do |handle|
  #           @handle = handle
  #           yield handle
  #           @handle = nil
  #         end
  #         close
  #       rescue LIBUSB::ERROR_NO_DEVICE
  #         msg =  'The target device has been disconnected'
  #         @logger.debug msg
  #         close
  #         raise Interrupt, msg
  #       end
  #     else
  #       raise Interrupt, 'No device found (check the log file)'
  #     end
  #   end

  #   # Opens and gets the current device handle (without claiming the
  #   #   associated interface).
  #   # @return [LIBUSB:DevHandle] the handle of the current selected device.
  #   def open
  #     @handle = @device.open
  #   end

  #   # A helper method to perform I/O.
  #   #
  #   # The currently associated device must have been properly opened (using
  #   #   {#open}).
  #   #
  #   # @param [Proc] block
  #   #   A block containing I/O operations.
  #   # @yieldparam [LIBUSB::DevHandle] handle
  #   #   The handle onto perform I/O operations.
  #   def process(&block)
  #     @handle.claim_interface(0) do
  #       yield @handle
  #     end
  #   end

  #   private

  #   def close
  #     @logger.debug 'close'
  #     @context.exit unless @context.nil?
  #   end

  #   # Send a 'Get Protocol' command to figure out if the device supports the
  #   # Android accessory protocol and returns either the version of the
  #   # protocol that the device supports or nil.
  #   #
  #   # @param [LIBUSB::DevHandle, nil] handle
  #   #   The input handle.
  #   # @return [Fixnum, nil] The version of the protocol that the device
  #   #   supports or nil.
  #   def get_protocol(handle = @handle)
  #     @logger.debug 'get_protocol'
  #     req_type = LIBUSB::ENDPOINT_IN | LIBUSB::REQUEST_TYPE_VENDOR
  #     res = handle.control_transfer(bmRequestType: req_type,
  #                                   bRequest: COMMAND_GETPROTOCOL,
  #                                   wValue: 0x0, wIndex: 0x0, dataIn: 2)
  #     version = res.unpack('S')[0]
  #     (res.size == 2 && version >= 1 ) ? version : nil
  #   end

  #   def oap_supported(handle = @handle)
  #     @logger.debug 'oap_supported'
  #     version = get_protocol(handle)
  #     @logger.info "#{handle.device.inspect} supports OAP version #{version}."

  #     version
  #   end

  #   def start_accessory_mode
  #     @logger.debug 'start_accessory_mode'
  #     serial_number = @device.serial_number

  #     @device.open_interface(0) do |handle|
  #       @handle = handle
  #       send_accessory_id
  #       send_start
  #       @handle = nil
  #     end

  #     sleep REENUMERATION_DELAY

  #     # The device should now reappear on the usb bus with the Google vendor id.
  #     # We retrieve it by using its serial number.
  #     @device = @context.devices(idVendor: GOOGLE_VID).collect do |d|
  #       d.serial_number == serial_number ? d : nil
  #     end.compact.first

  #     unless @device
  #       @logger.error ['Failed to retrieve the device after switching to ',
  #                      'accessory mode. This may be due to a lack of proper ',
  #                      'permissions ⇒ check your udev rules.', "\n",
  #                      'The Google vendor id rule may look like:', "\n",
  #                      'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ',
  #                      'MODE="0666", GROUP="plugdev"'
  #                     ].join
  #     end
  #     @device
  #   end


  #   def set_configuration
  #     @logger.debug 'set_configuration'
  #     res = nil
  #     serial_number = @device.serial_number
  #     @device = @context.devices(idVendor: GOOGLE_VID).collect do |d|
  #       d.serial_number == serial_number ? d : nil
  #     end.compact.first

  #     @device.open_interface(0) do |handle|
  #       req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_STANDARD
  #       res = handle.control_transfer(bmRequestType: req_type,
  #                                     bRequest: LIBUSB::REQUEST_SET_CONFIGURATION,
  #                                     wValue: 1, wIndex: 0x0, dataOut: nil)
  #     end

  #     sleep REENUMERATION_DELAY
  #     @device = @context.devices(idVendor: GOOGLE_VID).collect do |d|
  #       d.serial_number == serial_number ? d : nil
  #     end.compact.first
  #     res == 0
  #   end

  #   def select_device
  #     @logger.debug 'select_device'
  #     devices = compatible_devices
  #     if devices
  #       devices.each_with_index {|val, i| puts "#{i + 1} => #{val.inspect}" }
  #       index = nil
  #       until (1..devices.size).include? index
  #         print 'Select a device: '
  #         index = gets.chomp.to_i
  #         puts 'Please select a valid integer value!' unless (1..devices.size).include? index
  #       end

  #       @logger.debug "  Selected device: #{devices[index - 1].inspect}"
  #       devices[index - 1]
  #     else
  #       nil
  #     end
  #   end

  #   def send_accessory_id(id = @accessory_id)
  #     @logger.debug "send_accessory_id #{id.inspect}"
  #     req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_VENDOR
  #     id.each do |k,v|
  #       # Ensure the string is terminated by a null char
  #       s = "#{v}\0"
  #       r = @handle.control_transfer(bmRequestType: req_type,
  #                                    bRequest: COMMAND_SENDSTRING, wValue: 0x0,
  #                                    wIndex: id.keys.index(k), dataOut: s)

  #       # TODO: Manage an exception there. This should terminate the program.
  #       @logger.error "Failed to send #{k} string:" unless r == s.size
  #     end
  #   end

  #   def send_start
  #     req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_VENDOR
  #     res = @handle.control_transfer(bmRequestType: req_type,
  #                                    bRequest: COMMAND_START, wValue: 0x0,
  #                                    wIndex: 0x0, dataOut: nil)
  #   end

  # end # class Accessory

end
