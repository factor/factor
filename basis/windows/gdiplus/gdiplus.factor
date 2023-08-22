! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.destructors alien.syntax
classes.struct init kernel literals math namespaces windows.com
windows.com.syntax windows.kernel32 windows.ole32 windows.types ;
FROM: alien.c-types => float ;
IN: windows.gdiplus

LIBRARY: gdiplus

FUNCTION: void* GdipAlloc ( SIZE_T size )
FUNCTION: void GdipFree ( void* mem )

DESTRUCTOR: GdipFree

TYPEDEF: float REAL

ENUM: GpStatus
    { Ok                          0 }
    { GenericError                1 }
    { InvalidParameter            2 }
    { OutOfMemory                 3 }
    { ObjectBusy                  4 }
    { InsufficientBuffer          5 }
    { NotImplemented              6 }
    { Win32Error                  7 }
    { WrongState                  8 }
    { Aborted                     9 }
    { FileNotFound               10 }
    { ValueOverflow              11 }
    { AccessDenied               12 }
    { UnknownImageFormat         13 }
    { FontFamilyNotFound         14 }
    { FontStyleNotFound          15 }
    { NotTrueTypeFont            16 }
    { UnsupportedGdiplusVersion  17 }
    { GdiplusNotInitialized      18 }
    { PropertyNotFound           19 }
    { PropertyNotSupported       20 }
    { ProfileNotFound            21 } ;

CALLBACK: BOOL ImageAbort ( void* data )
TYPEDEF: ImageAbort DrawImageAbort
TYPEDEF: ImageAbort GetThumbnailImageAbort

STRUCT: GpPoint
    { X INT }
    { Y INT } ;

STRUCT: GpPointF
    { X REAL }
    { Y REAL } ;

STRUCT: GpPathData
    { Count INT }
    { Points GpPointF* }
    { Types BYTE* } ;

STRUCT: GpRectF
    { X REAL }
    { Y REAL }
    { Width REAL }
    { Height REAL } ;

STRUCT: GpRect
    { X INT }
    { Y INT }
    { Width INT }
    { Height INT } ;

STRUCT: CharacterRange
    { First INT }
    { Length INT } ;

TYPEDEF: UINT GraphicsState
TYPEDEF: UINT GraphicsContainer

ENUM: GpUnit
    { UnitWorld       0 }
    { UnitDisplay     1 }
    { UnitPixel       2 }
    { UnitPoint       3 }
    { UnitInch        4 }
    { UnitDocument    5 }
    { UnitMillimeter  6 } ;

ENUM: GpBrushType
    { BrushTypeSolidColor       0 }
    { BrushTypeHatchFill        1 }
    { BrushTypeTextureFill      2 }
    { BrushTypePathGradient     3 }
    { BrushTypeLinearGradient   4 } ;

ENUM: GpFillMode
    { FillModeAlternate   0 }
    { FillModeWinding     1 } ;

ENUM: GpLineCap
    { LineCapFlat             0x00 }
    { LineCapSquare           0x01 }
    { LineCapRound            0x02 }
    { LineCapTriangle         0x03 }

    { LineCapNoAnchor         0x10 }
    { LineCapSquareAnchor     0x11 }
    { LineCapRoundAnchor      0x12 }
    { LineCapDiamondAnchor    0x13 }
    { LineCapArrowAnchor      0x14 }

    { LineCapCustom           0xff }
    { LineCapAnchorMask       0xf0 } ;

ENUM: PathPointType
    { PathPointTypeStart            0 }
    { PathPointTypeLine             1 }
    { PathPointTypeBezier           3 }
    { PathPointTypePathTypeMask     7 }
    { PathPointTypePathDashMode    16 }
    { PathPointTypePathMarker      32 }
    { PathPointTypeCloseSubpath   128 }
    { PathPointTypeBezier3          3 } ;

ENUM: GpPenType
    { PenTypeSolidColor         BrushTypeSolidColor }
    { PenTypeHatchFill          BrushTypeHatchFill }
    { PenTypeTextureFill        BrushTypeTextureFill }
    { PenTypePathGradient       BrushTypePathGradient }
    { PenTypeLinearGradient     BrushTypeLinearGradient }
    { PenTypeUnknown            -1 } ;

ENUM: GpLineJoin
    { LineJoinMiter             0 }
    { LineJoinBevel             1 }
    { LineJoinRound             2 }
    { LineJoinMiterClipped      3 } ;

ENUM: QualityMode
    { QualityModeInvalid    -1 }
    { QualityModeDefault    0 }
    { QualityModeLow        1 }
    { QualityModeHigh       2 } ;

ENUM: SmoothingMode
    { SmoothingModeInvalid       QualityModeInvalid }
    { SmoothingModeDefault       QualityModeDefault }
    { SmoothingModeHighSpeed     QualityModeLow }
    { SmoothingModeHighQuality   QualityModeHigh }
    SmoothingModeNone
    SmoothingModeAntiAlias ;

ENUM: CompositingQuality
    { CompositingQualityInvalid            QualityModeInvalid }
    { CompositingQualityDefault            QualityModeDefault }
    { CompositingQualityHighSpeed          QualityModeLow }
    { CompositingQualityHighQuality        QualityModeHigh }
    CompositingQualityGammaCorrected
    CompositingQualityAssumeLinear ;

ENUM: InterpolationMode
    { InterpolationModeInvalid          QualityModeInvalid }
    { InterpolationModeDefault          QualityModeDefault }
    { InterpolationModeLowQuality       QualityModeLow }
    { InterpolationModeHighQuality      QualityModeHigh }
    InterpolationModeBilinear
    InterpolationModeBicubic
    InterpolationModeNearestNeighbor
    InterpolationModeHighQualityBilinear
    InterpolationModeHighQualityBicubic ;

ENUM: GpPenAlignment
    { PenAlignmentCenter     0 }
    { PenAlignmentInset      1 } ;

ENUM: PixelOffsetMode
    { PixelOffsetModeInvalid       QualityModeInvalid }
    { PixelOffsetModeDefault       QualityModeDefault }
    { PixelOffsetModeHighSpeed     QualityModeLow }
    { PixelOffsetModeHighQuality   QualityModeHigh }
    PixelOffsetModeNone
    PixelOffsetModeHalf ;

ENUM: GpDashCap
    { DashCapFlat       0 }
    { DashCapRound      2 }
    { DashCapTriangle   3 } ;

ENUM: GpDashStyle
    DashStyleSolid
    DashStyleDash
    DashStyleDot
    DashStyleDashDot
    DashStyleDashDotDot
    DashStyleCustom ;

ENUM: GpMatrixOrder
    { MatrixOrderPrepend   0 }
    { MatrixOrderAppend    1 } ;

ENUM: ImageType
    ImageTypeUnknown
    ImageTypeBitmap
    ImageTypeMetafile ;

ENUM: WarpMode
    WarpModePerspective
    WarpModeBilinear ;

ENUM: GpWrapMode
    WrapModeTile
    WrapModeTileFlipX
    WrapModeTileFlipY
    WrapModeTileFlipXY
    WrapModeClamp ;

ENUM: MetafileType
    MetafileTypeInvalid
    MetafileTypeWmf
    MetafileTypeWmfPlaceable
    MetafileTypeEmf
    MetafileTypeEmfPlusOnly
    MetafileTypeEmfPlusDual ;

ENUM: LinearGradientMode
    LinearGradientModeHorizontal
    LinearGradientModeVertical
    LinearGradientModeForwardDiagonal
    LinearGradientModeBackwardDiagonal ;

ENUM: EmfType
    { EmfTypeEmfOnly       MetafileTypeEmf }
    { EmfTypeEmfPlusOnly   MetafileTypeEmfPlusOnly }
    { EmfTypeEmfPlusDual   MetafileTypeEmfPlusDual } ;

ENUM: CompositingMode
    CompositingModeSourceOver
    CompositingModeSourceCopy ;

ENUM: TextRenderingHint
    { TextRenderingHintSystemDefault   0 }
    TextRenderingHintSingleBitPerPixelGridFit
    TextRenderingHintSingleBitPerPixel
    TextRenderingHintAntiAliasGridFit
    TextRenderingHintAntiAlias
    TextRenderingHintClearTypeGridFit ;

ENUM: StringAlignment
    { StringAlignmentNear      0 }
    { StringAlignmentCenter    1 }
    { StringAlignmentFar       2 } ;

ENUM: StringDigitSubstitute
    { StringDigitSubstituteUser          0 }
    { StringDigitSubstituteNone          1 }
    { StringDigitSubstituteNational      2 }
    { StringDigitSubstituteTraditional   3 } ;

ENUM: StringFormatFlags
    { StringFormatFlagsDirectionRightToLeft    0x00000001 }
    { StringFormatFlagsDirectionVertical       0x00000002 }
    { StringFormatFlagsNoFitBlackBox           0x00000004 }
    { StringFormatFlagsDisplayFormatControl    0x00000020 }
    { StringFormatFlagsNoFontFallback          0x00000400 }
    { StringFormatFlagsMeasureTrailingSpaces   0x00000800 }
    { StringFormatFlagsNoWrap                  0x00001000 }
    { StringFormatFlagsLineLimit               0x00002000 }
    { StringFormatFlagsNoClip                  0x00004000 } ;

ENUM: StringTrimming
    { StringTrimmingNone                   0 }
    { StringTrimmingCharacter              1 }
    { StringTrimmingWord                   2 }
    { StringTrimmingEllipsisCharacter      3 }
    { StringTrimmingEllipsisWord           4 }
    { StringTrimmingEllipsisPath           5 } ;

ENUM: FontStyle
    { FontStyleRegular      0 }
    { FontStyleBold         1 }
    { FontStyleItalic       2 }
    { FontStyleBoldItalic   3 }
    { FontStyleUnderline    4 }
    { FontStyleStrikeout    8 } ;

ENUM: HotkeyPrefix
    { HotkeyPrefixNone     0 }
    { HotkeyPrefixShow     1 }
    { HotkeyPrefixHide     2 } ;

ENUM: PaletteFlags
    { PaletteFlagsHasAlpha          1 }
    { PaletteFlagsGrayScale         2 }
    { PaletteFlagsHalftone          4 } ;

ENUM: ImageCodecFlags
    { ImageCodecFlagsEncoder            1 }
    { ImageCodecFlagsDecoder            2 }
    { ImageCodecFlagsSupportBitmap      4 }
    { ImageCodecFlagsSupportVector      8 }
    { ImageCodecFlagsSeekableEncode     16 }
    { ImageCodecFlagsBlockingDecode     32 }
    { ImageCodecFlagsBuiltin            65536 }
    { ImageCodecFlagsSystem             131072 }
    { ImageCodecFlagsUser               262144 } ;

ENUM: ImageFlags
    { ImageFlagsNone                0 }
    { ImageFlagsScalable            0x0001 }
    { ImageFlagsHasAlpha            0x0002 }
    { ImageFlagsHasTranslucent      0x0004 }
    { ImageFlagsPartiallyScalable   0x0008 }
    { ImageFlagsColorSpaceRGB       0x0010 }
    { ImageFlagsColorSpaceCMYK      0x0020 }
    { ImageFlagsColorSpaceGRAY      0x0040 }
    { ImageFlagsColorSpaceYCBCR     0x0080 }
    { ImageFlagsColorSpaceYCCK      0x0100 }
    { ImageFlagsHasRealDPI          0x1000 }
    { ImageFlagsHasRealPixelSize    0x2000 }
    { ImageFlagsReadOnly            0x00010000 }
    { ImageFlagsCaching             0x00020000 } ;

ENUM: CombineMode
    CombineModeReplace
    CombineModeIntersect
    CombineModeUnion
    CombineModeXor
    CombineModeExclude
    CombineModeComplement ;

ENUM: GpFlushIntention
    { FlushIntentionFlush   0 }
    { FlushIntentionSync    1 } ;

ENUM: GpCoordinateSpace
    CoordinateSpaceWorld
    CoordinateSpacePage
    CoordinateSpaceDevice ;

ENUM: GpTestControlEnum
    { TestControlForceBilinear    0 }
    { TestControlNoICM            1 }
    { TestControlGetBuildNumber   2 } ;

ENUM: MetafileFrameUnit
    { MetafileFrameUnitPixel        UnitPixel }
    { MetafileFrameUnitPoint        UnitPoint }
    { MetafileFrameUnitInch         UnitInch }
    { MetafileFrameUnitDocument     UnitDocument }
    { MetafileFrameUnitMillimeter   UnitMillimeter }
    MetafileFrameUnitGdi ;

ENUM: HatchStyle
    { HatchStyleHorizontal   0 }
    { HatchStyleVertical   1 }
    { HatchStyleForwardDiagonal   2 }
    { HatchStyleBackwardDiagonal   3 }
    { HatchStyleCross   4 }
    { HatchStyleDiagonalCross   5 }
    { HatchStyle05Percent   6 }
    { HatchStyle10Percent   7 }
    { HatchStyle20Percent   8 }
    { HatchStyle25Percent   9 }
    { HatchStyle30Percent   10 }
    { HatchStyle40Percent   11 }
    { HatchStyle50Percent   12 }
    { HatchStyle60Percent   13 }
    { HatchStyle70Percent   14 }
    { HatchStyle75Percent   15 }
    { HatchStyle80Percent   16 }
    { HatchStyle90Percent   17 }
    { HatchStyleLightDownwardDiagonal   18 }
    { HatchStyleLightUpwardDiagonal   19 }
    { HatchStyleDarkDownwardDiagonal   20 }
    { HatchStyleDarkUpwardDiagonal   21 }
    { HatchStyleWideDownwardDiagonal   22 }
    { HatchStyleWideUpwardDiagonal   23 }
    { HatchStyleLightVertical   24 }
    { HatchStyleLightHorizontal   25 }
    { HatchStyleNarrowVertical   26 }
    { HatchStyleNarrowHorizontal   27 }
    { HatchStyleDarkVertical   28 }
    { HatchStyleDarkHorizontal   29 }
    { HatchStyleDashedDownwardDiagonal   30 }
    { HatchStyleDashedUpwardDiagonal   31 }
    { HatchStyleDashedHorizontal   32 }
    { HatchStyleDashedVertical   33 }
    { HatchStyleSmallConfetti   34 }
    { HatchStyleLargeConfetti   35 }
    { HatchStyleZigZag   36 }
    { HatchStyleWave   37 }
    { HatchStyleDiagonalBrick   38 }
    { HatchStyleHorizontalBrick   39 }
    { HatchStyleWeave   40 }
    { HatchStylePlaid   41 }
    { HatchStyleDivot   42 }
    { HatchStyleDottedGrid   43 }
    { HatchStyleDottedDiamond   44 }
    { HatchStyleShingle   45 }
    { HatchStyleTrellis   46 }
    { HatchStyleSphere   47 }
    { HatchStyleSmallGrid   48 }
    { HatchStyleSmallCheckerBoard   49 }
    { HatchStyleLargeCheckerBoard   50 }
    { HatchStyleOutlinedDiamond   51 }
    { HatchStyleSolidDiamond   52 }
    { HatchStyleTotal   53 }
    { HatchStyleLargeGrid   4 }
    { HatchStyleMin   0 }
    { HatchStyleMax   52 } ;

ENUM: DebugEventLevel
    DebugEventLevelFatal
    DebugEventLevelWarning ;

CALLBACK: void DebugEventProc ( DebugEventLevel level, c-string msg )
CALLBACK: GpStatus NotificationHookProc ( ULONG_PTR* x )
CALLBACK: void NotificationUnhookProc ( ULONG_PTR x )

STRUCT: GdiplusStartupInput
    { GdiplusVersion UINT32 }
    { DebugEventCallback DebugEventProc }
    { SuppressBackgroundThread BOOL }
    { SuppressExternalCodecs BOOL } ;

STRUCT: GdiplusStartupOutput
    { NotificationHook NotificationHookProc }
    { NotificationUnhook NotificationUnhookProc } ;

FUNCTION: GpStatus GdiplusStartup ( ULONG_PTR* x, GdiplusStartupInput* in, GdiplusStartupOutput* out )
FUNCTION: void GdiplusShutdown ( ULONG_PTR x )

TYPEDEF: DWORD ARGB
TYPEDEF: INT PixelFormat

<PRIVATE
: pixel-format-constant ( n m l -- format )
    [ ] [ 8 shift ] [ ] tri* bitor bitor ; inline
PRIVATE>

CONSTANT: PixelFormatIndexed   0x00010000
CONSTANT: PixelFormatGDI       0x00020000
CONSTANT: PixelFormatAlpha     0x00040000
CONSTANT: PixelFormatPAlpha    0x00080000
CONSTANT: PixelFormatExtended  0x00100000
CONSTANT: PixelFormatCanonical 0x00200000

CONSTANT: PixelFormatUndefined 0
CONSTANT: PixelFormatDontCare  0
CONSTANT: PixelFormatMax               15

: PixelFormat1bppIndexed ( -- x )
    1  1 flags{ PixelFormatIndexed PixelFormatGDI } pixel-format-constant ; inline
: PixelFormat4bppIndexed ( -- x )
    2  4 flags{ PixelFormatIndexed PixelFormatGDI } pixel-format-constant ; inline
: PixelFormat8bppIndexed ( -- x )
    3  8 flags{ PixelFormatIndexed PixelFormatGDI } pixel-format-constant ; inline
: PixelFormat16bppGrayScale ( -- x )
    4 16 PixelFormatExtended pixel-format-constant ; inline
: PixelFormat16bppRGB555 ( -- x )
    5 16 PixelFormatGDI pixel-format-constant ; inline
: PixelFormat16bppRGB565 ( -- x )
    6 16 PixelFormatGDI pixel-format-constant ; inline
: PixelFormat16bppARGB1555 ( -- x )
    7 16 flags{ PixelFormatAlpha PixelFormatGDI } pixel-format-constant ; inline
: PixelFormat24bppRGB ( -- x )
    8 24 PixelFormatGDI pixel-format-constant ; inline
: PixelFormat32bppRGB ( -- x )
    9 32 PixelFormatGDI pixel-format-constant ; inline
: PixelFormat32bppARGB ( -- x )
    10 32 flags{ PixelFormatAlpha PixelFormatGDI PixelFormatCanonical } pixel-format-constant ; inline
: PixelFormat32bppPARGB ( -- x )
    11 32 flags{ PixelFormatAlpha PixelFormatPAlpha PixelFormatGDI } pixel-format-constant ; inline
: PixelFormat48bppRGB ( -- x )
    12 48 PixelFormatExtended pixel-format-constant ; inline
: PixelFormat64bppARGB ( -- x )
    13 64 flags{ PixelFormatAlpha PixelFormatCanonical PixelFormatExtended } pixel-format-constant ; inline
: PixelFormat64bppPARGB ( -- x )
    14 64 flags{ PixelFormatAlpha PixelFormatPAlpha PixelFormatExtended } pixel-format-constant ; inline

STRUCT: ColorPalette
    { Flags UINT }
    { Count UINT }
    { Entries ARGB[1] } ;

! XXX RECTL and SIZEL should go with other metafile definitions if we add them
STRUCT: RECTL
    { left   LONG }
    { top    LONG }
    { right  LONG }
    { bottom LONG } ;

STRUCT: SIZEL
    { width LONG }
    { height LONG } ;

STRUCT: ENHMETAHEADER3
    { iType DWORD }
    { nSize DWORD }
    { rclBounds RECTL }
    { rclFrame RECTL }
    { dSignature DWORD }
    { nVersion DWORD }
    { nBytes DWORD }
    { nRecords DWORD }
    { nHandles WORD }
    { sReserved WORD }
    { nDescription DWORD }
    { offDescription DWORD }
    { nPalEntries DWORD }
    { szlDevice SIZEL }
    { szlMillimeters SIZEL } ;

STRUCT: PWMFRect16
    { Left INT16 }
    { Top INT16 }
    { Right INT16 }
    { Bottom INT16 } ;

STRUCT: WmfPlaceableFileHeader
    { Key UINT32 }
    { Hmf INT16 }
    { BoundingBox PWMFRect16 }
    { Inch INT16 }
    { Reserved INT16[2] }
    { Checksum INT16 } ;

CONSTANT: GDIP_EMFPLUSFLAGS_DISPLAY 1

! XXX we don't have a METAHEADER struct defined
! UNION-STRUCT: MetafileHeader-union
!     { WmfHeader METAHEADER }
!     { EmfHeader ENHMETAHEADER3 } ;

UNION-STRUCT: MetafileHeader-union
    { EmfHeader ENHMETAHEADER3 } ;

STRUCT: MetafileHeader
    { Type MetafileType }
    { Size UINT }
    { Version UINT }
    { EmfPlusFlags UINT }
    { DpiX REAL }
    { DpiY REAL }
    { X INT }
    { Y INT }
    { Width INT }
    { Height INT }
    { Header-union MetafileHeader-union }
    { EmfPlusHeaderSize INT }
    { LogicalDpiX INT }
    { LogicalDpiY INT } ;

CONSTANT: ImageFormatUndefined      GUID: {b96b3ca9-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatMemoryBMP      GUID: {b96b3caa-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatBMP            GUID: {b96b3cab-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatEMF            GUID: {b96b3cac-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatWMF            GUID: {b96b3cad-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatJPEG           GUID: {b96b3cae-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatPNG            GUID: {b96b3caf-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatGIF            GUID: {b96b3cb0-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatTIFF           GUID: {b96b3cb1-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatEXIF           GUID: {b96b3cb2-0728-11d3-9d7b-0000f81ef32e}
CONSTANT: ImageFormatIcon           GUID: {b96b3cb5-0728-11d3-9d7b-0000f81ef32e}

CONSTANT: FrameDimensionTime        GUID: {6aedbd6d-3fb5-418a-83a6-7f45229dc872}
CONSTANT: FrameDimensionPage        GUID: {7462dc86-6180-4c7e-8e3f-ee7333a7a483}
CONSTANT: FrameDimensionResolution  GUID: {84236f7b-3bd3-428f-8dab-4ea1439ca315}

ENUM: ImageLockMode
    { ImageLockModeRead           1 }
    { ImageLockModeWrite          2 }
    { ImageLockModeUserInputBuf   4 } ;

ENUM: RotateFlipType
    { RotateNoneFlipNone 0 }
    { Rotate180FlipXY    RotateNoneFlipNone }

    { Rotate90FlipNone   1 }
    { Rotate270FlipXY    Rotate90FlipNone }

    { Rotate180FlipNone  2 }
    { RotateNoneFlipXY   Rotate180FlipNone }

    { Rotate270FlipNone  3 }
    { Rotate90FlipXY     Rotate270FlipNone }

    { RotateNoneFlipX    4 }
    { Rotate180FlipY     RotateNoneFlipX }

    { Rotate90FlipX      5 }
    { Rotate270FlipY     Rotate90FlipX }

    { Rotate180FlipX     6 }
    { RotateNoneFlipY    Rotate180FlipX }

    { Rotate270FlipX     7 }
    { Rotate90FlipY      Rotate270FlipX } ;

STRUCT: EncoderParameter
    { Guid GUID }
    { NumberOfValues ULONG }
    { Type ULONG }
    { Value void* } ;

STRUCT: EncoderParameters
    { Count UINT }
    { Parameter EncoderParameter[1] } ;

STRUCT: ImageCodecInfo
    { Clsid CLSID }
    { FormatID GUID }
    { CodecName WCHAR* }
    { DllName WCHAR* }
    { FormatDescription WCHAR* }
    { FilenameExtension WCHAR* }
    { MimeType WCHAR* }
    { Flags DWORD }
    { Version DWORD }
    { SigCount DWORD }
    { SigSize DWORD }
    { SigPattern BYTE* }
    { SigMask BYTE* } ;

STRUCT: BitmapData
    { Width UINT }
    { Height UINT }
    { Stride INT }
    { PixelFormat PixelFormat }
    { Scan0 void* }
    { Reserved UINT_PTR } ;

STRUCT: ImageItemData
    { Size UINT }
    { Position UINT }
    { Desc void* }
    { DescSize UINT }
    { Data void* }
    { DataSize UINT }
    { Cookie UINT } ;

STRUCT: PropertyItem
    { id PROPID }
    { length ULONG }
    { type WORD }
    { value void* } ;

CONSTANT: PropertyTagTypeByte       1
CONSTANT: PropertyTagTypeASCII      2
CONSTANT: PropertyTagTypeShort      3
CONSTANT: PropertyTagTypeLong       4
CONSTANT: PropertyTagTypeRational   5
CONSTANT: PropertyTagTypeUndefined  7
CONSTANT: PropertyTagTypeSLONG      9
CONSTANT: PropertyTagTypeSRational 10

CONSTANT: PropertyTagExifIFD                0x8769
CONSTANT: PropertyTagGpsIFD                 0x8825

CONSTANT: PropertyTagNewSubfileType         0x00FE
CONSTANT: PropertyTagSubfileType            0x00FF
CONSTANT: PropertyTagImageWidth             0x0100
CONSTANT: PropertyTagImageHeight            0x0101
CONSTANT: PropertyTagBitsPerSample          0x0102
CONSTANT: PropertyTagCompression            0x0103
CONSTANT: PropertyTagPhotometricInterp      0x0106
CONSTANT: PropertyTagThreshHolding          0x0107
CONSTANT: PropertyTagCellWidth              0x0108
CONSTANT: PropertyTagCellHeight             0x0109
CONSTANT: PropertyTagFillOrder              0x010A
CONSTANT: PropertyTagDocumentName           0x010D
CONSTANT: PropertyTagImageDescription       0x010E
CONSTANT: PropertyTagEquipMake              0x010F
CONSTANT: PropertyTagEquipModel             0x0110
CONSTANT: PropertyTagStripOffsets           0x0111
CONSTANT: PropertyTagOrientation            0x0112
CONSTANT: PropertyTagSamplesPerPixel        0x0115
CONSTANT: PropertyTagRowsPerStrip           0x0116
CONSTANT: PropertyTagStripBytesCount        0x0117
CONSTANT: PropertyTagMinSampleValue         0x0118
CONSTANT: PropertyTagMaxSampleValue         0x0119
CONSTANT: PropertyTagXResolution            0x011A
CONSTANT: PropertyTagYResolution            0x011B
CONSTANT: PropertyTagPlanarConfig           0x011C
CONSTANT: PropertyTagPageName               0x011D
CONSTANT: PropertyTagXPosition              0x011E
CONSTANT: PropertyTagYPosition              0x011F
CONSTANT: PropertyTagFreeOffset             0x0120
CONSTANT: PropertyTagFreeByteCounts         0x0121
CONSTANT: PropertyTagGrayResponseUnit       0x0122
CONSTANT: PropertyTagGrayResponseCurve      0x0123
CONSTANT: PropertyTagT4Option               0x0124
CONSTANT: PropertyTagT6Option               0x0125
CONSTANT: PropertyTagResolutionUnit         0x0128
CONSTANT: PropertyTagPageNumber             0x0129
CONSTANT: PropertyTagTransferFuncition      0x012D
CONSTANT: PropertyTagSoftwareUsed           0x0131
CONSTANT: PropertyTagDateTime               0x0132
CONSTANT: PropertyTagArtist                 0x013B
CONSTANT: PropertyTagHostComputer           0x013C
CONSTANT: PropertyTagPredictor              0x013D
CONSTANT: PropertyTagWhitePoint             0x013E
CONSTANT: PropertyTagPrimaryChromaticities  0x013F
CONSTANT: PropertyTagColorMap               0x0140
CONSTANT: PropertyTagHalftoneHints          0x0141
CONSTANT: PropertyTagTileWidth              0x0142
CONSTANT: PropertyTagTileLength             0x0143
CONSTANT: PropertyTagTileOffset             0x0144
CONSTANT: PropertyTagTileByteCounts         0x0145
CONSTANT: PropertyTagInkSet                 0x014C
CONSTANT: PropertyTagInkNames               0x014D
CONSTANT: PropertyTagNumberOfInks           0x014E
CONSTANT: PropertyTagDotRange               0x0150
CONSTANT: PropertyTagTargetPrinter          0x0151
CONSTANT: PropertyTagExtraSamples           0x0152
CONSTANT: PropertyTagSampleFormat           0x0153
CONSTANT: PropertyTagSMinSampleValue        0x0154
CONSTANT: PropertyTagSMaxSampleValue        0x0155
CONSTANT: PropertyTagTransferRange          0x0156

CONSTANT: PropertyTagJPEGProc               0x0200
CONSTANT: PropertyTagJPEGInterFormat        0x0201
CONSTANT: PropertyTagJPEGInterLength        0x0202
CONSTANT: PropertyTagJPEGRestartInterval    0x0203
CONSTANT: PropertyTagJPEGLosslessPredictors 0x0205
CONSTANT: PropertyTagJPEGPointTransforms    0x0206
CONSTANT: PropertyTagJPEGQTables            0x0207
CONSTANT: PropertyTagJPEGDCTables           0x0208
CONSTANT: PropertyTagJPEGACTables           0x0209

CONSTANT: PropertyTagYCbCrCoefficients      0x0211
CONSTANT: PropertyTagYCbCrSubsampling       0x0212
CONSTANT: PropertyTagYCbCrPositioning       0x0213
CONSTANT: PropertyTagREFBlackWhite          0x0214

CONSTANT: PropertyTagICCProfile          0x8773

CONSTANT: PropertyTagGamma                0x0301
CONSTANT: PropertyTagICCProfileDescriptor 0x0302
CONSTANT: PropertyTagSRGBRenderingIntent  0x0303

CONSTANT: PropertyTagImageTitle          0x0320
CONSTANT: PropertyTagCopyright           0x8298

CONSTANT: PropertyTagResolutionXUnit            0x5001
CONSTANT: PropertyTagResolutionYUnit            0x5002
CONSTANT: PropertyTagResolutionXLengthUnit      0x5003
CONSTANT: PropertyTagResolutionYLengthUnit      0x5004
CONSTANT: PropertyTagPrintFlags                 0x5005
CONSTANT: PropertyTagPrintFlagsVersion          0x5006
CONSTANT: PropertyTagPrintFlagsCrop             0x5007
CONSTANT: PropertyTagPrintFlagsBleedWidth       0x5008
CONSTANT: PropertyTagPrintFlagsBleedWidthScale  0x5009
CONSTANT: PropertyTagHalftoneLPI                0x500A
CONSTANT: PropertyTagHalftoneLPIUnit            0x500B
CONSTANT: PropertyTagHalftoneDegree             0x500C
CONSTANT: PropertyTagHalftoneShape              0x500D
CONSTANT: PropertyTagHalftoneMisc               0x500E
CONSTANT: PropertyTagHalftoneScreen             0x500F
CONSTANT: PropertyTagJPEGQuality                0x5010
CONSTANT: PropertyTagGridSize                   0x5011
CONSTANT: PropertyTagThumbnailFormat            0x5012
CONSTANT: PropertyTagThumbnailWidth             0x5013
CONSTANT: PropertyTagThumbnailHeight            0x5014
CONSTANT: PropertyTagThumbnailColorDepth        0x5015
CONSTANT: PropertyTagThumbnailPlanes            0x5016
CONSTANT: PropertyTagThumbnailRawBytes          0x5017
CONSTANT: PropertyTagThumbnailSize              0x5018
CONSTANT: PropertyTagThumbnailCompressedSize    0x5019
CONSTANT: PropertyTagColorTransferFunction      0x501A
CONSTANT: PropertyTagThumbnailData              0x501B

CONSTANT: PropertyTagThumbnailImageWidth        0x5020
CONSTANT: PropertyTagThumbnailImageHeight       0x5021
CONSTANT: PropertyTagThumbnailBitsPerSample     0x5022
CONSTANT: PropertyTagThumbnailCompression       0x5023
CONSTANT: PropertyTagThumbnailPhotometricInterp 0x5024
CONSTANT: PropertyTagThumbnailImageDescription  0x5025
CONSTANT: PropertyTagThumbnailEquipMake         0x5026
CONSTANT: PropertyTagThumbnailEquipModel        0x5027
CONSTANT: PropertyTagThumbnailStripOffsets      0x5028
CONSTANT: PropertyTagThumbnailOrientation       0x5029
CONSTANT: PropertyTagThumbnailSamplesPerPixel   0x502A
CONSTANT: PropertyTagThumbnailRowsPerStrip      0x502B
CONSTANT: PropertyTagThumbnailStripBytesCount   0x502C
CONSTANT: PropertyTagThumbnailResolutionX       0x502D
CONSTANT: PropertyTagThumbnailResolutionY       0x502E
CONSTANT: PropertyTagThumbnailPlanarConfig      0x502F
CONSTANT: PropertyTagThumbnailResolutionUnit    0x5030
CONSTANT: PropertyTagThumbnailTransferFunction  0x5031
CONSTANT: PropertyTagThumbnailSoftwareUsed      0x5032
CONSTANT: PropertyTagThumbnailDateTime          0x5033
CONSTANT: PropertyTagThumbnailArtist            0x5034
CONSTANT: PropertyTagThumbnailWhitePoint        0x5035
CONSTANT: PropertyTagThumbnailPrimaryChromaticities 0x5036
CONSTANT: PropertyTagThumbnailYCbCrCoefficients 0x5037
CONSTANT: PropertyTagThumbnailYCbCrSubsampling  0x5038
CONSTANT: PropertyTagThumbnailYCbCrPositioning  0x5039
CONSTANT: PropertyTagThumbnailRefBlackWhite     0x503A
CONSTANT: PropertyTagThumbnailCopyRight         0x503B

CONSTANT: PropertyTagLuminanceTable    0x5090
CONSTANT: PropertyTagChrominanceTable  0x5091

CONSTANT: PropertyTagFrameDelay        0x5100
CONSTANT: PropertyTagLoopCount         0x5101

CONSTANT: PropertyTagPixelUnit         0x5110
CONSTANT: PropertyTagPixelPerUnitX     0x5111
CONSTANT: PropertyTagPixelPerUnitY     0x5112
CONSTANT: PropertyTagPaletteHistogram  0x5113

CONSTANT: PropertyTagExifExposureTime  0x829A
CONSTANT: PropertyTagExifFNumber       0x829D

CONSTANT: PropertyTagExifExposureProg  0x8822
CONSTANT: PropertyTagExifSpectralSense 0x8824
CONSTANT: PropertyTagExifISOSpeed      0x8827
CONSTANT: PropertyTagExifOECF          0x8828

CONSTANT: PropertyTagExifVer           0x9000
CONSTANT: PropertyTagExifDTOrig        0x9003
CONSTANT: PropertyTagExifDTDigitized   0x9004

CONSTANT: PropertyTagExifCompConfig    0x9101
CONSTANT: PropertyTagExifCompBPP       0x9102

CONSTANT: PropertyTagExifShutterSpeed  0x9201
CONSTANT: PropertyTagExifAperture      0x9202
CONSTANT: PropertyTagExifBrightness    0x9203
CONSTANT: PropertyTagExifExposureBias  0x9204
CONSTANT: PropertyTagExifMaxAperture   0x9205
CONSTANT: PropertyTagExifSubjectDist   0x9206
CONSTANT: PropertyTagExifMeteringMode  0x9207
CONSTANT: PropertyTagExifLightSource   0x9208
CONSTANT: PropertyTagExifFlash         0x9209
CONSTANT: PropertyTagExifFocalLength   0x920A
CONSTANT: PropertyTagExifMakerNote     0x927C
CONSTANT: PropertyTagExifUserComment   0x9286
CONSTANT: PropertyTagExifDTSubsec      0x9290
CONSTANT: PropertyTagExifDTOrigSS      0x9291
CONSTANT: PropertyTagExifDTDigSS       0x9292

CONSTANT: PropertyTagExifFPXVer        0xA000
CONSTANT: PropertyTagExifColorSpace    0xA001
CONSTANT: PropertyTagExifPixXDim       0xA002
CONSTANT: PropertyTagExifPixYDim       0xA003
CONSTANT: PropertyTagExifRelatedWav    0xA004
CONSTANT: PropertyTagExifInterop       0xA005
CONSTANT: PropertyTagExifFlashEnergy   0xA20B
CONSTANT: PropertyTagExifSpatialFR     0xA20C
CONSTANT: PropertyTagExifFocalXRes     0xA20E
CONSTANT: PropertyTagExifFocalYRes     0xA20F
CONSTANT: PropertyTagExifFocalResUnit  0xA210
CONSTANT: PropertyTagExifSubjectLoc    0xA214
CONSTANT: PropertyTagExifExposureIndex 0xA215
CONSTANT: PropertyTagExifSensingMethod 0xA217
CONSTANT: PropertyTagExifFileSource    0xA300
CONSTANT: PropertyTagExifSceneType     0xA301
CONSTANT: PropertyTagExifCfaPattern    0xA302

CONSTANT: PropertyTagGpsVer            0x0000
CONSTANT: PropertyTagGpsLatitudeRef    0x0001
CONSTANT: PropertyTagGpsLatitude       0x0002
CONSTANT: PropertyTagGpsLongitudeRef   0x0003
CONSTANT: PropertyTagGpsLongitude      0x0004
CONSTANT: PropertyTagGpsAltitudeRef    0x0005
CONSTANT: PropertyTagGpsAltitude       0x0006
CONSTANT: PropertyTagGpsGpsTime        0x0007
CONSTANT: PropertyTagGpsGpsSatellites  0x0008
CONSTANT: PropertyTagGpsGpsStatus      0x0009
CONSTANT: PropertyTagGpsGpsMeasureMode 0x000A
CONSTANT: PropertyTagGpsGpsDop         0x000B
CONSTANT: PropertyTagGpsSpeedRef       0x000C
CONSTANT: PropertyTagGpsSpeed          0x000D
CONSTANT: PropertyTagGpsTrackRef       0x000E
CONSTANT: PropertyTagGpsTrack          0x000F
CONSTANT: PropertyTagGpsImgDirRef      0x0010
CONSTANT: PropertyTagGpsImgDir         0x0011
CONSTANT: PropertyTagGpsMapDatum       0x0012
CONSTANT: PropertyTagGpsDestLatRef     0x0013
CONSTANT: PropertyTagGpsDestLat        0x0014
CONSTANT: PropertyTagGpsDestLongRef    0x0015
CONSTANT: PropertyTagGpsDestLong       0x0016
CONSTANT: PropertyTagGpsDestBearRef    0x0017
CONSTANT: PropertyTagGpsDestBear       0x0018
CONSTANT: PropertyTagGpsDestDistRef    0x0019
CONSTANT: PropertyTagGpsDestDist       0x001A

ENUM: ColorChannelFlags
    ColorChannelFlagsC
    ColorChannelFlagsM
    ColorChannelFlagsY
    ColorChannelFlagsK
    ColorChannelFlagsLast ;

STRUCT: GpColor
    { Argb ARGB } ;

STRUCT: ColorMatrix
    { m REAL[5][5] } ;

ENUM: ColorMatrixFlags
    { ColorMatrixFlagsDefault    0 }
    { ColorMatrixFlagsSkipGrays  1 }
    { ColorMatrixFlagsAltGray    2 } ;

ENUM: ColorAdjustType
    ColorAdjustTypeDefault
    ColorAdjustTypeBitmap
    ColorAdjustTypeBrush
    ColorAdjustTypePen
    ColorAdjustTypeText
    ColorAdjustTypeCount
    ColorAdjustTypeAny ;

STRUCT: ColorMap
    { oldColor GpColor }
    { newColor GpColor } ;

C-TYPE: GpGraphics
C-TYPE: GpPen
C-TYPE: GpBrush
C-TYPE: GpHatch
C-TYPE: GpSolidFill
C-TYPE: GpPath
C-TYPE: GpMatrix
C-TYPE: GpPathIterator
C-TYPE: GpCustomLineCap
C-TYPE: GpAdjustableArrowCap
C-TYPE: GpImage
C-TYPE: GpMetafile
C-TYPE: GpImageAttributes
C-TYPE: GpCachedBitmap
C-TYPE: GpBitmap
C-TYPE: GpPathGradient
C-TYPE: GpLineGradient
C-TYPE: GpTexture
C-TYPE: GpFont
C-TYPE: GpFontCollection
C-TYPE: GpFontFamily
C-TYPE: GpStringFormat
C-TYPE: GpRegion
C-TYPE: CGpEffect

! dummy out other windows types we don't care to define yet
C-TYPE: LOGFONTA
C-TYPE: LOGFONTW

FUNCTION: GpStatus GdipCreateAdjustableArrowCap ( REAL x, REAL x, BOOL x, GpAdjustableArrowCap** x )
FUNCTION: GpStatus GdipGetAdjustableArrowCapFillState ( GpAdjustableArrowCap* x, BOOL* x )
FUNCTION: GpStatus GdipGetAdjustableArrowCapHeight ( GpAdjustableArrowCap* x, REAL* x )
FUNCTION: GpStatus GdipGetAdjustableArrowCapMiddleInset ( GpAdjustableArrowCap* x, REAL* x )
FUNCTION: GpStatus GdipGetAdjustableArrowCapWidth ( GpAdjustableArrowCap* x, REAL* x )
FUNCTION: GpStatus GdipSetAdjustableArrowCapFillState ( GpAdjustableArrowCap* x, BOOL x )
FUNCTION: GpStatus GdipSetAdjustableArrowCapHeight ( GpAdjustableArrowCap* x, REAL x )
FUNCTION: GpStatus GdipSetAdjustableArrowCapMiddleInset ( GpAdjustableArrowCap* x, REAL x )
FUNCTION: GpStatus GdipSetAdjustableArrowCapWidth ( GpAdjustableArrowCap* x, REAL x )

FUNCTION: GpStatus GdipBitmapApplyEffect ( GpBitmap* x, CGpEffect* x, RECT* x, BOOL x, VOID** x, INT* x )
FUNCTION: GpStatus GdipBitmapCreateApplyEffect ( GpBitmap** x, INT x, CGpEffect* x, RECT* x, RECT* x, GpBitmap** x, BOOL x, VOID** x, INT* x )
FUNCTION: GpStatus GdipBitmapGetPixel ( GpBitmap* x, INT x, INT x, ARGB* x )
FUNCTION: GpStatus GdipBitmapLockBits ( GpBitmap* x, GpRect* x, UINT x,
             PixelFormat x, BitmapData* x )
FUNCTION: GpStatus GdipBitmapSetPixel ( GpBitmap* x, INT x, INT x, ARGB x )
FUNCTION: GpStatus GdipBitmapSetResolution ( GpBitmap* x, REAL x, REAL x )
FUNCTION: GpStatus GdipBitmapUnlockBits ( GpBitmap* x, BitmapData* x )
FUNCTION: GpStatus GdipCloneBitmapArea ( REAL x, REAL x, REAL x, REAL x, PixelFormat x, GpBitmap* x, GpBitmap** x )
FUNCTION: GpStatus GdipCloneBitmapAreaI ( INT x, INT x, INT x, INT x, PixelFormat x, GpBitmap* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromFile ( WCHAR* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromFileICM ( WCHAR* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromGdiDib ( BITMAPINFO* x, VOID* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromGraphics ( INT x, INT x, GpGraphics* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromHBITMAP ( HBITMAP x,  HPALETTE x,  GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromHICON ( HICON x,  GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromResource ( HINSTANCE x, WCHAR* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromScan0 ( INT x, INT x, INT x, PixelFormat x, BYTE* x,
             GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromStream ( IStream* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateBitmapFromStreamICM ( IStream* x, GpBitmap** x )
FUNCTION: GpStatus GdipCreateHBITMAPFromBitmap ( GpBitmap* x, HBITMAP* x, ARGB x )
FUNCTION: GpStatus GdipCreateHICONFromBitmap ( GpBitmap* x, HICON* x )
FUNCTION: GpStatus GdipDeleteEffect ( CGpEffect* x )
FUNCTION: GpStatus GdipSetEffectParameters ( CGpEffect* x, VOID* x, UINT x )


FUNCTION: GpStatus GdipCloneBrush ( GpBrush* x, GpBrush** x )
FUNCTION: GpStatus GdipDeleteBrush ( GpBrush* x )
FUNCTION: GpStatus GdipGetBrushType ( GpBrush* x, GpBrushType* x )


FUNCTION: GpStatus GdipCreateCachedBitmap ( GpBitmap* x, GpGraphics* x,
             GpCachedBitmap** x )
FUNCTION: GpStatus GdipDeleteCachedBitmap ( GpCachedBitmap* x )
FUNCTION: GpStatus GdipDrawCachedBitmap ( GpGraphics* x, GpCachedBitmap* x, INT x, INT x )


FUNCTION: GpStatus GdipCloneCustomLineCap ( GpCustomLineCap* x, GpCustomLineCap** x )
FUNCTION: GpStatus GdipCreateCustomLineCap ( GpPath* x, GpPath* x, GpLineCap x, REAL x,
             GpCustomLineCap** x )
FUNCTION: GpStatus GdipDeleteCustomLineCap ( GpCustomLineCap* x )
FUNCTION: GpStatus GdipGetCustomLineCapBaseCap ( GpCustomLineCap* x, GpLineCap* x )
FUNCTION: GpStatus GdipSetCustomLineCapBaseCap ( GpCustomLineCap* x, GpLineCap x )
FUNCTION: GpStatus GdipGetCustomLineCapBaseInset ( GpCustomLineCap* x, REAL* x )
FUNCTION: GpStatus GdipSetCustomLineCapBaseInset ( GpCustomLineCap* x, REAL x )
FUNCTION: GpStatus GdipSetCustomLineCapStrokeCaps ( GpCustomLineCap* x, GpLineCap x,
             GpLineCap x )
FUNCTION: GpStatus GdipGetCustomLineCapStrokeJoin ( GpCustomLineCap* x, GpLineJoin* x )
FUNCTION: GpStatus GdipSetCustomLineCapStrokeJoin ( GpCustomLineCap* x, GpLineJoin x )
FUNCTION: GpStatus GdipGetCustomLineCapWidthScale ( GpCustomLineCap* x, REAL* x )
FUNCTION: GpStatus GdipSetCustomLineCapWidthScale ( GpCustomLineCap* x, REAL x )

FUNCTION: GpStatus GdipCloneFont ( GpFont* x, GpFont** x )
FUNCTION: GpStatus GdipCreateFont ( GpFontFamily* x,  REAL x,  INT x,  GpUnit x,
             GpFont** x )
FUNCTION: GpStatus GdipCreateFontFromDC ( HDC x, GpFont** x )
FUNCTION: GpStatus GdipCreateFontFromLogfontA ( HDC x, LOGFONTA* x, GpFont** x )
FUNCTION: GpStatus GdipCreateFontFromLogfontW ( HDC x, LOGFONTW* x, GpFont** x )
FUNCTION: GpStatus GdipDeleteFont ( GpFont* x )
FUNCTION: GpStatus GdipGetLogFontA ( GpFont* x, GpGraphics* x, LOGFONTA* x )
FUNCTION: GpStatus GdipGetLogFontW ( GpFont* x, GpGraphics* x, LOGFONTW* x )
FUNCTION: GpStatus GdipGetFamily ( GpFont* x,  GpFontFamily** x )
FUNCTION: GpStatus GdipGetFontUnit ( GpFont* x,  GpUnit* x )
FUNCTION: GpStatus GdipGetFontSize ( GpFont* x,  REAL* x )
FUNCTION: GpStatus GdipGetFontStyle ( GpFont* x,  INT* x )
FUNCTION: GpStatus GdipGetFontHeight ( GpFont* x,  GpGraphics* x,
                 REAL* x )
FUNCTION: GpStatus GdipGetFontHeightGivenDPI ( GpFont* x,  REAL x,  REAL* x )


FUNCTION: GpStatus GdipNewInstalledFontCollection ( GpFontCollection** x )
FUNCTION: GpStatus GdipNewPrivateFontCollection ( GpFontCollection** x )
FUNCTION: GpStatus GdipDeletePrivateFontCollection ( GpFontCollection** x )
FUNCTION: GpStatus GdipPrivateAddFontFile ( GpFontCollection* x,  WCHAR* x )
FUNCTION: GpStatus GdipPrivateAddMemoryFont ( GpFontCollection* x,
                 void* x, INT x )
FUNCTION: GpStatus GdipGetFontCollectionFamilyCount ( GpFontCollection* x,  INT* x )
FUNCTION: GpStatus GdipGetFontCollectionFamilyList ( GpFontCollection* x,  INT x,
                 GpFontFamily** x,  INT* x )


FUNCTION: GpStatus GdipCloneFontFamily ( GpFontFamily* x,  GpFontFamily** x )
FUNCTION: GpStatus GdipCreateFontFamilyFromName ( WCHAR* x,
             GpFontCollection* x,  GpFontFamily** x )
FUNCTION: GpStatus GdipDeleteFontFamily ( GpFontFamily* x )
FUNCTION: GpStatus GdipGetFamilyName ( GpFontFamily* x,  WCHAR* x,  LANGID x )
FUNCTION: GpStatus GdipGetCellAscent ( GpFontFamily* x,  INT x,  UINT16* x )
FUNCTION: GpStatus GdipGetCellDescent ( GpFontFamily* x,  INT x,  UINT16* x )
FUNCTION: GpStatus GdipGetEmHeight ( GpFontFamily* x,  INT x,  UINT16* x )
FUNCTION: GpStatus GdipGetGenericFontFamilySansSerif ( GpFontFamily** x )
FUNCTION: GpStatus GdipGetGenericFontFamilySerif ( GpFontFamily** x )
FUNCTION: GpStatus GdipGetGenericFontFamilyMonospace ( GpFontFamily** x )
FUNCTION: GpStatus GdipGetLineSpacing ( GpFontFamily* x,  INT x,  UINT16* x )
FUNCTION: GpStatus GdipIsStyleAvailable ( GpFontFamily* x,  INT x,  BOOL* x )


FUNCTION: GpStatus GdipFlush ( GpGraphics* x,  GpFlushIntention x )
FUNCTION: GpStatus GdipBeginContainer ( GpGraphics* x, GpRectF* x, GpRectF* x, GpUnit x, GraphicsContainer* x )
FUNCTION: GpStatus GdipBeginContainer2 ( GpGraphics* x, GraphicsContainer* x )
FUNCTION: GpStatus GdipBeginContainerI ( GpGraphics* x, GpRect* x, GpRect* x, GpUnit x, GraphicsContainer* x )
FUNCTION: GpStatus GdipEndContainer ( GpGraphics* x, GraphicsContainer x )
FUNCTION: GpStatus GdipComment ( GpGraphics* x, UINT x, BYTE* x )
FUNCTION: GpStatus GdipCreateFromHDC ( HDC x, GpGraphics** x )
FUNCTION: GpStatus GdipCreateFromHDC2 ( HDC x, HANDLE x, GpGraphics** x )
FUNCTION: GpStatus GdipCreateFromHWND ( HWND x, GpGraphics** x )
FUNCTION: GpStatus GdipCreateFromHWNDICM ( HWND x, GpGraphics** x )
FUNCTION: HPALETTE GdipCreateHalftonePalette ( )
FUNCTION: GpStatus GdipDeleteGraphics ( GpGraphics* x )
FUNCTION: GpStatus GdipDrawArc ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawArcI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawBezier ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawBezierI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipDrawBeziers ( GpGraphics* x, GpPen* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipDrawBeziersI ( GpGraphics* x, GpPen* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipDrawClosedCurve ( GpGraphics* x, GpPen* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipDrawClosedCurveI ( GpGraphics* x, GpPen* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipDrawClosedCurve2 ( GpGraphics* x, GpPen* x, GpPointF* x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawClosedCurve2I ( GpGraphics* x, GpPen* x, GpPoint* x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawCurve ( GpGraphics* x, GpPen* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipDrawCurveI ( GpGraphics* x, GpPen* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipDrawCurve2 ( GpGraphics* x, GpPen* x, GpPointF* x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawCurve2I ( GpGraphics* x, GpPen* x, GpPoint* x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawCurve3 ( GpGraphics* x, GpPen* x, GpPointF* x, INT x, INT x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawCurve3I ( GpGraphics* x, GpPen* x, GpPoint* x, INT x, INT x, INT x, REAL x )
FUNCTION: GpStatus GdipDrawDriverString ( GpGraphics* x, UINT16* x, INT x,
             GpFont* x, GpBrush* x, GpPointF* x, INT x, GpMatrix* x )
FUNCTION: GpStatus GdipDrawEllipse ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawEllipseI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipDrawImage ( GpGraphics* x, GpImage* x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawImageI ( GpGraphics* x, GpImage* x, INT x, INT x )
FUNCTION: GpStatus GdipDrawImagePointRect ( GpGraphics* x, GpImage* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, GpUnit x )
FUNCTION: GpStatus GdipDrawImagePointRectI ( GpGraphics* x, GpImage* x, INT x, INT x, INT x, INT x, INT x, INT x, GpUnit x )
FUNCTION: GpStatus GdipDrawImagePoints ( GpGraphics* x, GpImage* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipDrawImagePointsI ( GpGraphics* x, GpImage* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipDrawImagePointsRect ( GpGraphics* x, GpImage* x,
             GpPointF* x, INT x, REAL x, REAL x, REAL x, REAL x, GpUnit x,
             GpImageAttributes* x, DrawImageAbort x, VOID* x )
FUNCTION: GpStatus GdipDrawImagePointsRectI ( GpGraphics* x, GpImage* x,
             GpPoint* x, INT x, INT x, INT x, INT x, INT x, GpUnit x,
             GpImageAttributes* x, DrawImageAbort x, VOID* x )
FUNCTION: GpStatus GdipDrawImageRect ( GpGraphics* x, GpImage* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawImageRectI ( GpGraphics* x, GpImage* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipDrawImageRectRect ( GpGraphics* x, GpImage* x, REAL x, REAL x, REAL x,
             REAL x, REAL x, REAL x, REAL x, REAL x, GpUnit x, GpImageAttributes* x, DrawImageAbort x,
             VOID* x )
FUNCTION: GpStatus GdipDrawImageRectRectI ( GpGraphics* x, GpImage* x, INT x, INT x, INT x,
             INT x, INT x, INT x, INT x, INT x, GpUnit x, GpImageAttributes* x, DrawImageAbort x,
             VOID* x )
FUNCTION: GpStatus GdipDrawLine ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawLineI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipDrawLines ( GpGraphics* x, GpPen* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipDrawLinesI ( GpGraphics* x, GpPen* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipDrawPath ( GpGraphics* x, GpPen* x, GpPath* x )
FUNCTION: GpStatus GdipDrawPie ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawPieI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawPolygon ( GpGraphics* x, GpPen* x, GpPointF* x,  INT x )
FUNCTION: GpStatus GdipDrawPolygonI ( GpGraphics* x, GpPen* x, GpPoint* x,  INT x )
FUNCTION: GpStatus GdipDrawRectangle ( GpGraphics* x, GpPen* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipDrawRectangleI ( GpGraphics* x, GpPen* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipDrawRectangles ( GpGraphics* x, GpPen* x, GpRectF* x, INT x )
FUNCTION: GpStatus GdipDrawRectanglesI ( GpGraphics* x, GpPen* x, GpRect* x, INT x )
FUNCTION: GpStatus GdipDrawString ( GpGraphics* x, WCHAR* x, INT x,
             GpFont* x, GpRectF* x,  GpStringFormat* x,
             GpBrush* x )
FUNCTION: GpStatus GdipFillClosedCurve2 ( GpGraphics* x, GpBrush* x, GpPointF* x, INT x,
             REAL x, GpFillMode x )
FUNCTION: GpStatus GdipFillClosedCurve2I ( GpGraphics* x, GpBrush* x, GpPoint* x, INT x,
             REAL x, GpFillMode x )
FUNCTION: GpStatus GdipFillEllipse ( GpGraphics* x, GpBrush* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipFillEllipseI ( GpGraphics* x, GpBrush* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipFillPath ( GpGraphics* x, GpBrush* x, GpPath* x )
FUNCTION: GpStatus GdipFillPie ( GpGraphics* x, GpBrush* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipFillPieI ( GpGraphics* x, GpBrush* x, INT x, INT x, INT x, INT x, REAL x, REAL x )
FUNCTION: GpStatus GdipFillPolygon ( GpGraphics* x, GpBrush* x, GpPointF* x,
             INT x, GpFillMode x )
FUNCTION: GpStatus GdipFillPolygonI ( GpGraphics* x, GpBrush* x, GpPoint* x,
             INT x, GpFillMode x )
FUNCTION: GpStatus GdipFillPolygon2 ( GpGraphics* x, GpBrush* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipFillPolygon2I ( GpGraphics* x, GpBrush* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipFillRectangle ( GpGraphics* x, GpBrush* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipFillRectangleI ( GpGraphics* x, GpBrush* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipFillRectangles ( GpGraphics* x, GpBrush* x, GpRectF* x, INT x )
FUNCTION: GpStatus GdipFillRectanglesI ( GpGraphics* x, GpBrush* x, GpRect* x, INT x )
FUNCTION: GpStatus GdipFillRegion ( GpGraphics* x, GpBrush* x, GpRegion* x )
FUNCTION: GpStatus GdipGetClip ( GpGraphics* x, GpRegion* x )
FUNCTION: GpStatus GdipGetClipBounds ( GpGraphics* x, GpRectF* x )
FUNCTION: GpStatus GdipGetClipBoundsI ( GpGraphics* x, GpRect* x )
FUNCTION: GpStatus GdipGetCompositingMode ( GpGraphics* x, CompositingMode* x )
FUNCTION: GpStatus GdipGetCompositingQuality ( GpGraphics* x, CompositingQuality* x )
FUNCTION: GpStatus GdipGetDC ( GpGraphics* x, HDC* x )
FUNCTION: GpStatus GdipGetDpiX ( GpGraphics* x, REAL* x )
FUNCTION: GpStatus GdipGetDpiY ( GpGraphics* x, REAL* x )
FUNCTION: GpStatus GdipGetImageDecoders ( UINT x, UINT x, ImageCodecInfo* x )
FUNCTION: GpStatus GdipGetImageDecodersSize ( UINT* x, UINT* x )
FUNCTION: GpStatus GdipGetImageGraphicsContext ( GpImage* x, GpGraphics** x )
FUNCTION: GpStatus GdipGetInterpolationMode ( GpGraphics* x, InterpolationMode* x )
FUNCTION: GpStatus GdipGetNearestColor ( GpGraphics* x, ARGB* x )
FUNCTION: GpStatus GdipGetPageScale ( GpGraphics* x, REAL* x )
FUNCTION: GpStatus GdipGetPageUnit ( GpGraphics* x, GpUnit* x )
FUNCTION: GpStatus GdipGetPixelOffsetMode ( GpGraphics* x, PixelOffsetMode* x )
FUNCTION: GpStatus GdipGetSmoothingMode ( GpGraphics* x, SmoothingMode* x )
FUNCTION: GpStatus GdipGetTextContrast ( GpGraphics* x, UINT* x )
FUNCTION: GpStatus GdipGetTextRenderingHint ( GpGraphics* x, TextRenderingHint* x )
FUNCTION: GpStatus GdipGetWorldTransform ( GpGraphics* x, GpMatrix* x )
FUNCTION: GpStatus GdipGraphicsClear ( GpGraphics* x, ARGB x )
FUNCTION: GpStatus GdipGetVisibleClipBounds ( GpGraphics* x, GpRectF* x )
FUNCTION: GpStatus GdipGetVisibleClipBoundsI ( GpGraphics* x, GpRect* x )
FUNCTION: GpStatus GdipIsClipEmpty ( GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsVisiblePoint ( GpGraphics* x, REAL x, REAL x, BOOL* x )
FUNCTION: GpStatus GdipIsVisiblePointI ( GpGraphics* x, INT x, INT x, BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRect ( GpGraphics* x, REAL x, REAL x, REAL x, REAL x, BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRectI ( GpGraphics* x, INT x, INT x, INT x, INT x, BOOL* x )
FUNCTION: GpStatus GdipMeasureCharacterRanges ( GpGraphics* x,  WCHAR* x,
             INT x,  GpFont* x,  GpRectF* x,  GpStringFormat* x,  INT x,
             GpRegion** x )
FUNCTION: GpStatus GdipMeasureDriverString ( GpGraphics* x, UINT16* x, INT x,
             GpFont* x, GpPointF* x, INT x, GpMatrix* x, GpRectF* x )
FUNCTION: GpStatus GdipMeasureString ( GpGraphics* x, WCHAR* x, INT x,
             GpFont* x, GpRectF* x, GpStringFormat* x, GpRectF* x, INT* x, INT* x )
FUNCTION: GpStatus GdipMultiplyWorldTransform ( GpGraphics* x, GpMatrix* x, GpMatrixOrder x )
FUNCTION: GpStatus GdipRecordMetafileFileName ( WCHAR* x, HDC x, EmfType x,
             GpRectF* x, MetafileFrameUnit x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipRecordMetafileFileNameI ( WCHAR* x, HDC x, EmfType x,
             GpRect* x, MetafileFrameUnit x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipRecordMetafileI ( HDC x, EmfType x, GpRect* x,
             MetafileFrameUnit x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipReleaseDC ( GpGraphics* x, HDC x )
FUNCTION: GpStatus GdipResetClip ( GpGraphics* x )
FUNCTION: GpStatus GdipResetWorldTransform ( GpGraphics* x )
FUNCTION: GpStatus GdipRestoreGraphics ( GpGraphics* x, GraphicsState x )
FUNCTION: GpStatus GdipRotateWorldTransform ( GpGraphics* x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipSaveGraphics ( GpGraphics* x, GraphicsState* x )
FUNCTION: GpStatus GdipScaleWorldTransform ( GpGraphics* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipSetClipHrgn ( GpGraphics* x, HRGN x, CombineMode x )
FUNCTION: GpStatus GdipSetClipGraphics ( GpGraphics* x, GpGraphics* x, CombineMode x )
FUNCTION: GpStatus GdipSetClipPath ( GpGraphics* x, GpPath* x, CombineMode x )
FUNCTION: GpStatus GdipSetClipRect ( GpGraphics* x, REAL x, REAL x, REAL x, REAL x, CombineMode x )
FUNCTION: GpStatus GdipSetClipRectI ( GpGraphics* x, INT x, INT x, INT x, INT x, CombineMode x )
FUNCTION: GpStatus GdipSetClipRegion ( GpGraphics* x, GpRegion* x, CombineMode x )
FUNCTION: GpStatus GdipSetCompositingMode ( GpGraphics* x, CompositingMode x )
FUNCTION: GpStatus GdipSetCompositingQuality ( GpGraphics* x, CompositingQuality x )
FUNCTION: GpStatus GdipSetInterpolationMode ( GpGraphics* x, InterpolationMode x )
FUNCTION: GpStatus GdipSetPageScale ( GpGraphics* x, REAL x )
FUNCTION: GpStatus GdipSetPageUnit ( GpGraphics* x, GpUnit x )
FUNCTION: GpStatus GdipSetPixelOffsetMode ( GpGraphics* x, PixelOffsetMode x )
FUNCTION: GpStatus GdipSetRenderingOrigin ( GpGraphics* x, INT x, INT x )
FUNCTION: GpStatus GdipSetSmoothingMode ( GpGraphics* x, SmoothingMode x )
FUNCTION: GpStatus GdipSetTextContrast ( GpGraphics* x, UINT x )
FUNCTION: GpStatus GdipSetTextRenderingHint ( GpGraphics* x, TextRenderingHint x )
FUNCTION: GpStatus GdipSetWorldTransform ( GpGraphics* x, GpMatrix* x )
FUNCTION: GpStatus GdipTransformPoints ( GpGraphics* x,  GpCoordinateSpace x,  GpCoordinateSpace x,
                                                 GpPointF* x,  INT x )
FUNCTION: GpStatus GdipTransformPointsI ( GpGraphics* x,  GpCoordinateSpace x,  GpCoordinateSpace x,
                                                  GpPoint* x,  INT x )
FUNCTION: GpStatus GdipTranslateClip ( GpGraphics* x, REAL x, REAL x )
FUNCTION: GpStatus GdipTranslateClipI ( GpGraphics* x, INT x, INT x )
FUNCTION: GpStatus GdipTranslateWorldTransform ( GpGraphics* x, REAL x, REAL x, GpMatrixOrder x )


FUNCTION: GpStatus GdipAddPathArc ( GpPath* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathArcI ( GpPath* x, INT x, INT x, INT x, INT x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathBezier ( GpPath* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathBezierI ( GpPath* x, INT x, INT x, INT x, INT x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipAddPathBeziers ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipAddPathBeziersI ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipAddPathClosedCurve ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipAddPathClosedCurveI ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipAddPathClosedCurve2 ( GpPath* x, GpPointF* x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathClosedCurve2I ( GpPath* x, GpPoint* x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathCurve ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipAddPathCurveI ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipAddPathCurve2 ( GpPath* x, GpPointF* x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathCurve2I ( GpPath* x, GpPoint* x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathCurve3 ( GpPath* x, GpPointF* x, INT x, INT x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathCurve3I ( GpPath* x, GpPoint* x, INT x, INT x, INT x, REAL x )
FUNCTION: GpStatus GdipAddPathEllipse ( GpPath* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathEllipseI ( GpPath* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipAddPathLine ( GpPath* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathLineI ( GpPath* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipAddPathLine2 ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipAddPathLine2I ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipAddPathPath ( GpPath* x, GpPath* x, BOOL x )
FUNCTION: GpStatus GdipAddPathPie ( GpPath* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathPieI ( GpPath* x, INT x, INT x, INT x, INT x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathPolygon ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipAddPathPolygonI ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipAddPathRectangle ( GpPath* x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipAddPathRectangleI ( GpPath* x, INT x, INT x, INT x, INT x )
FUNCTION: GpStatus GdipAddPathRectangles ( GpPath* x, GpRectF* x, INT x )
FUNCTION: GpStatus GdipAddPathRectanglesI ( GpPath* x, GpRect* x, INT x )
FUNCTION: GpStatus GdipAddPathString ( GpPath* x, WCHAR* x, INT x, GpFontFamily* x, INT x, REAL x, GpRectF* x, GpStringFormat* x )
FUNCTION: GpStatus GdipAddPathStringI ( GpPath* x, WCHAR* x, INT x, GpFontFamily* x, INT x, REAL x, GpRect* x, GpStringFormat* x )
FUNCTION: GpStatus GdipClearPathMarkers ( GpPath* x )
FUNCTION: GpStatus GdipClonePath ( GpPath* x, GpPath** x )
FUNCTION: GpStatus GdipClosePathFigure ( GpPath* x )
FUNCTION: GpStatus GdipClosePathFigures ( GpPath* x )
FUNCTION: GpStatus GdipCreatePath ( GpFillMode x, GpPath** x )
FUNCTION: GpStatus GdipCreatePath2 ( GpPointF* x, BYTE* x, INT x,
             GpFillMode x, GpPath** x )
FUNCTION: GpStatus GdipCreatePath2I ( GpPoint* x, BYTE* x, INT x, GpFillMode x, GpPath** x )
FUNCTION: GpStatus GdipDeletePath ( GpPath* x )
FUNCTION: GpStatus GdipFlattenPath ( GpPath* x, GpMatrix* x, REAL x )
FUNCTION: GpStatus GdipIsOutlineVisiblePathPoint ( GpPath* x, REAL x, REAL x, GpPen* x,
             GpGraphics* x, BOOL* x )
FUNCTION: GpStatus GdipIsOutlineVisiblePathPointI ( GpPath* x, INT x, INT x, GpPen* x,
             GpGraphics* x, BOOL* x )
FUNCTION: GpStatus GdipIsVisiblePathPoint ( GpPath* x, REAL x, REAL x, GpGraphics* x, BOOL* x )
FUNCTION: GpStatus GdipIsVisiblePathPointI ( GpPath* x, INT x, INT x, GpGraphics* x, BOOL* x )
FUNCTION: GpStatus GdipGetPathData ( GpPath* x, GpPathData* x )
FUNCTION: GpStatus GdipGetPathFillMode ( GpPath* x, GpFillMode* x )
FUNCTION: GpStatus GdipGetPathLastPoint ( GpPath* x, GpPointF* x )
FUNCTION: GpStatus GdipGetPathPoints ( GpPath* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipGetPathPointsI ( GpPath* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipGetPathTypes ( GpPath* x, BYTE* x, INT x )
FUNCTION: GpStatus GdipGetPathWorldBounds ( GpPath* x, GpRectF* x, GpMatrix* x, GpPen* x )
FUNCTION: GpStatus GdipGetPathWorldBoundsI ( GpPath* x, GpRect* x, GpMatrix* x, GpPen* x )
FUNCTION: GpStatus GdipGetPointCount ( GpPath* x, INT* x )
FUNCTION: GpStatus GdipResetPath ( GpPath* x )
FUNCTION: GpStatus GdipReversePath ( GpPath* x )
FUNCTION: GpStatus GdipSetPathFillMode ( GpPath* x, GpFillMode x )
FUNCTION: GpStatus GdipSetPathMarker ( GpPath* x )
FUNCTION: GpStatus GdipStartPathFigure ( GpPath* x )
FUNCTION: GpStatus GdipTransformPath ( GpPath* x, GpMatrix* x )
FUNCTION: GpStatus GdipWarpPath ( GpPath* x, GpMatrix* x, GpPointF* x, INT x, REAL x,
             REAL x, REAL x, REAL x, WarpMode x, REAL x )
FUNCTION: GpStatus GdipWidenPath ( GpPath* x, GpPen* x, GpMatrix* x, REAL x )


FUNCTION: GpStatus GdipCreateHatchBrush ( HatchStyle x, ARGB x, ARGB x, GpHatch** x )
FUNCTION: GpStatus GdipGetHatchBackgroundColor ( GpHatch* x, ARGB* x )
FUNCTION: GpStatus GdipGetHatchForegroundColor ( GpHatch* x, ARGB* x )
FUNCTION: GpStatus GdipGetHatchStyle ( GpHatch* x, HatchStyle* x )


FUNCTION: GpStatus GdipCloneImage ( GpImage* x,  GpImage** x )
FUNCTION: GpStatus GdipCloneImageAttributes ( GpImageAttributes* x, GpImageAttributes** x )
FUNCTION: GpStatus GdipDisposeImage ( GpImage* x )
FUNCTION: GpStatus GdipEmfToWmfBits ( HENHMETAFILE x, UINT x, LPBYTE x, INT x, INT x )
FUNCTION: GpStatus GdipFindFirstImageItem ( GpImage* x, ImageItemData* x )
FUNCTION: GpStatus GdipFindNextImageItem ( GpImage* x, ImageItemData* x )
FUNCTION: GpStatus GdipGetAllPropertyItems ( GpImage* x, UINT x, UINT x, PropertyItem* x )
FUNCTION: GpStatus GdipGetImageBounds ( GpImage* x, GpRectF* x, GpUnit* x )
FUNCTION: GpStatus GdipGetImageDimension ( GpImage* x, REAL* x, REAL* x )
FUNCTION: GpStatus GdipGetImageFlags ( GpImage* x, UINT* x )
FUNCTION: GpStatus GdipGetImageHeight ( GpImage* x, UINT* x )
FUNCTION: GpStatus GdipGetImageHorizontalResolution ( GpImage* x, REAL* x )
FUNCTION: GpStatus GdipGetImageItemData ( GpImage* x, ImageItemData* x )
FUNCTION: GpStatus GdipGetImagePalette ( GpImage* x, ColorPalette* x, INT x )
FUNCTION: GpStatus GdipGetImagePaletteSize ( GpImage* x, INT* x )
FUNCTION: GpStatus GdipGetImagePixelFormat ( GpImage* x, PixelFormat* x )
FUNCTION: GpStatus GdipGetImageRawFormat ( GpImage* x, GUID* x )
FUNCTION: GpStatus GdipGetImageThumbnail ( GpImage* x, UINT x, UINT x, GpImage** x, GetThumbnailImageAbort x, VOID* x )
FUNCTION: GpStatus GdipGetImageType ( GpImage* x, ImageType* x )
FUNCTION: GpStatus GdipGetImageVerticalResolution ( GpImage* x, REAL* x )
FUNCTION: GpStatus GdipGetImageWidth ( GpImage* x, UINT* x )
FUNCTION: GpStatus GdipGetPropertyCount ( GpImage* x, UINT* x )
FUNCTION: GpStatus GdipGetPropertyIdList ( GpImage* x, UINT x, PROPID* x )
FUNCTION: GpStatus GdipGetPropertyItem ( GpImage* x, PROPID x, UINT x, PropertyItem* x )
FUNCTION: GpStatus GdipGetPropertyItemSize ( GpImage* x, PROPID x, UINT* x )
FUNCTION: GpStatus GdipGetPropertySize ( GpImage* x, UINT* x, UINT* x )
FUNCTION: GpStatus GdipImageForceValidation ( GpImage* x )
FUNCTION: GpStatus GdipImageGetFrameCount ( GpImage* x, GUID* x, UINT* x )
FUNCTION: GpStatus GdipImageGetFrameDimensionsCount ( GpImage* x, UINT* x )
FUNCTION: GpStatus GdipImageGetFrameDimensionsList ( GpImage* x, GUID* x, UINT x )
FUNCTION: GpStatus GdipImageRotateFlip ( GpImage* x, RotateFlipType x )
FUNCTION: GpStatus GdipImageSelectActiveFrame ( GpImage* x, GUID* x, UINT x )
FUNCTION: GpStatus GdipLoadImageFromFile ( WCHAR* x, GpImage** x )
FUNCTION: GpStatus GdipLoadImageFromFileICM ( WCHAR* x, GpImage** x )
FUNCTION: GpStatus GdipLoadImageFromStream ( IStream* x, GpImage** x )
FUNCTION: GpStatus GdipLoadImageFromStreamICM ( IStream* x, GpImage** x )
FUNCTION: GpStatus GdipRemovePropertyItem ( GpImage* x, PROPID x )
FUNCTION: GpStatus GdipSaveImageToFile ( GpImage* x, WCHAR* x, CLSID* x, EncoderParameters* x )
FUNCTION: GpStatus GdipSaveImageToStream ( GpImage* x, IStream* x,
             CLSID* x, EncoderParameters* x )
FUNCTION: GpStatus GdipSetImagePalette ( GpImage* x, ColorPalette* x )
FUNCTION: GpStatus GdipSetPropertyItem ( GpImage* x, PropertyItem* x )


FUNCTION: GpStatus GdipCreateImageAttributes ( GpImageAttributes** x )
FUNCTION: GpStatus GdipDisposeImageAttributes ( GpImageAttributes* x )
FUNCTION: GpStatus GdipSetImageAttributesCachedBackground ( GpImageAttributes* x,
             BOOL x )
FUNCTION: GpStatus GdipSetImageAttributesColorKeys ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, ARGB x, ARGB x )
FUNCTION: GpStatus GdipSetImageAttributesColorMatrix ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, ColorMatrix* x, ColorMatrix* x,
             ColorMatrixFlags x )
FUNCTION: GpStatus GdipSetImageAttributesGamma ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, REAL x )
FUNCTION: GpStatus GdipSetImageAttributesNoOp ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x )
FUNCTION: GpStatus GdipSetImageAttributesOutputChannel ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, ColorChannelFlags x )
FUNCTION: GpStatus GdipSetImageAttributesOutputChannelColorProfile (
             GpImageAttributes* x, ColorAdjustType x, BOOL x, WCHAR* x )
FUNCTION: GpStatus GdipSetImageAttributesRemapTable ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, UINT x, ColorMap* x )
FUNCTION: GpStatus GdipSetImageAttributesThreshold ( GpImageAttributes* x,
             ColorAdjustType x, BOOL x, REAL x )
FUNCTION: GpStatus GdipSetImageAttributesToIdentity ( GpImageAttributes* x,
             ColorAdjustType x )
FUNCTION: GpStatus GdipSetImageAttributesWrapMode ( GpImageAttributes* x, GpWrapMode x,
             ARGB x, BOOL x )


FUNCTION: GpStatus GdipCreateLineBrush ( GpPointF* x, GpPointF* x,
             ARGB x, ARGB x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipCreateLineBrushI ( GpPoint* x, GpPoint* x,
             ARGB x, ARGB x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipCreateLineBrushFromRect ( GpRectF* x, ARGB x, ARGB x,
             LinearGradientMode x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipCreateLineBrushFromRectI ( GpRect* x, ARGB x, ARGB x,
             LinearGradientMode x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipCreateLineBrushFromRectWithAngle ( GpRectF* x,
             ARGB x, ARGB x, REAL x, BOOL x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipCreateLineBrushFromRectWithAngleI ( GpRect* x,
             ARGB x, ARGB x, REAL x, BOOL x, GpWrapMode x, GpLineGradient** x )
FUNCTION: GpStatus GdipGetLineColors ( GpLineGradient* x, ARGB* x )
FUNCTION: GpStatus GdipGetLineGammaCorrection ( GpLineGradient* x, BOOL* x )
FUNCTION: GpStatus GdipGetLineRect ( GpLineGradient* x, GpRectF* x )
FUNCTION: GpStatus GdipGetLineRectI ( GpLineGradient* x, GpRect* x )
FUNCTION: GpStatus GdipGetLineWrapMode ( GpLineGradient* x, GpWrapMode* x )
FUNCTION: GpStatus GdipSetLineBlend ( GpLineGradient* x, REAL* x,
             REAL* x, INT x )
FUNCTION: GpStatus GdipGetLineBlend ( GpLineGradient* x, REAL* x, REAL* x, INT x )
FUNCTION: GpStatus GdipGetLineBlendCount ( GpLineGradient* x, INT* x )
FUNCTION: GpStatus GdipSetLinePresetBlend ( GpLineGradient* x, ARGB* x,
             REAL* x, INT x )
FUNCTION: GpStatus GdipGetLinePresetBlend ( GpLineGradient* x, ARGB* x, REAL* x, INT x )
FUNCTION: GpStatus GdipGetLinePresetBlendCount ( GpLineGradient* x, INT* x )
FUNCTION: GpStatus GdipResetLineTransform ( GpLineGradient* x )
FUNCTION: GpStatus GdipRotateLineTransform ( GpLineGradient* x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipScaleLineTransform ( GpLineGradient* x, REAL x, REAL x,
             GpMatrixOrder x )
FUNCTION: GpStatus GdipSetLineColors ( GpLineGradient* x, ARGB x, ARGB x )
FUNCTION: GpStatus GdipSetLineGammaCorrection ( GpLineGradient* x, BOOL x )
FUNCTION: GpStatus GdipSetLineSigmaBlend ( GpLineGradient* x, REAL x, REAL x )
FUNCTION: GpStatus GdipSetLineTransform ( GpLineGradient* x, GpMatrix* x )
FUNCTION: GpStatus GdipSetLineLinearBlend ( GpLineGradient* x, REAL x, REAL x )
FUNCTION: GpStatus GdipSetLineWrapMode ( GpLineGradient* x, GpWrapMode x )
FUNCTION: GpStatus GdipTranslateLineTransform ( GpLineGradient* x, REAL x, REAL x,
             GpMatrixOrder x )


FUNCTION: GpStatus GdipCloneMatrix ( GpMatrix* x, GpMatrix** x )
FUNCTION: GpStatus GdipCreateMatrix ( GpMatrix** x )
FUNCTION: GpStatus GdipCreateMatrix2 ( REAL x, REAL x, REAL x, REAL x, REAL x, REAL x, GpMatrix** x )
FUNCTION: GpStatus GdipCreateMatrix3 ( GpRectF* x, GpPointF* x, GpMatrix** x )
FUNCTION: GpStatus GdipCreateMatrix3I ( GpRect* x, GpPoint* x, GpMatrix** x )
FUNCTION: GpStatus GdipDeleteMatrix ( GpMatrix* x )
FUNCTION: GpStatus GdipGetMatrixElements ( GpMatrix* x, REAL* x )
FUNCTION: GpStatus GdipInvertMatrix ( GpMatrix* x )
FUNCTION: GpStatus GdipIsMatrixEqual ( GpMatrix* x,  GpMatrix* x,  BOOL* x )
FUNCTION: GpStatus GdipIsMatrixIdentity ( GpMatrix* x,  BOOL* x )
FUNCTION: GpStatus GdipIsMatrixInvertible ( GpMatrix* x,  BOOL* x )
FUNCTION: GpStatus GdipMultiplyMatrix ( GpMatrix* x, GpMatrix* x, GpMatrixOrder x )
FUNCTION: GpStatus GdipRotateMatrix ( GpMatrix* x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipShearMatrix ( GpMatrix* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipScaleMatrix ( GpMatrix* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipSetMatrixElements ( GpMatrix* x, REAL x, REAL x, REAL x, REAL x, REAL x, REAL x )
FUNCTION: GpStatus GdipTransformMatrixPoints ( GpMatrix* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipTransformMatrixPointsI ( GpMatrix* x, GpPoint* x, INT x )
FUNCTION: GpStatus GdipTranslateMatrix ( GpMatrix* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipVectorTransformMatrixPoints ( GpMatrix* x, GpPointF* x, INT x )
FUNCTION: GpStatus GdipVectorTransformMatrixPointsI ( GpMatrix* x, GpPoint* x, INT x )


FUNCTION: GpStatus GdipConvertToEmfPlus ( GpGraphics* x, GpMetafile* x, INT* x,
             EmfType x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipConvertToEmfPlusToFile ( GpGraphics* x, GpMetafile* x, INT* x, WCHAR* x, EmfType x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipConvertToEmfPlusToStream ( GpGraphics* x, GpMetafile* x, INT* x, IStream* x, EmfType x, WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipCreateMetafileFromEmf ( HENHMETAFILE x, BOOL x, GpMetafile** x )
FUNCTION: GpStatus GdipCreateMetafileFromWmf ( HMETAFILE x, BOOL x,
             WmfPlaceableFileHeader* x, GpMetafile** x )
FUNCTION: GpStatus GdipCreateMetafileFromWmfFile ( WCHAR* x,  WmfPlaceableFileHeader* x,
             GpMetafile** x )
FUNCTION: GpStatus GdipCreateMetafileFromFile ( WCHAR* x, GpMetafile** x )
FUNCTION: GpStatus GdipCreateMetafileFromStream ( IStream* x, GpMetafile** x )
FUNCTION: GpStatus GdipSetMetafileDownLevelRasterizationLimit ( GpMetafile* x, UINT x )


FUNCTION: GpStatus GdipGetMetafileHeaderFromEmf ( HENHMETAFILE x, MetafileHeader* x )
FUNCTION: GpStatus GdipGetMetafileHeaderFromFile ( WCHAR* x, MetafileHeader* x )
FUNCTION: GpStatus GdipGetMetafileHeaderFromMetafile ( GpMetafile* x, MetafileHeader* x )
FUNCTION: GpStatus GdipGetMetafileHeaderFromStream ( IStream* x, MetafileHeader* x )
FUNCTION: GpStatus GdipGetMetafileHeaderFromWmf ( HMETAFILE x, WmfPlaceableFileHeader* x, MetafileHeader* x )


FUNCTION: GpStatus GdiplusNotificationHook ( ULONG_PTR* x )
FUNCTION: void GdiplusNotificationUnhook ( ULONG_PTR x )


FUNCTION: GpStatus GdipCreatePathGradient ( GpPointF* x, INT x, GpWrapMode x, GpPathGradient** x )
FUNCTION: GpStatus GdipCreatePathGradientI ( GpPoint* x, INT x, GpWrapMode x, GpPathGradient** x )
FUNCTION: GpStatus GdipCreatePathGradientFromPath ( GpPath* x,
             GpPathGradient** x )
FUNCTION: GpStatus GdipGetPathGradientBlend ( GpPathGradient* x, REAL* x, REAL* x, INT x )
FUNCTION: GpStatus GdipGetPathGradientBlendCount ( GpPathGradient* x, INT* x )
FUNCTION: GpStatus GdipGetPathGradientCenterColor ( GpPathGradient* x, ARGB* x )
FUNCTION: GpStatus GdipGetPathGradientCenterPoint ( GpPathGradient* x, GpPointF* x )
FUNCTION: GpStatus GdipGetPathGradientCenterPointI ( GpPathGradient* x, GpPoint* x )
FUNCTION: GpStatus GdipGetPathGradientFocusScales ( GpPathGradient* x, REAL* x, REAL* x )
FUNCTION: GpStatus GdipGetPathGradientGammaCorrection ( GpPathGradient* x, BOOL* x )
FUNCTION: GpStatus GdipGetPathGradientPointCount ( GpPathGradient* x, INT* x )
FUNCTION: GpStatus GdipSetPathGradientPresetBlend ( GpPathGradient* x,
             ARGB* x, REAL* x, INT x )
FUNCTION: GpStatus GdipGetPathGradientRect ( GpPathGradient* x, GpRectF* x )
FUNCTION: GpStatus GdipGetPathGradientRectI ( GpPathGradient* x, GpRect* x )
FUNCTION: GpStatus GdipGetPathGradientSurroundColorsWithCount ( GpPathGradient* x,
             ARGB* x, INT* x )
FUNCTION: GpStatus GdipGetPathGradientWrapMode ( GpPathGradient* x, GpWrapMode* x )
FUNCTION: GpStatus GdipSetPathGradientBlend ( GpPathGradient* x, REAL* x, REAL* x, INT x )
FUNCTION: GpStatus GdipSetPathGradientCenterColor ( GpPathGradient* x, ARGB x )
FUNCTION: GpStatus GdipSetPathGradientCenterPoint ( GpPathGradient* x, GpPointF* x )
FUNCTION: GpStatus GdipSetPathGradientCenterPointI ( GpPathGradient* x, GpPoint* x )
FUNCTION: GpStatus GdipSetPathGradientFocusScales ( GpPathGradient* x, REAL x, REAL x )
FUNCTION: GpStatus GdipSetPathGradientGammaCorrection ( GpPathGradient* x, BOOL x )
FUNCTION: GpStatus GdipSetPathGradientSigmaBlend ( GpPathGradient* x, REAL x, REAL x )
FUNCTION: GpStatus GdipSetPathGradientSurroundColorsWithCount ( GpPathGradient* x,
             ARGB* x, INT* x )
FUNCTION: GpStatus GdipSetPathGradientWrapMode ( GpPathGradient* x, GpWrapMode x )
FUNCTION: GpStatus GdipGetPathGradientSurroundColorCount ( GpPathGradient* x, INT* x )


FUNCTION: GpStatus GdipCreatePathIter ( GpPathIterator** x, GpPath* x )
FUNCTION: GpStatus GdipDeletePathIter ( GpPathIterator* x )
FUNCTION: GpStatus GdipPathIterCopyData ( GpPathIterator* x, INT* x, GpPointF* x, BYTE* x,
             INT x, INT x )
FUNCTION: GpStatus GdipPathIterGetCount ( GpPathIterator* x, INT* x )
FUNCTION: GpStatus GdipPathIterGetSubpathCount ( GpPathIterator* x, INT* x )
FUNCTION: GpStatus GdipPathIterEnumerate ( GpPathIterator* x, INT* x, GpPointF* x, BYTE* x, INT x )
FUNCTION: GpStatus GdipPathIterHasCurve ( GpPathIterator* x, BOOL* x )
FUNCTION: GpStatus GdipPathIterIsValid ( GpPathIterator* x, BOOL* x )
FUNCTION: GpStatus GdipPathIterNextMarker ( GpPathIterator* x, INT* x, INT* x, INT* x )
FUNCTION: GpStatus GdipPathIterNextMarkerPath ( GpPathIterator* x, INT* x, GpPath* x )
FUNCTION: GpStatus GdipPathIterNextPathType ( GpPathIterator* x, INT* x, BYTE* x, INT* x, INT* x )
FUNCTION: GpStatus GdipPathIterNextSubpath ( GpPathIterator* x, INT* x, INT* x, INT* x, BOOL* x )
FUNCTION: GpStatus GdipPathIterNextSubpathPath ( GpPathIterator* x, INT* x, GpPath* x, BOOL* x )
FUNCTION: GpStatus GdipPathIterRewind ( GpPathIterator* x )


FUNCTION: GpStatus GdipClonePen ( GpPen* x, GpPen** x )
FUNCTION: GpStatus GdipCreatePen1 ( ARGB x, REAL x, GpUnit x, GpPen** x )
FUNCTION: GpStatus GdipCreatePen2 ( GpBrush* x, REAL x, GpUnit x, GpPen** x )
FUNCTION: GpStatus GdipDeletePen ( GpPen* x )
FUNCTION: GpStatus GdipGetPenBrushFill ( GpPen* x, GpBrush** x )
FUNCTION: GpStatus GdipGetPenColor ( GpPen* x, ARGB* x )
FUNCTION: GpStatus GdipGetPenCustomStartCap ( GpPen* x, GpCustomLineCap** x )
FUNCTION: GpStatus GdipGetPenCustomEndCap ( GpPen* x, GpCustomLineCap** x )
FUNCTION: GpStatus GdipGetPenDashArray ( GpPen* x, REAL* x, INT x )
FUNCTION: GpStatus GdipGetPenDashCount ( GpPen* x, INT* x )
FUNCTION: GpStatus GdipGetPenDashOffset ( GpPen* x, REAL* x )
FUNCTION: GpStatus GdipGetPenDashStyle ( GpPen* x, GpDashStyle* x )
FUNCTION: GpStatus GdipGetPenMode ( GpPen* x, GpPenAlignment* x )
FUNCTION: GpStatus GdipResetPenTransform ( GpPen* x )
FUNCTION: GpStatus GdipScalePenTransform ( GpPen* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipSetPenBrushFill ( GpPen* x, GpBrush* x )
FUNCTION: GpStatus GdipSetPenColor ( GpPen* x, ARGB x )
FUNCTION: GpStatus GdipSetPenCompoundArray ( GpPen* x, REAL* x, INT x )
FUNCTION: GpStatus GdipSetPenCustomEndCap ( GpPen* x, GpCustomLineCap* x )
FUNCTION: GpStatus GdipSetPenCustomStartCap ( GpPen* x, GpCustomLineCap* x )
FUNCTION: GpStatus GdipSetPenDashArray ( GpPen* x, REAL* x, INT x )
FUNCTION: GpStatus GdipSetPenDashCap197819 ( GpPen* x, GpDashCap x )
FUNCTION: GpStatus GdipSetPenDashOffset ( GpPen* x, REAL x )
FUNCTION: GpStatus GdipSetPenDashStyle ( GpPen* x, GpDashStyle x )
FUNCTION: GpStatus GdipSetPenEndCap ( GpPen* x, GpLineCap x )
FUNCTION: GpStatus GdipGetPenFillType ( GpPen* x, GpPenType* x )
FUNCTION: GpStatus GdipSetPenLineCap197819 ( GpPen* x, GpLineCap x, GpLineCap x, GpDashCap x )
FUNCTION: GpStatus GdipSetPenLineJoin ( GpPen* x, GpLineJoin x )
FUNCTION: GpStatus GdipSetPenMode ( GpPen* x, GpPenAlignment x )
FUNCTION: GpStatus GdipSetPenMiterLimit ( GpPen* x, REAL x )
FUNCTION: GpStatus GdipSetPenStartCap ( GpPen* x, GpLineCap x )
FUNCTION: GpStatus GdipSetPenWidth ( GpPen* x, REAL x )
FUNCTION: GpStatus GdipGetPenDashCap197819 ( GpPen* x, GpDashCap* x )
FUNCTION: GpStatus GdipGetPenEndCap ( GpPen* x, GpLineCap* x )
FUNCTION: GpStatus GdipGetPenLineJoin ( GpPen* x, GpLineJoin* x )
FUNCTION: GpStatus GdipGetPenMiterLimit ( GpPen* x, REAL* x )
FUNCTION: GpStatus GdipGetPenStartCap ( GpPen* x, GpLineCap* x )
FUNCTION: GpStatus GdipGetPenUnit ( GpPen* x, GpUnit* x )
FUNCTION: GpStatus GdipGetPenWidth ( GpPen* x, REAL* x )


FUNCTION: GpStatus GdipCloneRegion ( GpRegion* x,  GpRegion** x )
FUNCTION: GpStatus GdipCombineRegionPath ( GpRegion* x,  GpPath* x,  CombineMode x )
FUNCTION: GpStatus GdipCombineRegionRect ( GpRegion* x,  GpRectF* x,  CombineMode x )
FUNCTION: GpStatus GdipCombineRegionRectI ( GpRegion* x,  GpRect* x,  CombineMode x )
FUNCTION: GpStatus GdipCombineRegionRegion ( GpRegion* x,  GpRegion* x,  CombineMode x )
FUNCTION: GpStatus GdipCreateRegion ( GpRegion** x )
FUNCTION: GpStatus GdipCreateRegionPath ( GpPath* x,  GpRegion** x )
FUNCTION: GpStatus GdipCreateRegionRect ( GpRectF* x,  GpRegion** x )
FUNCTION: GpStatus GdipCreateRegionRectI ( GpRect* x,  GpRegion** x )
FUNCTION: GpStatus GdipCreateRegionRgnData ( BYTE* x,  INT x,  GpRegion** x )
FUNCTION: GpStatus GdipCreateRegionHrgn ( HRGN x,  GpRegion** x )
FUNCTION: GpStatus GdipDeleteRegion ( GpRegion* x )
FUNCTION: GpStatus GdipGetRegionBounds ( GpRegion* x,  GpGraphics* x,  GpRectF* x )
FUNCTION: GpStatus GdipGetRegionBoundsI ( GpRegion* x,  GpGraphics* x,  GpRect* x )
FUNCTION: GpStatus GdipGetRegionData ( GpRegion* x,  BYTE* x,  UINT x,  UINT* x )
FUNCTION: GpStatus GdipGetRegionDataSize ( GpRegion* x,  UINT* x )
FUNCTION: GpStatus GdipGetRegionHRgn ( GpRegion* x,  GpGraphics* x,  HRGN* x )
FUNCTION: GpStatus GdipIsEmptyRegion ( GpRegion* x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsEqualRegion ( GpRegion* x,  GpRegion* x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsInfiniteRegion ( GpRegion* x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRegionPoint ( GpRegion* x,  REAL x,  REAL x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRegionPointI ( GpRegion* x,  INT x,  INT x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRegionRect ( GpRegion* x,  REAL x,  REAL x,  REAL x,  REAL x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipIsVisibleRegionRectI ( GpRegion* x,  INT x,  INT x,  INT x,  INT x,  GpGraphics* x,  BOOL* x )
FUNCTION: GpStatus GdipSetEmpty ( GpRegion* x )
FUNCTION: GpStatus GdipSetInfinite ( GpRegion* x )
FUNCTION: GpStatus GdipTransformRegion ( GpRegion* x,  GpMatrix* x )
FUNCTION: GpStatus GdipTranslateRegion ( GpRegion* x,  REAL x,  REAL x )
FUNCTION: GpStatus GdipTranslateRegionI ( GpRegion* x,  INT x,  INT x )


FUNCTION: GpStatus GdipCreateSolidFill ( ARGB x, GpSolidFill** x )
FUNCTION: GpStatus GdipGetSolidFillColor ( GpSolidFill* x, ARGB* x )
FUNCTION: GpStatus GdipSetSolidFillColor ( GpSolidFill* x, ARGB x )


FUNCTION: GpStatus GdipCloneStringFormat ( GpStringFormat* x, GpStringFormat** x )
FUNCTION: GpStatus GdipCreateStringFormat ( INT x, LANGID x, GpStringFormat** x )
FUNCTION: GpStatus GdipDeleteStringFormat ( GpStringFormat* x )
FUNCTION: GpStatus GdipGetStringFormatAlign ( GpStringFormat* x, StringAlignment* x )
FUNCTION: GpStatus GdipGetStringFormatDigitSubstitution ( GpStringFormat* x, LANGID* x,
                 StringDigitSubstitute* x )
FUNCTION: GpStatus GdipGetStringFormatFlags ( GpStringFormat* x,  INT* x )
FUNCTION: GpStatus GdipGetStringFormatHotkeyPrefix ( GpStringFormat* x, INT* x )
FUNCTION: GpStatus GdipGetStringFormatLineAlign ( GpStringFormat* x, StringAlignment* x )
FUNCTION: GpStatus GdipGetStringFormatMeasurableCharacterRangeCount (
                 GpStringFormat* x,  INT* x )
FUNCTION: GpStatus GdipGetStringFormatTabStopCount ( GpStringFormat* x, INT* x )
FUNCTION: GpStatus GdipGetStringFormatTabStops ( GpStringFormat* x, INT x, REAL* x, REAL* x )
FUNCTION: GpStatus GdipGetStringFormatTrimming ( GpStringFormat* x, StringTrimming* x )
FUNCTION: GpStatus GdipSetStringFormatAlign ( GpStringFormat* x, StringAlignment x )
FUNCTION: GpStatus GdipSetStringFormatDigitSubstitution ( GpStringFormat* x, LANGID x, StringDigitSubstitute x )
FUNCTION: GpStatus GdipSetStringFormatHotkeyPrefix ( GpStringFormat* x, INT x )
FUNCTION: GpStatus GdipSetStringFormatLineAlign ( GpStringFormat* x, StringAlignment x )
FUNCTION: GpStatus GdipSetStringFormatMeasurableCharacterRanges (
                 GpStringFormat* x,  INT x,  CharacterRange* x )
FUNCTION: GpStatus GdipSetStringFormatTabStops ( GpStringFormat* x, REAL x, INT x, REAL* x )
FUNCTION: GpStatus GdipSetStringFormatTrimming ( GpStringFormat* x, StringTrimming x )
FUNCTION: GpStatus GdipSetStringFormatFlags ( GpStringFormat* x,  INT x )
FUNCTION: GpStatus GdipStringFormatGetGenericDefault ( GpStringFormat** x )
FUNCTION: GpStatus GdipStringFormatGetGenericTypographic ( GpStringFormat** x )


FUNCTION: GpStatus GdipCreateTexture ( GpImage* x, GpWrapMode x, GpTexture** x )
FUNCTION: GpStatus GdipCreateTexture2 ( GpImage* x, GpWrapMode x, REAL x, REAL x, REAL x, REAL x, GpTexture** x )
FUNCTION: GpStatus GdipCreateTexture2I ( GpImage* x, GpWrapMode x, INT x, INT x, INT x, INT x, GpTexture** x )
FUNCTION: GpStatus GdipCreateTextureIA ( GpImage* x, GpImageAttributes* x,
             REAL x, REAL x, REAL x, REAL x, GpTexture** x )
FUNCTION: GpStatus GdipCreateTextureIAI ( GpImage* x, GpImageAttributes* x,
             INT x, INT x, INT x, INT x, GpTexture** x )
FUNCTION: GpStatus GdipGetTextureTransform ( GpTexture* x, GpMatrix* x )
FUNCTION: GpStatus GdipGetTextureWrapMode ( GpTexture* x,  GpWrapMode* x )
FUNCTION: GpStatus GdipMultiplyTextureTransform ( GpTexture* x,
             GpMatrix* x, GpMatrixOrder x )
FUNCTION: GpStatus GdipResetTextureTransform ( GpTexture* x )
FUNCTION: GpStatus GdipRotateTextureTransform ( GpTexture* x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipScaleTextureTransform ( GpTexture* x, REAL x, REAL x, GpMatrixOrder x )
FUNCTION: GpStatus GdipSetTextureTransform ( GpTexture* x, GpMatrix* x )
FUNCTION: GpStatus GdipSetTextureWrapMode ( GpTexture* x,  GpWrapMode x )
FUNCTION: GpStatus GdipTranslateTextureTransform ( GpTexture* x, REAL x, REAL x,
             GpMatrixOrder x )


FUNCTION: GpStatus GdipCreateStreamOnFile ( WCHAR* x, UINT x, IStream** x )
FUNCTION: GpStatus GdipGetImageEncodersSize ( UINT* numEncoders,  UINT* size )
FUNCTION: GpStatus GdipGetImageEncoders ( UINT numEncoders,  UINT size,  ImageCodecInfo* encoders )
FUNCTION: GpStatus GdipTestControl ( GpTestControlEnum x, void* x )

ERROR: gdi+-error status ;

: check-gdi+-status ( GpStatus -- )
    dup Ok = [ drop ] [ gdi+-error ] if ;

CONSTANT: standard-gdi+-startup-input
    S{ GdiplusStartupInput
        { GdiplusVersion 1 }
        { DebugEventCallback f }
        { SuppressBackgroundThread 0 }
        { SuppressExternalCodecs 0 }
    }

: (start-gdi+) ( startup-input -- token startup-output )
    { ULONG_PTR GdiplusStartupOutput }
    [ swapd GdiplusStartup check-gdi+-status ] with-out-parameters ;
: start-gdi+ ( -- token )
    standard-gdi+-startup-input (start-gdi+) drop ; inline
: stop-gdi+ ( token -- )
    GdiplusShutdown ;

DESTRUCTOR: stop-gdi+

SYMBOL: gdi-token

STARTUP-HOOK: [ start-gdi+ gdi-token set-global ]

SHUTDOWN-HOOK: [ gdi-token get-global [ stop-gdi+ ] when* ]
