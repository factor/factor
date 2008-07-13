USING: iokit alien.syntax alien.c-types kernel system ;
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
: kIOHIDMaxOutputReportSizeKey	      "MaxOutputReportSize" ; inline
: kIOHIDMaxFeatureReportSizeKey	      "MaxFeatureReportSize" ; inline
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

: kIOHIDElementVendorSpecificKey
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

TYPEDEF: ptrdiff_t IOHIDElementCookie
TYPEDEF: int IOHIDElementType
TYPEDEF: int IOHIDElementCollectionType
TYPEDEF: int IOHIDReportType
TYPEDEF: uint IOHIDOptionsType
TYPEDEF: uint IOHIDQueueOptionsType
TYPEDEF: uint IOHIDElementFlags

: kIOHIDElementTypeInput_Misc        1 ; inline
: kIOHIDElementTypeInput_Button      2 ; inline
: kIOHIDElementTypeInput_Axis        3 ; inline
: kIOHIDElementTypeInput_ScanCodes   4 ; inline
: kIOHIDElementTypeOutput            129 ; inline
: kIOHIDElementTypeFeature           257 ; inline
: kIOHIDElementTypeCollection        513 ; inline

: kIOHIDElementCollectionTypePhysical	    HEX: 00 ; inline
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

: kIOHIDOptionsTypeNone	       HEX: 00 ; inline
: kIOHIDOptionsTypeSeizeDevice HEX: 01 ; inline

: kIOHIDQueueOptionsTypeNone	   HEX: 00 ; inline
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
