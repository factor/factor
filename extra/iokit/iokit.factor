USING: alien.syntax alien.c-types core-foundation
core-foundation.bundles core-foundation.dictionaries system
combinators kernel sequences debugger io accessors ;
IN: iokit

<<
    os macosx?
    [ "/System/Library/Frameworks/IOKit.framework" load-framework ]
    when
>>

: kIOKitBuildVersionKey   "IOKitBuildVersion" ; inline
: kIOKitDiagnosticsKey   "IOKitDiagnostics" ; inline
 
: kIORegistryPlanesKey   "IORegistryPlanes" ; inline
: kIOCatalogueKey    "IOCatalogue" ; inline

: kIOServicePlane    "IOService" ; inline
: kIOPowerPlane    "IOPower" ; inline
: kIODeviceTreePlane   "IODeviceTree" ; inline
: kIOAudioPlane    "IOAudio" ; inline
: kIOFireWirePlane   "IOFireWire" ; inline
: kIOUSBPlane    "IOUSB" ; inline

: kIOServiceClass    "IOService" ; inline

: kIOResourcesClass   "IOResources" ; inline

: kIOClassKey    "IOClass" ; inline
: kIOProbeScoreKey   "IOProbeScore" ; inline
: kIOKitDebugKey    "IOKitDebug" ; inline

: kIOProviderClassKey   "IOProviderClass" ; inline
: kIONameMatchKey    "IONameMatch" ; inline
: kIOPropertyMatchKey   "IOPropertyMatch" ; inline
: kIOPathMatchKey    "IOPathMatch" ; inline
: kIOLocationMatchKey   "IOLocationMatch" ; inline
: kIOParentMatchKey   "IOParentMatch" ; inline
: kIOResourceMatchKey   "IOResourceMatch" ; inline
: kIOMatchedServiceCountKey  "IOMatchedServiceCountMatch" ; inline

: kIONameMatchedKey   "IONameMatched" ; inline

: kIOMatchCategoryKey   "IOMatchCategory" ; inline
: kIODefaultMatchCategoryKey  "IODefaultMatchCategory" ; inline

: kIOUserClientClassKey   "IOUserClientClass" ; inline

: kIOUserClientCrossEndianKey   "IOUserClientCrossEndian" ; inline
: kIOUserClientCrossEndianCompatibleKey  "IOUserClientCrossEndianCompatible" ; inline
: kIOUserClientSharedInstanceKey   "IOUserClientSharedInstance" ; inline

: kIOPublishNotification   "IOServicePublish" ; inline
: kIOFirstPublishNotification  "IOServiceFirstPublish" ; inline
: kIOMatchedNotification   "IOServiceMatched" ; inline
: kIOFirstMatchNotification  "IOServiceFirstMatch" ; inline
: kIOTerminatedNotification  "IOServiceTerminate" ; inline

: kIOGeneralInterest   "IOGeneralInterest" ; inline
: kIOBusyInterest    "IOBusyInterest" ; inline
: kIOAppPowerStateInterest  "IOAppPowerStateInterest" ; inline
: kIOPriorityPowerStateInterest  "IOPriorityPowerStateInterest" ; inline

: kIOPlatformDeviceMessageKey "IOPlatformDeviceMessage" ; inline

: kIOCFPlugInTypesKey   "IOCFPlugInTypes" ; inline

: kIOCommandPoolSizeKey         "IOCommandPoolSize" ; inline

: kIOMaximumBlockCountReadKey "IOMaximumBlockCountRead" ; inline
: kIOMaximumBlockCountWriteKey "IOMaximumBlockCountWrite" ; inline
: kIOMaximumByteCountReadKey "IOMaximumByteCountRead" ; inline
: kIOMaximumByteCountWriteKey "IOMaximumByteCountWrite" ; inline
: kIOMaximumSegmentCountReadKey "IOMaximumSegmentCountRead" ; inline
: kIOMaximumSegmentCountWriteKey "IOMaximumSegmentCountWrite" ; inline
: kIOMaximumSegmentByteCountReadKey "IOMaximumSegmentByteCountRead" ; inline
: kIOMaximumSegmentByteCountWriteKey "IOMaximumSegmentByteCountWrite" ; inline
: kIOMinimumSegmentAlignmentByteCountKey "IOMinimumSegmentAlignmentByteCount" ; inline
: kIOMaximumSegmentAddressableBitCountKey "IOMaximumSegmentAddressableBitCount" ; inline

: kIOIconKey "IOIcon" ; inline
: kIOBundleResourceFileKey "IOBundleResourceFile" ; inline

: kIOBusBadgeKey "IOBusBadge" ; inline
: kIODeviceIconKey "IODeviceIcon" ; inline

: kIOPlatformSerialNumberKey  "IOPlatformSerialNumber"  ; inline

: kIOPlatformUUIDKey  "IOPlatformUUID"  ; inline

: kIONVRAMDeletePropertyKey  "IONVRAM-DELETE-PROPERTY" ; inline
: kIODTNVRAMPanicInfoKey   "aapl,panic-info" ; inline

: kIOBootDeviceKey "IOBootDevice"   ; inline
: kIOBootDevicePathKey "IOBootDevicePath"  ; inline
: kIOBootDeviceSizeKey "IOBootDeviceSize"  ; inline

: kOSBuildVersionKey   "OS Build Version" ; inline

: kNilOptions 0 ; inline

TYPEDEF: uint mach_port_t
TYPEDEF: int kern_return_t
TYPEDEF: int boolean_t
TYPEDEF: mach_port_t io_object_t
TYPEDEF: io_object_t io_iterator_t
TYPEDEF: io_object_t io_registry_entry_t
TYPEDEF: io_object_t io_service_t
TYPEDEF: char[128] io_name_t
TYPEDEF: char[512] io_string_t
TYPEDEF: kern_return_t IOReturn

TYPEDEF: uint IOOptionBits

: MACH_PORT_NULL 0 ; inline
: KERN_SUCCESS 0 ; inline

FUNCTION: IOReturn IOMasterPort ( mach_port_t bootstrap, mach_port_t* master ) ;

FUNCTION: CFDictionaryRef IOServiceMatching ( char* name ) ;
FUNCTION: CFDictionaryRef IOServiceNameMatching ( char* name ) ;
FUNCTION: CFDictionaryRef IOBSDNameMatching ( char* name ) ;

FUNCTION: IOReturn IOObjectRetain ( io_object_t o ) ;
FUNCTION: IOReturn IOObjectRelease ( io_object_t o ) ;

FUNCTION: IOReturn IOServiceGetMatchingServices ( mach_port_t master, CFDictionaryRef matchingDict, io_iterator_t* iterator ) ;

FUNCTION: io_object_t IOIteratorNext ( io_iterator_t i ) ;
FUNCTION: void IOIteratorReset ( io_iterator_t i ) ;
FUNCTION: boolean_t IOIteratorIsValid ( io_iterator_t i ) ;

FUNCTION: IOReturn IORegistryEntryGetPath ( io_registry_entry_t entry, io_name_t plane, io_string_t path ) ;

FUNCTION: IOReturn IORegistryEntryCreateCFProperties ( io_registry_entry_t entry, CFMutableDictionaryRef properties, CFAllocatorRef allocator, IOOptionBits options ) ;

FUNCTION: char* mach_error_string ( IOReturn error ) ;

TUPLE: mach-error error-code ;
C: <mach-error> mach-error

M: mach-error error.
    "IOKit call failed: " print error-code>> mach_error_string print ;

: mach-error ( return -- )
    dup KERN_SUCCESS = [ drop ] [ <mach-error> throw ] if ;

: master-port ( -- port )
    MACH_PORT_NULL 0 <uint> [ IOMasterPort mach-error ] keep *uint ;

: io-services-matching-dictionary ( nsdictionary -- iterator )
    master-port swap 0 <uint>
    [ IOServiceGetMatchingServices mach-error ] keep
    *uint ;

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
    [ dup IOIteratorNext dup MACH_PORT_NULL = not ]
    [ ]
    [ drop ] produce ;

: io-objects-from-iterator ( i -- array )
    io-objects-from-iterator* [ release-io-object ] dip ;
    
: properties-from-io-object ( o -- o nsdictionary )
    dup f <void*> [
        kCFAllocatorDefault kNilOptions
        IORegistryEntryCreateCFProperties mach-error
    ]
    keep *void* ;

