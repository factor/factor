! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax classes.struct
windows.kernel32 windows.types alien.libraries ;
IN: windows.ddk.winusb

<< "winusb" "winusb.dll" stdcall add-library >>
LIBRARY: winusb

TYPEDEF: PVOID WINUSB_INTERFACE_HANDLE
TYPEDEF: WINUSB_INTERFACE_HANDLE* PWINUSB_INTERFACE_HANDLE

STRUCT: USB_INTERFACE_DESCRIPTOR
    { bLength            UCHAR }
    { bDescriptorType    UCHAR }
    { bInterfaceNumber   UCHAR }
    { bAlternateSetting  UCHAR }
    { bNumEndpoints      UCHAR }
    { bInterfaceClass    UCHAR }
    { bInterfaceSubClass UCHAR }
    { bInterfaceProtocol UCHAR }
    { iInterface         UCHAR } ;
TYPEDEF: USB_INTERFACE_DESCRIPTOR* PUSB_INTERFACE_DESCRIPTOR

ENUM: USBD_PIPE_TYPE
    UsbdPipeTypeControl
    UsbdPipeTypeIsochronous
    UsbdPipeTypeBulk
    UsbdPipeTypeInterrupt ;

STRUCT: WINUSB_PIPE_INFORMATION
    { PipeType                   USBD_PIPE_TYPE }
    { PipeId                     UCHAR          }
    { MaximumPacketSize          USHORT         }
    { Interval                   UCHAR          } ;
TYPEDEF: WINUSB_PIPE_INFORMATION* PWINUSB_PIPE_INFORMATION

STRUCT: WINUSB_SETUP_PACKET
    { RequestType   UCHAR  }
    { Request       UCHAR  }
    { Value         USHORT }
    { Index         USHORT }
    { Length        USHORT } ;
TYPEDEF: WINUSB_SETUP_PACKET* PWINUSB_SETUP_PACKET

FUNCTION: BOOL WinUsb_AbortPipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID )
FUNCTION: BOOL WinUsb_FlushPipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID )
FUNCTION: BOOL WinUsb_ControlTransfer ( WINUSB_INTERFACE_HANDLE InterfaceHandle, WINUSB_SETUP_PACKET SetupPacket, PUCHAR Buffer, ULONG BufferLength, PULONG LengthTransferred, LPOVERLAPPED Overlapped )
FUNCTION: BOOL WinUsb_Initialize ( HANDLE DeviceHandle, PWINUSB_INTERFACE_HANDLE InterfaceHandle )
FUNCTION: BOOL WinUsb_Free ( WINUSB_INTERFACE_HANDLE InterfaceHandle )
FUNCTION: BOOL WinUsb_GetAssociatedInterface ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR AssociatedInterfaceIndex, PWINUSB_INTERFACE_HANDLE AssociatedInterfaceHandle )
FUNCTION: BOOL WinUsb_GetCurrentAlternateSetting ( WINUSB_INTERFACE_HANDLE InterfaceHandle, PUCHAR SettingNumber )
FUNCTION: BOOL WinUsb_GetDescriptor ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR DescriptorType, UCHAR Index, USHORT LanguageID, PUCHAR Buffer, ULONG BufferLength, PULONG LengthTransferred )
FUNCTION: BOOL WinUsb_GetPowerPolicy ( WINUSB_INTERFACE_HANDLE InterfaceHandle, ULONG PolicyType, PULONG ValueLength, PVOID Value )
FUNCTION: BOOL WinUsb_GetOverlappedResult ( WINUSB_INTERFACE_HANDLE InterfaceHandle, LPOVERLAPPED lpOverlapped, LPDWORD lpNumberOfBytesTransferred, BOOL bWait )
FUNCTION: BOOL WinUsb_GetPipePolicy ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID, ULONG PolicyType, PULONG ValueLength, PVOID Value )
FUNCTION: BOOL WinUsb_QueryInterfaceSettings ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR AlternateInterfaceNumber, PUSB_INTERFACE_DESCRIPTOR UsbAltInterfaceDescriptor )
FUNCTION: BOOL WinUsb_QueryDeviceInformation ( WINUSB_INTERFACE_HANDLE InterfaceHandle, ULONG InformationType, PULONG BufferLength, PVOID Buffer )
FUNCTION: BOOL WinUsb_QueryPipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR AlternateInterfaceNumber, UCHAR PipeIndex, PWINUSB_PIPE_INFORMATION PipeInformation )
FUNCTION: BOOL WinUsb_ReadPipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID, PUCHAR Buffer, ULONG BufferLength, PULONG LengthTransferred, LPOVERLAPPED Overlapped )
FUNCTION: BOOL WinUsb_ResetPipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID )
FUNCTION: BOOL WinUsb_SetCurrentAlternateSetting ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR SettingNumber )
FUNCTION: BOOL WinUsb_SetPowerPolicy ( WINUSB_INTERFACE_HANDLE InterfaceHandle, ULONG PolicyType, ULONG ValueLength, PVOID Value )
FUNCTION: BOOL WinUsb_SetPipePolicy ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID, ULONG PolicyType, ULONG ValueLength, PVOID Value )
FUNCTION: BOOL WinUsb_WritePipe ( WINUSB_INTERFACE_HANDLE InterfaceHandle, UCHAR PipeID, PUCHAR Buffer, ULONG BufferLength, PULONG LengthTransferred, LPOVERLAPPED Overlapped )
