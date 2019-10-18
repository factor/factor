USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx.dcommon windows.kernel32
windows.ole32 windows.types windows.directx ;
IN: windows.directx.dwrite

LIBRARY: dwrite

ENUM: DWRITE_FONT_FILE_TYPE
    DWRITE_FONT_FILE_TYPE_UNKNOWN
    DWRITE_FONT_FILE_TYPE_CFF
    DWRITE_FONT_FILE_TYPE_TRUETYPE
    DWRITE_FONT_FILE_TYPE_TRUETYPE_COLLECTION
    DWRITE_FONT_FILE_TYPE_TYPE1_PFM
    DWRITE_FONT_FILE_TYPE_TYPE1_PFB
    DWRITE_FONT_FILE_TYPE_VECTOR
    DWRITE_FONT_FILE_TYPE_BITMAP ;

ENUM: DWRITE_FONT_FACE_TYPE
    DWRITE_FONT_FACE_TYPE_CFF
    DWRITE_FONT_FACE_TYPE_TRUETYPE
    DWRITE_FONT_FACE_TYPE_TRUETYPE_COLLECTION
    DWRITE_FONT_FACE_TYPE_TYPE1
    DWRITE_FONT_FACE_TYPE_VECTOR
    DWRITE_FONT_FACE_TYPE_BITMAP
    DWRITE_FONT_FACE_TYPE_UNKNOWN ;

ENUM: DWRITE_FONT_SIMULATIONS
    DWRITE_FONT_SIMULATIONS_NONE
    DWRITE_FONT_SIMULATIONS_BOLD
    DWRITE_FONT_SIMULATIONS_OBLIQUE ;

ENUM: DWRITE_FONT_WEIGHT
    { DWRITE_FONT_WEIGHT_THIN        100 }
    { DWRITE_FONT_WEIGHT_EXTRA_LIGHT 200 }
    { DWRITE_FONT_WEIGHT_ULTRA_LIGHT 200 }
    { DWRITE_FONT_WEIGHT_LIGHT       300 }
    { DWRITE_FONT_WEIGHT_NORMAL      400 }
    { DWRITE_FONT_WEIGHT_REGULAR     400 }
    { DWRITE_FONT_WEIGHT_MEDIUM      500 }
    { DWRITE_FONT_WEIGHT_DEMI_BOLD   600 }
    { DWRITE_FONT_WEIGHT_SEMI_BOLD   600 }
    { DWRITE_FONT_WEIGHT_BOLD        700 }
    { DWRITE_FONT_WEIGHT_EXTRA_BOLD  800 }
    { DWRITE_FONT_WEIGHT_ULTRA_BOLD  800 }
    { DWRITE_FONT_WEIGHT_BLACK       900 }
    { DWRITE_FONT_WEIGHT_HEAVY       900 }
    { DWRITE_FONT_WEIGHT_EXTRA_BLACK 950 }
    { DWRITE_FONT_WEIGHT_ULTRA_BLACK 950 } ;

ENUM: DWRITE_FONT_STRETCH
    { DWRITE_FONT_STRETCH_UNDEFINED       0 }
    { DWRITE_FONT_STRETCH_ULTRA_CONDENSED 1 }
    { DWRITE_FONT_STRETCH_EXTRA_CONDENSED 2 }
    { DWRITE_FONT_STRETCH_CONDENSED       3 }
    { DWRITE_FONT_STRETCH_SEMI_CONDENSED  4 }
    { DWRITE_FONT_STRETCH_NORMAL          5 }
    { DWRITE_FONT_STRETCH_MEDIUM          5 }
    { DWRITE_FONT_STRETCH_SEMI_EXPANDED   6 }
    { DWRITE_FONT_STRETCH_EXPANDED        7 }
    { DWRITE_FONT_STRETCH_EXTRA_EXPANDED  8 }
    { DWRITE_FONT_STRETCH_ULTRA_EXPANDED  9 } ;

ENUM: DWRITE_FONT_STYLE
    DWRITE_FONT_STYLE_NORMAL
    DWRITE_FONT_STYLE_OBLIQUE
    DWRITE_FONT_STYLE_ITALIC ;

ENUM: DWRITE_INFORMATIONAL_STRING_ID
    DWRITE_INFORMATIONAL_STRING_NONE
    DWRITE_INFORMATIONAL_STRING_COPYRIGHT_NOTICE
    DWRITE_INFORMATIONAL_STRING_VERSION_STRINGS
    DWRITE_INFORMATIONAL_STRING_TRADEMARK
    DWRITE_INFORMATIONAL_STRING_MANUFACTURER
    DWRITE_INFORMATIONAL_STRING_DESIGNER
    DWRITE_INFORMATIONAL_STRING_DESIGNER_URL
    DWRITE_INFORMATIONAL_STRING_DESCRIPTION
    DWRITE_INFORMATIONAL_STRING_FONT_VENDOR_URL
    DWRITE_INFORMATIONAL_STRING_LICENSE_DESCRIPTION
    DWRITE_INFORMATIONAL_STRING_LICENSE_INFO_URL
    DWRITE_INFORMATIONAL_STRING_WIN32_FAMILY_NAMES
    DWRITE_INFORMATIONAL_STRING_WIN32_SUBFAMILY_NAMES
    DWRITE_INFORMATIONAL_STRING_PREFERRED_FAMILY_NAMES
    DWRITE_INFORMATIONAL_STRING_PREFERRED_SUBFAMILY_NAMES
    DWRITE_INFORMATIONAL_STRING_SAMPLE_TEXT ;

STRUCT: DWRITE_FONT_METRICS
    { designUnitsPerEm       USHORT }
    { ascent                 USHORT }
    { descent                USHORT }
    { lineGap                SHORT  }
    { capHeight              USHORT }
    { xHeight                USHORT }
    { underlinePosition      SHORT  }
    { underlineThickness     USHORT }
    { strikethroughPosition  SHORT  }
    { strikethroughThickness USHORT } ;

STRUCT: DWRITE_GLYPH_METRICS
    { leftSideBearing   INT32  }
    { advanceWidth      UINT32 }
    { rightSideBearing  INT32  }
    { topSideBearing    INT32  }
    { advanceHeight     UINT32 }
    { bottomSideBearing INT32  }
    { verticalOriginY   INT32  } ;

STRUCT: DWRITE_GLYPH_OFFSET
    { advanceOffset  FLOAT }
    { ascenderOffset FLOAT } ;

ENUM: DWRITE_FACTORY_TYPE
    DWRITE_FACTORY_TYPE_SHARED
    DWRITE_FACTORY_TYPE_ISOLATED ;

C-TYPE: IDWriteFontFileStream

COM-INTERFACE: IDWriteFontFileLoader IUnknown {727cad4e-d6af-4c9e-8a08-d695b11caa49}
    HRESULT CreateStreamFromKey ( void* fontFileReferenceKey, UINT32 fontFileReferenceKeySize, IDWriteFontFileStream** fontFileStream ) ;

COM-INTERFACE: IDWriteLocalFontFileLoader IDWriteFontFileLoader {b2d9f3ec-c9fe-4a11-a2ec-d86208f7c0a2}
    HRESULT GetFilePathLengthFromKey ( void* fontFileReferenceKey, UINT32 fontFileReferenceKeySize, UINT32* filePathLength )
    HRESULT GetFilePathFromKey ( void* fontFileReferenceKey, UINT32 fontFileReferenceKeySize, WCHAR* filePath, UINT32 filePathSize )
    HRESULT GetLastWriteTimeFromKey ( void* fontFileReferenceKey, UINT32 fontFileReferenceKeySize, FILETIME* lastWriteTime ) ;

COM-INTERFACE: IDWriteFontFileStream IUnknown {6d4865fe-0ab8-4d91-8f62-5dd6be34a3e0}
    HRESULT ReadFileFragment ( void** fragmentStart, UINT64 fileOffset, UINT64 fragmentSize, void** fragmentContext )
    void ReleaseFileFragment ( void* fragmentContext )
    HRESULT GetFileSize ( UINT64* fileSize )
    HRESULT GetLastWriteTime ( UINT64* lastWriteTime ) ;

COM-INTERFACE: IDWriteFontFile IUnknown {739d886a-cef5-47dc-8769-1a8b41bebbb0}
    HRESULT GetReferenceKey ( void** fontFileReferenceKey, UINT32* fontFileReferenceKeySize )
    HRESULT GetLoader ( IDWriteFontFileLoader** fontFileLoader )
    HRESULT Analyze ( BOOL* isSupportedFontType, DWRITE_FONT_FILE_TYPE* fontFileType, DWRITE_FONT_FACE_TYPE* fontFaceType, UINT32* numberOfFaces ) ;

ENUM: DWRITE_PIXEL_GEOMETRY
    DWRITE_PIXEL_GEOMETRY_FLAT
    DWRITE_PIXEL_GEOMETRY_RGB
    DWRITE_PIXEL_GEOMETRY_BGR ;

ENUM: DWRITE_RENDERING_MODE
    DWRITE_RENDERING_MODE_DEFAULT
    DWRITE_RENDERING_MODE_ALIASED
    DWRITE_RENDERING_MODE_CLEARTYPE_GDI_CLASSIC
    DWRITE_RENDERING_MODE_CLEARTYPE_GDI_NATURAL
    DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL
    DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL_SYMMETRIC
    DWRITE_RENDERING_MODE_OUTLINE ;

STRUCT: DWRITE_MATRIX
    { m11 FLOAT }
    { m12 FLOAT }
    { m21 FLOAT }
    { m22 FLOAT }
    { dx  FLOAT }
    { dy  FLOAT } ;

COM-INTERFACE: IDWriteRenderingParams IUnknown {2f0da53a-2add-47cd-82ee-d9ec34688e75}
    FLOAT GetGamma ( )
    FLOAT GetEnhancedContrast ( )
    FLOAT GetClearTypeLevel ( )
    DWRITE_PIXEL_GEOMETRY GetPixelGeometry ( )
    DWRITE_RENDERING_MODE GetRenderingMode ( ) ;

C-TYPE: ID2D1SimplifiedGeometrySink

TYPEDEF: ID2D1SimplifiedGeometrySink IDWriteGeometrySink

COM-INTERFACE: IDWriteFontFace IUnknown {5f49804d-7024-4d43-bfa9-d25984f53849}
    DWRITE_FONT_FACE_TYPE GetType ( )
    HRESULT GetFiles ( UINT32* numberOfFiles, IDWriteFontFile** fontFiles )
    UINT32 GetIndex ( )
    DWRITE_FONT_SIMULATIONS GetSimulations ( )
    BOOL IsSymbolFont ( )
    void GetMetrics ( DWRITE_FONT_METRICS* fontFaceMetrics )
    USHORT GetGlyphCount ( )
    HRESULT GetDesignGlyphMetrics ( USHORT* glyphIndices, UINT32 glyphCount, DWRITE_GLYPH_METRICS* glyphMetrics, BOOL isSideways )
    HRESULT GetGlyphIndices ( UINT32* codePoints, UINT32 codePointCount, USHORT* glyphIndices )
    HRESULT TryGetFontTable ( UINT32 openTypeTableTag, void** tableData, UINT32* tableSize, void** tableContext, BOOL* exists )
    void ReleaseFontTable ( void* tableContext )
    HRESULT GetGlyphRunOutline ( FLOAT emSize, USHORT* glyphIndices, FLOAT* glyphAdvances, DWRITE_GLYPH_OFFSET* glyphOffsets, UINT32 glyphCount, BOOL isSideways, BOOL isRightToLeft, IDWriteGeometrySink* geometrySink )
    HRESULT GetRecommendedRenderingMode ( FLOAT emSize, FLOAT pixelsPerDip, DWRITE_MEASURING_MODE measuringMode, IDWriteRenderingParams* renderingParams, DWRITE_RENDERING_MODE* renderingMode )
    HRESULT GetGdiCompatibleMetrics ( FLOAT emSize, FLOAT pixelsPerDip, DWRITE_MATRIX* transform, DWRITE_FONT_METRICS* fontFaceMetrics )
    HRESULT GetGdiCompatibleGlyphMetrics ( FLOAT emSize, FLOAT pixelsPerDip, DWRITE_MATRIX* transform, BOOL useGdiNatural, USHORT* glyphIndices, UINT32 glyphCount, DWRITE_GLYPH_METRICS* glyphMetrics, BOOL isSideways ) ;

C-TYPE: IDWriteFactory
C-TYPE: IDWriteFontFileEnumerator

COM-INTERFACE: IDWriteFontCollectionLoader IUnknown {cca920e4-52f0-492b-bfa8-29c72ee0a468}
    HRESULT CreateEnumeratorFromKey ( IDWriteFactory* factory, void* collectionKey, UINT32 collectionKeySize, IDWriteFontFileEnumerator** fontFileEnumerator ) ;

COM-INTERFACE: IDWriteFontFileEnumerator IUnknown {72755049-5ff7-435d-8348-4be97cfa6c7c}
    HRESULT MoveNext ( BOOL* hasCurrentFile )
    HRESULT GetCurrentFontFile ( IDWriteFontFile** fontFile ) ;

COM-INTERFACE: IDWriteLocalizedStrings IUnknown {08256209-099a-4b34-b86d-c22b110e7771}
    UINT32 GetCount ( )
    HRESULT FindLocaleName ( WCHAR* localeName, UINT32* index, BOOL* exists )
    HRESULT GetLocaleNameLength ( UINT32 index, UINT32* length )
    HRESULT GetLocaleName ( UINT32 index, WCHAR* localeName, UINT32 size )
    HRESULT GetStringLength ( UINT32 index, UINT32* length )
    HRESULT GetString ( UINT32 index, WCHAR* stringBuffer, UINT32 size ) ;

C-TYPE: IDWriteFontFamily
C-TYPE: IDWriteFont

COM-INTERFACE: IDWriteFontCollection IUnknown {a84cee02-3eea-4eee-a827-87c1a02a0fcc}
    UINT32 GetFontFamilyCount ( )
    HRESULT GetFontFamily ( UINT32 index, IDWriteFontFamily** fontFamily )
    HRESULT FindFamilyName ( WCHAR* familyName, UINT32* index, BOOL* exists )
    HRESULT GetFontFromFontFace ( IDWriteFontFace* fontFace, IDWriteFont** font ) ;

COM-INTERFACE: IDWriteFontList IUnknown {1a0d8438-1d97-4ec1-aef9-a2fb86ed6acb}
    HRESULT GetFontCollection ( IDWriteFontCollection** fontCollection )
    UINT32 GetFontCount ( )
    HRESULT GetFont ( UINT32 index, IDWriteFont** font ) ;

COM-INTERFACE: IDWriteFontFamily IDWriteFontList {da20d8ef-812a-4c43-9802-62ec4abd7add}
    HRESULT GetFamilyNames ( IDWriteLocalizedStrings** names )
    HRESULT GetFirstMatchingFont ( DWRITE_FONT_WEIGHT  weight, DWRITE_FONT_STRETCH stretch, DWRITE_FONT_STYLE style, IDWriteFont** matchingFont )
    HRESULT GetMatchingFonts ( DWRITE_FONT_WEIGHT weight, DWRITE_FONT_STRETCH stretch, DWRITE_FONT_STYLE style, IDWriteFontList** matchingFonts ) ;

COM-INTERFACE: IDWriteFont IUnknown {acd16696-8c14-4f5d-877e-fe3fc1d32737}
    HRESULT GetFontFamily ( IDWriteFontFamily** fontFamily )
    DWRITE_FONT_WEIGHT GetWeight ( )
    DWRITE_FONT_STRETCH GetStretch ( )
    DWRITE_FONT_STYLE GetStyle ( )
    BOOL IsSymbolFont ( )
    HRESULT GetFaceNames ( IDWriteLocalizedStrings** names )
    HRESULT GetInformationalStrings ( DWRITE_INFORMATIONAL_STRING_ID informationalStringID, IDWriteLocalizedStrings** informationalStrings, BOOL* exists )
    DWRITE_FONT_SIMULATIONS GetSimulations ( )
    void GetMetrics ( DWRITE_FONT_METRICS* fontMetrics )
    HRESULT HasCharacter ( UINT32 unicodeValue, BOOL* exists )
    HRESULT CreateFontFace ( IDWriteFontFace** fontFace ) ;

ENUM: DWRITE_READING_DIRECTION
    DWRITE_READING_DIRECTION_LEFT_TO_RIGHT
    DWRITE_READING_DIRECTION_RIGHT_TO_LEFT ;

ENUM: DWRITE_FLOW_DIRECTION
    DWRITE_FLOW_DIRECTION_TOP_TO_BOTTOM ;

ENUM: DWRITE_TEXT_ALIGNMENT
    DWRITE_TEXT_ALIGNMENT_LEADING
    DWRITE_TEXT_ALIGNMENT_TRAILING
    DWRITE_TEXT_ALIGNMENT_CENTER ;

ENUM: DWRITE_PARAGRAPH_ALIGNMENT
    DWRITE_PARAGRAPH_ALIGNMENT_NEAR
    DWRITE_PARAGRAPH_ALIGNMENT_FAR
    DWRITE_PARAGRAPH_ALIGNMENT_CENTER ;

ENUM: DWRITE_WORD_WRAPPING
    DWRITE_WORD_WRAPPING_WRAP
    DWRITE_WORD_WRAPPING_NO_WRAP ;

ENUM: DWRITE_LINE_SPACING_METHOD
    DWRITE_LINE_SPACING_METHOD_DEFAULT
    DWRITE_LINE_SPACING_METHOD_UNIFORM ;

ENUM: DWRITE_TRIMMING_GRANULARITY
    DWRITE_TRIMMING_GRANULARITY_NONE
    DWRITE_TRIMMING_GRANULARITY_CHARACTER
    DWRITE_TRIMMING_GRANULARITY_WORD ;

TYPEDEF: int DWRITE_FONT_FEATURE_TAG
CONSTANT: DWRITE_FONT_FEATURE_TAG_ALTERNATIVE_FRACTIONS               0x63726661
CONSTANT: DWRITE_FONT_FEATURE_TAG_PETITE_CAPITALS_FROM_CAPITALS       0x63703263
CONSTANT: DWRITE_FONT_FEATURE_TAG_SMALL_CAPITALS_FROM_CAPITALS        0x63733263
CONSTANT: DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_ALTERNATES               0x746c6163
CONSTANT: DWRITE_FONT_FEATURE_TAG_CASE_SENSITIVE_FORMS                0x65736163
CONSTANT: DWRITE_FONT_FEATURE_TAG_GLYPH_COMPOSITION_DECOMPOSITION     0x706d6363
CONSTANT: DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_LIGATURES                0x67696c63
CONSTANT: DWRITE_FONT_FEATURE_TAG_CAPITAL_SPACING                     0x70737063
CONSTANT: DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_SWASH                    0x68777363
CONSTANT: DWRITE_FONT_FEATURE_TAG_CURSIVE_POSITIONING                 0x73727563
CONSTANT: DWRITE_FONT_FEATURE_TAG_DEFAULT                             0x746c6664
CONSTANT: DWRITE_FONT_FEATURE_TAG_DISCRETIONARY_LIGATURES             0x67696c64
CONSTANT: DWRITE_FONT_FEATURE_TAG_EXPERT_FORMS                        0x74707865
CONSTANT: DWRITE_FONT_FEATURE_TAG_FRACTIONS                           0x63617266
CONSTANT: DWRITE_FONT_FEATURE_TAG_FULL_WIDTH                          0x64697766
CONSTANT: DWRITE_FONT_FEATURE_TAG_HALF_FORMS                          0x666c6168
CONSTANT: DWRITE_FONT_FEATURE_TAG_HALANT_FORMS                        0x6e6c6168
CONSTANT: DWRITE_FONT_FEATURE_TAG_ALTERNATE_HALF_WIDTH                0x746c6168
CONSTANT: DWRITE_FONT_FEATURE_TAG_HISTORICAL_FORMS                    0x74736968
CONSTANT: DWRITE_FONT_FEATURE_TAG_HORIZONTAL_KANA_ALTERNATES          0x616e6b68
CONSTANT: DWRITE_FONT_FEATURE_TAG_HISTORICAL_LIGATURES                0x67696c68
CONSTANT: DWRITE_FONT_FEATURE_TAG_HALF_WIDTH                          0x64697768
CONSTANT: DWRITE_FONT_FEATURE_TAG_HOJO_KANJI_FORMS                    0x6f6a6f68
CONSTANT: DWRITE_FONT_FEATURE_TAG_JIS04_FORMS                         0x3430706a
CONSTANT: DWRITE_FONT_FEATURE_TAG_JIS78_FORMS                         0x3837706a
CONSTANT: DWRITE_FONT_FEATURE_TAG_JIS83_FORMS                         0x3338706a
CONSTANT: DWRITE_FONT_FEATURE_TAG_JIS90_FORMS                         0x3039706a
CONSTANT: DWRITE_FONT_FEATURE_TAG_KERNING                             0x6e72656b
CONSTANT: DWRITE_FONT_FEATURE_TAG_STANDARD_LIGATURES                  0x6167696c
CONSTANT: DWRITE_FONT_FEATURE_TAG_LINING_FIGURES                      0x6d756e6c
CONSTANT: DWRITE_FONT_FEATURE_TAG_LOCALIZED_FORMS                     0x6c636f6c
CONSTANT: DWRITE_FONT_FEATURE_TAG_MARK_POSITIONING                    0x6b72616d
CONSTANT: DWRITE_FONT_FEATURE_TAG_MATHEMATICAL_GREEK                  0x6b72676d
CONSTANT: DWRITE_FONT_FEATURE_TAG_MARK_TO_MARK_POSITIONING            0x6b6d6b6d
CONSTANT: DWRITE_FONT_FEATURE_TAG_ALTERNATE_ANNOTATION_FORMS          0x746c616e
CONSTANT: DWRITE_FONT_FEATURE_TAG_NLC_KANJI_FORMS                     0x6b636c6e
CONSTANT: DWRITE_FONT_FEATURE_TAG_OLD_STYLE_FIGURES                   0x6d756e6f
CONSTANT: DWRITE_FONT_FEATURE_TAG_ORDINALS                            0x6e64726f
CONSTANT: DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_ALTERNATE_WIDTH        0x746c6170
CONSTANT: DWRITE_FONT_FEATURE_TAG_PETITE_CAPITALS                     0x70616370
CONSTANT: DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_FIGURES                0x6d756e70
CONSTANT: DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_WIDTHS                 0x64697770
CONSTANT: DWRITE_FONT_FEATURE_TAG_QUARTER_WIDTHS                      0x64697771
CONSTANT: DWRITE_FONT_FEATURE_TAG_REQUIRED_LIGATURES                  0x67696c72
CONSTANT: DWRITE_FONT_FEATURE_TAG_RUBY_NOTATION_FORMS                 0x79627572
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_ALTERNATES                0x746c6173
CONSTANT: DWRITE_FONT_FEATURE_TAG_SCIENTIFIC_INFERIORS                0x666e6973
CONSTANT: DWRITE_FONT_FEATURE_TAG_SMALL_CAPITALS                      0x70636d73
CONSTANT: DWRITE_FONT_FEATURE_TAG_SIMPLIFIED_FORMS                    0x6c706d73
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_1                     0x31307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_2                     0x32307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_3                     0x33307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_4                     0x34307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_5                     0x35307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_6                     0x36307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_7                     0x37307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_8                     0x38307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_9                     0x39307373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_10                    0x30317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_11                    0x31317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_12                    0x32317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_13                    0x33317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_14                    0x34317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_15                    0x35317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_16                    0x36317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_17                    0x37317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_18                    0x38317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_19                    0x39317373
CONSTANT: DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_20                    0x30327373
CONSTANT: DWRITE_FONT_FEATURE_TAG_SUBSCRIPT                           0x73627573
CONSTANT: DWRITE_FONT_FEATURE_TAG_SUPERSCRIPT                         0x73707573
CONSTANT: DWRITE_FONT_FEATURE_TAG_SWASH                               0x68737773
CONSTANT: DWRITE_FONT_FEATURE_TAG_TITLING                             0x6c746974
CONSTANT: DWRITE_FONT_FEATURE_TAG_TRADITIONAL_NAME_FORMS              0x6d616e74
CONSTANT: DWRITE_FONT_FEATURE_TAG_TABULAR_FIGURES                     0x6d756e74
CONSTANT: DWRITE_FONT_FEATURE_TAG_TRADITIONAL_FORMS                   0x64617274
CONSTANT: DWRITE_FONT_FEATURE_TAG_THIRD_WIDTHS                        0x64697774
CONSTANT: DWRITE_FONT_FEATURE_TAG_UNICASE                             0x63696e75
CONSTANT: DWRITE_FONT_FEATURE_TAG_SLASHED_ZERO                        0x6f72657a

STRUCT: DWRITE_TEXT_RANGE
    { startPosition UINT32 }
    { length        UINT32 } ;

STRUCT: DWRITE_FONT_FEATURE
    { nameTag   DWRITE_FONT_FEATURE_TAG }
    { parameter UINT32                  } ;

STRUCT: DWRITE_TYPOGRAPHIC_FEATURES
    { features     DWRITE_FONT_FEATURE* }
    { featureCount UINT32               } ;

STRUCT: DWRITE_TRIMMING
    { granularity    DWRITE_TRIMMING_GRANULARITY }
    { delimiter      UINT32                      }
    { delimiterCount UINT32                      } ;

C-TYPE: IDWriteTypography
C-TYPE: IDWriteInlineObject

COM-INTERFACE: IDWriteTextFormat IUnknown {9c906818-31d7-4fd3-a151-7c5e225db55a}
    HRESULT SetTextAlignment ( DWRITE_TEXT_ALIGNMENT textAlignment )
    HRESULT SetParagraphAlignment ( DWRITE_PARAGRAPH_ALIGNMENT paragraphAlignment )
    HRESULT SetWordWrapping ( DWRITE_WORD_WRAPPING wordWrapping )
    HRESULT SetReadingDirection ( DWRITE_READING_DIRECTION readingDirection )
    HRESULT SetFlowDirection ( DWRITE_FLOW_DIRECTION flowDirection )
    HRESULT SetIncrementalTabStop ( FLOAT incrementalTabStop )
    HRESULT SetTrimming ( DWRITE_TRIMMING* trimmingOptions, IDWriteInlineObject* trimmingSign )
    HRESULT SetLineSpacing ( DWRITE_LINE_SPACING_METHOD lineSpacingMethod, FLOAT lineSpacing, FLOAT baseline )
    DWRITE_TEXT_ALIGNMENT GetTextAlignment ( )
    DWRITE_PARAGRAPH_ALIGNMENT GetParagraphAlignment ( )
    DWRITE_WORD_WRAPPING GetWordWrapping ( )
    DWRITE_READING_DIRECTION GetReadingDirection ( )
    DWRITE_FLOW_DIRECTION GetFlowDirection ( )
    FLOAT GetIncrementalTabStop ( )
    HRESULT GetTrimming ( DWRITE_TRIMMING* trimmingOptions, IDWriteInlineObject** trimmingSign )
    HRESULT GetLineSpacing ( DWRITE_LINE_SPACING_METHOD* lineSpacingMethod, FLOAT* lineSpacing, FLOAT* baseline )
    HRESULT GetFontCollection ( IDWriteFontCollection** fontCollection )
    UINT32 GetFontFamilyNameLength ( )
    HRESULT GetFontFamilyName ( WCHAR* fontFamilyName, UINT32 nameSize )
    DWRITE_FONT_WEIGHT GetFontWeight ( )
    DWRITE_FONT_STYLE GetFontStyle ( )
    DWRITE_FONT_STRETCH GetFontStretch ( )
    FLOAT GetFontSize ( )
    UINT32 GetLocaleNameLength ( )
    HRESULT GetLocaleName ( WCHAR* localeName, UINT32 nameSize ) ;

COM-INTERFACE: IDWriteTypography IUnknown {55f1112b-1dc2-4b3c-9541-f46894ed85b6}
    HRESULT AddFontFeature ( DWRITE_FONT_FEATURE fontFeature )
    UINT32 GetFontFeatureCount ( )
    HRESULT GetFontFeature ( UINT32 fontFeatureIndex, DWRITE_FONT_FEATURE* fontFeature ) ;

ENUM: DWRITE_SCRIPT_SHAPES
    DWRITE_SCRIPT_SHAPES_DEFAULT
    DWRITE_SCRIPT_SHAPES_NO_VISUAL ;

STRUCT: DWRITE_SCRIPT_ANALYSIS
    { script USHORT               }
    { shapes DWRITE_SCRIPT_SHAPES } ;

ENUM: DWRITE_BREAK_CONDITION
    DWRITE_BREAK_CONDITION_NEUTRAL
    DWRITE_BREAK_CONDITION_CAN_BREAK
    DWRITE_BREAK_CONDITION_MAY_NOT_BREAK
    DWRITE_BREAK_CONDITION_MUST_BREAK ;

STRUCT: DWRITE_LINE_BREAKPOINT
    { data BYTE } ;

ENUM: DWRITE_NUMBER_SUBSTITUTION_METHOD
    DWRITE_NUMBER_SUBSTITUTION_METHOD_FROM_CULTURE
    DWRITE_NUMBER_SUBSTITUTION_METHOD_CONTEXTUAL
    DWRITE_NUMBER_SUBSTITUTION_METHOD_NONE
    DWRITE_NUMBER_SUBSTITUTION_METHOD_NATIONAL
    DWRITE_NUMBER_SUBSTITUTION_METHOD_TRADITIONAL ;

COM-INTERFACE: IDWriteNumberSubstitution IUnknown {14885CC9-BAB0-4f90-B6ED-5C366A2CD03D} ;

STRUCT: DWRITE_SHAPING_TEXT_PROPERTIES
    { data USHORT } ;

STRUCT: DWRITE_SHAPING_GLYPH_PROPERTIES
    { data USHORT } ;

COM-INTERFACE: IDWriteTextAnalysisSource IUnknown {688e1a58-5094-47c8-adc8-fbcea60ae92b}
    HRESULT GetTextAtPosition ( UINT32 textPosition, WCHAR** textString, UINT32* textLength )
    HRESULT GetTextBeforePosition ( UINT32 textPosition, WCHAR** textString, UINT32* textLength )
    DWRITE_READING_DIRECTION GetParagraphReadingDirection ( )
    HRESULT GetLocaleName ( UINT32 textPosition, UINT32* textLength, WCHAR** localeName )
    HRESULT GetNumberSubstitution ( UINT32 textPosition, UINT32* textLength, IDWriteNumberSubstitution** numberSubstitution ) ;

COM-INTERFACE: IDWriteTextAnalysisSink IUnknown {5810cd44-0ca0-4701-b3fa-bec5182ae4f6}
    HRESULT SetScriptAnalysis ( UINT32 textPosition, UINT32 textLength, DWRITE_SCRIPT_ANALYSIS* scriptAnalysis )
    HRESULT SetLineBreakpoints ( UINT32 textPosition, UINT32 textLength, DWRITE_LINE_BREAKPOINT* lineBreakpoints )
    HRESULT SetBidiLevel ( UINT32 textPosition, UINT32 textLength, BYTE explicitLevel, BYTE resolvedLevel )
    HRESULT SetNumberSubstitution ( UINT32 textPosition, UINT32 textLength, IDWriteNumberSubstitution* numberSubstitution ) ;

COM-INTERFACE: IDWriteTextAnalyzer IUnknown {b7e6163e-7f46-43b4-84b3-e4e6249c365d}
    HRESULT AnalyzeScript ( IDWriteTextAnalysisSource* analysisSource, UINT32 textPosition, UINT32 textLength, IDWriteTextAnalysisSink* analysisSink )
    HRESULT AnalyzeBidi ( IDWriteTextAnalysisSource* analysisSource, UINT32 textPosition, UINT32 textLength, IDWriteTextAnalysisSink* analysisSink )
    HRESULT AnalyzeNumberSubstitution ( IDWriteTextAnalysisSource* analysisSource, UINT32 textPosition, UINT32 textLength, IDWriteTextAnalysisSink* analysisSink )
    HRESULT AnalyzeLineBreakpoints ( IDWriteTextAnalysisSource* analysisSource, UINT32 textPosition, UINT32 textLength, IDWriteTextAnalysisSink* analysisSink )
    HRESULT GetGlyphs ( WCHAR* textString, UINT32 textLength, IDWriteFontFace* fontFace, BOOL isSideways, BOOL isRightToLeft, DWRITE_SCRIPT_ANALYSIS* scriptAnalysis, WCHAR* localeName, IDWriteNumberSubstitution* numberSubstitution, DWRITE_TYPOGRAPHIC_FEATURES** features, UINT32* featureRangeLengths, UINT32 featureRanges, UINT32 maxGlyphCount, USHORT* clusterMap, DWRITE_SHAPING_TEXT_PROPERTIES* textProps, USHORT* glyphIndices, DWRITE_SHAPING_GLYPH_PROPERTIES* glyphProps, UINT32* actualGlyphCount )
    HRESULT GetGlyphPlacements ( WCHAR* textString, USHORT* clusterMap, DWRITE_SHAPING_TEXT_PROPERTIES* textProps, UINT32 textLength, USHORT* glyphIndices, DWRITE_SHAPING_GLYPH_PROPERTIES* glyphProps, UINT32 glyphCount, IDWriteFontFace* fontFace, FLOAT fontEmSize, BOOL isSideways, BOOL isRightToLeft, DWRITE_SCRIPT_ANALYSIS* scriptAnalysis, WCHAR* localeName, DWRITE_TYPOGRAPHIC_FEATURES** features, UINT32* featureRangeLengths, UINT32 featureRanges, FLOAT* glyphAdvances, DWRITE_GLYPH_OFFSET* glyphOffsets )
    HRESULT GetGdiCompatibleGlyphPlacements ( WCHAR* textString, USHORT* clusterMap, DWRITE_SHAPING_TEXT_PROPERTIES* textProps, UINT32 textLength, USHORT* glyphIndices, DWRITE_SHAPING_GLYPH_PROPERTIES* glyphProps, UINT32 glyphCount, IDWriteFontFace* fontFace, FLOAT fontEmSize, FLOAT pixelsPerDip, DWRITE_MATRIX* transform, BOOL useGdiNatural, BOOL isSideways, BOOL isRightToLeft, DWRITE_SCRIPT_ANALYSIS* scriptAnalysis, WCHAR* localeName, DWRITE_TYPOGRAPHIC_FEATURES** features, UINT32* featureRangeLengths, UINT32 featureRanges, FLOAT* glyphAdvances, DWRITE_GLYPH_OFFSET* glyphOffsets ) ;

STRUCT: DWRITE_GLYPH_RUN
    { fontFace      IDWriteFontFace*     }
    { fontEmSize    FLOAT                }
    { glyphCount    UINT32               }
    { glyphIndices  USHORT*              }
    { glyphAdvances FLOAT*               }
    { glyphOffsets  DWRITE_GLYPH_OFFSET* }
    { isSideways    BOOL                 }
    { bidiLevel     UINT32               } ;

STRUCT: DWRITE_GLYPH_RUN_DESCRIPTION
    { localeName   WCHAR*  }
    { string       WCHAR*  }
    { stringLength UINT32  }
    { clusterMap   USHORT* }
    { textPosition UINT32  } ;

STRUCT: DWRITE_UNDERLINE
    { width            FLOAT                    }
    { thickness        FLOAT                    }
    { offset           FLOAT                    }
    { runHeight        FLOAT                    }
    { readingDirection DWRITE_READING_DIRECTION }
    { flowDirection    DWRITE_FLOW_DIRECTION    }
    { localeName       WCHAR*                   }
    { measuringMode    DWRITE_MEASURING_MODE    } ;

STRUCT: DWRITE_STRIKETHROUGH
    { width            FLOAT                    }
    { thickness        FLOAT                    }
    { offset           FLOAT                    }
    { readingDirection DWRITE_READING_DIRECTION }
    { flowDirection    DWRITE_FLOW_DIRECTION    }
    { localeName       WCHAR*                   }
    { measuringMode    DWRITE_MEASURING_MODE    } ;

STRUCT: DWRITE_LINE_METRICS
    { length                   UINT32 }
    { trailingWhitespaceLength UINT32 }
    { newlineLength            UINT32 }
    { height                   FLOAT  }
    { baseline                 FLOAT  }
    { isTrimmed                BOOL   } ;

STRUCT: DWRITE_CLUSTER_METRICS
    { width  FLOAT  }
    { length USHORT }
    { data   USHORT } ;

STRUCT: DWRITE_TEXT_METRICS
    { left                             FLOAT  }
    { top                              FLOAT  }
    { width                            FLOAT  }
    { widthIncludingTrailingWhitespace FLOAT  }
    { height                           FLOAT  }
    { layoutWidth                      FLOAT  }
    { layoutHeight                     FLOAT  }
    { maxBidiReorderingDepth           UINT32 }
    { lineCount                        UINT32 } ;

STRUCT: DWRITE_INLINE_OBJECT_METRICS
    { width             FLOAT }
    { height            FLOAT }
    { baseline          FLOAT }
    { supportsSideways  BOOL  } ;

STRUCT: DWRITE_OVERHANG_METRICS
    { left   FLOAT }
    { top    FLOAT }
    { right  FLOAT }
    { bottom FLOAT } ;

STRUCT: DWRITE_HIT_TEST_METRICS
    { textPosition UINT32 }
    { length       UINT32 }
    { left         FLOAT  }
    { top          FLOAT  }
    { width        FLOAT  }
    { height       FLOAT  }
    { bidiLevel    UINT32 }
    { isText       BOOL   }
    { isTrimmed    BOOL   } ;

C-TYPE: IDWriteTextRenderer

COM-INTERFACE: IDWriteInlineObject IUnknown {8339FDE3-106F-47ab-8373-1C6295EB10B3}
    HRESULT Draw ( void* clientDrawingContext, IDWriteTextRenderer* renderer, FLOAT originX, FLOAT originY, BOOL isSideways, BOOL isRightToLeft, IUnknown* clientDrawingEffect )
    HRESULT GetMetrics ( DWRITE_INLINE_OBJECT_METRICS* metrics )
    HRESULT GetOverhangMetrics ( DWRITE_OVERHANG_METRICS* overhangs )
    HRESULT GetBreakConditions ( DWRITE_BREAK_CONDITION* breakConditionBefore, DWRITE_BREAK_CONDITION* breakConditionAfter ) ;

COM-INTERFACE: IDWritePixelSnapping IUnknown {eaf3a2da-ecf4-4d24-b644-b34f6842024b}
    HRESULT IsPixelSnappingDisabled ( void* clientDrawingContext, BOOL* isDisabled )
    HRESULT GetCurrentTransform ( void* clientDrawingContext, DWRITE_MATRIX* transform )
    HRESULT GetPixelsPerDip ( void* clientDrawingContext, FLOAT* pixelsPerDip ) ;

COM-INTERFACE: IDWriteTextRenderer IDWritePixelSnapping {ef8a8135-5cc6-45fe-8825-c5a0724eb819}
    HRESULT DrawGlyphRun ( void* clientDrawingContext, FLOAT baselineOriginX, FLOAT baselineOriginY, DWRITE_MEASURING_MODE measuringMode, DWRITE_GLYPH_RUN* glyphRun, DWRITE_GLYPH_RUN_DESCRIPTION* glyphRunDescription, IUnknown* clientDrawingEffect )
    HRESULT DrawUnderline ( void* clientDrawingContext, FLOAT baselineOriginX, FLOAT baselineOriginY, DWRITE_UNDERLINE* underline, IUnknown* clientDrawingEffect )
    HRESULT DrawStrikethrough ( void* clientDrawingContext, FLOAT baselineOriginX, FLOAT baselineOriginY, DWRITE_STRIKETHROUGH* strikethrough, IUnknown* clientDrawingEffect )
    HRESULT DrawInlineObject ( void* clientDrawingContext, FLOAT originX, FLOAT originY, IDWriteInlineObject* inlineObject, BOOL isSideways, BOOL isRightToLeft, IUnknown* clientDrawingEffect ) ;

COM-INTERFACE: IDWriteTextLayout IDWriteTextFormat {53737037-6d14-410b-9bfe-0b182bb70961}
    HRESULT SetMaxWidth ( FLOAT maxWidth )
    HRESULT SetMaxHeight ( FLOAT maxHeight )
    HRESULT SetFontCollection ( IDWriteFontCollection* fontCollection, DWRITE_TEXT_RANGE textRange )
    HRESULT SetFontFamilyName ( WCHAR* fontFamilyName, DWRITE_TEXT_RANGE textRange )
    HRESULT SetFontWeight ( DWRITE_FONT_WEIGHT fontWeight, DWRITE_TEXT_RANGE textRange )
    HRESULT SetFontStyle ( DWRITE_FONT_STYLE fontStyle, DWRITE_TEXT_RANGE textRange )
    HRESULT SetFontStretch ( DWRITE_FONT_STRETCH fontStretch, DWRITE_TEXT_RANGE textRange )
    HRESULT SetFontSize ( FLOAT fontSize, DWRITE_TEXT_RANGE textRange )
    HRESULT SetUnderline ( BOOL hasUnderline, DWRITE_TEXT_RANGE textRange )
    HRESULT SetStrikethrough ( BOOL hasStrikethrough, DWRITE_TEXT_RANGE textRange )
    HRESULT SetDrawingEffect ( IUnknown* drawingEffect, DWRITE_TEXT_RANGE textRange )
    HRESULT SetInlineObject ( IDWriteInlineObject* inlineObject, DWRITE_TEXT_RANGE textRange )
    HRESULT SetTypography ( IDWriteTypography* typography, DWRITE_TEXT_RANGE textRange )
    HRESULT SetLocaleName ( WCHAR* localeName, DWRITE_TEXT_RANGE textRange )
    FLOAT GetMaxWidth ( )
    FLOAT GetMaxHeight ( )
    HRESULT GetFontCollection2 ( UINT32 currentPosition, IDWriteFontCollection** fontCollection, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontFamilyNameLength2 ( UINT32 currentPosition, UINT32* nameLength, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontFamilyName2 ( UINT32 currentPosition, WCHAR* fontFamilyName, UINT32 nameSize, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontWeight2 ( UINT32 currentPosition, DWRITE_FONT_WEIGHT* fontWeight, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontStyle2 ( UINT32 currentPosition, DWRITE_FONT_STYLE* fontStyle, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontStretch2 ( UINT32 currentPosition, DWRITE_FONT_STRETCH* fontStretch, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetFontSize2 ( UINT32 currentPosition, FLOAT* fontSize, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetUnderline ( UINT32 currentPosition, BOOL* hasUnderline, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetStrikethrough ( UINT32 currentPosition, BOOL* hasStrikethrough, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetDrawingEffect ( UINT32 currentPosition, IUnknown** drawingEffect, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetInlineObject ( UINT32 currentPosition, IDWriteInlineObject** inlineObject, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetTypography ( UINT32 currentPosition, IDWriteTypography** typography, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetLocaleNameLength2 ( UINT32 currentPosition, UINT32* nameLength, DWRITE_TEXT_RANGE* textRange )
    HRESULT GetLocaleName2 ( UINT32 currentPosition, WCHAR* localeName, UINT32 nameSize, DWRITE_TEXT_RANGE* textRange )
    HRESULT Draw ( void* clientDrawingContext, IDWriteTextRenderer* renderer, FLOAT originX, FLOAT originY )
    HRESULT GetLineMetrics ( DWRITE_LINE_METRICS* lineMetrics, UINT32 maxLineCount, UINT32* actualLineCount )
    HRESULT GetMetrics ( DWRITE_TEXT_METRICS* textMetrics )
    HRESULT GetOverhangMetrics ( DWRITE_OVERHANG_METRICS* overhangs )
    HRESULT GetClusterMetrics ( DWRITE_CLUSTER_METRICS* clusterMetrics, UINT32 maxClusterCount, UINT32* actualClusterCount )
    HRESULT DetermineMinWidth ( FLOAT* minWidth )
    HRESULT HitTestPoint ( FLOAT pointX, FLOAT pointY, BOOL* isTrailingHit, BOOL* isInside, DWRITE_HIT_TEST_METRICS* hitTestMetrics )
    HRESULT HitTestTextPosition ( UINT32 textPosition, BOOL isTrailingHit, FLOAT* pointX, FLOAT* pointY, DWRITE_HIT_TEST_METRICS* hitTestMetrics )
    HRESULT HitTestTextRange ( UINT32 textPosition, UINT32 textLength, FLOAT originX, FLOAT originY, DWRITE_HIT_TEST_METRICS* hitTestMetrics, UINT32 maxHitTestMetricsCount, UINT32* actualHitTestMetricsCount ) ;

COM-INTERFACE: IDWriteBitmapRenderTarget IUnknown {5e5a32a3-8dff-4773-9ff6-0696eab77267}
    HRESULT DrawGlyphRun ( FLOAT baselineOriginX, FLOAT baselineOriginY, DWRITE_MEASURING_MODE measuringMode, DWRITE_GLYPH_RUN* glyphRun, IDWriteRenderingParams* renderingParams, COLORREF textColor, RECT* blackBoxRect )
    HDC GetMemoryDC ( )
    FLOAT GetPixelsPerDip ( )
    HRESULT SetPixelsPerDip ( FLOAT pixelsPerDip )
    HRESULT GetCurrentTransform ( DWRITE_MATRIX* transform )
    HRESULT SetCurrentTransform ( DWRITE_MATRIX* transform )
    HRESULT GetSize ( SIZE* size )
    HRESULT Resize ( UINT32 width, UINT32 height ) ;

C-TYPE: LOGFONTW

COM-INTERFACE: IDWriteGdiInterop IUnknown {1edd9491-9853-4299-898f-6432983b6f3a}
    HRESULT CreateFontFromLOGFONT ( LOGFONTW* logFont, IDWriteFont** font )
    HRESULT ConvertFontToLOGFONT ( IDWriteFont* font, LOGFONTW* logFont, BOOL* isSystemFont )
    HRESULT ConvertFontFaceToLOGFONT ( IDWriteFontFace* font, LOGFONTW* logFont )
    HRESULT CreateFontFaceFromHdc ( HDC hdc, IDWriteFontFace** fontFace )
    HRESULT CreateBitmapRenderTarget ( HDC hdc, UINT32 width, UINT32 height, IDWriteBitmapRenderTarget** renderTarget ) ;

ENUM: DWRITE_TEXTURE_TYPE
    DWRITE_TEXTURE_ALIASED_1x1
    DWRITE_TEXTURE_CLEARTYPE_3x1 ;

CONSTANT: DWRITE_ALPHA_MAX 255

COM-INTERFACE: IDWriteGlyphRunAnalysis IUnknown {7d97dbf7-e085-42d4-81e3-6a883bded118}
    HRESULT GetAlphaTextureBounds ( DWRITE_TEXTURE_TYPE textureType, RECT* textureBounds )
    HRESULT CreateAlphaTexture ( DWRITE_TEXTURE_TYPE textureType, RECT* textureBounds, BYTE* alphaValues, UINT32 bufferSize )
    HRESULT GetAlphaBlendParams ( IDWriteRenderingParams* renderingParams, FLOAT* blendGamma, FLOAT* blendEnhancedContrast, FLOAT* blendClearTypeLevel ) ;

COM-INTERFACE: IDWriteFactory IUnknown {b859ee5a-d838-4b5b-a2e8-1adc7d93db48}
    HRESULT GetSystemFontCollection ( IDWriteFontCollection** fontCollection, BOOL checkForUpdates )
    HRESULT CreateCustomFontCollection ( IDWriteFontCollectionLoader* collectionLoader, void* collectionKey, UINT32 collectionKeySize, IDWriteFontCollection** fontCollection )
    HRESULT RegisterFontCollectionLoader ( IDWriteFontCollectionLoader* fontCollectionLoader )
    HRESULT UnregisterFontCollectionLoader ( IDWriteFontCollectionLoader* fontCollectionLoader )
    HRESULT CreateFontFileReference ( WCHAR* filePath, FILETIME* lastWriteTime, IDWriteFontFile** fontFile )
    HRESULT CreateCustomFontFileReference ( void* fontFileReferenceKey, UINT32 fontFileReferenceKeySize, IDWriteFontFileLoader* fontFileLoader, IDWriteFontFile** fontFile )
    HRESULT CreateFontFace ( DWRITE_FONT_FACE_TYPE fontFaceType, UINT32 numberOfFiles, IDWriteFontFile** fontFiles, UINT32 faceIndex, DWRITE_FONT_SIMULATIONS fontFaceSimulationFlags, IDWriteFontFace** fontFace )
    HRESULT CreateRenderingParams ( IDWriteRenderingParams** renderingParams )
    HRESULT CreateMonitorRenderingParams ( HMONITOR monitor, IDWriteRenderingParams** renderingParams )
    HRESULT CreateCustomRenderingParams ( FLOAT gamma, FLOAT enhancedContrast, FLOAT clearTypeLevel, DWRITE_PIXEL_GEOMETRY pixelGeometry, DWRITE_RENDERING_MODE renderingMode, IDWriteRenderingParams** renderingParams )
    HRESULT RegisterFontFileLoader ( IDWriteFontFileLoader* fontFileLoader )
    HRESULT UnregisterFontFileLoader ( IDWriteFontFileLoader* fontFileLoader )
    HRESULT CreateTextFormat ( WCHAR* fontFamilyName, IDWriteFontCollection* fontCollection, DWRITE_FONT_WEIGHT fontWeight, DWRITE_FONT_STYLE fontStyle, DWRITE_FONT_STRETCH fontStretch, FLOAT fontSize, WCHAR* localeName, IDWriteTextFormat** textFormat )
    HRESULT CreateTypography ( IDWriteTypography** typography )
    HRESULT GetGdiInterop ( IDWriteGdiInterop** gdiInterop )
    HRESULT CreateTextLayout ( WCHAR* string, UINT32 stringLength, IDWriteTextFormat* textFormat, FLOAT maxWidth, FLOAT maxHeight, IDWriteTextLayout** textLayout )
    HRESULT CreateGdiCompatibleTextLayout ( WCHAR* string, UINT32 stringLength, IDWriteTextFormat* textFormat, FLOAT layoutWidth, FLOAT layoutHeight, FLOAT pixelsPerDip, DWRITE_MATRIX* transform, BOOL useGdiNatural, IDWriteTextLayout** textLayout )
    HRESULT CreateEllipsisTrimmingSign ( IDWriteTextFormat* textFormat, IDWriteInlineObject** trimmingSign )
    HRESULT CreateTextAnalyzer ( IDWriteTextAnalyzer** textAnalyzer )
    HRESULT CreateNumberSubstitution ( DWRITE_NUMBER_SUBSTITUTION_METHOD substitutionMethod, WCHAR* localeName, BOOL ignoreUserOverride, IDWriteNumberSubstitution** numberSubstitution )
    HRESULT CreateGlyphRunAnalysis ( DWRITE_GLYPH_RUN* glyphRun, FLOAT pixelsPerDip, DWRITE_MATRIX* transform, DWRITE_RENDERING_MODE renderingMode, DWRITE_MEASURING_MODE measuringMode, FLOAT baselineOriginX, FLOAT baselineOriginY, IDWriteGlyphRunAnalysis** glyphRunAnalysis ) ;

FUNCTION: HRESULT DWriteCreateFactory (
    DWRITE_FACTORY_TYPE factoryType,
    REFIID              iid,
    IUnknown**          factory )

CONSTANT: DWRITE_E_FILEFORMAT             0x88985000
CONSTANT: DWRITE_E_UNEXPECTED             0x88985001
CONSTANT: DWRITE_E_NOFONT                 0x88985002
CONSTANT: DWRITE_E_FILENOTFOUND           0x88985003
CONSTANT: DWRITE_E_FILEACCESS             0x88985004
CONSTANT: DWRITE_E_FONTCOLLECTIONOBSOLETE 0x88985005
CONSTANT: DWRITE_E_ALREADYREGISTERED      0x88985006
