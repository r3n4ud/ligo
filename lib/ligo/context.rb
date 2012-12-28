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

  # This class is a derivative work of `LIBUSB::Context` as included in
  #   [LIBUSB](https://github.com/larskanis/libusb), written by Lars Kanis and
  #   released under the LGPLv3.
  # @author Renaud AUBIN
  # @api public
  class Context < LIBUSB::Context
    include LIBUSB

    # @api private
    # Returns the list of AOAP-compatible devices
    # @return [Array<Ligo::Device>] the list of AOAP-compatible devices
    #   currently connected on the USB bus.
    def device_list
      pppDevs = FFI::MemoryPointer.new :pointer
      size = Call.libusb_get_device_list(@ctx, pppDevs)
      ppDevs = pppDevs.read_pointer
      pDevs = []
      size.times do |devi|
        pDev = ppDevs.get_pointer(devi*FFI.type_size(:pointer))
        # Use Ligo::Device instead of LIBUSB::Device
        device = Ligo::Device.new(self, pDev)
        if VENDOR_IDS.include?(device.idVendor)
          begin
            # Include only AOAP compatible devices
            pDevs << device if device.aoap?
          rescue LIBUSB::ERROR_ACCESS
            # @todo Do something about this exception, log at least!
          end
        end
      end
      Call.libusb_free_device_list(ppDevs, 1)
      pDevs
    end
    private :device_list
  end

end
