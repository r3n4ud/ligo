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

require 'logger'
require 'libusb'

require 'ligo/version'

# This module contains the Android Open Accessory Protocol utility classes to
# enable custom USB I/O with AOAP-compatible devices.
#
# @see http://source.android.com/tech/accessories/index.html
# @see http://source.android.com/tech/accessories/aoap/aoa.html
# @see
#  http://developer.android.com/guide/topics/connectivity/usb/accessory.html
# @author Renaud AUBIN
module Ligo
  require 'ligo/logging'
  require 'ligo/constants'
  require 'ligo/accessory'
  require 'ligo/context'
  require 'ligo/device'
end
