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

# TODO: Add a proper mention to libusb LGPL licensing since the following code
# is a derivative work of Lars Kanis LIBUSB::Context.

module Ligo

  class Context < LIBUSB::Context
    include LIBUSB

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
            # TODO: do something about this exception, log at least!
          end
        end
      end
      Call.libusb_free_device_list(ppDevs, 1)
      pDevs
    end
    private :device_list
  end

end
