! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax classes.struct combinators endian
kernel locals math sequences specialized-arrays
system unix.time unix.types ;
IN: libusb

C-LIBRARY: libusb cdecl {
    { windows "libusb-1.0.dll" }
    { macos "libusb-1.0.dylib" }
    { unix "libusb-1.0.so" }
}

LIBRARY: libusb

: libusb_cpu_to_le16 ( x -- y )
    2 >native-endian le> ; inline

ALIAS: libusb_le16_to_cpu libusb_cpu_to_le16

ENUM: libusb_class_code
    { LIBUSB_CLASS_PER_INTERFACE 0 }
    { LIBUSB_CLASS_AUDIO         1 }
    { LIBUSB_CLASS_COMM          2 }
    { LIBUSB_CLASS_HID           3 }
    { LIBUSB_CLASS_PRINTER       7 }
    { LIBUSB_CLASS_PTP           6 }
    { LIBUSB_CLASS_MASS_STORAGE  8 }
    { LIBUSB_CLASS_HUB           9 }
    { LIBUSB_CLASS_DATA          10 }
    { LIBUSB_CLASS_VENDOR_SPEC 0xff } ;

ENUM: libusb_descriptor_type
    { LIBUSB_DT_DEVICE    0x01 }
    { LIBUSB_DT_CONFIG    0x02 }
    { LIBUSB_DT_STRING    0x03 }
    { LIBUSB_DT_INTERFACE 0x04 }
    { LIBUSB_DT_ENDPOINT  0x05 }
    { LIBUSB_DT_HID       0x21 }
    { LIBUSB_DT_REPORT    0x22 }
    { LIBUSB_DT_PHYSICAL  0x23 }
    { LIBUSB_DT_HUB       0x29 } ;

CONSTANT: LIBUSB_DT_DEVICE_SIZE           18
CONSTANT: LIBUSB_DT_CONFIG_SIZE           9
CONSTANT: LIBUSB_DT_INTERFACE_SIZE        9
CONSTANT: LIBUSB_DT_ENDPOINT_SIZE         7
CONSTANT: LIBUSB_DT_ENDPOINT_AUDIO_SIZE   9
CONSTANT: LIBUSB_DT_HUB_NONVAR_SIZE       7

CONSTANT: LIBUSB_ENDPOINT_ADDRESS_MASK    0x0f
CONSTANT: LIBUSB_ENDPOINT_DIR_MASK        0x80

ENUM: libusb_endpoint_direction
    { LIBUSB_ENDPOINT_IN  0x80 }
    { LIBUSB_ENDPOINT_OUT 0x00 } ;

CONSTANT: LIBUSB_TRANSFER_TYPE_MASK 0x03

ENUM: libusb_transfer_type
    { LIBUSB_TRANSFER_TYPE_CONTROL     0 }
    { LIBUSB_TRANSFER_TYPE_ISOCHRONOUS 1 }
    { LIBUSB_TRANSFER_TYPE_BULK        2 }
    { LIBUSB_TRANSFER_TYPE_INTERRUPT   3 } ;

ENUM: libusb_standard_request
    { LIBUSB_REQUEST_GET_STATUS        0x00 }
    { LIBUSB_REQUEST_CLEAR_FEATURE     0x01 }
    { LIBUSB_REQUEST_SET_FEATURE       0x03 }
    { LIBUSB_REQUEST_SET_ADDRESS       0x05 }
    { LIBUSB_REQUEST_GET_DESCRIPTOR    0x06 }
    { LIBUSB_REQUEST_SET_DESCRIPTOR    0x07 }
    { LIBUSB_REQUEST_GET_CONFIGURATION 0x08 }
    { LIBUSB_REQUEST_SET_CONFIGURATION 0x09 }
    { LIBUSB_REQUEST_GET_INTERFACE     0x0A }
    { LIBUSB_REQUEST_SET_INTERFACE     0x0B }
    { LIBUSB_REQUEST_SYNCH_FRAME       0x0C } ;

ENUM: libusb_request_type
    { LIBUSB_REQUEST_TYPE_STANDARD 0x00 }
    { LIBUSB_REQUEST_TYPE_CLASS    0x20 }
    { LIBUSB_REQUEST_TYPE_VENDOR   0x40 }
    { LIBUSB_REQUEST_TYPE_RESERVED 0x60 } ;

ENUM: libusb_request_recipient
    { LIBUSB_RECIPIENT_DEVICE    0x00 }
    { LIBUSB_RECIPIENT_INTERFACE 0x01 }
    { LIBUSB_RECIPIENT_ENDPOINT  0x02 }
    { LIBUSB_RECIPIENT_OTHER     0x03 } ;

CONSTANT: LIBUSB_ISO_SYNC_TYPE_MASK 0x0C

ENUM: libusb_iso_sync_type
    { LIBUSB_ISO_SYNC_TYPE_NONE     0 }
    { LIBUSB_ISO_SYNC_TYPE_ASYNC    1 }
    { LIBUSB_ISO_SYNC_TYPE_ADAPTIVE 2 }
    { LIBUSB_ISO_SYNC_TYPE_SYNC     3 } ;

CONSTANT: LIBUSB_ISO_USAGE_TYPE_MASK 0x30

ENUM: libusb_iso_usage_type
    { LIBUSB_ISO_USAGE_TYPE_DATA     0 }
    { LIBUSB_ISO_USAGE_TYPE_FEEDBACK 1 }
    { LIBUSB_ISO_USAGE_TYPE_IMPLICIT 2 } ;

STRUCT: libusb_device_descriptor
    { bLength             uint8_t  }
    { bDescriptorType     uint8_t  }
    { bcdUSB              uint16_t }
    { bDeviceClass        uint8_t  }
    { bDeviceSubClass     uint8_t  }
    { bDeviceProtocol     uint8_t  }
    { bMaxPacketSize0     uint8_t  }
    { idVendor            uint16_t }
    { idProduct           uint16_t }
    { bcdDevice           uint16_t }
    { iManufacturer       uint8_t  }
    { iProduct            uint8_t  }
    { iSerialNumber       uint8_t  }
    { bNumConfigurations  uint8_t  } ;

STRUCT: libusb_endpoint_descriptor
    { bLength           uint8_t  }
    { bDescriptorType   uint8_t  }
    { bEndpointAddress  uint8_t  }
    { bmAttributes      uint8_t  }
    { wMaxPacketSize    uint16_t }
    { bInterval         uint8_t  }
    { bRefresh          uint8_t  }
    { bSynchAddress     uint8_t  }
    { extra             uchar*   }
    { extra_length      int      } ;

STRUCT: libusb_interface_descriptor
    { bLength             uint8_t                     }
    { bDescriptorType     uint8_t                     }
    { bInterfaceNumber    uint8_t                     }
    { bAlternateSetting   uint8_t                     }
    { bNumEndpoints       uint8_t                     }
    { bInterfaceClass     uint8_t                     }
    { bInterfaceSubClass  uint8_t                     }
    { bInterfaceProtocol  uint8_t                     }
    { iInterface          uint8_t                     }
    { endpoint            libusb_endpoint_descriptor* }
    { extra               uchar*                      }
    { extra_length        int                         } ;

STRUCT: libusb_interface
    { altsetting     libusb_interface_descriptor* }
    { num_altsetting int                          } ;

STRUCT: libusb_config_descriptor
    { bLength              uint8_t           }
    { bDescriptorType      uint8_t           }
    { wTotalLength         uint16_t          }
    { bNumInterfaces       uint8_t           }
    { bConfigurationValue  uint8_t           }
    { iConfiguration       uint8_t           }
    { bmAttributes         uint8_t           }
    { MaxPower             uint8_t           }
    { interface            libusb_interface* }
    { extra                uchar*            }
    { extra_length         int               } ;

STRUCT: libusb_control_setup
    { bmRequestType  uint8_t  }
    { bRequest       uint8_t  }
    { wValue         uint16_t }
    { wIndex         uint16_t }
    { wLength        uint16_t } ;

: LIBUSB_CONTROL_SETUP_SIZE ( -- x ) libusb_control_setup heap-size ; inline

C-TYPE: libusb_context
C-TYPE: libusb_device
C-TYPE: libusb_device_handle

ENUM: libusb_error
    { LIBUSB_SUCCESS             0 }
    { LIBUSB_ERROR_IO            -1 }
    { LIBUSB_ERROR_INVALID_PARAM -2 }
    { LIBUSB_ERROR_ACCESS        -3 }
    { LIBUSB_ERROR_NO_DEVICE     -4 }
    { LIBUSB_ERROR_NOT_FOUND     -5 }
    { LIBUSB_ERROR_BUSY          -6 }
    { LIBUSB_ERROR_TIMEOUT       -7 }
    { LIBUSB_ERROR_OVERFLOW      -8 }
    { LIBUSB_ERROR_PIPE          -9 }
    { LIBUSB_ERROR_INTERRUPTED   -10 }
    { LIBUSB_ERROR_NO_MEM        -11 }
    { LIBUSB_ERROR_NOT_SUPPORTED -12 }
    { LIBUSB_ERROR_OTHER         -99 } ;

ENUM: libusb_transfer_status
    LIBUSB_TRANSFER_COMPLETED
    LIBUSB_TRANSFER_ERROR
    LIBUSB_TRANSFER_TIMED_OUT
    LIBUSB_TRANSFER_CANCELLED
    LIBUSB_TRANSFER_STALL
    LIBUSB_TRANSFER_NO_DEVICE
    LIBUSB_TRANSFER_OVERFLOW ;

ENUM: libusb_transfer_flags
    { LIBUSB_TRANSFER_SHORT_NOT_OK  1 }
    { LIBUSB_TRANSFER_FREE_BUFFER   2 }
    { LIBUSB_TRANSFER_FREE_TRANSFER 4 } ;

STRUCT: libusb_iso_packet_descriptor
    { length        uint                   }
    { actual_length uint                   }
    { status        libusb_transfer_status } ;
SPECIALIZED-ARRAY: libusb_iso_packet_descriptor

C-TYPE: libusb_transfer

CALLBACK: void libusb_transfer_cb_fn ( libusb_transfer* transfer )

STRUCT: libusb_transfer
    { dev_handle      libusb_device_handle*           }
    { flags           uint8_t                         }
    { endpoint        uchar                           }
    { type            uchar                           }
    { timeout         uint                            }
    { status          libusb_transfer_status          }
    { length          int                             }
    { actual_length   int                             }
    { callback        libusb_transfer_cb_fn           }
    { user_data       void*                           }
    { buffer          uchar*                          }
    { num_iso_packets int                             }
    { iso_packet_desc libusb_iso_packet_descriptor[0] } ;

FUNCTION: int libusb_init ( libusb_context** ctx )
FUNCTION: void libusb_exit ( libusb_context* ctx )
FUNCTION: void libusb_set_debug ( libusb_context* ctx, int level )

FUNCTION: ssize_t libusb_get_device_list ( libusb_context* ctx, libusb_device*** list )
FUNCTION: void libusb_free_device_list ( libusb_device** list, int unref_devices )
FUNCTION: libusb_device* libusb_ref_device ( libusb_device* dev )
FUNCTION: void libusb_unref_device ( libusb_device* dev )

FUNCTION: int libusb_get_configuration ( libusb_device_handle* dev, int* config )
FUNCTION: int libusb_get_device_descriptor ( libusb_device* dev, libusb_device_descriptor* desc )
FUNCTION: int libusb_get_active_config_descriptor ( libusb_device* dev, libusb_config_descriptor** config )
FUNCTION: int libusb_get_config_descriptor ( libusb_device* dev, uint8_t config_index, libusb_config_descriptor** config )
FUNCTION: int libusb_get_config_descriptor_by_value ( libusb_device* dev, uint8_t bConfigurationValue, libusb_config_descriptor** config )
FUNCTION: void libusb_free_config_descriptor ( libusb_config_descriptor* config )
FUNCTION: uint8_t libusb_get_bus_number ( libusb_device* dev )
FUNCTION: uint8_t libusb_get_device_address ( libusb_device* dev )
FUNCTION: int libusb_get_max_packet_size ( libusb_device* dev, uchar endpoint )

FUNCTION: int libusb_open ( libusb_device* dev, libusb_device_handle** handle )
FUNCTION: void libusb_close ( libusb_device_handle* dev_handle )
FUNCTION: libusb_device* libusb_get_device ( libusb_device_handle* dev_handle )

FUNCTION: int libusb_set_configuration ( libusb_device_handle* dev, int configuration )
FUNCTION: int libusb_claim_interface ( libusb_device_handle* dev, int iface )
FUNCTION: int libusb_release_interface ( libusb_device_handle* dev, int iface )

FUNCTION: libusb_device_handle* libusb_open_device_with_vid_pid ( libusb_context* ctx, uint16_t vendor_id, uint16_t product_id )

FUNCTION: int libusb_set_interface_alt_setting ( libusb_device_handle* dev, int interface_number, int alternate_setting )
FUNCTION: int libusb_clear_halt ( libusb_device_handle* dev, uchar endpoint )
FUNCTION: int libusb_reset_device ( libusb_device_handle* dev )

FUNCTION: int libusb_kernel_driver_active ( libusb_device_handle* dev, int interface )
FUNCTION: int libusb_detach_kernel_driver ( libusb_device_handle* dev, int interface )
FUNCTION: int libusb_attach_kernel_driver ( libusb_device_handle* dev, int interface )

: libusb_control_transfer_get_data ( transfer -- data )
    buffer>> LIBUSB_CONTROL_SETUP_SIZE swap <displaced-alien> ; inline

: libusb_control_transfer_get_setup ( transfer -- setup )
    buffer>> libusb_control_setup memory>struct ; inline

:: libusb_fill_control_setup ( buffer bmRequestType bRequest wValue wIndex wLength -- )
    buffer libusb_control_setup memory>struct
    bmRequestType              >>bmRequestType
    bRequest                   >>bRequest
    wValue libusb_cpu_to_le16  >>wValue
    wIndex libusb_cpu_to_le16  >>wIndex
    wLength libusb_cpu_to_le16 >>wLength drop ; inline

FUNCTION: libusb_transfer* libusb_alloc_transfer ( int iso_packets )
FUNCTION: int libusb_submit_transfer ( libusb_transfer* transfer )
FUNCTION: int libusb_cancel_transfer ( libusb_transfer* transfer )
FUNCTION: void libusb_free_transfer ( libusb_transfer* transfer )

:: libusb_fill_control_transfer ( transfer dev_handle buffer callback user_data timeout -- )
    transfer
    dev_handle                   >>dev_handle
    0                            >>endpoint
    LIBUSB_TRANSFER_TYPE_CONTROL >>type
    timeout                      >>timeout
    buffer                       >>buffer
    user_data                    >>user_data
    callback                     >>callback

    buffer [
        libusb_control_setup memory>struct wLength>> LIBUSB_CONTROL_SETUP_SIZE +
    ] [ 0 ] if* >>length drop ; inline

:: libusb_fill_bulk_transfer ( transfer dev_handle endpoint buffer length callback user_data timeout -- )
    transfer
    dev_handle                >>dev_handle
    endpoint                  >>endpoint
    LIBUSB_TRANSFER_TYPE_BULK >>type
    timeout                   >>timeout
    buffer                    >>buffer
    length                    >>length
    user_data                 >>user_data
    callback                  >>callback
    drop ; inline

:: libusb_fill_interrupt_transfer ( transfer dev_handle endpoint buffer length callback user_data timeout -- )
    transfer
    dev_handle                     >>dev_handle
    endpoint                       >>endpoint
    LIBUSB_TRANSFER_TYPE_INTERRUPT >>type
    timeout                        >>timeout
    buffer                         >>buffer
    length                         >>length
    user_data                      >>user_data
    callback                       >>callback
    drop ; inline

:: libusb_fill_iso_transfer ( transfer dev_handle endpoint buffer length num_iso_packets callback user_data timeout -- )
    transfer
    dev_handle                       >>dev_handle
    endpoint                         >>endpoint
    LIBUSB_TRANSFER_TYPE_ISOCHRONOUS >>type
    timeout                          >>timeout
    buffer                           >>buffer
    length                           >>length
    num_iso_packets                  >>num_iso_packets
    user_data                        >>user_data
    callback                         >>callback
    drop ; inline

: libusb_set_iso_packet_lengths ( transfer length -- )
    [ [ iso_packet_desc>> >c-ptr ]
      [ num_iso_packets>> ] bi
      libusb_iso_packet_descriptor <c-direct-array>
    ] dip [ >>length drop ] curry each ; inline

:: libusb_get_iso_packet_buffer ( transfer packet -- data )
    packet transfer num_iso_packets>> >=
    [ f ]
    [
        transfer
        [ iso_packet_desc>> >c-ptr ]
        [ num_iso_packets>> ] bi
        libusb_iso_packet_descriptor <c-direct-array> 0
        [ length>> + ] reduce
        transfer buffer>> <displaced-alien>
    ] if ;

:: libusb_get_iso_packet_buffer_simple ( transfer packet -- data )
    packet transfer num_iso_packets>> >=
    [ f ]
    [
        0 transfer
        [ iso_packet_desc>> >c-ptr ]
        [ num_iso_packets>> ] bi
        libusb_iso_packet_descriptor <c-direct-array> nth
        length>> packet *
        transfer buffer>> <displaced-alien>
    ] if ;

FUNCTION: int libusb_control_transfer ( libusb_device_handle* dev_handle,
    uint8_t request_type, uint8_t request, uint16_t value, uint16_t index,
    uchar* data, uint16_t length, uint timeout )

FUNCTION: int libusb_bulk_transfer ( libusb_device_handle* dev_handle,
    uchar endpoint, uchar* data, int length,
    int* actual_length, uint timeout )

FUNCTION: int libusb_interrupt_transfer ( libusb_device_handle* dev_handle,
    uchar endpoint, uchar* data, int length,
    int* actual_length, int timeout )

:: libusb_get_descriptor ( dev desc_type desc_index data length -- int )
    dev LIBUSB_ENDPOINT_IN LIBUSB_REQUEST_GET_DESCRIPTOR
    desc_type 8 shift desc_index bitor 0 data
    length 1000 libusb_control_transfer ; inline

:: libusb_get_string_descriptor ( dev desc_index langid data length -- int )
    dev LIBUSB_ENDPOINT_IN LIBUSB_REQUEST_GET_DESCRIPTOR
    LIBUSB_DT_STRING 8 shift desc_index bitor
    langid data length 1000 libusb_control_transfer ; inline

FUNCTION: int libusb_get_string_descriptor_ascii ( libusb_device_handle* dev,
                                                   uint8_t               index,
                                                   uchar*                data,
                                                   int                   length )

FUNCTION: int libusb_try_lock_events ( libusb_context* ctx )
FUNCTION: void libusb_lock_events ( libusb_context* ctx )
FUNCTION: void libusb_unlock_events ( libusb_context* ctx )
FUNCTION: int libusb_event_handling_ok ( libusb_context* ctx )
FUNCTION: int libusb_event_handler_active ( libusb_context* ctx )
FUNCTION: void libusb_lock_event_waiters ( libusb_context* ctx )
FUNCTION: void libusb_unlock_event_waiters ( libusb_context* ctx )
FUNCTION: int libusb_wait_for_event ( libusb_context* ctx, timeval* tv )
FUNCTION: int libusb_handle_events_timeout ( libusb_context* ctx, timeval* tv )
FUNCTION: int libusb_handle_events ( libusb_context* ctx )
FUNCTION: int libusb_handle_events_locked ( libusb_context* ctx, timeval* tv )
FUNCTION: int libusb_get_next_timeout ( libusb_context* ctx, timeval* tv )

STRUCT: libusb_pollfd
    { fd     int   }
    { events short } ;

CALLBACK: void libusb_pollfd_added_cb ( int fd, short events, void* user_data )
CALLBACK: void libusb_pollfd_removed_cb ( int fd, void* user_data )

FUNCTION: libusb_pollfd** libusb_get_pollfds ( libusb_context* ctx )
FUNCTION: void libusb_set_pollfd_notifiers ( libusb_context*          ctx,
                                             libusb_pollfd_added_cb   added_cb,
                                             libusb_pollfd_removed_cb removed_cb,
                                             void*                    user_data )
