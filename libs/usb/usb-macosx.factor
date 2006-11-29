! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: usb
USING: kernel alien ;

"usb" "/opt/local/lib/libusb.dylib" "cdecl" add-library

LIBRARY: usb

BEGIN-STRUCT: usb_bus
  FIELD: void*      next
  FIELD: void*      prev	
  FIELD: char[1025] dirname
  FIELD: void*      devices
  FIELD: uint       location
  FIELD: void*      root_dev
END-STRUCT

! __attribute__ ((packed))
BEGIN-STRUCT: usb_device_descriptor
  PACKED-FIELD: uchar bLength
  PACKED-FIELD: uchar bDescriptorType
  PACKED-FIELD: ushort bcdUSB
  PACKED-FIELD: uchar  bDeviceClass
  PACKED-FIELD: uchar  bDeviceSubClass
  PACKED-FIELD: uchar  bDeviceProtocol
  PACKED-FIELD: uchar  bMaxPacketSize0
  PACKED-FIELD: ushort idVendor
  PACKED-FIELD: ushort idProduct
  PACKED-FIELD: ushort bcdDevice;
  PACKED-FIELD: uchar  iManufacturer
  PACKED-FIELD: uchar  iProduct
  PACKED-FIELD: uchar  iSerialNumber
  PACKED-FIELD: uchar  bNumConfigurations
END-STRUCT

BEGIN-STRUCT: usb_config_descriptor
  PACKED-FIELD: uchar  bLength ! __attribute__ ((packed))
  PACKED-FIELD: uchar  bDescriptorType ! __attribute__ ((packed))
  PACKED-FIELD: ushort wTotalLength ! __attribute__ ((packed))
  PACKED-FIELD: uchar  bNumInterfaces !  __attribute__ ((packed))
  PACKED-FIELD: uchar  bConfigurationValue ! __attribute__ ((packed))
  PACKED-FIELD: uchar  iConfiguration ! __attribute__ ((packed))
  PACKED-FIELD: uchar  bmAttributes ! __attribute__ ((packed))
  PACKED-FIELD: uchar  MaxPower ! __attribute__ ((packed))

  FIELD: void*  interface

  FIELD: uchar* extra
  FIELD: int extralen
END-STRUCT

BEGIN-STRUCT: usb_device
  FIELD: void* next
  FIELD: void* prev
  FIELD: char[1025] filename
  FIELD: usb_bus* bus
  FIELD: usb_device_descriptor descriptor
  FIELD: usb_config_descriptor* config
  FIELD: void* dev
  FIELD: uchar devnum
  FIELD: uchar num_children
  FIELD: void* children
END-STRUCT

