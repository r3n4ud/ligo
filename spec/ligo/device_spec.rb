require 'spec_helper'

# Assumption: two devices are connected on the usb bus and not yet in accessory
# mode. Those devices are a Galaxy Nexus running 4.2 AOSP and a HTC Flyer
# running 3.2 (with UMS support).

describe Ligo::Device do
  before(:all) do
    @default_accessory = Ligo::Accessory.new
    ctx = Ligo::Context.new
    @gnexus = ctx.devices(idVendor: 0x04e8).first
    @flyer  = ctx.devices(idVendor: 0x0bb4).first
  end

  it 'should derive from LIBUSB::Device' do
    Ligo::Device.superclass.should be LIBUSB::Device
  end

  context 'when passing the Galaxy Nexus to accessory mode' do
    specify { @gnexus.should_not be_accessory_mode }
    specify { @gnexus.idVendor.should  be 0x04e8 }
    specify { @gnexus.idProduct.should be 0x6860 }
    specify { @gnexus.should be_aoap }
    specify { @gnexus.should_not be_uas }
    specify { @gnexus.aoap_version.should be 2 }
    # Now, the order matters!
    specify { @gnexus.attach_accessory(@default_accessory).should be true }
    specify { @gnexus.idVendor.should be 0x18d1 }
    specify { Ligo::GOOGLE_PIDS.should include @gnexus.idProduct }
  end

  context 'when passing the Flyer to accessory mode' do
    specify { @flyer.should_not be_accessory_mode }
    specify { @flyer.idVendor.should  be 0x0bb4 }
    specify { @flyer.idProduct.should be 0x0ca9 }
    specify { @flyer.should be_aoap }
    specify { @flyer.should be_uas }
    specify { @flyer.aoap_version.should be 1 }
    # Now, the order matters!
    specify { @flyer.attach_accessory(@default_accessory).should be true }
    specify { @flyer.idVendor.should be 0x18d1 }
    specify { Ligo::GOOGLE_PIDS.should include @flyer.idProduct }
  end

end
