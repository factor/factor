USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx.audiodefs windows.kernel32
windows.types ;
IN: windows.directx.xapo

CONSTANT: XAPO_MIN_CHANNELS 1
CONSTANT: XAPO_MAX_CHANNELS 64

CONSTANT: XAPO_MIN_FRAMERATE 1000
CONSTANT: XAPO_MAX_FRAMERATE 200000

CONSTANT: XAPO_REGISTRATION_STRING_LENGTH 256

CONSTANT: XAPO_FLAG_CHANNELS_MUST_MATCH      0x00000001

CONSTANT: XAPO_FLAG_FRAMERATE_MUST_MATCH     0x00000002

CONSTANT: XAPO_FLAG_BITSPERSAMPLE_MUST_MATCH 0x00000004

CONSTANT: XAPO_FLAG_BUFFERCOUNT_MUST_MATCH   0x00000008

CONSTANT: XAPO_FLAG_INPLACE_REQUIRED         0x00000020

CONSTANT: XAPO_FLAG_INPLACE_SUPPORTED        0x00000010

STRUCT: XAPO_REGISTRATION_PROPERTIES
    { clsid                GUID       }
    { FriendlyName         WCHAR[256] }
    { CopyrightInfo        WCHAR[256] }
    { MajorVersion         UINT32     }
    { MinorVersion         UINT32     }
    { Flags                UINT32     }
    { MinInputBufferCount  UINT32     }
    { MaxInputBufferCount  UINT32     }
    { MinOutputBufferCount UINT32     }
    { MaxOutputBufferCount UINT32     } ;

STRUCT: XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS
    { pFormat                    WAVEFORMATEX* }
    { MaxFrameCount              UINT32        } ;

ENUM: XAPO_BUFFER_FLAGS
    XAPO_BUFFER_SILENT
    XAPO_BUFFER_VALID ;

STRUCT: XAPO_PROCESS_BUFFER_PARAMETERS
    { pBuffer                    void*             }
    { BufferFlags                XAPO_BUFFER_FLAGS }
    { ValidFrameCount            UINT32            } ;

COM-INTERFACE: IXAPO IUnknown {A90BC001-E897-E897-55E4-9E4700000000}
    HRESULT GetRegistrationProperties ( XAPO_REGISTRATION_PROPERTIES** ppRegistrationProperties )
    HRESULT IsInputFormatSupported ( WAVEFORMATEX* pOutputFormat, WAVEFORMATEX* pRequestedInputFormat, WAVEFORMATEX** ppSupportedInputFormat )
    HRESULT IsOutputFormatSupported ( WAVEFORMATEX* pInputFormat, WAVEFORMATEX* pRequestedOutputFormat, WAVEFORMATEX** ppSupportedOutputFormat )
    HRESULT Initialize ( void* pData, UINT32 DataByteSize )
    void Reset ( )
    HRESULT LockForProcess ( UINT32 InputLockedParameterCount, XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS* pInputLockedParameters, UINT32 OutputLockedParameterCount, XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS* pOutputLockedParameters )
    void UnlockForProcess ( )
    void Process ( UINT32 InputProcessParameterCount, XAPO_PROCESS_BUFFER_PARAMETERS* pInputProcessParameters, UINT32 OutputProcessParameterCount, XAPO_PROCESS_BUFFER_PARAMETERS* pOutputProcessParameters, BOOL IsEnabled )
    UINT32 CalcInputFrames ( UINT32 OutputFrameCount )
    UINT32 CalcOutputFrames ( UINT32 InputFrameCount ) ;

COM-INTERFACE: IXAPOParameters IUnknown {A90BC001-E897-E897-55E4-9E4700000001}
    void SetParameters ( void* pParameters, UINT32 ParameterByteSize )
    void GetParameters ( void* pParameters, UINT32 ParameterByteSize ) ;
