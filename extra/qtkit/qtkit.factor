USING: alien.c-types classes.struct cocoa cocoa.application
cocoa.classes core-foundation core-foundation.strings kernel ;
IN: qtkit

STRUCT: QTTime
    { timeValue longlong }
    { timeScale long }
    { flags     long } ;

STRUCT: QTTimeRange
    { time      QTTime }
    { duration  QTTime } ;

STRUCT: SMPTETime
    { mSubframes       SInt16 }
    { mSubframeDivisor SInt16 }
    { mCounter         UInt32 }
    { mType            UInt32 }
    { mFlags           UInt32 }
    { mHours           SInt16 }
    { mMinutes         SInt16 }
    { mSeconds         SInt16 }
    { mFrames          SInt16 } ;

CFSTRING: QTKitErrorDomain "QTKitErrorDomain"
CFSTRING: QTErrorCaptureInputKey "QTErrorCaptureInputKey"
CFSTRING: QTErrorCaptureOutputKey "QTErrorCaptureOutputKey"
CFSTRING: QTErrorDeviceKey "QTErrorDeviceKey"
CFSTRING: QTErrorExcludingDeviceKey "QTErrorExcludingDeviceKey"
CFSTRING: QTErrorTimeKey "QTErrorTimeKey"
CFSTRING: QTErrorFileSizeKey "QTErrorFileSizeKey"
CFSTRING: QTErrorRecordingSuccesfullyFinishedKey "QTErrorRecordingSuccesfullyFinishedKey"

CONSTANT: QTErrorUnknown                                      -1
CONSTANT: QTErrorIncompatibleInput                          1002
CONSTANT: QTErrorIncompatibleOutput                         1003
CONSTANT: QTErrorInvalidInputsOrOutputs                     1100
CONSTANT: QTErrorDeviceAlreadyUsedbyAnotherSession          1101
CONSTANT: QTErrorNoDataCaptured                             1200
CONSTANT: QTErrorSessionConfigurationChanged                1201
CONSTANT: QTErrorDiskFull                                   1202
CONSTANT: QTErrorDeviceWasDisconnected                      1203
CONSTANT: QTErrorMediaChanged                               1204
CONSTANT: QTErrorMaximumDurationReached                     1205
CONSTANT: QTErrorMaximumFileSizeReached                     1206
CONSTANT: QTErrorMediaDiscontinuity                         1207
CONSTANT: QTErrorMaximumNumberOfSamplesForFileFormatReached 1208
CONSTANT: QTErrorDeviceNotConnected                         1300
CONSTANT: QTErrorDeviceInUseByAnotherApplication            1301
CONSTANT: QTErrorDeviceExcludedByAnotherDevice              1302

FRAMEWORK: /System/Library/Frameworks/QTKit.framework

IMPORT: QTCaptureAudioPreviewOutput
IMPORT: QTCaptureConnection
IMPORT: QTCaptureDecompressedAudioOutput
IMPORT: QTCaptureDecompressedVideoOutput
IMPORT: QTCaptureDevice
IMPORT: QTCaptureDeviceInput
IMPORT: QTCaptureFileOutput
IMPORT: QTCaptureInput
IMPORT: QTCaptureLayer
IMPORT: QTCaptureMovieFileOutput
IMPORT: QTCaptureOutput
IMPORT: QTCaptureSession
IMPORT: QTCaptureVideoPreviewOutput
IMPORT: QTCaptureView
IMPORT: QTCompressionOptions
IMPORT: QTDataReference
IMPORT: QTFormatDescription
IMPORT: QTMedia
IMPORT: QTMovie
IMPORT: QTMovieLayer
IMPORT: QTMovieView
IMPORT: QTSampleBuffer
IMPORT: QTTrack

: <movie> ( filename -- movie )
    QTMovie swap <NSString> f -> movieWithFile:error: -> retain ;

! XXX: comment these out to workaround build machine issue
! : movie-attributes ( movie -- attributes )
!     -> movieAttributes plist> ;
! : play ( movie -- )
!     -> play ;
! : stop ( movie -- )
!     -> stop ;
! : movie-tracks ( movie -- tracks )
!     -> tracks NSFastEnumeration>vector ;
! : track-attributes ( track -- attributes )
!     -> trackAttributes plist> ;
