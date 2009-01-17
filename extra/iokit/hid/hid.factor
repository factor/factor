USING: iokit alien alien.syntax alien.c-types kernel
system core-foundation core-foundation.data
core-foundation.dictionaries ;
IN: iokit.hid

: kIOHIDDeviceKey "IOHIDDevice" ; inline

: kIOHIDTransportKey                  "Transport" ; inline
: kIOHIDVendorIDKey                   "VendorID" ; inline
: kIOHIDVendorIDSourceKey             "VendorIDSource" ; inline
: kIOHIDProductIDKey                  "ProductID" ; inline
: kIOHIDVersionNumberKey              "VersionNumber" ; inline
: kIOHIDManufacturerKey               "Manufacturer" ; inline
: kIOHIDProductKey                    "Product" ; inline
: kIOHIDSerialNumberKey               "SerialNumber" ; inline
: kIOHIDCountryCodeKey                "CountryCode" ; inline
: kIOHIDLocationIDKey                 "LocationID" ; inline
: kIOHIDDeviceUsageKey                "DeviceUsage" ; inline
: kIOHIDDeviceUsagePageKey            "DeviceUsagePage" ; inline
: kIOHIDDeviceUsagePairsKey           "DeviceUsagePairs" ; inline
: kIOHIDPrimaryUsageKey               "PrimaryUsage" ; inline
: kIOHIDPrimaryUsagePageKey           "PrimaryUsagePage" ; inline
: kIOHIDMaxInputReportSizeKey         "MaxInputReportSize" ; inline
: kIOHIDMaxOutputReportSizeKey       "MaxOutputReportSize" ; inline
: kIOHIDMaxFeatureReportSizeKey       "MaxFeatureReportSize" ; inline
: kIOHIDReportIntervalKey             "ReportInterval" ; inline

: kIOHIDElementKey                    "Elements" ; inline

: kIOHIDElementCookieKey                      "ElementCookie" ; inline
: kIOHIDElementTypeKey                        "Type" ; inline
: kIOHIDElementCollectionTypeKey              "CollectionType" ; inline
: kIOHIDElementUsageKey                       "Usage" ; inline
: kIOHIDElementUsagePageKey                   "UsagePage" ; inline
: kIOHIDElementMinKey                         "Min" ; inline
: kIOHIDElementMaxKey                         "Max" ; inline
: kIOHIDElementScaledMinKey                   "ScaledMin" ; inline
: kIOHIDElementScaledMaxKey                   "ScaledMax" ; inline
: kIOHIDElementSizeKey                        "Size" ; inline
: kIOHIDElementReportSizeKey                  "ReportSize" ; inline
: kIOHIDElementReportCountKey                 "ReportCount" ; inline
: kIOHIDElementReportIDKey                    "ReportID" ; inline
: kIOHIDElementIsArrayKey                     "IsArray" ; inline
: kIOHIDElementIsRelativeKey                  "IsRelative" ; inline
: kIOHIDElementIsWrappingKey                  "IsWrapping" ; inline
: kIOHIDElementIsNonLinearKey                 "IsNonLinear" ; inline
: kIOHIDElementHasPreferredStateKey           "HasPreferredState" ; inline
: kIOHIDElementHasNullStateKey                "HasNullState" ; inline
: kIOHIDElementFlagsKey                       "Flags" ; inline
: kIOHIDElementUnitKey                        "Unit" ; inline
: kIOHIDElementUnitExponentKey                "UnitExponent" ; inline
: kIOHIDElementNameKey                        "Name" ; inline
: kIOHIDElementValueLocationKey               "ValueLocation" ; inline
: kIOHIDElementDuplicateIndexKey              "DuplicateIndex" ; inline
: kIOHIDElementParentCollectionKey            "ParentCollection" ; inline

: kIOHIDElementVendorSpecificKey ( -- str )
    cpu ppc? "VendorSpecifc" "VendorSpecific" ? ; inline

: kIOHIDElementCookieMinKey           "ElementCookieMin" ; inline
: kIOHIDElementCookieMaxKey           "ElementCookieMax" ; inline
: kIOHIDElementUsageMinKey            "UsageMin" ; inline
: kIOHIDElementUsageMaxKey            "UsageMax" ; inline

: kIOHIDElementCalibrationMinKey              "CalibrationMin" ; inline
: kIOHIDElementCalibrationMaxKey              "CalibrationMax" ; inline
: kIOHIDElementCalibrationSaturationMinKey    "CalibrationSaturationMin" ; inline
: kIOHIDElementCalibrationSaturationMaxKey    "CalibrationSaturationMax" ; inline
: kIOHIDElementCalibrationDeadZoneMinKey      "CalibrationDeadZoneMin" ; inline
: kIOHIDElementCalibrationDeadZoneMaxKey      "CalibrationDeadZoneMax" ; inline
: kIOHIDElementCalibrationGranularityKey      "CalibrationGranularity" ; inline

: kIOHIDElementTypeInput_Misc        1 ; inline
: kIOHIDElementTypeInput_Button      2 ; inline
: kIOHIDElementTypeInput_Axis        3 ; inline
: kIOHIDElementTypeInput_ScanCodes   4 ; inline
: kIOHIDElementTypeOutput            129 ; inline
: kIOHIDElementTypeFeature           257 ; inline
: kIOHIDElementTypeCollection        513 ; inline

: kIOHIDElementCollectionTypePhysical     HEX: 00 ; inline
: kIOHIDElementCollectionTypeApplication    HEX: 01 ; inline
: kIOHIDElementCollectionTypeLogical        HEX: 02 ; inline
: kIOHIDElementCollectionTypeReport         HEX: 03 ; inline
: kIOHIDElementCollectionTypeNamedArray     HEX: 04 ; inline
: kIOHIDElementCollectionTypeUsageSwitch    HEX: 05 ; inline
: kIOHIDElementCollectionTypeUsageModifier  HEX: 06 ; inline

: kIOHIDReportTypeInput    0 ; inline
: kIOHIDReportTypeOutput   1 ; inline
: kIOHIDReportTypeFeature  2 ; inline
: kIOHIDReportTypeCount    3 ; inline

: kIOHIDOptionsTypeNone        HEX: 00 ; inline
: kIOHIDOptionsTypeSeizeDevice HEX: 01 ; inline

: kIOHIDQueueOptionsTypeNone    HEX: 00 ; inline
: kIOHIDQueueOptionsTypeEnqueueAll HEX: 01 ; inline

: kIOHIDElementFlagsConstantMask        HEX: 0001 ; inline
: kIOHIDElementFlagsVariableMask        HEX: 0002 ; inline
: kIOHIDElementFlagsRelativeMask        HEX: 0004 ; inline
: kIOHIDElementFlagsWrapMask            HEX: 0008 ; inline
: kIOHIDElementFlagsNonLinearMask       HEX: 0010 ; inline
: kIOHIDElementFlagsNoPreferredMask     HEX: 0020 ; inline
: kIOHIDElementFlagsNullStateMask       HEX: 0040 ; inline
: kIOHIDElementFlagsVolativeMask        HEX: 0080 ; inline
: kIOHIDElementFlagsBufferedByteMask    HEX: 0100 ; inline

: kIOHIDValueScaleTypeCalibrated 0 ; inline
: kIOHIDValueScaleTypePhysical   1 ; inline

: kIOHIDTransactionDirectionTypeInput  0 ; inline
: kIOHIDTransactionDirectionTypeOutput 1 ; inline

: kIOHIDTransactionOptionDefaultOutputValue 1 ; inline

TYPEDEF: ptrdiff_t IOHIDElementCookie
TYPEDEF: int IOHIDElementType
TYPEDEF: int IOHIDElementCollectionType
TYPEDEF: int IOHIDReportType
TYPEDEF: uint IOHIDOptionsType
TYPEDEF: uint IOHIDQueueOptionsType
TYPEDEF: uint IOHIDElementFlags
TYPEDEF: void* IOHIDDeviceRef
TYPEDEF: void* IOHIDElementRef
TYPEDEF: void* IOHIDValueRef
TYPEDEF: void* IOHIDManagerRef
TYPEDEF: void* IOHIDTransactionRef
TYPEDEF: UInt32 IOHIDValueScaleType
TYPEDEF: UInt32 IOHIDTransactionDirectionType

TYPEDEF: void* IOHIDCallback
: IOHIDCallback ( quot -- alien )
    [ "void" { "void*" "IOReturn" "void*" } "cdecl" ]
    dip alien-callback ; inline

TYPEDEF: void* IOHIDReportCallback
: IOHIDReportCallback ( quot -- alien )
    [ "void" { "void*" "IOReturn" "void*" "IOHIDReportType" "UInt32" "uchar*" "CFIndex" } "cdecl" ]
    dip alien-callback ; inline

TYPEDEF: void* IOHIDValueCallback
: IOHIDValueCallback ( quot -- alien )
    [ "void" { "void*" "IOReturn" "void*" "IOHIDValueRef" } "cdecl" ]
    dip alien-callback ; inline

TYPEDEF: void* IOHIDValueMultipleCallback
: IOHIDValueMultipleCallback ( quot -- alien )
    [ "void" { "void*" "IOReturn" "void*" "CFDictionaryRef" } "cdecl" ]
    dip alien-callback ; inline

TYPEDEF: void* IOHIDDeviceCallback
: IOHIDDeviceCallback ( quot -- alien )
    [ "void" { "void*" "IOReturn" "void*" "IOHIDDeviceRef" } "cdecl" ]
    dip alien-callback ; inline

! IOHIDDevice

FUNCTION: CFTypeID IOHIDDeviceGetTypeID ( ) ;
FUNCTION: IOHIDDeviceRef IOHIDDeviceCreate ( CFAllocatorRef allocator, io_service_t service ) ;
FUNCTION: IOReturn IOHIDDeviceOpen ( IOHIDDeviceRef device, IOOptionBits options ) ;
FUNCTION: IOReturn IOHIDDeviceClose ( IOHIDDeviceRef device, IOOptionBits options ) ;
FUNCTION: Boolean IOHIDDeviceConformsTo ( IOHIDDeviceRef device, UInt32 usagePage, UInt32 usage ) ;
FUNCTION: CFTypeRef IOHIDDeviceGetProperty ( IOHIDDeviceRef device, CFStringRef key ) ;
FUNCTION: Boolean IOHIDDeviceSetProperty ( IOHIDDeviceRef device, CFStringRef key, CFTypeRef property ) ;
FUNCTION: CFArrayRef IOHIDDeviceCopyMatchingElements ( IOHIDDeviceRef device, CFDictionaryRef matching, IOOptionBits options ) ;
FUNCTION: void IOHIDDeviceScheduleWithRunLoop ( IOHIDDeviceRef device, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDDeviceUnscheduleFromRunLoop ( IOHIDDeviceRef device, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDDeviceRegisterRemovalCallback ( IOHIDDeviceRef device, IOHIDCallback callback, void* context ) ;
FUNCTION: void IOHIDDeviceRegisterInputValueCallback ( IOHIDDeviceRef device, IOHIDValueCallback callback, void* context ) ;
FUNCTION: void IOHIDDeviceRegisterInputReportCallback ( IOHIDDeviceRef device, uchar* report, CFIndex reportLength, IOHIDReportCallback callback, void* context ) ;
FUNCTION: void IOHIDDeviceSetInputValueMatching ( IOHIDDeviceRef device, CFDictionaryRef matching ) ;
FUNCTION: void IOHIDDeviceSetInputValueMatchingMultiple ( IOHIDDeviceRef device, CFArrayRef multiple ) ;
FUNCTION: IOReturn IOHIDDeviceSetValue ( IOHIDDeviceRef device, IOHIDElementRef element, IOHIDValueRef value ) ;
FUNCTION: IOReturn IOHIDDeviceSetValueMultiple ( IOHIDDeviceRef device, CFDictionaryRef multiple ) ;
FUNCTION: IOReturn IOHIDDeviceSetValueWithCallback ( IOHIDDeviceRef device, IOHIDElementRef element, IOHIDValueRef value, CFTimeInterval timeout, IOHIDValueCallback callback, void* context ) ;
FUNCTION: IOReturn IOHIDDeviceSetValueMultipleWithCallback ( IOHIDDeviceRef device, CFDictionaryRef multiple, CFTimeInterval timeout, IOHIDValueMultipleCallback callback, void* context ) ;
FUNCTION: IOReturn IOHIDDeviceGetValue ( IOHIDDeviceRef device, IOHIDElementRef element, IOHIDValueRef* pValue ) ;
FUNCTION: IOReturn IOHIDDeviceCopyValueMultiple ( IOHIDDeviceRef device, CFArrayRef elements, CFDictionaryRef* pMultiple ) ;
FUNCTION: IOReturn IOHIDDeviceGetValueWithCallback ( IOHIDDeviceRef device, IOHIDElementRef element, IOHIDValueRef* pValue, CFTimeInterval timeout, IOHIDValueCallback callback, void* context ) ;
FUNCTION: IOReturn IOHIDDeviceCopyValueMultipleWithCallback ( IOHIDDeviceRef device, CFArrayRef elements, CFDictionaryRef* pMultiple, CFTimeInterval timeout, IOHIDValueMultipleCallback callback, void* context ) ;
FUNCTION: IOReturn IOHIDDeviceSetReport ( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uchar* report, CFIndex reportLength ) ;
FUNCTION: IOReturn IOHIDDeviceSetReportWithCallback ( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uchar* report, CFIndex reportLength, CFTimeInterval timeout, IOHIDReportCallback callback, void* context ) ;
FUNCTION: IOReturn IOHIDDeviceGetReport ( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uchar* report, CFIndex* pReportLength ) ;
FUNCTION: IOReturn IOHIDDeviceGetReportWithCallback ( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID, uchar* report, CFIndex* pReportLength, CFTimeInterval timeout, IOHIDReportCallback callback, void* context ) ;

! IOHIDManager

FUNCTION: CFTypeID IOHIDManagerGetTypeID ( ) ;
FUNCTION: IOHIDManagerRef IOHIDManagerCreate ( CFAllocatorRef allocator, IOOptionBits options ) ;
FUNCTION: IOReturn IOHIDManagerOpen ( IOHIDManagerRef manager, IOOptionBits options ) ;
FUNCTION: IOReturn IOHIDManagerClose ( IOHIDManagerRef manager, IOOptionBits options ) ;
FUNCTION: CFTypeRef IOHIDManagerGetProperty ( IOHIDManagerRef manager, CFStringRef key ) ;
FUNCTION: Boolean IOHIDManagerSetProperty ( IOHIDManagerRef manager, CFStringRef key, CFTypeRef value ) ;
FUNCTION: void IOHIDManagerScheduleWithRunLoop ( IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDManagerUnscheduleFromRunLoop ( IOHIDManagerRef manager, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDManagerSetDeviceMatching ( IOHIDManagerRef manager, CFDictionaryRef matching ) ;
FUNCTION: void IOHIDManagerSetDeviceMatchingMultiple ( IOHIDManagerRef manager, CFArrayRef multiple ) ;
FUNCTION: CFSetRef IOHIDManagerCopyDevices ( IOHIDManagerRef manager ) ;
FUNCTION: void IOHIDManagerRegisterDeviceMatchingCallback ( IOHIDManagerRef manager, IOHIDDeviceCallback callback, void* context ) ;
FUNCTION: void IOHIDManagerRegisterDeviceRemovalCallback ( IOHIDManagerRef manager, IOHIDDeviceCallback callback, void* context ) ;
FUNCTION: void IOHIDManagerRegisterInputReportCallback ( IOHIDManagerRef manager, IOHIDReportCallback callback, void* context ) ;
FUNCTION: void IOHIDManagerRegisterInputValueCallback ( IOHIDManagerRef manager, IOHIDValueCallback callback, void* context ) ;
FUNCTION: void IOHIDManagerSetInputValueMatching ( IOHIDManagerRef manager, CFDictionaryRef matching ) ;
FUNCTION: void IOHIDManagerSetInputValueMatchingMultiple ( IOHIDManagerRef manager, CFArrayRef multiple ) ;

! IOHIDElement

FUNCTION: CFTypeID IOHIDElementGetTypeID ( ) ;
FUNCTION: IOHIDElementRef IOHIDElementCreateWithDictionary ( CFAllocatorRef allocator, CFDictionaryRef dictionary ) ;
FUNCTION: IOHIDDeviceRef IOHIDElementGetDevice ( IOHIDElementRef element ) ;
FUNCTION: IOHIDElementRef IOHIDElementGetParent ( IOHIDElementRef element ) ;
FUNCTION: CFArrayRef IOHIDElementGetChildren ( IOHIDElementRef element ) ;
FUNCTION: void IOHIDElementAttach ( IOHIDElementRef element, IOHIDElementRef toAttach ) ;
FUNCTION: void IOHIDElementDetach ( IOHIDElementRef element, IOHIDElementRef toDetach ) ;
FUNCTION: CFArrayRef IOHIDElementCopyAttached ( IOHIDElementRef element ) ;
FUNCTION: IOHIDElementCookie IOHIDElementGetCookie ( IOHIDElementRef element ) ;
FUNCTION: IOHIDElementType IOHIDElementGetType ( IOHIDElementRef element ) ;
FUNCTION: IOHIDElementCollectionType IOHIDElementGetCollectionType ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetUsagePage ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetUsage ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementIsVirtual ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementIsRelative ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementIsWrapping ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementIsArray ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementIsNonLinear ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementHasPreferredState ( IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDElementHasNullState ( IOHIDElementRef element ) ;
FUNCTION: CFStringRef IOHIDElementGetName ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetReportID ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetReportSize ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetReportCount ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetUnit ( IOHIDElementRef element ) ;
FUNCTION: UInt32 IOHIDElementGetUnitExponent ( IOHIDElementRef element ) ;
FUNCTION: CFIndex IOHIDElementGetLogicalMin ( IOHIDElementRef element ) ;
FUNCTION: CFIndex IOHIDElementGetLogicalMax ( IOHIDElementRef element ) ;
FUNCTION: CFIndex IOHIDElementGetPhysicalMin ( IOHIDElementRef element ) ;
FUNCTION: CFIndex IOHIDElementGetPhysicalMax ( IOHIDElementRef element ) ;
FUNCTION: CFTypeRef IOHIDElementGetProperty ( IOHIDElementRef element, CFStringRef key ) ;
FUNCTION: Boolean IOHIDElementSetProperty ( IOHIDElementRef element, CFStringRef key, CFTypeRef property ) ;

! IOHIDValue

FUNCTION: CFTypeID IOHIDValueGetTypeID ( ) ;
FUNCTION: IOHIDValueRef IOHIDValueCreateWithIntegerValue ( CFAllocatorRef allocator, IOHIDElementRef element, ulonglong timeStamp, CFIndex value ) ;
FUNCTION: IOHIDValueRef IOHIDValueCreateWithBytes ( CFAllocatorRef allocator, IOHIDElementRef element, ulonglong timeStamp, uchar* bytes, CFIndex length ) ;
FUNCTION: IOHIDValueRef IOHIDValueCreateWithBytesNoCopy ( CFAllocatorRef allocator, IOHIDElementRef element, ulonglong timeStamp, uchar* bytes, CFIndex length ) ;
FUNCTION: IOHIDElementRef IOHIDValueGetElement ( IOHIDValueRef value ) ;
FUNCTION: ulonglong IOHIDValueGetTimeStamp ( IOHIDValueRef value ) ;
FUNCTION: CFIndex IOHIDValueGetLength ( IOHIDValueRef value ) ;
FUNCTION: uchar* IOHIDValueGetBytePtr ( IOHIDValueRef value ) ;
FUNCTION: CFIndex IOHIDValueGetIntegerValue ( IOHIDValueRef value ) ;
FUNCTION: double IOHIDValueGetScaledValue ( IOHIDValueRef value, IOHIDValueScaleType type ) ;

! IOHIDTransaction

FUNCTION: CFTypeID IOHIDTransactionGetTypeID ( ) ;
FUNCTION: IOHIDTransactionRef IOHIDTransactionCreate ( CFAllocatorRef allocator, IOHIDDeviceRef device, IOHIDTransactionDirectionType direction, IOOptionBits options ) ;
FUNCTION: IOHIDDeviceRef IOHIDTransactionGetDevice ( IOHIDTransactionRef transaction ) ;
FUNCTION: IOHIDTransactionDirectionType IOHIDTransactionGetDirection ( IOHIDTransactionRef transaction ) ;
FUNCTION: void IOHIDTransactionSetDirection ( IOHIDTransactionRef transaction, IOHIDTransactionDirectionType direction ) ;
FUNCTION: void IOHIDTransactionAddElement ( IOHIDTransactionRef transaction, IOHIDElementRef element ) ;
FUNCTION: void IOHIDTransactionRemoveElement ( IOHIDTransactionRef transaction, IOHIDElementRef element ) ;
FUNCTION: Boolean IOHIDTransactionContainsElement ( IOHIDTransactionRef transaction, IOHIDElementRef element ) ;
FUNCTION: void IOHIDTransactionScheduleWithRunLoop ( IOHIDTransactionRef transaction, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDTransactionUnscheduleFromRunLoop ( IOHIDTransactionRef transaction, CFRunLoopRef runLoop, CFStringRef runLoopMode ) ;
FUNCTION: void IOHIDTransactionSetValue ( IOHIDTransactionRef transaction, IOHIDElementRef element, IOHIDValueRef value, IOOptionBits options ) ;
FUNCTION: IOHIDValueRef IOHIDTransactionGetValue ( IOHIDTransactionRef transaction, IOHIDElementRef element, IOOptionBits options ) ;
FUNCTION: IOReturn IOHIDTransactionCommit ( IOHIDTransactionRef transaction ) ;
FUNCTION: IOReturn IOHIDTransactionCommitWithCallback ( IOHIDTransactionRef transaction, CFTimeInterval timeout, IOHIDCallback callback, void* context ) ;
FUNCTION: void IOHIDTransactionClear ( IOHIDTransactionRef transaction ) ;

