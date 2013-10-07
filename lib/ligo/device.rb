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

  require 'ligo/constants'

  # This class provides a convenient wrapper class around `LIBUSB::Device` and
  #   implements the Android Open Accessory Protocol to interact with compatible
  #   devices.
  #
  # This class is a derivative work of `LIBUSB::Device` as included in
  #   [LIBUSB](https://github.com/larskanis/libusb), written by Lars Kanis and
  #   released under the LGPLv3.
  # @author Renaud AUBIN
  # @api public
  class Device < LIBUSB::Device
    include Logging

    # @api private
    attr_reader :pDev

    # @api private
    attr_reader :pDevDesc

    # Returns the version of the AOA protocol that this device supports
    # @return [Fixnum] the version of the AOA protocol that this device
    #   supports.
    attr_reader :aoap_version

    # Returns the associated {Accessory}
    # @return [Accessory, nil] the associated accessory if any or nil.
    attr_reader :accessory

    # Returns the accessory mode input endpoint
    # @return [LIBUSB::Endpoint, nil] the input endpoint or nil if the device is
    #   not in accessory mode.
    attr_reader :in

    # Returns the accessory mode output endpoint
    # @return [LIBUSB::Endpoint, nil] the output endpoint or nil if the device
    #   is not in accessory mode.
    attr_reader :out

    # Returns the device handle
    # @todo Improve the :handle doc
    # @return [LIBUSB::DevHandle, nil] the device handle or nil.
    attr_reader :handle

    # @api private
    def initialize context, pDev
      @aoap_version = 0
      @accessory, @in, @out, @handle = nil, nil, nil, nil
      super context, pDev
    end

    def process(&block)
      begin
        self.open_interface(0) do |handle|
          @handle = handle
          yield handle
          @handle = nil
        end
        # close
      rescue LIBUSB::ERROR_NO_DEVICE
        msg =  'The target device has been disconnected'
        logger.debug msg
        # close
        raise Interrupt, msg
      end
    end

    # Opens an handle and claim the default interface for further operations
    # @return [LIBUSB::DevHandle] the handle to operate on.
    # @raise
    def open_and_claim
      @handle = open
      @handle.claim_interface(0)
      @handle.clear_halt(@in)
      @handle
    end

    # Finalizes the device (release and close)
    # @return
    # @raise [LIBUSB::ERROR_TIMEOUT] in case of timeout.
    def finalize
      if @handle
        @handle.release_interface(0)
        @handle.close
      end
    end

    # Simple write method (blocking until timeout)
    # @param [Fixnum] buffer_size
    #   The number of bytes expected to be received.
    # @param [Fixnum] timeout
    #   The timeout in ms (default: 1000). 0 for an infinite timeout.
    # @return [String] the received buffer (at most buffer_size bytes).
    # @raise [LIBUSB::ERROR_TIMEOUT] in case of timeout.
    def read(buffer_size, timeout = 1000)
      handle.bulk_transfer(endpoint: @in,
                           dataIn: buffer_size,
                           timeout: timeout)
    end
    alias_method :recv, :read

    # Simple write method (blocking until timeout)
    # @param [String] buffer
    #   The buffer to be sent.
    # @param [Fixnum] timeout
    #   The timeout in ms (default: 1000). 0 for an infinite timeout.
    # @return [Fixnum] the number of bytes actually sent.
    # @raise [LIBUSB::ERROR_TIMEOUT] in case of timeout.
    def write(buffer, timeout = 1000)
        handle.bulk_transfer(endpoint: @out,
                             dataOut: buffer,
                             timeout: timeout)
    end
    alias_method :send, :write

    # Associates with an accessory and switch to accessory mode
    #
    # Prepare an OAP compatible device to interact with a given {Ligo::Accessory}:
    # * Switch the current assigned device to accessory mode
    # * Set the I/O endpoints
    # @param [Ligo::Accessory] accessory
    #   The virtual accessory to be associated with the Android device.
    # @return [true, false] true for success, false otherwise.
    def attach_accessory(accessory)
      logger.debug "attach_accessory(#{accessory})"

      @accessory = accessory

      if accessory_mode?
        # if the device is already in accessory mode, we send
        # set_configuration to force an usb attached event on the device
        begin
          set_configuration
        rescue LIBUSB::ERROR_NO_DEVICE
          logger.debug '  set_configuration raises LIBUSB::ERROR_NO_DEVICE - Retry'
          sleep REENUMERATION_DELAY
          # Set configuration may fail
          retry
        end
      else
        # the device is not in accessory mode, start_accessory_mode is
        # sufficient to get an usb attached event on the device
        return false unless start_accessory_mode
      end

      # Find out the in/out endpoints
      self.interfaces.first.endpoints.each do |ep|
        if ep.bEndpointAddress & 0b10000000 == 0
          @out = ep if @out.nil?
        else
          @in = ep if @in.nil?
        end
      end
      true
    end

    # Switches to accessory mode
    #
    # Send identifying string information to the device and request the device start up in accessory
    # mode.
    # @return [true, false] true for success, false otherwise.
    def start_accessory_mode
      logger.debug 'start_accessory_mode'
      sn = self.serial_number

      # First simple win support for my GNexus, MTP is the first interface. As a
      # consequence, we use the second one.
      # TODO: improve interface detection (rescue LIBUSB_NOT_SUPPORTED on
      # open_interface?)
      interface_num = case Ligo.os
                      when :windows
                        1
                      else
                        0
                      end

      self.open_interface(interface_num) do |handle|
        @handle = handle
        send_accessory_id
        send_start
        @handle = nil
      end

      # On Windows, a GNexus in accessory mode presents the Android Accessory
      # Interface as the very first interface (i.e. 0).

      wait_and_retrieve_by_serial(sn)
    end

    # Sends a `set configuration` control transfer
    #
    # Set the device's configuration to a value of 1 with a SET_CONFIGURATION (0x09) device
    # request.
    # @return [true, false] true for success, false otherwise.
    def set_configuration
      logger.debug 'set_configuration'
      res = nil
      sn = self.serial_number
      device = get_device(sn)

      begin
        device.open_interface(0) do |handle|
          req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_STANDARD
          res = handle.control_transfer(bmRequestType: req_type,
                                        bRequest: LIBUSB::REQUEST_SET_CONFIGURATION,
                                        wValue: 1, wIndex: 0x0, dataOut: nil)
        end

        wait_and_retrieve_by_serial(sn)
        res == 0
      end
    end

    # Check if the current {Device} is in accessory mode
    # @return [true, false] true if the {Device} is in accessory mode, false
    #   otherwise.
    def accessory_mode?
      (self.idVendor == GOOGLE_VID) && (GOOGLE_PIDS.include? self.idProduct)
    end

    # Check if the current {Device} supports AOAP
    # @return [true, false] true if the {Ligo::Device} supports AOAP, false
    #   otherwise.
    def aoap?
      @aoap_version = self.get_protocol
      logger.info "#{self.inspect} supports AOAP version #{@aoap_version}."
      @aoap_version >= 1
    end

    # Check if the current {Device} is in UMS mode
    # @return [true, false] true if the {Device} is in UMS mode, false otherwise
    def uas?
      if RUBY_PLATFORM=~/linux/i
        # http://cateee.net/lkddb/web-lkddb/USB_UAS.html
        (self.settings[0].bInterfaceClass == 0x08) &&
          (self.settings[0].bInterfaceSubClass == 0x06)
      else
        false
      end
    end

    # Sends a `get protocol` control transfer
    #
    # Send a 51 control request ("Get Protocol") to figure out if the device
    #   supports the Android accessory protocol. We assume here that the device
    #   has not been opened.
    # @return [Fixnum] the AOAP protocol version supported by the device (0 for
    #   no AOAP support).
    def get_protocol
      logger.debug 'get_protocol'
      res, version = 0, 0
      self.open do |h|

        h.detach_kernel_driver(0) if self.uas? && h.kernel_driver_active?(0)
        req_type = LIBUSB::ENDPOINT_IN | LIBUSB::REQUEST_TYPE_VENDOR
        res = h.control_transfer(bmRequestType: req_type,
                                 bRequest: COMMAND_GETPROTOCOL,
                                 wValue: 0x0, wIndex: 0x0, dataIn: 2)

        version = res.unpack('S')[0]
      end

      (res.size == 2 && version >= 1 ) ? version : 0
    rescue LIBUSB::ERROR_NOT_SUPPORTED
      0
    end

    # Sends identifying string information to the device
    #
    # We assume here that the device has already been opened.
    # @api private
    # @return
    def send_accessory_id
      logger.debug 'send_accessory_id'
      req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_VENDOR
      @accessory.each do |k,v|
        # Ensure the string is terminated by a null char
        s = "#{v}\0"
        r = @handle.control_transfer(bmRequestType: req_type,
                                     bRequest: COMMAND_SENDSTRING, wValue: 0x0,
                                     wIndex: @accessory.keys.index(k), dataOut: s)

        # TODO: Manage an exception there. This should terminate the program.
        logger.error "Failed to send #{k} string" unless r == s.size
      end
    end
    private :send_accessory_id

    # Sends AOA protocol start command to the device
    # @api private
    # @return [Fixnum]
    def send_start
      logger.debug 'send_start'
      req_type = LIBUSB::ENDPOINT_OUT | LIBUSB::REQUEST_TYPE_VENDOR
      res = @handle.control_transfer(bmRequestType: req_type,
                                     bRequest: COMMAND_START, wValue: 0x0,
                                     wIndex: 0x0, dataOut: nil)
    end
    private :send_start

    # Retrieves an AOAP device by its serial number
    # @api private
    # @param [String] sn
    #   The serial number of the device to be found.
    # @return [LIBUSB::Device] the device matching the given serial number.
    def get_device(sn)
      device = @context.devices(idVendor: GOOGLE_VID).collect do |d|
        d.serial_number == sn ? d : nil
      end.compact.first
    end

    # @api private
    # @return [true, false] true for success, false otherwise.
    def wait_and_retrieve_by_serial(sn)
      sleep REENUMERATION_DELAY
      # The device should now reappear on the usb bus with the Google vendor id.
      # We retrieve it by using its serial number.
      device = get_device(sn)

      if device
        # Retrieve new pointers (check if the old ones should be dereferenced)
        @pDev = device.pDev
        @pDevDesc = device.pDevDesc
        true
      else
        logger.error ['Failed to retrieve the device after switching to ',
                      'accessory mode. This may be due to a lack of proper ',
                      'permissions ⇒ check your udev rules.', "\n",
                      'The Google vendor id rule may look like:', "\n",
                      'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ',
                      'MODE="0666", GROUP="plugdev"'
                     ].join
        false
      end
    end
    private :wait_and_retrieve_by_serial

  end

end
