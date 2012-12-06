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

  # Android devices Vendor Ids
  # @see android source code system/core/adb/usb_vendor.c
  VENDOR_IDS = [
                GOOGLE_VID          = 0x18d1,
                INTEL_VID           = 0x8087,
                HTC_VID             = 0x0bb4,
                SAMSUNG_VID         = 0x04e8,
                MOTOROLA_VID        = 0x22b8,
                LGE_VID             = 0x1004,
                HUAWEI_VID          = 0x12D1,
                ACER_VID            = 0x0502,
                SONY_ERICSSON_VID   = 0x0FCE,
                FOXCONN_VID         = 0x0489,
                DELL_VID            = 0x413c,
                NVIDIA_VID          = 0x0955,
                GARMIN_ASUS_VID     = 0x091E,
                SHARP_VID           = 0x04dd,
                ZTE_VID             = 0x19D2,
                KYOCERA_VID         = 0x0482,
                PANTECH_VID         = 0x10A9,
                QUALCOMM_VID        = 0x05c6,
                OTGV_VID            = 0x2257,
                NEC_VID             = 0x0409,
                PMC_VID             = 0x04DA,
                TOSHIBA_VID         = 0x0930,
                SK_TELESYS_VID      = 0x1F53,
                KT_TECH_VID         = 0x2116,
                ASUS_VID            = 0x0b05,
                PHILIPS_VID         = 0x0471,
                TI_VID              = 0x0451,
                FUNAI_VID           = 0x0F1C,
                GIGABYTE_VID        = 0x0414,
                IRIVER_VID          = 0x2420,
                COMPAL_VID          = 0x1219,
                T_AND_A_VID         = 0x1BBB,
                LENOVOMOBILE_VID    = 0x2006,
                LENOVO_VID          = 0x17EF,
                VIZIO_VID           = 0xE040,
                K_TOUCH_VID         = 0x24E3,
                PEGATRON_VID        = 0x1D4D,
                ARCHOS_VID          = 0x0E79,
                POSITIVO_VID        = 0x1662,
                FUJITSU_VID         = 0x04C5,
                LUMIGON_VID         = 0x25E3,
                QUANTA_VID          = 0x0408,
                INQ_MOBILE_VID      = 0x2314,
                SONY_VID            = 0x054C,
                YULONG_COOLPAD_VID  = 0x1EBF
               ]

  # Accessory Protocol allowed product ids
  GOOGLE_PIDS = *(0x2d00..0x2d05)

  ## Accessory Protocol Commands
  # Accessory Protocol "Get Protocol" command
  COMMAND_GETPROTOCOL = 51
  # Accessory Protocol "Send Id String" command
  COMMAND_SENDSTRING  = 52
  # Accessory Protocol "Accessory Mode Start Up" commands
  COMMAND_START       = 53

  # USB reenumeration delay in seconds
  REENUMERATION_DELAY = 1

end
