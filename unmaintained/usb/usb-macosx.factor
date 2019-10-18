! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: usb
USING: kernel alien ;

"usb" "libusb.dylib" "cdecl" add-library

LIBRARY: usb

C-STRUCT: usb_bus
    { "void*" "next" }
    { "void*" "prev" }
    { { "char" 1025 } "dirname" }
    { "void*" "devices" }
    { "uint" "location" }
    { "void*" "root_dev" } ;

C-STRUCT: usb_device_descriptor
    { +packed+ "uchar" "bLength" }
    { +packed+ "uchar" "bDescriptorType" }
    { +packed+ "ushort" "bcdUSB" }
    { +packed+ "uchar" "bDeviceClass" }
    { +packed+ "uchar" "bDeviceSubClass" }
    { +packed+ "uchar" "bDeviceProtocol" }
    { +packed+ "uchar" "bMaxPacketSize0" }
    { +packed+ "ushort" "idVendor" }
    { +packed+ "ushort" "idProduct" }
    { +packed+ "ushort" "bcdDevice;" }
    { +packed+ "uchar" "iManufacturer" }
    { +packed+ "uchar" "iProduct" }
    { +packed+ "uchar" "iSerialNumber" }
    { +packed+ "uchar" "bNumConfigurations" } ;

C-STRUCT: usb_config_descriptor
    { +packed+ "uchar" "bLength" }
    { +packed+ "uchar" "bDescriptorType" }
    { +packed+ "ushort" "wTotalLength" }
    { +packed+ "uchar" "bNumInterfaces" }
    { +packed+ "uchar" "bConfigurationValue" }
    { +packed+ "uchar" "iConfiguration" }
    { +packed+ "uchar" "bmAttributes" }
    { +packed+ "uchar" "MaxPower" }
    
    { "void*" "interface" }
    
    { "uchar*" "extra" }
    { "int" "extralen" } ;

C-STRUCT: usb_device
    { "void*" "next" }
    { "void*" "prev" }
    { { "char" 1025 } "filename" }
    { "usb_bus*" "bus" }
    { "usb_device_descriptor" "descriptor" }
    { "usb_config_descriptor*" "config" }
    { "void*" "dev" }
    { "uchar" "devnum" }
    { "uchar" "num_children" }
    { "void*" "children" } ;

