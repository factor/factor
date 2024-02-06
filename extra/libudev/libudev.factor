! Copyright (C) 2010 Niklas Waern.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
fry kernel sequences unix.types ;
IN: libudev

<< "libudev" "libudev.so" cdecl add-library >>

LIBRARY: libudev

C-TYPE: udev

FUNCTION: udev* udev_ref (
    udev* udev )



FUNCTION: void udev_unref (
    udev* udev )



FUNCTION: udev* udev_new ( )



CALLBACK: void udev_set_log_fn_callback (
    udev* udev
    int priority,
    c-string file,
    int line,
    c-string fn,
    c-string format )
    ! va_list args ) ;
FUNCTION: void udev_set_log_fn (
    udev* udev,
    udev_set_log_fn_callback log_fn )



FUNCTION: int udev_get_log_priority (
    udev* udev )



FUNCTION: void udev_set_log_priority (
    udev* udev,
    int priority )



FUNCTION: c-string udev_get_sys_path (
    udev* udev )



FUNCTION: c-string udev_get_dev_path (
    udev* udev )



FUNCTION: void* udev_get_userdata (
    udev* udev )



FUNCTION: void udev_set_userdata (
    udev* udev,
    void* userdata )



C-TYPE: udev_list_entry

FUNCTION: udev_list_entry* udev_list_entry_get_next (
    udev_list_entry* list_entry )



FUNCTION: udev_list_entry* udev_list_entry_get_by_name (
    udev_list_entry* list_entry,
    c-string name )



FUNCTION: c-string udev_list_entry_get_name (
    udev_list_entry* list_entry )



FUNCTION: c-string udev_list_entry_get_value (
    udev_list_entry* list_entry )



! Helper to iterate over all entries of a list.
: udev_list_entry_foreach ( ... first_entry quot: ( ... x -- ... ) -- ... )
    '[ _ keep udev_list_entry_get_next dup ] loop drop ; inline


! Get all list entries _as_ a list
: udev-list-entries ( first_entry -- seq )
    [ ] collector [ udev_list_entry_foreach ] dip ;



C-TYPE: udev_device

FUNCTION: udev_device* udev_device_ref (
    udev_device* udev_device )



FUNCTION: void udev_device_unref (
    udev_device* udev_device )



FUNCTION: udev* udev_device_get_udev (
    udev_device* udev_device )



FUNCTION: udev_device* udev_device_new_from_syspath (
    udev* udev,
    c-string syspath )



FUNCTION: udev_device* udev_device_new_from_devnum (
    udev* udev,
    char type,
    dev_t devnum )



FUNCTION: udev_device* udev_device_new_from_subsystem_sysname (
    udev* udev,
    c-string subsystem,
    c-string sysname )



FUNCTION: udev_device* udev_device_get_parent (
    udev_device* udev_device )



FUNCTION: udev_device* udev_device_get_parent_with_subsystem_devtype (
    udev_device* udev_device,
    c-string subsystem,
    c-string devtype )



FUNCTION: c-string udev_device_get_devpath (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_subsystem (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_devtype (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_syspath (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_sysname (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_sysnum (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_devnode (
    udev_device* udev_device )



FUNCTION: udev_list_entry* udev_device_get_devlinks_list_entry (
    udev_device* udev_device )



FUNCTION: udev_list_entry* udev_device_get_properties_list_entry (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_property_value (
    udev_device* udev_device,
    c-string key )



FUNCTION: c-string udev_device_get_driver (
    udev_device* udev_device )



FUNCTION: dev_t udev_device_get_devnum (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_action (
    udev_device* udev_device )



FUNCTION: ulonglong udev_device_get_seqnum (
    udev_device* udev_device )



FUNCTION: c-string udev_device_get_sysattr_value (
    udev_device* udev_device,
    c-string sysattr )



C-TYPE: udev_monitor

FUNCTION: udev_monitor* udev_monitor_ref (
    udev_monitor* udev_monitor )



FUNCTION: void udev_monitor_unref (
    udev_monitor* udev_monitor )



FUNCTION: udev* udev_monitor_get_udev (
    udev_monitor* udev_monitor )



FUNCTION: udev_monitor* udev_monitor_new_from_netlink (
    udev* udev,
    c-string name )



FUNCTION: udev_monitor* udev_monitor_new_from_socket (
    udev* udev,
    c-string socket_path )



FUNCTION: int udev_monitor_enable_receiving (
    udev_monitor* udev_monitor )



FUNCTION: int udev_monitor_set_receive_buffer_size (
    udev_monitor* udev_monitor,
    int size )



FUNCTION: int udev_monitor_get_fd (
    udev_monitor* udev_monitor )



FUNCTION: udev_device* udev_monitor_receive_device (
    udev_monitor* udev_monitor )



FUNCTION: int udev_monitor_filter_add_match_subsystem_devtype (
    udev_monitor* udev_monitor,
    c-string subsystem,
    c-string devtype )



FUNCTION: int udev_monitor_filter_update (
    udev_monitor* udev_monitor )



FUNCTION: int udev_monitor_filter_remove (
    udev_monitor* udev_monitor )



C-TYPE: udev_enumerate

FUNCTION: udev_enumerate* udev_enumerate_ref (
    udev_enumerate* udev_enumerate )



FUNCTION: void udev_enumerate_unref (
    udev_enumerate* udev_enumerate )



FUNCTION: udev* udev_enumerate_get_udev (
    udev_enumerate* udev_enumerate )



FUNCTION: udev_enumerate* udev_enumerate_new (
    udev* udev )



FUNCTION: int udev_enumerate_add_match_subsystem (
    udev_enumerate* udev_enumerate,
    c-string subsystem )



FUNCTION: int udev_enumerate_add_nomatch_subsystem (
    udev_enumerate* udev_enumerate,
    c-string subsystem )



FUNCTION: int udev_enumerate_add_match_sysattr (
    udev_enumerate* udev_enumerate,
    c-string sysattr,
    c-string value )



FUNCTION: int udev_enumerate_add_nomatch_sysattr (
    udev_enumerate* udev_enumerate,
    c-string sysattr,
    c-string value )



FUNCTION: int udev_enumerate_add_match_property (
    udev_enumerate* udev_enumerate,
    c-string property,
    c-string value )



FUNCTION: int udev_enumerate_add_match_sysname (
    udev_enumerate* udev_enumerate,
    c-string sysname )



FUNCTION: int udev_enumerate_add_syspath (
    udev_enumerate* udev_enumerate,
    c-string syspath )



FUNCTION: int udev_enumerate_scan_devices (
    udev_enumerate* udev_enumerate )



FUNCTION: int udev_enumerate_scan_subsystems (
    udev_enumerate* udev_enumerate )



FUNCTION: udev_list_entry* udev_enumerate_get_list_entry (
    udev_enumerate* udev_enumerate )



C-TYPE: udev_queue

FUNCTION: udev_queue* udev_queue_ref (
    udev_queue* udev_queue )



FUNCTION: void udev_queue_unref (
    udev_queue* udev_queue )



FUNCTION: udev* udev_queue_get_udev (
    udev_queue* udev_queue )



FUNCTION: udev_queue* udev_queue_new (
    udev* udev )



FUNCTION: ulonglong udev_queue_get_kernel_seqnum (
    udev_queue* udev_queue )



FUNCTION: ulonglong udev_queue_get_udev_seqnum (
    udev_queue* udev_queue )



FUNCTION: int udev_queue_get_udev_is_active (
    udev_queue* udev_queue )



FUNCTION: int udev_queue_get_queue_is_empty (
    udev_queue* udev_queue )



FUNCTION: int udev_queue_get_seqnum_is_finished (
    udev_queue* udev_queue,
    ulonglong seqnum )



FUNCTION: int udev_queue_get_seqnum_sequence_is_finished (
    udev_queue* udev_queue,
    ulonglong start,
    ulonglong end )



FUNCTION: udev_list_entry* udev_queue_get_queued_list_entry (
    udev_queue* udev_queue )



FUNCTION: udev_list_entry* udev_queue_get_failed_list_entry (
    udev_queue* udev_queue )
