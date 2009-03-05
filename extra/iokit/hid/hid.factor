USING: iokit alien alien.syntax alien.c-types kernel
system core-foundation core-foundation.data
core-foundation.dictionaries ;
IN: iokit.hid

CONSTANT: kIOHIDDeviceKey "IOHIDDevice"

CONSTANT: kIOHIDTransportKey                  "Transport"
CONSTANT: kIOHIDVendorIDKey                   "VendorID"
CONSTANT: kIOHIDVendorIDSourceKey             "VendorIDSource"
CONSTANT: kIOHIDProductIDKey                  "ProductID"
CONSTANT: kIOHIDVersionNumberKey              "VersionNumber"
CONSTANT: kIOHIDManufacturerKey               "Manufacturer"
CONSTANT: kIOHIDProductKey                    "Product"
CONSTANT: kIOHIDSerialNumberKey               "SerialNumber"
CONSTANT: kIOHIDCountryCodeKey                "CountryCode"
CONSTANT: kIOHIDLocationIDKey                 "LocationID"
CONSTANT: kIOHIDDeviceUsageKey                "DeviceUsage"
CONSTANT: kIOHIDDeviceUsagePageKey            "DeviceUsagePage"
CONSTANT: kIOHIDDeviceUsagePairsKey           "DeviceUsagePairs"
CONSTANT: kIOHIDPrimaryUsageKey               "PrimaryUsage"
CONSTANT: kIOHIDPrimaryUsagePageKey           "PrimaryUsagePage"
CONSTANT: kIOHIDMaxInputReportSizeKey         "MaxInputReportSize"
CONSTANT: kIOHIDMaxOutputReportSizeKey       "MaxOutputReportSize"
CONSTANT: kIOHIDMaxFeatureReportSizeKey       "MaxFeatureReportSize"
CONSTANT: kIOHIDReportIntervalKey             "ReportInterval"

CONSTANT: kIOHIDElementKey                    "Elements"

CONSTANT: kIOHIDElementCookieKey                      "ElementCookie"
CONSTANT: kIOHIDElementTypeKey                        "Type"
CONSTANT: kIOHIDElementCollectionTypeKey              "CollectionType"
CONSTANT: kIOHIDElementUsageKey                       "Usage"
CONSTANT: kIOHIDElementUsagePageKey                   "UsagePage"
CONSTANT: kIOHIDElementMinKey                         "Min"
CONSTANT: kIOHIDElementMaxKey                         "Max"
CONSTANT: kIOHIDElementScaledMinKey                   "ScaledMin"
CONSTANT: kIOHIDElementScaledMaxKey                   "ScaledMax"
CONSTANT: kIOHIDElementSizeKey                        "Size"
CONSTANT: kIOHIDElementReportSizeKey                  "ReportSize"
CONSTANT: kIOHIDElementReportCountKey                 "ReportCount"
CONSTANT: kIOHIDElementReportIDKey                    "ReportID"
CONSTANT: kIOHIDElementIsArrayKey                     "IsArray"
CONSTANT: kIOHIDElementIsRelativeKey                  "IsRelative"
CONSTANT: kIOHIDElementIsWrappingKey                  "IsWrapping"
CONSTANT: kIOHIDElementIsNonLinearKey                 "IsNonLinear"
CONSTANT: kIOHIDElementHasPreferredStateKey           "HasPreferredState"
CONSTANT: kIOHIDElementHasNullStateKey                "HasNullState"
CONSTANT: kIOHIDElementFlagsKey                       "Flags"
CONSTANT: kIOHIDElementUnitKey                        "Unit"
CONSTANT: kIOHIDElementUnitExponentKey                "UnitExponent"
CONSTANT: kIOHIDElementNameKey                        "Name"
CONSTANT: kIOHIDElementValueLocationKey               "ValueLocation"
CONSTANT: kIOHIDElementDuplicateIndexKey              "DuplicateIndex"
CONSTANT: kIOHIDElementParentCollectionKey            "ParentCollection"

: kIOHIDElementVendorSpecificKey ( -- str )
    cpu ppc? "VendorSpecifc" "VendorSpecific" ? ; inline

CONSTANT: kIOHIDElementCookieMinKey           "ElementCookieMin"
CONSTANT: kIOHIDElementCookieMaxKey           "ElementCookieMax"
CONSTANT: kIOHIDElementUsageMinKey            "UsageMin"
CONSTANT: kIOHIDElementUsageMaxKey            "UsageMax"

CONSTANT: kIOHIDElementCalibrationMinKey              "CalibrationMin"
CONSTANT: kIOHIDElementCalibrationMaxKey              "CalibrationMax"
CONSTANT: kIOHIDElementCalibrationSaturationMinKey    "CalibrationSaturationMin"
CONSTANT: kIOHIDElementCalibrationSaturationMaxKey    "CalibrationSaturationMax"
CONSTANT: kIOHIDElementCalibrationDeadZoneMinKey      "CalibrationDeadZoneMin"
CONSTANT: kIOHIDElementCalibrationDeadZoneMaxKey      "CalibrationDeadZoneMax"
CONSTANT: kIOHIDElementCalibrationGranularityKey      "CalibrationGranularity"

CONSTANT: kIOHIDElementTypeInput_Misc        1
CONSTANT: kIOHIDElementTypeInput_Button      2
CONSTANT: kIOHIDElementTypeInput_Axis        3
CONSTANT: kIOHIDElementTypeInput_ScanCodes   4
CONSTANT: kIOHIDElementTypeOutput            129
CONSTANT: kIOHIDElementTypeFeature           257
CONSTANT: kIOHIDElementTypeCollection        513

CONSTANT: kIOHIDElementCollectionTypePhysical     HEX: 00
CONSTANT: kIOHIDElementCollectionTypeApplication    HEX: 01
CONSTANT: kIOHIDElementCollectionTypeLogical        HEX: 02
CONSTANT: kIOHIDElementCollectionTypeReport         HEX: 03
CONSTANT: kIOHIDElementCollectionTypeNamedArray     HEX: 04
CONSTANT: kIOHIDElementCollectionTypeUsageSwitch    HEX: 05
CONSTANT: kIOHIDElementCollectionTypeUsageModifier  HEX: 06

CONSTANT: kIOHIDReportTypeInput    0
CONSTANT: kIOHIDReportTypeOutput   1
CONSTANT: kIOHIDReportTypeFeature  2
CONSTANT: kIOHIDReportTypeCount    3

CONSTANT: kIOHIDOptionsTypeNone        HEX: 00
CONSTANT: kIOHIDOptionsTypeSeizeDevice HEX: 01

CONSTANT: kIOHIDQueueOptionsTypeNone    HEX: 00
CONSTANT: kIOHIDQueueOptionsTypeEnqueueAll HEX: 01

CONSTANT: kIOHIDElementFlagsConstantMask        HEX: 0001
CONSTANT: kIOHIDElementFlagsVariableMask        HEX: 0002
CONSTANT: kIOHIDElementFlagsRelativeMask        HEX: 0004
CONSTANT: kIOHIDElementFlagsWrapMask            HEX: 0008
CONSTANT: kIOHIDElementFlagsNonLinearMask       HEX: 0010
CONSTANT: kIOHIDElementFlagsNoPreferredMask     HEX: 0020
CONSTANT: kIOHIDElementFlagsNullStateMask       HEX: 0040
CONSTANT: kIOHIDElementFlagsVolativeMask        HEX: 0080
CONSTANT: kIOHIDElementFlagsBufferedByteMask    HEX: 0100

CONSTANT: kIOHIDValueScaleTypeCalibrated 0
CONSTANT: kIOHIDValueScaleTypePhysical   1

CONSTANT: kIOHIDTransactionDirectionTypeInput  0
CONSTANT: kIOHIDTransactionDirectionTypeOutput 1

CONSTANT: kIOHIDTransactionOptionDefaultOutputValue 1

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

