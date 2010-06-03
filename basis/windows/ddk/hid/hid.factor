! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct kernel math windows.types windows.ole32 ;
IN: windows.ddk.hid

<< "hid" "hid.dll" stdcall add-library >>
LIBRARY: hid

TYPEDEF: LONG   NTSTATUS
TYPEDEF: USHORT USAGE
TYPEDEF: USAGE* PUSAGE

CONSTANT: HID_USAGE_PAGE_UNDEFINED      HEX: 00
CONSTANT: HID_USAGE_PAGE_GENERIC        HEX: 01
CONSTANT: HID_USAGE_PAGE_SIMULATION     HEX: 02
CONSTANT: HID_USAGE_PAGE_VR             HEX: 03
CONSTANT: HID_USAGE_PAGE_SPORT          HEX: 04
CONSTANT: HID_USAGE_PAGE_GAME           HEX: 05
CONSTANT: HID_USAGE_PAGE_KEYBOARD       HEX: 07
CONSTANT: HID_USAGE_PAGE_LED            HEX: 08
CONSTANT: HID_USAGE_PAGE_BUTTON         HEX: 09
CONSTANT: HID_USAGE_PAGE_ORDINAL        HEX: 0A
CONSTANT: HID_USAGE_PAGE_TELEPHONY      HEX: 0B
CONSTANT: HID_USAGE_PAGE_CONSUMER       HEX: 0C
CONSTANT: HID_USAGE_PAGE_DIGITIZER      HEX: 0D
CONSTANT: HID_USAGE_PAGE_UNICODE        HEX: 10
CONSTANT: HID_USAGE_PAGE_ALPHANUMERIC   HEX: 14

CONSTANT: HID_USAGE_PAGE_MICROSOFT_BLUETOOTH_HANDSFREE  HEX: FFF3

CONSTANT: HID_USAGE_GENERIC_POINTER      HEX: 01
CONSTANT: HID_USAGE_GENERIC_MOUSE        HEX: 02
CONSTANT: HID_USAGE_GENERIC_JOYSTICK     HEX: 04
CONSTANT: HID_USAGE_GENERIC_GAMEPAD      HEX: 05
CONSTANT: HID_USAGE_GENERIC_KEYBOARD     HEX: 06
CONSTANT: HID_USAGE_GENERIC_KEYPAD       HEX: 07
CONSTANT: HID_USAGE_GENERIC_SYSTEM_CTL   HEX: 80

CONSTANT: HID_USAGE_GENERIC_X                        HEX: 30
CONSTANT: HID_USAGE_GENERIC_Y                        HEX: 31
CONSTANT: HID_USAGE_GENERIC_Z                        HEX: 32
CONSTANT: HID_USAGE_GENERIC_RX                       HEX: 33
CONSTANT: HID_USAGE_GENERIC_RY                       HEX: 34
CONSTANT: HID_USAGE_GENERIC_RZ                       HEX: 35
CONSTANT: HID_USAGE_GENERIC_SLIDER                   HEX: 36
CONSTANT: HID_USAGE_GENERIC_DIAL                     HEX: 37
CONSTANT: HID_USAGE_GENERIC_WHEEL                    HEX: 38
CONSTANT: HID_USAGE_GENERIC_HATSWITCH                HEX: 39
CONSTANT: HID_USAGE_GENERIC_COUNTED_BUFFER           HEX: 3A
CONSTANT: HID_USAGE_GENERIC_BYTE_COUNT               HEX: 3B
CONSTANT: HID_USAGE_GENERIC_MOTION_WAKEUP            HEX: 3C
CONSTANT: HID_USAGE_GENERIC_VX                       HEX: 40
CONSTANT: HID_USAGE_GENERIC_VY                       HEX: 41
CONSTANT: HID_USAGE_GENERIC_VZ                       HEX: 42
CONSTANT: HID_USAGE_GENERIC_VBRX                     HEX: 43
CONSTANT: HID_USAGE_GENERIC_VBRY                     HEX: 44
CONSTANT: HID_USAGE_GENERIC_VBRZ                     HEX: 45
CONSTANT: HID_USAGE_GENERIC_VNO                      HEX: 46
CONSTANT: HID_USAGE_GENERIC_SYSCTL_POWER             HEX: 81
CONSTANT: HID_USAGE_GENERIC_SYSCTL_SLEEP             HEX: 82
CONSTANT: HID_USAGE_GENERIC_SYSCTL_WAKE              HEX: 83
CONSTANT: HID_USAGE_GENERIC_SYSCTL_CONTEXT_MENU      HEX: 84
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MAIN_MENU         HEX: 85
CONSTANT: HID_USAGE_GENERIC_SYSCTL_APP_MENU          HEX: 86
CONSTANT: HID_USAGE_GENERIC_SYSCTL_HELP_MENU         HEX: 87
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_EXIT         HEX: 88
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_SELECT       HEX: 89
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_RIGHT        HEX: 8A
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_LEFT         HEX: 8B
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_UP           HEX: 8C
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_DOWN         HEX: 8D

CONSTANT: HID_USAGE_SIMULATION_RUDDER                HEX: BA
CONSTANT: HID_USAGE_SIMULATION_THROTTLE              HEX: BB

CONSTANT: HID_USAGE_KEYBOARD_NOEVENT     HEX: 00
CONSTANT: HID_USAGE_KEYBOARD_ROLLOVER    HEX: 01
CONSTANT: HID_USAGE_KEYBOARD_POSTFAIL    HEX: 02
CONSTANT: HID_USAGE_KEYBOARD_UNDEFINED   HEX: 03

CONSTANT: HID_USAGE_KEYBOARD_aA          HEX: 04
CONSTANT: HID_USAGE_KEYBOARD_zZ          HEX: 1D
CONSTANT: HID_USAGE_KEYBOARD_ONE         HEX: 1E
CONSTANT: HID_USAGE_KEYBOARD_ZERO        HEX: 27
CONSTANT: HID_USAGE_KEYBOARD_LCTRL       HEX: E0
CONSTANT: HID_USAGE_KEYBOARD_LSHFT       HEX: E1
CONSTANT: HID_USAGE_KEYBOARD_LALT        HEX: E2
CONSTANT: HID_USAGE_KEYBOARD_LGUI        HEX: E3
CONSTANT: HID_USAGE_KEYBOARD_RCTRL       HEX: E4
CONSTANT: HID_USAGE_KEYBOARD_RSHFT       HEX: E5
CONSTANT: HID_USAGE_KEYBOARD_RALT        HEX: E6
CONSTANT: HID_USAGE_KEYBOARD_RGUI        HEX: E7
CONSTANT: HID_USAGE_KEYBOARD_SCROLL_LOCK HEX: 47
CONSTANT: HID_USAGE_KEYBOARD_NUM_LOCK    HEX: 53
CONSTANT: HID_USAGE_KEYBOARD_CAPS_LOCK   HEX: 39
CONSTANT: HID_USAGE_KEYBOARD_F1          HEX: 3A
CONSTANT: HID_USAGE_KEYBOARD_F12         HEX: 45
CONSTANT: HID_USAGE_KEYBOARD_RETURN      HEX: 28
CONSTANT: HID_USAGE_KEYBOARD_ESCAPE      HEX: 29
CONSTANT: HID_USAGE_KEYBOARD_DELETE      HEX: 2A
CONSTANT: HID_USAGE_KEYBOARD_PRINT_SCREEN HEX: 46

CONSTANT: HID_USAGE_LED_NUM_LOCK               HEX: 01
CONSTANT: HID_USAGE_LED_CAPS_LOCK              HEX: 02
CONSTANT: HID_USAGE_LED_SCROLL_LOCK            HEX: 03
CONSTANT: HID_USAGE_LED_COMPOSE                HEX: 04
CONSTANT: HID_USAGE_LED_KANA                   HEX: 05
CONSTANT: HID_USAGE_LED_POWER                  HEX: 06
CONSTANT: HID_USAGE_LED_SHIFT                  HEX: 07
CONSTANT: HID_USAGE_LED_DO_NOT_DISTURB         HEX: 08
CONSTANT: HID_USAGE_LED_MUTE                   HEX: 09
CONSTANT: HID_USAGE_LED_TONE_ENABLE            HEX: 0A
CONSTANT: HID_USAGE_LED_HIGH_CUT_FILTER        HEX: 0B
CONSTANT: HID_USAGE_LED_LOW_CUT_FILTER         HEX: 0C
CONSTANT: HID_USAGE_LED_EQUALIZER_ENABLE       HEX: 0D
CONSTANT: HID_USAGE_LED_SOUND_FIELD_ON         HEX: 0E
CONSTANT: HID_USAGE_LED_SURROUND_FIELD_ON      HEX: 0F
CONSTANT: HID_USAGE_LED_REPEAT                 HEX: 10
CONSTANT: HID_USAGE_LED_STEREO                 HEX: 11
CONSTANT: HID_USAGE_LED_SAMPLING_RATE_DETECT   HEX: 12
CONSTANT: HID_USAGE_LED_SPINNING               HEX: 13
CONSTANT: HID_USAGE_LED_CAV                    HEX: 14
CONSTANT: HID_USAGE_LED_CLV                    HEX: 15
CONSTANT: HID_USAGE_LED_RECORDING_FORMAT_DET   HEX: 16
CONSTANT: HID_USAGE_LED_OFF_HOOK               HEX: 17
CONSTANT: HID_USAGE_LED_RING                   HEX: 18
CONSTANT: HID_USAGE_LED_MESSAGE_WAITING        HEX: 19
CONSTANT: HID_USAGE_LED_DATA_MODE              HEX: 1A
CONSTANT: HID_USAGE_LED_BATTERY_OPERATION      HEX: 1B
CONSTANT: HID_USAGE_LED_BATTERY_OK             HEX: 1C
CONSTANT: HID_USAGE_LED_BATTERY_LOW            HEX: 1D
CONSTANT: HID_USAGE_LED_SPEAKER                HEX: 1E
CONSTANT: HID_USAGE_LED_HEAD_SET               HEX: 1F
CONSTANT: HID_USAGE_LED_HOLD                   HEX: 20
CONSTANT: HID_USAGE_LED_MICROPHONE             HEX: 21
CONSTANT: HID_USAGE_LED_COVERAGE               HEX: 22
CONSTANT: HID_USAGE_LED_NIGHT_MODE             HEX: 23
CONSTANT: HID_USAGE_LED_SEND_CALLS             HEX: 24
CONSTANT: HID_USAGE_LED_CALL_PICKUP            HEX: 25
CONSTANT: HID_USAGE_LED_CONFERENCE             HEX: 26
CONSTANT: HID_USAGE_LED_STAND_BY               HEX: 27
CONSTANT: HID_USAGE_LED_CAMERA_ON              HEX: 28
CONSTANT: HID_USAGE_LED_CAMERA_OFF             HEX: 29
CONSTANT: HID_USAGE_LED_ON_LINE                HEX: 2A
CONSTANT: HID_USAGE_LED_OFF_LINE               HEX: 2B
CONSTANT: HID_USAGE_LED_BUSY                   HEX: 2C
CONSTANT: HID_USAGE_LED_READY                  HEX: 2D
CONSTANT: HID_USAGE_LED_PAPER_OUT              HEX: 2E
CONSTANT: HID_USAGE_LED_PAPER_JAM              HEX: 2F
CONSTANT: HID_USAGE_LED_REMOTE                 HEX: 30
CONSTANT: HID_USAGE_LED_FORWARD                HEX: 31
CONSTANT: HID_USAGE_LED_REVERSE                HEX: 32
CONSTANT: HID_USAGE_LED_STOP                   HEX: 33
CONSTANT: HID_USAGE_LED_REWIND                 HEX: 34
CONSTANT: HID_USAGE_LED_FAST_FORWARD           HEX: 35
CONSTANT: HID_USAGE_LED_PLAY                   HEX: 36
CONSTANT: HID_USAGE_LED_PAUSE                  HEX: 37
CONSTANT: HID_USAGE_LED_RECORD                 HEX: 38
CONSTANT: HID_USAGE_LED_ERROR                  HEX: 39
CONSTANT: HID_USAGE_LED_SELECTED_INDICATOR     HEX: 3A
CONSTANT: HID_USAGE_LED_IN_USE_INDICATOR       HEX: 3B
CONSTANT: HID_USAGE_LED_MULTI_MODE_INDICATOR   HEX: 3C
CONSTANT: HID_USAGE_LED_INDICATOR_ON           HEX: 3D
CONSTANT: HID_USAGE_LED_INDICATOR_FLASH        HEX: 3E
CONSTANT: HID_USAGE_LED_INDICATOR_SLOW_BLINK   HEX: 3F
CONSTANT: HID_USAGE_LED_INDICATOR_FAST_BLINK   HEX: 40
CONSTANT: HID_USAGE_LED_INDICATOR_OFF          HEX: 41
CONSTANT: HID_USAGE_LED_FLASH_ON_TIME          HEX: 42
CONSTANT: HID_USAGE_LED_SLOW_BLINK_ON_TIME     HEX: 43
CONSTANT: HID_USAGE_LED_SLOW_BLINK_OFF_TIME    HEX: 44
CONSTANT: HID_USAGE_LED_FAST_BLINK_ON_TIME     HEX: 45
CONSTANT: HID_USAGE_LED_FAST_BLINK_OFF_TIME    HEX: 46
CONSTANT: HID_USAGE_LED_INDICATOR_COLOR        HEX: 47
CONSTANT: HID_USAGE_LED_RED                    HEX: 48
CONSTANT: HID_USAGE_LED_GREEN                  HEX: 49
CONSTANT: HID_USAGE_LED_AMBER                  HEX: 4A
CONSTANT: HID_USAGE_LED_GENERIC_INDICATOR      HEX: 4B

CONSTANT: HID_USAGE_TELEPHONY_PHONE                  HEX: 01
CONSTANT: HID_USAGE_TELEPHONY_ANSWERING_MACHINE      HEX: 02
CONSTANT: HID_USAGE_TELEPHONY_MESSAGE_CONTROLS       HEX: 03
CONSTANT: HID_USAGE_TELEPHONY_HANDSET                HEX: 04
CONSTANT: HID_USAGE_TELEPHONY_HEADSET                HEX: 05
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD                 HEX: 06
CONSTANT: HID_USAGE_TELEPHONY_PROGRAMMABLE_BUTTON    HEX: 07
CONSTANT: HID_USAGE_TELEPHONY_REDIAL                 HEX: 24
CONSTANT: HID_USAGE_TELEPHONY_TRANSFER               HEX: 25
CONSTANT: HID_USAGE_TELEPHONY_DROP                   HEX: 26
CONSTANT: HID_USAGE_TELEPHONY_LINE                   HEX: 2A
CONSTANT: HID_USAGE_TELEPHONY_RING_ENABLE            HEX: 2D
CONSTANT: HID_USAGE_TELEPHONY_SEND                   HEX: 31
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD_0               HEX: B0
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD_D               HEX: BF
CONSTANT: HID_USAGE_TELEPHONY_HOST_AVAILABLE         HEX: F1

CONSTANT: HID_USAGE_MS_BTH_HF_DIALNUMBER             HEX: 21
CONSTANT: HID_USAGE_MS_BTH_HF_DIALMEMORY             HEX: 22

CONSTANT: HID_USAGE_CONSUMERCTRL          HEX: 01
CONSTANT: HID_USAGE_DIGITIZER_PEN         HEX: 02
CONSTANT: HID_USAGE_DIGITIZER_IN_RANGE    HEX: 32
CONSTANT: HID_USAGE_DIGITIZER_TIP_SWITCH  HEX: 42
CONSTANT: HID_USAGE_DIGITIZER_BARREL_SWITCH HEX: 44

CONSTANT: HIDP_LINK_COLLECTION_ROOT        -1
CONSTANT: HIDP_LINK_COLLECTION_UNSPECIFIED 0

ENUM: HIDP_REPORT_TYPE
    HidP_Input
    HidP_Output
    HidP_Feature ;

STRUCT: USAGE_AND_PAGE
    { Usage     USAGE }
    { UsagePage USAGE } ;
TYPEDEF: USAGE_AND_PAGE* PUSAGE_AND_PAGE

: HidP_IsSameUsageAndPage ( u1 u2 -- ? ) = ; inline

STRUCT: HIDP_BUTTONS_CAPS_range
    { UsageMin        USAGE  }
    { UsageMax        USAGE  }
    { StringMin       USHORT }
    { StringMax       USHORT }
    { DesignatorMin   USHORT }
    { DesignatorMax   USHORT }
    { DataIndexMin    USHORT }
    { DataIndexMax    USHORT } ;

STRUCT: HIDP_BUTTONS_CAPS_not_range
    { Usage           USAGE  }
    { Reserved1       USAGE  }
    { StringIndex     USHORT }
    { Reserved2       USHORT }
    { DesignatorIndex USHORT }
    { Reserved3       USHORT }
    { DataIndex       USHORT }
    { Reserved4       USHORT } ;

UNION-STRUCT: HIDP_BUTTONS_CAPS_union
    { Range    HIDP_BUTTONS_CAPS_range     }
    { NotRange HIDP_BUTTONS_CAPS_not_range } ;

STRUCT: HIDP_BUTTON_CAPS
    { UsagePage          USAGE                   }
    { ReportID           UCHAR                   }
    { IsAlias            BOOLEAN                 }
    { BitField           USHORT                  }
    { LinkCollection     USHORT                  }
    { LinkUsage          USAGE                   }
    { LinkUsagePage      USAGE                   }
    { IsRange            BOOLEAN                 }
    { IsStringRange      BOOLEAN                 }
    { IsDesignatorRange  BOOLEAN                 }
    { IsAbsolute         BOOLEAN                 }
    { Reserved           ULONG[10]               }
    { Union              HIDP_BUTTONS_CAPS_union } ;
TYPEDEF: HIDP_BUTTON_CAPS* PHIDP_BUTTON_CAPS

STRUCT: HIDP_VALUE_CAPS_range
    { UsageMin        USAGE  }
    { UsageMax        USAGE  }
    { StringMin       USHORT }
    { StringMax       USHORT }
    { DesignatorMin   USHORT }
    { DesignatorMax   USHORT }
    { DataIndexMin    USHORT }
    { DataIndexMax    USHORT } ;

STRUCT: HIDP_VALUE_CAPS_not_range
    { Usage             USAGE  }
    { Reserved1         USAGE  }
    { StringIndex       USHORT }
    { Reserved2         USHORT }
    { DesignatorIndex   USHORT }
    { Reserved3         USHORT }
    { DataIndex         USHORT }
    { Reserved4         USHORT } ;

UNION-STRUCT: HIDP_VALUE_CAPS_union
    { Range    HIDP_VALUE_CAPS_range     }
    { NotRange HIDP_VALUE_CAPS_not_range } ;

STRUCT: HIDP_VALUE_CAPS
    { UsagePage          USAGE                  }
    { ReportID           UCHAR                  }
    { IsAlias            BOOLEAN                }
    { BitField           USHORT                 }
    { LinkCollection     USHORT                 }
    { LinkUsage          USAGE                  }
    { LinkUsagePage      USAGE                  }
    { IsRange            BOOLEAN                }
    { IsStringRange      BOOLEAN                }
    { IsDesignatorRange  BOOLEAN                }
    { IsAbsolute         BOOLEAN                }
    { HasNull            BOOLEAN                }
    { Reserved           UCHAR                  }
    { BitSize            USHORT                 }
    { ReportCount        USHORT                 }
    { Reserved2          USHORT[5]              }
    { UnitsExp           ULONG                  }
    { Units              ULONG                  }
    { LogicalMin         LONG                   }
    { LogicalMax         LONG                   }
    { PhysicalMin        LONG                   }
    { PhysicalMax        LONG                   }
    { Union              HIDP_VALUE_CAPS_union  } ;
TYPEDEF: HIDP_VALUE_CAPS* PHIDP_VALUE_CAPS

STRUCT: HIDP_LINK_COLLECTION_NODE
    { LinkUsage                        USAGE  }
    { LinkUsagePage                    USAGE  }
    { Parent                           USHORT }
    { NumberOfChildren                 USHORT }
    { NextSibling                      USHORT }
    { FirstChild                       USHORT }
    { CollectionTypeIsAliasBitfield    ULONG  }
    { UserContext                      PVOID  } ;
TYPEDEF: HIDP_LINK_COLLECTION_NODE* PHIDP_LINK_COLLECTION_NODE

TYPEDEF: PUCHAR PHIDP_REPORT_DESCRIPTOR
C-TYPE: HIDP_PREPARSED_DATA
TYPEDEF: HIDP_PREPARSED_DATA* PHIDP_PREPARSED_DATA

STRUCT: HIDP_CAPS
    { Usage                       USAGE      }
    { UsagePage                   USAGE      }
    { InputReportByteLength       USHORT     }
    { OutputReportByteLength      USHORT     }
    { FeatureReportByteLength     USHORT     }
    { Reserved                    USHORT[17] }
    { NumberLinkCollectionNodes   USHORT     }
    { NumberInputButtonCaps       USHORT     }
    { NumberInputValueCaps        USHORT     }
    { NumberInputDataIndices      USHORT     }
    { NumberOutputButtonCaps      USHORT     }
    { NumberOutputValueCaps       USHORT     }
    { NumberOutputDataIndices     USHORT     }
    { NumberFeatureButtonCaps     USHORT     }
    { NumberFeatureValueCaps      USHORT     }
    { NumberFeatureDataIndices    USHORT     } ;
TYPEDEF: HIDP_CAPS* PHIDP_CAPS

STRUCT: HIDP_DATA
    { DataIndex  USHORT }
    { Reserved   USHORT }
    { RawValue   ULONG  } ;
TYPEDEF: HIDP_DATA* PHIDP_DATA

STRUCT: HIDP_UNKNOWN_TOKEN
    { Token     UCHAR    }
    { Reserved  UCHAR[3] }
    { BitField  ULONG    } ;
TYPEDEF: HIDP_UNKNOWN_TOKEN* PHIDP_UNKNOWN_TOKEN

STRUCT: HIDP_EXTENDED_ATTRIBUTES
    { NumGlobalUnknowns   UCHAR               }
    { Reserved            UCHAR[3]            }
    { GlobalUnknowns      PHIDP_UNKNOWN_TOKEN }
    { Data                ULONG[1]            } ;
TYPEDEF: HIDP_EXTENDED_ATTRIBUTES* PHIDP_EXTENDED_ATTRIBUTES

FUNCTION: NTSTATUS
HidP_GetCaps (
   PHIDP_PREPARSED_DATA      PreparsedData,
   PHIDP_CAPS                Capabilities
   ) ;

FUNCTION: NTSTATUS
HidP_GetLinkCollectionNodes (
   PHIDP_LINK_COLLECTION_NODE LinkCollectionNodes,
   PULONG                     LinkCollectionNodesLength,
   PHIDP_PREPARSED_DATA       PreparsedData
   ) ;

FUNCTION: NTSTATUS
HidP_GetSpecificButtonCaps (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   USAGE                Usage,
   PHIDP_BUTTON_CAPS    ButtonCaps,
   PUSHORT              ButtonCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
   ) ;

FUNCTION: NTSTATUS
HidP_GetButtonCaps (
   HIDP_REPORT_TYPE     ReportType,
   PHIDP_BUTTON_CAPS    ButtonCaps,
   PUSHORT              ButtonCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
) ;

FUNCTION: NTSTATUS
HidP_GetSpecificValueCaps (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   USAGE                Usage,
   PHIDP_VALUE_CAPS     ValueCaps,
   PUSHORT              ValueCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
   ) ;

FUNCTION: NTSTATUS
HidP_GetValueCaps (
   HIDP_REPORT_TYPE     ReportType,
   PHIDP_VALUE_CAPS     ValueCaps,
   PUSHORT              ValueCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
) ;

FUNCTION: NTSTATUS
HidP_GetExtendedAttributes (
    HIDP_REPORT_TYPE            ReportType,
    USHORT                      DataIndex,
    PHIDP_PREPARSED_DATA        PreparsedData,
    PHIDP_EXTENDED_ATTRIBUTES   Attributes,
    PULONG                      LengthAttributes
    ) ;

FUNCTION: NTSTATUS
HidP_InitializeReportForID (
   HIDP_REPORT_TYPE     ReportType,
   UCHAR                ReportID,
   PHIDP_PREPARSED_DATA PreparsedData,
   PCHAR                Report,
   ULONG                ReportLength
   ) ;

FUNCTION: NTSTATUS
HidP_SetData (
    HIDP_REPORT_TYPE     ReportType,
    PHIDP_DATA           DataList,
    PULONG               DataLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_GetData (
    HIDP_REPORT_TYPE     ReportType,
    PHIDP_DATA           DataList,
    PULONG               DataLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: ULONG
HidP_MaxDataListLength (
   HIDP_REPORT_TYPE      ReportType,
   PHIDP_PREPARSED_DATA  PreparsedData
   ) ;

FUNCTION: NTSTATUS
HidP_SetUsages (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   PUSAGE               UsageList,
   PULONG               UsageLength,
   PHIDP_PREPARSED_DATA PreparsedData,
   PCHAR                Report,
   ULONG                ReportLength
   ) ;
ALIAS: HidP_SetButtons HidP_SetUsages

FUNCTION: NTSTATUS
HidP_UnsetUsages (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   PUSAGE               UsageList,
   PULONG               UsageLength,
   PHIDP_PREPARSED_DATA PreparsedData,
   PCHAR                Report,
   ULONG                ReportLength
   ) ;
ALIAS: HidP_UnsetButtons HidP_UnsetUsages

FUNCTION: NTSTATUS
HidP_GetUsages (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   PUSAGE               UsageList,
   PULONG               UsageLength,
   PHIDP_PREPARSED_DATA PreparsedData,
   PCHAR                Report,
   ULONG                ReportLength
   ) ;
ALIAS: HidP_GetButtons HidP_GetUsages

FUNCTION: NTSTATUS
HidP_GetUsagesEx (
    HIDP_REPORT_TYPE     ReportType,
    USHORT               LinkCollection,
    PUSAGE_AND_PAGE      ButtonList,
    ULONG*               UsageLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
   ) ;
ALIAS: HidP_GetButtonsEx HidP_GetUsagesEx

FUNCTION: ULONG
HidP_MaxUsageListLength (
   HIDP_REPORT_TYPE      ReportType,
   USAGE                 UsagePage,
   PHIDP_PREPARSED_DATA  PreparsedData
   ) ;

FUNCTION: NTSTATUS
HidP_SetUsageValue (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    ULONG                UsageValue,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_SetScaledUsageValue (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    LONG                 UsageValue,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_SetUsageValueArray (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    PCHAR                UsageValue,
    USHORT               UsageValueByteLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;


FUNCTION: NTSTATUS
HidP_GetUsageValue (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    PULONG               UsageValue,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_GetScaledUsageValue (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    PLONG                UsageValue,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_GetUsageValueArray (
    HIDP_REPORT_TYPE     ReportType,
    USAGE                UsagePage,
    USHORT               LinkCollection,
    USAGE                Usage,
    PCHAR                UsageValue,
    USHORT               UsageValueByteLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    ) ;

FUNCTION: NTSTATUS
HidP_UsageListDifference (
   PUSAGE   PreviousUsageList,
   PUSAGE   CurrentUsageList,
   PUSAGE   BreakUsageList,
   PUSAGE   MakeUsageList,
   ULONG    UsageListLength
    ) ;

FUNCTION: NTSTATUS
HidP_UsageAndPageListDifference (
   PUSAGE_AND_PAGE PreviousUsageList,
   PUSAGE_AND_PAGE CurrentUsageList,
   PUSAGE_AND_PAGE BreakUsageList,
   PUSAGE_AND_PAGE MakeUsageList,
   ULONG           UsageListLength
   ) ;

ENUM: HIDP_KEYBOARD_DIRECTION
    HidP_Keyboard_Break
    HidP_Keyboard_Make ;

STRUCT: HIDP_KEYBOARD_MODIFIER_STATE
    { ul ULONG } ;
TYPEDEF: HIDP_KEYBOARD_MODIFIER_STATE* PHIDP_KEYBOARD_MODIFIER_STATE

CALLBACK: BOOLEAN PHIDP_INSERT_SCANCODES (
    PVOID Context,
    PCHAR NewScanCodes,
    ULONG Length ) ;

FUNCTION: NTSTATUS
HidP_TranslateUsageAndPagesToI8042ScanCodes (
    PUSAGE_AND_PAGE               ChangedUsageList,
    ULONG                         UsageListLength,
    HIDP_KEYBOARD_DIRECTION       KeyAction,
    PHIDP_KEYBOARD_MODIFIER_STATE ModifierState,
    PHIDP_INSERT_SCANCODES        InsertCodesProcedure,
    PVOID                         InsertCodesContext
    ) ;


FUNCTION: NTSTATUS
HidP_TranslateUsagesToI8042ScanCodes (
    PUSAGE                        ChangedUsageList,
    ULONG                         UsageListLength,
    HIDP_KEYBOARD_DIRECTION       KeyAction,
    PHIDP_KEYBOARD_MODIFIER_STATE ModifierState,
    PHIDP_INSERT_SCANCODES        InsertCodesProcedure,
    PVOID                         InsertCodesContext
    ) ;

CONSTANT: FACILITY_HID_ERROR_CODE HEX: 11
: HIDP_ERROR_CODES ( SEV CODE -- HRESULT )
    [ 28 shift ] dip bitor FACILITY_HID_ERROR_CODE 16 shift bitor ; inline
: HIDP_STATUS_SUCCESS                  ( -- HRESULT ) HEX: 0 HEX: 0 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NULL                     ( -- HRESULT ) HEX: 8 HEX: 1 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_PREPARSED_DATA   ( -- HRESULT ) HEX: C HEX: 1 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_REPORT_TYPE      ( -- HRESULT ) HEX: C HEX: 2 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_REPORT_LENGTH    ( -- HRESULT ) HEX: C HEX: 3 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_USAGE_NOT_FOUND          ( -- HRESULT ) HEX: C HEX: 4 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_VALUE_OUT_OF_RANGE       ( -- HRESULT ) HEX: C HEX: 5 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BAD_LOG_PHY_VALUES       ( -- HRESULT ) HEX: C HEX: 6 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BUFFER_TOO_SMALL         ( -- HRESULT ) HEX: C HEX: 7 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INTERNAL_ERROR           ( -- HRESULT ) HEX: C HEX: 8 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_I8042_TRANS_UNKNOWN      ( -- HRESULT ) HEX: C HEX: 9 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INCOMPATIBLE_REPORT_ID   ( -- HRESULT ) HEX: C HEX: A HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NOT_VALUE_ARRAY          ( -- HRESULT ) HEX: C HEX: B HIDP_ERROR_CODES ; inline
: HIDP_STATUS_IS_VALUE_ARRAY           ( -- HRESULT ) HEX: C HEX: C HIDP_ERROR_CODES ; inline
: HIDP_STATUS_DATA_INDEX_NOT_FOUND     ( -- HRESULT ) HEX: C HEX: D HIDP_ERROR_CODES ; inline
: HIDP_STATUS_DATA_INDEX_OUT_OF_RANGE  ( -- HRESULT ) HEX: C HEX: E HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BUTTON_NOT_PRESSED       ( -- HRESULT ) HEX: C HEX: F HIDP_ERROR_CODES ; inline
: HIDP_STATUS_REPORT_DOES_NOT_EXIST    ( -- HRESULT ) HEX: C HEX: 10 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NOT_IMPLEMENTED          ( -- HRESULT ) HEX: C HEX: 20 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_I8242_TRANS_UNKNOWN      ( -- HRESULT ) HIDP_STATUS_I8042_TRANS_UNKNOWN ; inline

STRUCT: HIDD_CONFIGURATION
    { cookie            PVOID }
    { size              ULONG }
    { RingBufferSize    ULONG } ;
TYPEDEF: HIDD_CONFIGURATION* PHIDD_CONFIGURATION

STRUCT: HIDD_ATTRIBUTES
    { Size           ULONG  }
    { VendorID       USHORT }
    { ProductID      USHORT }
    { VersionNumber  USHORT } ;
TYPEDEF: HIDD_ATTRIBUTES* PHIDD_ATTRIBUTES

FUNCTION: BOOLEAN
HidD_GetAttributes (
    HANDLE              HidDeviceObject,
    PHIDD_ATTRIBUTES    Attributes
    ) ;

FUNCTION: void
HidD_GetHidGuid (
   LPGUID   HidGuid
   ) ;

FUNCTION: BOOLEAN
HidD_GetPreparsedData (
   HANDLE                HidDeviceObject,
   PHIDP_PREPARSED_DATA* PreparsedData
   ) ;

FUNCTION: BOOLEAN
HidD_FreePreparsedData (
   PHIDP_PREPARSED_DATA PreparsedData
   ) ;

FUNCTION: BOOLEAN
HidD_FlushQueue (
   HANDLE                HidDeviceObject
   ) ;

FUNCTION: BOOLEAN
HidD_GetConfiguration (
   HANDLE               HidDeviceObject,
   PHIDD_CONFIGURATION  Configuration,
   ULONG                ConfigurationLength
   ) ;

FUNCTION: BOOLEAN
HidD_SetConfiguration (
   HANDLE               HidDeviceObject,
   PHIDD_CONFIGURATION  Configuration,
   ULONG                ConfigurationLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetFeature (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_SetFeature (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetInputReport (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_SetOutputReport (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetNumInputBuffers (
    HANDLE  HidDeviceObject,
    PULONG  NumberBuffers
    ) ;

FUNCTION: BOOLEAN
HidD_SetNumInputBuffers (
    HANDLE HidDeviceObject,
    ULONG  NumberBuffers
    ) ;

FUNCTION: BOOLEAN
HidD_GetPhysicalDescriptor (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetManufacturerString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetProductString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetIndexedString (
   HANDLE   HidDeviceObject,
   ULONG    StringIndex,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetSerialNumberString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;

FUNCTION: BOOLEAN
HidD_GetMsGenreDescriptor (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   ) ;
