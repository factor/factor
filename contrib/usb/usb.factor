! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! TODO: Windows path = 260
!       fpathconf under linux?
!
IN: usb
USING: kernel alien io math namespaces sequences parser ;

"usb" windows? [ "libusb.dll" ] [ "libusb.so" ] if "cdecl" add-library

: define-packed-field ( offset type name -- offset )
    >r parse-c-decl 
    >r 1 r> 
    >r swapd align r> r> 
    "struct-name" get swap "-" swap append3
    3dup define-getter 3dup define-setter
    drop c-size rot * + ;

: PACKED-FIELD: ( offset -- offset )
  scan scan define-packed-field ; parsing

LIBRARY: usb

BEGIN-STRUCT: usb_bus
  FIELD: void*      next
  FIELD: void*      prev	
  FIELD: char[4097] dirname
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
  FIELD: char[4097] filename
  FIELD: usb_bus* bus
  FIELD: usb_device_descriptor descriptor
  FIELD: usb_config_descriptor* config
  FIELD: void* dev
  FIELD: uchar devnum
  FIELD: uchar num_children
  FIELD: void* children
END-STRUCT

TYPEDEF: void* usb_dev_handle*

FUNCTION: usb_dev_handle* usb_open ( usb_device* dev ) ;
FUNCTION: int usb_close ( usb_dev_handle* dev ) ;
FUNCTION: int usb_get_string ( usb_dev_handle* dev, int index, int langid, char *buf, int buflen ) ;
FUNCTION: int usb_get_string_simple ( usb_dev_handle* dev, int index, char* buf, int buflen ) ;

FUNCTION: int usb_get_descriptor_by_endpoint ( usb_dev_handle* udev, int ep, uchar type, uchar index, void* buf, int size ) ;
FUNCTION: int usb_get_descriptor ( usb_dev_handle* udev, uchar type, uchar index, void* buf, int size ) ;

FUNCTION: int usb_bulk_write ( usb_dev_handle* dev, int ep, char* bytes, int size, int timeout ) ;
FUNCTION: int usb_bulk_read ( usb_dev_handle* dev, int ep, char* bytes, int size, int timeout ) ;
FUNCTION: int usb_interrupt_write ( usb_dev_handle* dev, int ep, char* bytes, int size, int timeout ) ;
FUNCTION: int usb_interrupt_read ( usb_dev_handle* dev, int ep, char* bytes, int size, int timeout ) ;
FUNCTION: int usb_control_msg ( usb_dev_handle* dev, int requesttype, int request, int value, int index, char* bytes, int size, int timeout ) ;
FUNCTION: int usb_set_configuration ( usb_dev_handle* dev, int configuration ) ;
FUNCTION: int usb_claim_interface ( usb_dev_handle* dev, int interface ) ;
FUNCTION: int usb_release_interface ( usb_dev_handle* dev, int interface ) ;
FUNCTION: int usb_set_altinterface ( usb_dev_handle* dev, int alternate ) ;
FUNCTION: int usb_resetep ( usb_dev_handle* dev, uint ep ) ;
FUNCTION: int usb_clear_halt ( usb_dev_handle* dev, uint ep ) ;
FUNCTION: int usb_reset ( usb_dev_handle* dev ) ;
FUNCTION: int usb_get_driver_np ( usb_dev_handle* dev, int interface, char* name, uint namelen ) ;
FUNCTION: char* usb_strerror ( ) ;

FUNCTION: void usb_init ( ) ;
FUNCTION: void usb_set_debug ( int level ) ;
FUNCTION: int usb_find_busses (  ) ;
FUNCTION: int usb_find_devices ( ) ;
FUNCTION: usb_device* usb_device ( usb_dev_handle* dev ) ;
FUNCTION: usb_bus* usb_get_busses ( ) ;


: t1 ( -- string )
  usb_find_busses drop usb_find_devices drop usb_get_busses usb_bus-dirname ;

: ((t2)) ( device -- )
  terpri
  [
    "  " write
    dup usb_device-filename write 
    " - " write dup usb_device-descriptor usb_device_descriptor-bLength number>string write 
    " - " write dup usb_device-descriptor usb_device_descriptor-idVendor >hex write 
    " - " write usb_device-descriptor usb_device_descriptor-idProduct >hex write 
  ] when* ;

: (t2) ( bus -- )
  [
    dup usb_bus-dirname write " - " write 
    dup usb_bus-devices ((t2))
    terpri
    usb_bus-next (t2) 
  ] when* ;

: t2 ( -- )
  usb_get_busses (t2) ;
