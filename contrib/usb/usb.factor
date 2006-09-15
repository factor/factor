! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: usb
USING: kernel alien io math ;

LIBRARY: usb

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
