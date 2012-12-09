<!--- coding: utf-8; fill-column: 80 --->
# ligō

* [Homepage](https://github.com/nibua-r/ligo#readme)
* [Issues](https://github.com/nibua-r/ligo/issues)
* [Documentation](http://rubydoc.info/gems/ligo/frames)
* [Email](mailto:root at renaud.io)

## Description

ligō is a ruby gem implementing the
[Android Open Accessory Protocol](http://source.android.com/tech/accessories/aoap/aoa.html)
to interact with Android devices via USB.

Android-side application is needed to make some use of this project.
A sample LigoTextDemo Android application will be released soon.

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

# You could inpect the Android devices list
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
1.9.3p327.

ligō is useless without Android-side application. A sample LigoTextDemo Android
application will be released soon to demonstrate the use of that gem.

## Install

ligō is currently under developement, as a consequence you'll need to live on the edge:

    $ git clone https://github.com/nibua-r/ligo.git
    $ cd ligo
    $ rake install

As soon as the ligō gem is released, you shall install by using:

    $ gem install ligo

## Pending tasks

* Write the specs and automate testing!
* Provide an Android demo application
* Improve the documentation
* Release and push the gem to rubygems.org

## Copyright

Copyright (c) 2012 Renaud AUBIN

See {file:LICENSE.txt} for details.
