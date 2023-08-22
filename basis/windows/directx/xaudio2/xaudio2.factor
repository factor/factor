USING: alien.c-types alien.syntax classes.struct math
windows.com windows.com.syntax windows.directx
windows.directx.audiodefs windows.types ;
IN: windows.directx.xaudio2

LIBRARY: xaudio2

CONSTANT: XAUDIO2_MAX_BUFFER_BYTES        0x80000000
CONSTANT: XAUDIO2_MAX_QUEUED_BUFFERS      64
CONSTANT: XAUDIO2_MAX_BUFFERS_SYSTEM      2
CONSTANT: XAUDIO2_MAX_AUDIO_CHANNELS      64
CONSTANT: XAUDIO2_MIN_SAMPLE_RATE         1000
CONSTANT: XAUDIO2_MAX_SAMPLE_RATE         200000
CONSTANT: XAUDIO2_MAX_VOLUME_LEVEL        16777216.0
: XAUDIO2_MIN_FREQ_RATIO ( -- z ) 1.0 1024.0 / ; inline
CONSTANT: XAUDIO2_MAX_FREQ_RATIO          1024.0
CONSTANT: XAUDIO2_DEFAULT_FREQ_RATIO      2.0
CONSTANT: XAUDIO2_MAX_FILTER_ONEOVERQ     1.5
CONSTANT: XAUDIO2_MAX_FILTER_FREQUENCY    1.0
CONSTANT: XAUDIO2_MAX_LOOP_COUNT          254
CONSTANT: XAUDIO2_MAX_INSTANCES           8

CONSTANT: XAUDIO2_MAX_RATIO_TIMES_RATE_XMA_MONO         600000
CONSTANT: XAUDIO2_MAX_RATIO_TIMES_RATE_XMA_MULTICHANNEL 300000

CONSTANT: XAUDIO2_COMMIT_NOW              0
CONSTANT: XAUDIO2_COMMIT_ALL              0
CONSTANT: XAUDIO2_INVALID_OPSET           0xffffffff
CONSTANT: XAUDIO2_NO_LOOP_REGION          0
CONSTANT: XAUDIO2_LOOP_INFINITE           255
CONSTANT: XAUDIO2_DEFAULT_CHANNELS        0
CONSTANT: XAUDIO2_DEFAULT_SAMPLERATE      0


CONSTANT: XAUDIO2_DEBUG_ENGINE            0x0001
CONSTANT: XAUDIO2_VOICE_NOPITCH           0x0002
CONSTANT: XAUDIO2_VOICE_NOSRC             0x0004
CONSTANT: XAUDIO2_VOICE_USEFILTER         0x0008
CONSTANT: XAUDIO2_VOICE_MUSIC             0x0010
CONSTANT: XAUDIO2_PLAY_TAILS              0x0020
CONSTANT: XAUDIO2_END_OF_STREAM           0x0040
CONSTANT: XAUDIO2_SEND_USEFILTER          0x0080


CONSTANT: XAUDIO2_DEFAULT_FILTER_TYPE      0
CONSTANT: XAUDIO2_DEFAULT_FILTER_FREQUENCY 1.0
CONSTANT: XAUDIO2_DEFAULT_FILTER_ONEOVERQ  1.0

CONSTANT: XAUDIO2_QUANTUM_NUMERATOR   1
CONSTANT: XAUDIO2_QUANTUM_DENOMINATOR 100

: XAUDIO2_QUANTUM_MS ( -- z )
    XAUDIO2_QUANTUM_DENOMINATOR 1000.0 XAUDIO2_QUANTUM_NUMERATOR * / ; inline

CONSTANT: XAUDIO2_E_INVALID_CALL          0x88960001
CONSTANT: XAUDIO2_E_XMA_DECODER_ERROR     0x88960002
CONSTANT: XAUDIO2_E_XAPO_CREATION_FAILED  0x88960003
CONSTANT: XAUDIO2_E_DEVICE_INVALIDATED    0x88960004

CONSTANT: Processor1  0x00000001
CONSTANT: Processor2  0x00000002
CONSTANT: Processor3  0x00000004
CONSTANT: Processor4  0x00000008
CONSTANT: Processor5  0x00000010
CONSTANT: Processor6  0x00000020
CONSTANT: Processor7  0x00000040
CONSTANT: Processor8  0x00000080
CONSTANT: Processor9  0x00000100
CONSTANT: Processor10 0x00000200
CONSTANT: Processor11 0x00000400
CONSTANT: Processor12 0x00000800
CONSTANT: Processor13 0x00001000
CONSTANT: Processor14 0x00002000
CONSTANT: Processor15 0x00004000
CONSTANT: Processor16 0x00008000
CONSTANT: Processor17 0x00010000
CONSTANT: Processor18 0x00020000
CONSTANT: Processor19 0x00040000
CONSTANT: Processor20 0x00080000
CONSTANT: Processor21 0x00100000
CONSTANT: Processor22 0x00200000
CONSTANT: Processor23 0x00400000
CONSTANT: Processor24 0x00800000
CONSTANT: Processor25 0x01000000
CONSTANT: Processor26 0x02000000
CONSTANT: Processor27 0x04000000
CONSTANT: Processor28 0x08000000
CONSTANT: Processor29 0x10000000
CONSTANT: Processor30 0x20000000
CONSTANT: Processor31 0x40000000
CONSTANT: Processor32 0x80000000
CONSTANT: XAUDIO2_ANY_PROCESSOR 0xffffffff
CONSTANT: XAUDIO2_DEFAULT_PROCESSOR 0xffffffff
TYPEDEF: int XAUDIO2_WINDOWS_PROCESSOR_SPECIFIER
TYPEDEF: int XAUDIO2_PROCESSOR

CONSTANT: NotDefaultDevice            0x0
CONSTANT: DefaultConsoleDevice        0x1
CONSTANT: DefaultMultimediaDevice     0x2
CONSTANT: DefaultCommunicationsDevice 0x4
CONSTANT: DefaultGameDevice           0x8
CONSTANT: GlobalDefaultDevice         0xf
CONSTANT: InvalidDeviceRole           0x0
TYPEDEF: int XAUDIO2_DEVICE_ROLE

STRUCT: XAUDIO2_DEVICE_DETAILS
    { DeviceID     WCHAR[256]           }
    { DisplayName  WCHAR[256]           }
    { Role         XAUDIO2_DEVICE_ROLE  }
    { OutputFormat WAVEFORMATEXTENSIBLE } ;

STRUCT: XAUDIO2_VOICE_DETAILS
    { CreationFlags   UINT32 }
    { InputChannels   UINT32 }
    { InputSampleRate UINT32 } ;

C-TYPE: IXAudio2Voice

STRUCT: XAUDIO2_SEND_DESCRIPTOR
    { Flags        UINT32         }
    { pOutputVoice IXAudio2Voice* } ;

STRUCT: XAUDIO2_VOICE_SENDS
    { SendCount UINT32                   }
    { pSends    XAUDIO2_SEND_DESCRIPTOR* } ;

STRUCT: XAUDIO2_EFFECT_DESCRIPTOR
    { pEffect        IUnknown* }
    { InitialState   BOOL      }
    { OutputChannels UINT32    } ;

STRUCT: XAUDIO2_EFFECT_CHAIN
    { EffectCount        UINT32                     }
    { pEffectDescriptors XAUDIO2_EFFECT_DESCRIPTOR* } ;

ENUM: XAUDIO2_FILTER_TYPE
    LowPassFilter
    BandPassFilter
    HighPassFilter
    NotchFilter ;

STRUCT: XAUDIO2_FILTER_PARAMETERS
    { Type      XAUDIO2_FILTER_TYPE }
    { Frequency FLOAT               }
    { OneOverQ  FLOAT               } ;

STRUCT: XAUDIO2_BUFFER
    { Flags      UINT32 }
    { AudioBytes UINT32 }
    { pAudioData BYTE*  }
    { PlayBegin  UINT32 }
    { PlayLength UINT32 }
    { LoopBegin  UINT32 }
    { LoopLength UINT32 }
    { LoopCount  UINT32 }
    { pContext   void*  } ;


STRUCT: XAUDIO2_BUFFER_WMA
    { pDecodedPacketCumulativeBytes UINT32* }
    { PacketCount                   UINT32  } ;

STRUCT: XAUDIO2_VOICE_STATE
    { pCurrentBufferContext void*  }
    { BuffersQueued         UINT32 }
    { SamplesPlayed         UINT64 } ;

STRUCT: XAUDIO2_PERFORMANCE_DATA
    { AudioCyclesSinceLastQuery  UINT64 }
    { TotalCyclesSinceLastQuery  UINT64 }
    { MinimumCyclesPerQuantum    UINT32 }
    { MaximumCyclesPerQuantum    UINT32 }
    { MemoryUsageInBytes         UINT32 }
    { CurrentLatencyInSamples    UINT32 }
    { GlitchesSinceEngineStarted UINT32 }
    { ActiveSourceVoiceCount     UINT32 }
    { TotalSourceVoiceCount      UINT32 }
    { ActiveSubmixVoiceCount     UINT32 }
    { ActiveResamplerCount       UINT32 }
    { ActiveMatrixMixCount       UINT32 }
    { ActiveXmaSourceVoices      UINT32 }
    { ActiveXmaStreams           UINT32 } ;

STRUCT: XAUDIO2_DEBUG_CONFIGURATION
    { TraceMask       UINT32 }
    { BreakMask       UINT32 }
    { LogThreadID     BOOL   }
    { LogFileline     BOOL   }
    { LogFunctionName BOOL   }
    { LogTiming       BOOL   } ;

CONSTANT: XAUDIO2_LOG_ERRORS     0x0001
CONSTANT: XAUDIO2_LOG_WARNINGS   0x0002
CONSTANT: XAUDIO2_LOG_INFO       0x0004
CONSTANT: XAUDIO2_LOG_DETAIL     0x0008
CONSTANT: XAUDIO2_LOG_API_CALLS  0x0010
CONSTANT: XAUDIO2_LOG_FUNC_CALLS 0x0020
CONSTANT: XAUDIO2_LOG_TIMING     0x0040
CONSTANT: XAUDIO2_LOG_LOCKS      0x0080
CONSTANT: XAUDIO2_LOG_MEMORY     0x0100
CONSTANT: XAUDIO2_LOG_STREAMING  0x1000

C-TYPE: IXAudio2EngineCallback
C-TYPE: IXAudio2VoiceCallback
C-TYPE: IXAudio2SourceVoice
C-TYPE: IXAudio2SubmixVoice
C-TYPE: IXAudio2MasteringVoice

COM-INTERFACE: IXAudio2 IUnknown {8bcf1f58-9fe7-4583-8ac6-e2adc465c8bb}
    HRESULT GetDeviceCount ( UINT32* pCount )
    HRESULT GetDeviceDetails ( UINT32 Index, XAUDIO2_DEVICE_DETAILS* pDeviceDetails )
    HRESULT Initialize ( UINT32 Flags, XAUDIO2_PROCESSOR XAudio2Processor )
    HRESULT RegisterForCallbacks ( IXAudio2EngineCallback* pCallback )
    void UnregisterForCallbacks ( IXAudio2EngineCallback* pCallback )
    HRESULT CreateSourceVoice (
        IXAudio2SourceVoice**  ppSourceVoice,
        WAVEFORMATEX*          pSourceFormat,
        UINT32                 Flags,
        FLOAT                  MaxFrequencyRatio,
        IXAudio2VoiceCallback* pCallback,
        XAUDIO2_VOICE_SENDS*   pSendList,
        XAUDIO2_EFFECT_CHAIN*  pEffectChain )
    HRESULT CreateSubmixVoice (
        IXAudio2SubmixVoice** ppSubmixVoice,
        UINT32                InputChannels,
        UINT32                InputSampleRate,
        UINT32                Flags,
        UINT32                ProcessingStage,
        XAUDIO2_VOICE_SENDS*  pSendList,
        XAUDIO2_EFFECT_CHAIN* pEffectChain )
    HRESULT CreateMasteringVoice (
        IXAudio2MasteringVoice** ppMasteringVoice,
        UINT32                   InputChannels,
        UINT32                   InputSampleRate,
        UINT32                   Flags
        UINT32                   DeviceIndex,
        XAUDIO2_EFFECT_CHAIN*    pEffectChain )
    HRESULT StartEngine ( )
    void StopEngine ( )
    HRESULT CommitChanges ( UINT32 OperationSet )
    void GetPerformanceData ( XAUDIO2_PERFORMANCE_DATA* pPerfData )
    void SetDebugConfiguration ( XAUDIO2_DEBUG_CONFIGURATION* pDebugConfiguration, void* pReserved ) ;

COM-INTERFACE: IXAudio2Voice f {00000000-0000-0000-0000-000000000000}
    void GetVoiceDetails ( XAUDIO2_VOICE_DETAILS* pVoiceDetails )
    HRESULT SetOutputVoices ( XAUDIO2_VOICE_SENDS* pSendList )
    HRESULT SetEffectChain ( XAUDIO2_EFFECT_CHAIN* pEffectChain )
    HRESULT EnableEffect ( UINT32 EffectIndex, UINT32 OperationSet )
    HRESULT DisableEffect ( UINT32 EffectIndex, UINT32 OperationSet )
    void GetEffectState ( UINT32 EffectIndex, BOOL* pEnabled )
    HRESULT SetEffectParameters (
        UINT32 EffectIndex,
        void*  pParameters,
        UINT32 ParametersByteSize,
        UINT32 OperationSet )
    HRESULT GetEffectParameters (
        UINT32 EffectIndex,
        void*  pParameters,
        UINT32 ParametersByteSize )
    HRESULT SetFilterParameters ( XAUDIO2_FILTER_PARAMETERS* pParameters, UINT32 OperationSet )
    void GetFilterParameters ( XAUDIO2_FILTER_PARAMETERS* pParameters )
    HRESULT SetOutputFilterParameters ( IXAudio2Voice*             pDestinationVoice,
                                        XAUDIO2_FILTER_PARAMETERS* pParameters,
                                        UINT32                     OperationSet )
    void GetOutputFilterParameters ( IXAudio2Voice*             pDestinationVoice,
                                     XAUDIO2_FILTER_PARAMETERS* pParameters )
    HRESULT SetVolume ( FLOAT  Volume,
                        UINT32 OperationSet )
    void GetVolume ( FLOAT* pVolume )
    HRESULT SetChannelVolumes ( UINT32 Channels,
                                FLOAT* pVolumes,
                                UINT32 OperationSet )
    void GetChannelVolumes ( UINT32 Channels, FLOAT* pVolumes )
    HRESULT SetOutputMatrix (
        IXAudio2Voice* pDestinationVoice,
        UINT32         SourceChannels,
        UINT32         DestinationChannels,
        FLOAT*         pLevelMatrix,
        UINT32         OperationSet )
    void GetOutputMatrix (
        IXAudio2Voice* pDestinationVoice,
        UINT32         SourceChannels,
        UINT32         DestinationChannels,
        FLOAT*         pLevelMatrix )
    void DestroyVoice ( ) ;

COM-INTERFACE: IXAudio2SourceVoice IXAudio2Voice {00000000-0000-0000-0000-000000000000}
    HRESULT Start ( UINT32 Flags, UINT32 OperationSet )
    HRESULT Stop ( UINT32 Flags, UINT32 OperationSet )
    HRESULT SubmitSourceBuffer ( XAUDIO2_BUFFER* pBuffer, XAUDIO2_BUFFER_WMA* pBufferWMA )
    HRESULT FlushSourceBuffers ( )
    HRESULT Discontinuity ( )
    HRESULT ExitLoop ( UINT32 OperationSet )
    void GetState ( XAUDIO2_VOICE_STATE* pVoiceState )
    HRESULT SetFrequencyRatio ( FLOAT Ratio, UINT32 OperationSet )
    void GetFrequencyRatio ( FLOAT* pRatio )
    HRESULT SetSourceSampleRate ( UINT32 NewSourceSampleRate ) ;

COM-INTERFACE: IXAudio2SubmixVoice IXAudio2Voice {00000000-0000-0000-0000-000000000000} ;
COM-INTERFACE: IXAudio2MasteringVoice IXAudio2Voice {00000000-0000-0000-0000-000000000000} ;

COM-INTERFACE: IXAudio2EngineCallback f {00000000-0000-0000-0000-000000000000}
    void OnProcessingPassStart ( )
    void OnProcessingPassEnd ( )
    void OnCriticalError ( HRESULT Error ) ;

COM-INTERFACE: IXAudio2VoiceCallback f {00000000-0000-0000-0000-000000000000}
    void OnVoiceProcessingPassStart ( UINT32 BytesRequired )
    void OnVoiceProcessingPassEnd ( )
    void OnStreamEnd ( )
    void OnBufferStart ( void* pBufferContext )
    void OnBufferEnd ( void* pBufferContext )
    void OnLoopEnd ( void* pBufferContext )
    void OnVoiceError ( void* pBufferContext, HRESULT Error ) ;
