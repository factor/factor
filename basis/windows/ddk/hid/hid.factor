! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct kernel math windows.types windows.ole32 ;
IN: windows.ddk.hid

<< "hid" "hid.dll" stdcall add-library >>
LIBRARY: hid

TYPEDEF: LONG   NTSTATUS
TYPEDEF: USHORT USAGE
TYPEDEF: USAGE* PUSAGE

CONSTANT: HID_USAGE_PAGE_UNDEFINED      0x00
CONSTANT: HID_USAGE_PAGE_GENERIC        0x01
CONSTANT: HID_USAGE_PAGE_SIMULATION     0x02
CONSTANT: HID_USAGE_PAGE_VR             0x03
CONSTANT: HID_USAGE_PAGE_SPORT          0x04
CONSTANT: HID_USAGE_PAGE_GAME           0x05
CONSTANT: HID_USAGE_PAGE_KEYBOARD       0x07
CONSTANT: HID_USAGE_PAGE_LED            0x08
CONSTANT: HID_USAGE_PAGE_BUTTON         0x09
CONSTANT: HID_USAGE_PAGE_ORDINAL        0x0A
CONSTANT: HID_USAGE_PAGE_TELEPHONY      0x0B
CONSTANT: HID_USAGE_PAGE_CONSUMER       0x0C
CONSTANT: HID_USAGE_PAGE_DIGITIZER      0x0D
CONSTANT: HID_USAGE_PAGE_UNICODE        0x10
CONSTANT: HID_USAGE_PAGE_ALPHANUMERIC   0x14

CONSTANT: HID_USAGE_PAGE_MICROSOFT_BLUETOOTH_HANDSFREE  0xFFF3

CONSTANT: HID_USAGE_GENERIC_POINTER      0x01
CONSTANT: HID_USAGE_GENERIC_MOUSE        0x02
CONSTANT: HID_USAGE_GENERIC_JOYSTICK     0x04
CONSTANT: HID_USAGE_GENERIC_GAMEPAD      0x05
CONSTANT: HID_USAGE_GENERIC_KEYBOARD     0x06
CONSTANT: HID_USAGE_GENERIC_KEYPAD       0x07
CONSTANT: HID_USAGE_GENERIC_SYSTEM_CTL   0x80

CONSTANT: HID_USAGE_GENERIC_X                        0x30
CONSTANT: HID_USAGE_GENERIC_Y                        0x31
CONSTANT: HID_USAGE_GENERIC_Z                        0x32
CONSTANT: HID_USAGE_GENERIC_RX                       0x33
CONSTANT: HID_USAGE_GENERIC_RY                       0x34
CONSTANT: HID_USAGE_GENERIC_RZ                       0x35
CONSTANT: HID_USAGE_GENERIC_SLIDER                   0x36
CONSTANT: HID_USAGE_GENERIC_DIAL                     0x37
CONSTANT: HID_USAGE_GENERIC_WHEEL                    0x38
CONSTANT: HID_USAGE_GENERIC_HATSWITCH                0x39
CONSTANT: HID_USAGE_GENERIC_COUNTED_BUFFER           0x3A
CONSTANT: HID_USAGE_GENERIC_BYTE_COUNT               0x3B
CONSTANT: HID_USAGE_GENERIC_MOTION_WAKEUP            0x3C
CONSTANT: HID_USAGE_GENERIC_VX                       0x40
CONSTANT: HID_USAGE_GENERIC_VY                       0x41
CONSTANT: HID_USAGE_GENERIC_VZ                       0x42
CONSTANT: HID_USAGE_GENERIC_VBRX                     0x43
CONSTANT: HID_USAGE_GENERIC_VBRY                     0x44
CONSTANT: HID_USAGE_GENERIC_VBRZ                     0x45
CONSTANT: HID_USAGE_GENERIC_VNO                      0x46
CONSTANT: HID_USAGE_GENERIC_SYSCTL_POWER             0x81
CONSTANT: HID_USAGE_GENERIC_SYSCTL_SLEEP             0x82
CONSTANT: HID_USAGE_GENERIC_SYSCTL_WAKE              0x83
CONSTANT: HID_USAGE_GENERIC_SYSCTL_CONTEXT_MENU      0x84
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MAIN_MENU         0x85
CONSTANT: HID_USAGE_GENERIC_SYSCTL_APP_MENU          0x86
CONSTANT: HID_USAGE_GENERIC_SYSCTL_HELP_MENU         0x87
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_EXIT         0x88
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_SELECT       0x89
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_RIGHT        0x8A
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_LEFT         0x8B
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_UP           0x8C
CONSTANT: HID_USAGE_GENERIC_SYSCTL_MENU_DOWN         0x8D

CONSTANT: HID_USAGE_SIMULATION_RUDDER                0xBA
CONSTANT: HID_USAGE_SIMULATION_THROTTLE              0xBB

CONSTANT: HID_USAGE_KEYBOARD_NOEVENT     0x00
CONSTANT: HID_USAGE_KEYBOARD_ROLLOVER    0x01
CONSTANT: HID_USAGE_KEYBOARD_POSTFAIL    0x02
CONSTANT: HID_USAGE_KEYBOARD_UNDEFINED   0x03

CONSTANT: HID_USAGE_KEYBOARD_aA          0x04
CONSTANT: HID_USAGE_KEYBOARD_zZ          0x1D
CONSTANT: HID_USAGE_KEYBOARD_ONE         0x1E
CONSTANT: HID_USAGE_KEYBOARD_ZERO        0x27
CONSTANT: HID_USAGE_KEYBOARD_LCTRL       0xE0
CONSTANT: HID_USAGE_KEYBOARD_LSHFT       0xE1
CONSTANT: HID_USAGE_KEYBOARD_LALT        0xE2
CONSTANT: HID_USAGE_KEYBOARD_LGUI        0xE3
CONSTANT: HID_USAGE_KEYBOARD_RCTRL       0xE4
CONSTANT: HID_USAGE_KEYBOARD_RSHFT       0xE5
CONSTANT: HID_USAGE_KEYBOARD_RALT        0xE6
CONSTANT: HID_USAGE_KEYBOARD_RGUI        0xE7
CONSTANT: HID_USAGE_KEYBOARD_SCROLL_LOCK 0x47
CONSTANT: HID_USAGE_KEYBOARD_NUM_LOCK    0x53
CONSTANT: HID_USAGE_KEYBOARD_CAPS_LOCK   0x39
CONSTANT: HID_USAGE_KEYBOARD_F1          0x3A
CONSTANT: HID_USAGE_KEYBOARD_F12         0x45
CONSTANT: HID_USAGE_KEYBOARD_RETURN      0x28
CONSTANT: HID_USAGE_KEYBOARD_ESCAPE      0x29
CONSTANT: HID_USAGE_KEYBOARD_DELETE      0x2A
CONSTANT: HID_USAGE_KEYBOARD_PRINT_SCREEN 0x46

CONSTANT: HID_USAGE_LED_NUM_LOCK               0x01
CONSTANT: HID_USAGE_LED_CAPS_LOCK              0x02
CONSTANT: HID_USAGE_LED_SCROLL_LOCK            0x03
CONSTANT: HID_USAGE_LED_COMPOSE                0x04
CONSTANT: HID_USAGE_LED_KANA                   0x05
CONSTANT: HID_USAGE_LED_POWER                  0x06
CONSTANT: HID_USAGE_LED_SHIFT                  0x07
CONSTANT: HID_USAGE_LED_DO_NOT_DISTURB         0x08
CONSTANT: HID_USAGE_LED_MUTE                   0x09
CONSTANT: HID_USAGE_LED_TONE_ENABLE            0x0A
CONSTANT: HID_USAGE_LED_HIGH_CUT_FILTER        0x0B
CONSTANT: HID_USAGE_LED_LOW_CUT_FILTER         0x0C
CONSTANT: HID_USAGE_LED_EQUALIZER_ENABLE       0x0D
CONSTANT: HID_USAGE_LED_SOUND_FIELD_ON         0x0E
CONSTANT: HID_USAGE_LED_SURROUND_FIELD_ON      0x0F
CONSTANT: HID_USAGE_LED_REPEAT                 0x10
CONSTANT: HID_USAGE_LED_STEREO                 0x11
CONSTANT: HID_USAGE_LED_SAMPLING_RATE_DETECT   0x12
CONSTANT: HID_USAGE_LED_SPINNING               0x13
CONSTANT: HID_USAGE_LED_CAV                    0x14
CONSTANT: HID_USAGE_LED_CLV                    0x15
CONSTANT: HID_USAGE_LED_RECORDING_FORMAT_DET   0x16
CONSTANT: HID_USAGE_LED_OFF_HOOK               0x17
CONSTANT: HID_USAGE_LED_RING                   0x18
CONSTANT: HID_USAGE_LED_MESSAGE_WAITING        0x19
CONSTANT: HID_USAGE_LED_DATA_MODE              0x1A
CONSTANT: HID_USAGE_LED_BATTERY_OPERATION      0x1B
CONSTANT: HID_USAGE_LED_BATTERY_OK             0x1C
CONSTANT: HID_USAGE_LED_BATTERY_LOW            0x1D
CONSTANT: HID_USAGE_LED_SPEAKER                0x1E
CONSTANT: HID_USAGE_LED_HEAD_SET               0x1F
CONSTANT: HID_USAGE_LED_HOLD                   0x20
CONSTANT: HID_USAGE_LED_MICROPHONE             0x21
CONSTANT: HID_USAGE_LED_COVERAGE               0x22
CONSTANT: HID_USAGE_LED_NIGHT_MODE             0x23
CONSTANT: HID_USAGE_LED_SEND_CALLS             0x24
CONSTANT: HID_USAGE_LED_CALL_PICKUP            0x25
CONSTANT: HID_USAGE_LED_CONFERENCE             0x26
CONSTANT: HID_USAGE_LED_STAND_BY               0x27
CONSTANT: HID_USAGE_LED_CAMERA_ON              0x28
CONSTANT: HID_USAGE_LED_CAMERA_OFF             0x29
CONSTANT: HID_USAGE_LED_ON_LINE                0x2A
CONSTANT: HID_USAGE_LED_OFF_LINE               0x2B
CONSTANT: HID_USAGE_LED_BUSY                   0x2C
CONSTANT: HID_USAGE_LED_READY                  0x2D
CONSTANT: HID_USAGE_LED_PAPER_OUT              0x2E
CONSTANT: HID_USAGE_LED_PAPER_JAM              0x2F
CONSTANT: HID_USAGE_LED_REMOTE                 0x30
CONSTANT: HID_USAGE_LED_FORWARD                0x31
CONSTANT: HID_USAGE_LED_REVERSE                0x32
CONSTANT: HID_USAGE_LED_STOP                   0x33
CONSTANT: HID_USAGE_LED_REWIND                 0x34
CONSTANT: HID_USAGE_LED_FAST_FORWARD           0x35
CONSTANT: HID_USAGE_LED_PLAY                   0x36
CONSTANT: HID_USAGE_LED_PAUSE                  0x37
CONSTANT: HID_USAGE_LED_RECORD                 0x38
CONSTANT: HID_USAGE_LED_ERROR                  0x39
CONSTANT: HID_USAGE_LED_SELECTED_INDICATOR     0x3A
CONSTANT: HID_USAGE_LED_IN_USE_INDICATOR       0x3B
CONSTANT: HID_USAGE_LED_MULTI_MODE_INDICATOR   0x3C
CONSTANT: HID_USAGE_LED_INDICATOR_ON           0x3D
CONSTANT: HID_USAGE_LED_INDICATOR_FLASH        0x3E
CONSTANT: HID_USAGE_LED_INDICATOR_SLOW_BLINK   0x3F
CONSTANT: HID_USAGE_LED_INDICATOR_FAST_BLINK   0x40
CONSTANT: HID_USAGE_LED_INDICATOR_OFF          0x41
CONSTANT: HID_USAGE_LED_FLASH_ON_TIME          0x42
CONSTANT: HID_USAGE_LED_SLOW_BLINK_ON_TIME     0x43
CONSTANT: HID_USAGE_LED_SLOW_BLINK_OFF_TIME    0x44
CONSTANT: HID_USAGE_LED_FAST_BLINK_ON_TIME     0x45
CONSTANT: HID_USAGE_LED_FAST_BLINK_OFF_TIME    0x46
CONSTANT: HID_USAGE_LED_INDICATOR_COLOR        0x47
CONSTANT: HID_USAGE_LED_RED                    0x48
CONSTANT: HID_USAGE_LED_GREEN                  0x49
CONSTANT: HID_USAGE_LED_AMBER                  0x4A
CONSTANT: HID_USAGE_LED_GENERIC_INDICATOR      0x4B

CONSTANT: HID_USAGE_TELEPHONY_PHONE                  0x01
CONSTANT: HID_USAGE_TELEPHONY_ANSWERING_MACHINE      0x02
CONSTANT: HID_USAGE_TELEPHONY_MESSAGE_CONTROLS       0x03
CONSTANT: HID_USAGE_TELEPHONY_HANDSET                0x04
CONSTANT: HID_USAGE_TELEPHONY_HEADSET                0x05
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD                 0x06
CONSTANT: HID_USAGE_TELEPHONY_PROGRAMMABLE_BUTTON    0x07
CONSTANT: HID_USAGE_TELEPHONY_REDIAL                 0x24
CONSTANT: HID_USAGE_TELEPHONY_TRANSFER               0x25
CONSTANT: HID_USAGE_TELEPHONY_DROP                   0x26
CONSTANT: HID_USAGE_TELEPHONY_LINE                   0x2A
CONSTANT: HID_USAGE_TELEPHONY_RING_ENABLE            0x2D
CONSTANT: HID_USAGE_TELEPHONY_SEND                   0x31
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD_0               0xB0
CONSTANT: HID_USAGE_TELEPHONY_KEYPAD_D               0xBF
CONSTANT: HID_USAGE_TELEPHONY_HOST_AVAILABLE         0xF1

CONSTANT: HID_USAGE_MS_BTH_HF_DIALNUMBER             0x21
CONSTANT: HID_USAGE_MS_BTH_HF_DIALMEMORY             0x22

CONSTANT: HID_USAGE_CONSUMERCTRL          0x01
CONSTANT: HID_USAGE_DIGITIZER_PEN         0x02
CONSTANT: HID_USAGE_DIGITIZER_IN_RANGE    0x32
CONSTANT: HID_USAGE_DIGITIZER_TIP_SWITCH  0x42
CONSTANT: HID_USAGE_DIGITIZER_BARREL_SWITCH 0x44

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
   )

FUNCTION: NTSTATUS
HidP_GetLinkCollectionNodes (
   PHIDP_LINK_COLLECTION_NODE LinkCollectionNodes,
   PULONG                     LinkCollectionNodesLength,
   PHIDP_PREPARSED_DATA       PreparsedData
   )

FUNCTION: NTSTATUS
HidP_GetSpecificButtonCaps (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   USAGE                Usage,
   PHIDP_BUTTON_CAPS    ButtonCaps,
   PUSHORT              ButtonCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
   )

FUNCTION: NTSTATUS
HidP_GetButtonCaps (
   HIDP_REPORT_TYPE     ReportType,
   PHIDP_BUTTON_CAPS    ButtonCaps,
   PUSHORT              ButtonCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
)

FUNCTION: NTSTATUS
HidP_GetSpecificValueCaps (
   HIDP_REPORT_TYPE     ReportType,
   USAGE                UsagePage,
   USHORT               LinkCollection,
   USAGE                Usage,
   PHIDP_VALUE_CAPS     ValueCaps,
   PUSHORT              ValueCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
   )

FUNCTION: NTSTATUS
HidP_GetValueCaps (
   HIDP_REPORT_TYPE     ReportType,
   PHIDP_VALUE_CAPS     ValueCaps,
   PUSHORT              ValueCapsLength,
   PHIDP_PREPARSED_DATA PreparsedData
)

FUNCTION: NTSTATUS
HidP_GetExtendedAttributes (
    HIDP_REPORT_TYPE            ReportType,
    USHORT                      DataIndex,
    PHIDP_PREPARSED_DATA        PreparsedData,
    PHIDP_EXTENDED_ATTRIBUTES   Attributes,
    PULONG                      LengthAttributes
    )

FUNCTION: NTSTATUS
HidP_InitializeReportForID (
   HIDP_REPORT_TYPE     ReportType,
   UCHAR                ReportID,
   PHIDP_PREPARSED_DATA PreparsedData,
   PCHAR                Report,
   ULONG                ReportLength
   )

FUNCTION: NTSTATUS
HidP_SetData (
    HIDP_REPORT_TYPE     ReportType,
    PHIDP_DATA           DataList,
    PULONG               DataLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    )

FUNCTION: NTSTATUS
HidP_GetData (
    HIDP_REPORT_TYPE     ReportType,
    PHIDP_DATA           DataList,
    PULONG               DataLength,
    PHIDP_PREPARSED_DATA PreparsedData,
    PCHAR                Report,
    ULONG                ReportLength
    )

FUNCTION: ULONG
HidP_MaxDataListLength (
   HIDP_REPORT_TYPE      ReportType,
   PHIDP_PREPARSED_DATA  PreparsedData
   )

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
   )
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
   )
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
   )
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
   )
ALIAS: HidP_GetButtonsEx HidP_GetUsagesEx

FUNCTION: ULONG
HidP_MaxUsageListLength (
   HIDP_REPORT_TYPE      ReportType,
   USAGE                 UsagePage,
   PHIDP_PREPARSED_DATA  PreparsedData
   )

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
    )

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
    )

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
    )


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
    )

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
    )

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
    )

FUNCTION: NTSTATUS
HidP_UsageListDifference (
   PUSAGE   PreviousUsageList,
   PUSAGE   CurrentUsageList,
   PUSAGE   BreakUsageList,
   PUSAGE   MakeUsageList,
   ULONG    UsageListLength
    )

FUNCTION: NTSTATUS
HidP_UsageAndPageListDifference (
   PUSAGE_AND_PAGE PreviousUsageList,
   PUSAGE_AND_PAGE CurrentUsageList,
   PUSAGE_AND_PAGE BreakUsageList,
   PUSAGE_AND_PAGE MakeUsageList,
   ULONG           UsageListLength
   )

ENUM: HIDP_KEYBOARD_DIRECTION
    HidP_Keyboard_Break
    HidP_Keyboard_Make ;

STRUCT: HIDP_KEYBOARD_MODIFIER_STATE
    { ul ULONG } ;
TYPEDEF: HIDP_KEYBOARD_MODIFIER_STATE* PHIDP_KEYBOARD_MODIFIER_STATE

CALLBACK: BOOLEAN PHIDP_INSERT_SCANCODES (
    PVOID Context,
    PCHAR NewScanCodes,
    ULONG Length )

FUNCTION: NTSTATUS
HidP_TranslateUsageAndPagesToI8042ScanCodes (
    PUSAGE_AND_PAGE               ChangedUsageList,
    ULONG                         UsageListLength,
    HIDP_KEYBOARD_DIRECTION       KeyAction,
    PHIDP_KEYBOARD_MODIFIER_STATE ModifierState,
    PHIDP_INSERT_SCANCODES        InsertCodesProcedure,
    PVOID                         InsertCodesContext
    )


FUNCTION: NTSTATUS
HidP_TranslateUsagesToI8042ScanCodes (
    PUSAGE                        ChangedUsageList,
    ULONG                         UsageListLength,
    HIDP_KEYBOARD_DIRECTION       KeyAction,
    PHIDP_KEYBOARD_MODIFIER_STATE ModifierState,
    PHIDP_INSERT_SCANCODES        InsertCodesProcedure,
    PVOID                         InsertCodesContext
    )

CONSTANT: FACILITY_HID_ERROR_CODE 0x11
: HIDP_ERROR_CODES ( SEV CODE -- HRESULT )
    [ 28 shift ] dip bitor FACILITY_HID_ERROR_CODE 16 shift bitor ; inline
: HIDP_STATUS_SUCCESS                  ( -- HRESULT ) 0x0 0x0 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NULL                     ( -- HRESULT ) 0x8 0x1 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_PREPARSED_DATA   ( -- HRESULT ) 0xC 0x1 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_REPORT_TYPE      ( -- HRESULT ) 0xC 0x2 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INVALID_REPORT_LENGTH    ( -- HRESULT ) 0xC 0x3 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_USAGE_NOT_FOUND          ( -- HRESULT ) 0xC 0x4 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_VALUE_OUT_OF_RANGE       ( -- HRESULT ) 0xC 0x5 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BAD_LOG_PHY_VALUES       ( -- HRESULT ) 0xC 0x6 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BUFFER_TOO_SMALL         ( -- HRESULT ) 0xC 0x7 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INTERNAL_ERROR           ( -- HRESULT ) 0xC 0x8 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_I8042_TRANS_UNKNOWN      ( -- HRESULT ) 0xC 0x9 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_INCOMPATIBLE_REPORT_ID   ( -- HRESULT ) 0xC 0xA HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NOT_VALUE_ARRAY          ( -- HRESULT ) 0xC 0xB HIDP_ERROR_CODES ; inline
: HIDP_STATUS_IS_VALUE_ARRAY           ( -- HRESULT ) 0xC 0xC HIDP_ERROR_CODES ; inline
: HIDP_STATUS_DATA_INDEX_NOT_FOUND     ( -- HRESULT ) 0xC 0xD HIDP_ERROR_CODES ; inline
: HIDP_STATUS_DATA_INDEX_OUT_OF_RANGE  ( -- HRESULT ) 0xC 0xE HIDP_ERROR_CODES ; inline
: HIDP_STATUS_BUTTON_NOT_PRESSED       ( -- HRESULT ) 0xC 0xF HIDP_ERROR_CODES ; inline
: HIDP_STATUS_REPORT_DOES_NOT_EXIST    ( -- HRESULT ) 0xC 0x10 HIDP_ERROR_CODES ; inline
: HIDP_STATUS_NOT_IMPLEMENTED          ( -- HRESULT ) 0xC 0x20 HIDP_ERROR_CODES ; inline
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
    )

FUNCTION: void
HidD_GetHidGuid (
   LPGUID   HidGuid
   )

FUNCTION: BOOLEAN
HidD_GetPreparsedData (
   HANDLE                HidDeviceObject,
   PHIDP_PREPARSED_DATA* PreparsedData
   )

FUNCTION: BOOLEAN
HidD_FreePreparsedData (
   PHIDP_PREPARSED_DATA PreparsedData
   )

FUNCTION: BOOLEAN
HidD_FlushQueue (
   HANDLE                HidDeviceObject
   )

FUNCTION: BOOLEAN
HidD_GetConfiguration (
   HANDLE               HidDeviceObject,
   PHIDD_CONFIGURATION  Configuration,
   ULONG                ConfigurationLength
   )

FUNCTION: BOOLEAN
HidD_SetConfiguration (
   HANDLE               HidDeviceObject,
   PHIDD_CONFIGURATION  Configuration,
   ULONG                ConfigurationLength
   )

FUNCTION: BOOLEAN
HidD_GetFeature (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   )

FUNCTION: BOOLEAN
HidD_SetFeature (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   )

FUNCTION: BOOLEAN
HidD_GetInputReport (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   )

FUNCTION: BOOLEAN
HidD_SetOutputReport (
   HANDLE   HidDeviceObject,
   PVOID    ReportBuffer,
   ULONG    ReportBufferLength
   )

FUNCTION: BOOLEAN
HidD_GetNumInputBuffers (
    HANDLE  HidDeviceObject,
    PULONG  NumberBuffers
    )

FUNCTION: BOOLEAN
HidD_SetNumInputBuffers (
    HANDLE HidDeviceObject,
    ULONG  NumberBuffers
    )

FUNCTION: BOOLEAN
HidD_GetPhysicalDescriptor (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   )

FUNCTION: BOOLEAN
HidD_GetManufacturerString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   )

FUNCTION: BOOLEAN
HidD_GetProductString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   )

FUNCTION: BOOLEAN
HidD_GetIndexedString (
   HANDLE   HidDeviceObject,
   ULONG    StringIndex,
   PVOID    Buffer,
   ULONG    BufferLength
   )

FUNCTION: BOOLEAN
HidD_GetSerialNumberString (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   )

FUNCTION: BOOLEAN
HidD_GetMsGenreDescriptor (
   HANDLE   HidDeviceObject,
   PVOID    Buffer,
   ULONG    BufferLength
   )
