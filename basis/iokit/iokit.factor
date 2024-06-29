USING: alien.c-types alien.data alien.syntax core-foundation
core-foundation.bundles core-foundation.dictionaries kernel
sequences system unix.types ;
IN: iokit

<<
    os macos?
    [ "/System/Library/Frameworks/IOKit.framework" load-framework ]
    when
>>

CONSTANT: kIOKitBuildVersionKey   "IOKitBuildVersion"
CONSTANT: kIOKitDiagnosticsKey   "IOKitDiagnostics"

CONSTANT: kIORegistryPlanesKey   "IORegistryPlanes"
CONSTANT: kIOCatalogueKey    "IOCatalogue"

CONSTANT: kIOServicePlane    "IOService"
CONSTANT: kIOPowerPlane    "IOPower"
CONSTANT: kIODeviceTreePlane   "IODeviceTree"
CONSTANT: kIOAudioPlane    "IOAudio"
CONSTANT: kIOFireWirePlane   "IOFireWire"
CONSTANT: kIOUSBPlane    "IOUSB"

CONSTANT: kIOServiceClass    "IOService"

CONSTANT: kIOResourcesClass   "IOResources"

CONSTANT: kIOClassKey    "IOClass"
CONSTANT: kIOProbeScoreKey   "IOProbeScore"
CONSTANT: kIOKitDebugKey    "IOKitDebug"

CONSTANT: kIOProviderClassKey   "IOProviderClass"
CONSTANT: kIONameMatchKey    "IONameMatch"
CONSTANT: kIOPropertyMatchKey   "IOPropertyMatch"
CONSTANT: kIOPathMatchKey    "IOPathMatch"
CONSTANT: kIOLocationMatchKey   "IOLocationMatch"
CONSTANT: kIOParentMatchKey   "IOParentMatch"
CONSTANT: kIOResourceMatchKey   "IOResourceMatch"
CONSTANT: kIOMatchedServiceCountKey  "IOMatchedServiceCountMatch"

CONSTANT: kIONameMatchedKey   "IONameMatched"

CONSTANT: kIOMatchCategoryKey   "IOMatchCategory"
CONSTANT: kIODefaultMatchCategoryKey  "IODefaultMatchCategory"

CONSTANT: kIOUserClientClassKey   "IOUserClientClass"

CONSTANT: kIOUserClientCrossEndianKey   "IOUserClientCrossEndian"
CONSTANT: kIOUserClientCrossEndianCompatibleKey  "IOUserClientCrossEndianCompatible"
CONSTANT: kIOUserClientSharedInstanceKey   "IOUserClientSharedInstance"

CONSTANT: kIOPublishNotification   "IOServicePublish"
CONSTANT: kIOFirstPublishNotification  "IOServiceFirstPublish"
CONSTANT: kIOMatchedNotification   "IOServiceMatched"
CONSTANT: kIOFirstMatchNotification  "IOServiceFirstMatch"
CONSTANT: kIOTerminatedNotification  "IOServiceTerminate"

CONSTANT: kIOGeneralInterest   "IOGeneralInterest"
CONSTANT: kIOBusyInterest    "IOBusyInterest"
CONSTANT: kIOAppPowerStateInterest  "IOAppPowerStateInterest"
CONSTANT: kIOPriorityPowerStateInterest  "IOPriorityPowerStateInterest"

CONSTANT: kIOPlatformDeviceMessageKey "IOPlatformDeviceMessage"

CONSTANT: kIOCFPlugInTypesKey   "IOCFPlugInTypes"

CONSTANT: kIOCommandPoolSizeKey         "IOCommandPoolSize"

CONSTANT: kIOMaximumBlockCountReadKey "IOMaximumBlockCountRead"
CONSTANT: kIOMaximumBlockCountWriteKey "IOMaximumBlockCountWrite"
CONSTANT: kIOMaximumByteCountReadKey "IOMaximumByteCountRead"
CONSTANT: kIOMaximumByteCountWriteKey "IOMaximumByteCountWrite"
CONSTANT: kIOMaximumSegmentCountReadKey "IOMaximumSegmentCountRead"
CONSTANT: kIOMaximumSegmentCountWriteKey "IOMaximumSegmentCountWrite"
CONSTANT: kIOMaximumSegmentByteCountReadKey "IOMaximumSegmentByteCountRead"
CONSTANT: kIOMaximumSegmentByteCountWriteKey "IOMaximumSegmentByteCountWrite"
CONSTANT: kIOMinimumSegmentAlignmentByteCountKey "IOMinimumSegmentAlignmentByteCount"
CONSTANT: kIOMaximumSegmentAddressableBitCountKey "IOMaximumSegmentAddressableBitCount"

CONSTANT: kIOIconKey "IOIcon"
CONSTANT: kIOBundleResourceFileKey "IOBundleResourceFile"

CONSTANT: kIOBusBadgeKey "IOBusBadge"
CONSTANT: kIODeviceIconKey "IODeviceIcon"

CONSTANT: kIOPlatformSerialNumberKey  "IOPlatformSerialNumber"

CONSTANT: kIOPlatformUUIDKey  "IOPlatformUUID"

CONSTANT: kIONVRAMDeletePropertyKey  "IONVRAM-DELETE-PROPERTY"
CONSTANT: kIODTNVRAMPanicInfoKey   "aapl,panic-info"

CONSTANT: kIOBootDeviceKey "IOBootDevice"
CONSTANT: kIOBootDevicePathKey "IOBootDevicePath"
CONSTANT: kIOBootDeviceSizeKey "IOBootDeviceSize"

CONSTANT: kOSBuildVersionKey   "OS Build Version"

CONSTANT: kNilOptions 0

CONSTANT: MACH_PORT_NULL 0
CONSTANT: KERN_SUCCESS 0

FUNCTION: IOReturn IOMasterPort ( mach_port_t bootstrap, mach_port_t* master )

FUNCTION: CFDictionaryRef IOServiceMatching ( c-string name )
FUNCTION: CFDictionaryRef IOServiceNameMatching ( c-string name )
FUNCTION: CFDictionaryRef IOBSDNameMatching ( c-string name )

FUNCTION: IOReturn IOObjectRetain ( io_object_t o )
FUNCTION: IOReturn IOObjectRelease ( io_object_t o )

FUNCTION: IOReturn IOServiceGetMatchingServices ( mach_port_t master, CFDictionaryRef matchingDict, io_iterator_t* iterator )

FUNCTION: io_object_t IOIteratorNext ( io_iterator_t i )
FUNCTION: void IOIteratorReset ( io_iterator_t i )
FUNCTION: boolean_t IOIteratorIsValid ( io_iterator_t i )

FUNCTION: IOReturn IORegistryEntryGetPath ( io_registry_entry_t entry, io_name_t plane, io_string_t path )

FUNCTION: IOReturn IORegistryEntryCreateCFProperties ( io_registry_entry_t entry, CFMutableDictionaryRef properties, CFAllocatorRef allocator, IOOptionBits options )

FUNCTION: c-string mach_error_string ( IOReturn error )

TUPLE: mach-error-state error-code error-string ;
: <mach-error> ( code -- error )
    dup mach_error_string \ mach-error-state boa ;

: mach-error ( return -- )
    dup KERN_SUCCESS = [ drop ] [ <mach-error> throw ] if ;

: master-port ( -- port )
    MACH_PORT_NULL { uint } [ IOMasterPort mach-error ] with-out-parameters ;

: io-services-matching-dictionary ( nsdictionary -- iterator )
    master-port swap
    { uint } [ IOServiceGetMatchingServices mach-error ] with-out-parameters ;

: io-services-matching-service ( service -- iterator )
    IOServiceMatching io-services-matching-dictionary ;
: io-services-matching-service-name ( service-name -- iterator )
    IOServiceNameMatching io-services-matching-dictionary ;
: io-services-matching-bsd-name ( bsd-name -- iterator )
    IOBSDNameMatching io-services-matching-dictionary ;

: retain-io-object ( o -- o )
    [ IOObjectRetain mach-error ] keep ;
: release-io-object ( o -- )
    IOObjectRelease mach-error ;

: io-objects-from-iterator* ( i -- i array )
    [ dup IOIteratorNext dup MACH_PORT_NULL = not ] [ ] produce nip ;

: io-objects-from-iterator ( i -- array )
    io-objects-from-iterator* [ release-io-object ] dip ;

: properties-from-io-object ( o -- o nsdictionary )
    dup f void* <ref> [
        kCFAllocatorDefault kNilOptions
        IORegistryEntryCreateCFProperties mach-error
    ]
    keep void* deref ;
