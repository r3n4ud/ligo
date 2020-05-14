<!--- coding: utf-8; fill-column: 80 --->
# ![ligō](https://github.com/r3n4ud/ligo-logos/raw/master/logo/ligo.png)

[![Dependency Status](https://gemnasium.com/r3n4ud/ligo.png)](https://gemnasium.com/r3n4ud/ligo)
[![Code Climate](https://codeclimate.com/github/r3n4ud/ligo.png)](https://codeclimate.com/github/r3n4ud/ligo)

* [Homepage](https://github.com/r3n4ud/ligo#readme)
* [Issues](https://github.com/r3n4ud/ligo/issues)
* [Documentation](http://rubydoc.info/gems/ligo/frames)
* [Email](mailto:root at renaud.io)

## Description

ligō is a ruby gem implementing the
[Android Open Accessory Protocol](http://source.android.com/tech/accessories/aoap/aoa.html)
to interact with Android devices via USB.

Android-side application is needed to make some use of this project. A
[sample LigoTextDemo Android application](https://github.com/r3n4ud/LigoTextDemo)
is available for usage demonstration.

## Features

Just USB I/O using the Android Open Accessory Protocol…

## Examples

```ruby
require 'ligo'

id = {
  manufacturer: 'Ligo',
  model:        'VirtualAccessory',
  description:  'PC acts as an accessory!',
  version:      '0.1',
  uri:          'http://blog.renaud.io',
  serial:       '3678000012345678'
}

Ligo::Logging.configure_logger_output('/tmp/ligo-sample.log')
ctx = Ligo::Context.new
acc = Ligo::Accessory.new(id)

# You could inspect the Android devices list
puts ctx.devices.inspect

# Take the first one
dev = ctx.devices.first

# Switch the Android device to accessory mode
success = dev.attach_accessory(acc)

# then operate on the device (you'll need some Android code for this!)
if success
  dev.process do |handle|
    # I/O
  end
end
```

## Requirements

ligō will be nothing without the
[LIBUSB Ruby binding](https://github.com/larskanis/libusb) and the underlying
[libusb](http://libusbx.org/) library.

At the time of writing, ligō focuses on the GNU/Linux operating system and
YARV/MRI ruby. ligō has been developed and tested on Debian GNU/Linux with ruby
1.9.3p327 and 1.9.3p429.

ligō is useless without Android-side application. A
[sample LigoTextDemo Android application](https://github.com/r3n4ud/LigoTextDemo)
is available for usage demonstration.

## Install

You may install ligō by using:

    $ gem install ligo

Or, you can install it from the github repository:

    $ git clone https://github.com/r3n4ud/ligo.git
    $ cd ligo
    $ rake install


## Pending tasks

* Write the specs and automate testing!
* ~~Provide an Android demo application~~ → See
  [sample LigoTextDemo Android application](https://github.com/r3n4ud/LigoTextDemo),
  more to come soon…
* Improve the documentation → in progress, a first pass has been made…
* ~~Release and push the gem to rubygems.org~~
* Finalize and publish a [celluloid](https://github.com/celluloid/celluloid)-based write-back usage
  sample (already working with the
  [sample LigoTextDemo Android application](https://github.com/r3n4ud/LigoTextDemo) and the
  [libusb 0.3.0 gem](https://github.com/larskanis/libusb) async and polling APIs)
* Create a wiki with FAQ, supported devices listing, UMS/accessory interactions, etc.

## Contributing to ligō

* Follow the usual fork/branch/PR workflow to send changes, if I like them I'll merge them
* Help me to create a supported device listing

## Copyright

Copyright (c) 2012, 2013 Renaud AUBIN

See {file:LICENSE.txt} for details.
