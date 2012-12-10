require 'spec_helper'

# Assumption: two devices are connected on the usb bus and not yet in accessory
# mode. Those devices are a Galaxy Nexus running 4.2 AOSP and a HTC Flyer
# running 3.2 (with UMS support).

describe Ligo::Context do
  it "should derive from LIBUSB::Context" do
    subject.class.superclass.should be LIBUSB::Context
  end

  describe "#devices" do
    it "should return an Array" do
      subject.devices.class.should be Array
    end
    it "should return 2 devices" do
      subject.devices.size.should equal 2
    end
  end

end
