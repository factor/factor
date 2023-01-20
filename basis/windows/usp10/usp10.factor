! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax alien.destructors classes.struct
windows.types ;
IN: windows.usp10

LIBRARY: usp10

STRUCT: SCRIPT_CONTROL
    { flags DWORD } ;

STRUCT: SCRIPT_STATE
    { flags WORD } ;

STRUCT: SCRIPT_ANALYSIS
    { flags WORD }
    { s SCRIPT_STATE } ;

STRUCT: SCRIPT_ITEM
    { iCharPos int }
    { a SCRIPT_ANALYSIS } ;

FUNCTION: HRESULT ScriptItemize (
    WCHAR* pwcInChars,
    int cInChars,
    int cMaxItems,
    SCRIPT_CONTROL* psControl,
    SCRIPT_STATE* psState,
    SCRIPT_ITEM* pItems,
    int* pcItems
)

FUNCTION: HRESULT ScriptLayout (
    int cRuns,
    BYTE* pbLevel,
    int* piVisualToLogical,
    int* piLogicalToVisual
)

CONSTANT: SCRIPT_JUSTIFY_NONE 0
CONSTANT: SCRIPT_JUSTIFY_ARABIC_BLANK 1
CONSTANT: SCRIPT_JUSTIFY_CHARACTER 2
CONSTANT: SCRIPT_JUSTIFY_RESERVED1 3
CONSTANT: SCRIPT_JUSTIFY_BLANK 4
CONSTANT: SCRIPT_JUSTIFY_RESERVED2 5
CONSTANT: SCRIPT_JUSTIFY_RESERVED3 6
CONSTANT: SCRIPT_JUSTIFY_ARABIC_NORMAL 7
CONSTANT: SCRIPT_JUSTIFY_ARABIC_KASHIDA 8
CONSTANT: SCRIPT_JUSTIFY_ALEF 9
CONSTANT: SCRIPT_JUSTIFY_HA 10
CONSTANT: SCRIPT_JUSTIFY_RA 11
CONSTANT: SCRIPT_JUSTIFY_BA 12
CONSTANT: SCRIPT_JUSTIFY_BARA 13
CONSTANT: SCRIPT_JUSTIFY_SEEN 14
CONSTANT: SCRIPT_JUSTIFFY_RESERVED4 15

STRUCT: SCRIPT_VISATTR
    { flags WORD } ;

C-TYPE: SCRIPT_CACHE
C-TYPE: ABC

FUNCTION: HRESULT ScriptShape (
    HDC hdc,
    SCRIPT_CACHE* psc,
    WCHAR* pwcChars,
    int cChars,
    int cMaxGlyphs,
    SCRIPT_ANALYSIS* psa,
    WORD* pwOutGlyphs,
    WORD* pwLogClust,
    SCRIPT_VISATTR* psva,
    int* pcGlyphs
)

STRUCT: GOFFSET
    { du LONG }
    { dv LONG } ;

FUNCTION: HRESULT ScriptPlace (
    HDC hdc,
    SCRIPT_CACHE* psc,
    WORD* pwGlyphs,
    int cGlyphs,
    SCRIPT_VISATTR* psva,
    SCRIPT_ANALYSIS* psa,
    int* piAdvance,
    GOFFSET* pGoffset,
    ABC* pABC
)

FUNCTION: HRESULT ScriptTextOut (
    HDC hdc,
    SCRIPT_CACHE* psc,
    int x,
    int y,
    UINT fuOptions,
    RECT* lprc,
    SCRIPT_ANALYSIS* psa,
    WCHAR* pwcReserved,
    int iReserved,
    WORD* pwGlyphs,
    int cGlyphs,
    int* piAdvance,
    int* piJustify,
    GOFFSET* pGoffset
)

FUNCTION: HRESULT ScriptJustify (
    SCRIPT_VISATTR* psva,
    int* piAdvance,
    int cGlyphs,
    int iDx,
    int iMinKashida,
    int* piJustify
)

STRUCT: SCRIPT_LOGATTR
    { flags BYTE } ;

FUNCTION: HRESULT ScriptBreak (
    WCHAR* pwcChars,
    int cChars,
    SCRIPT_ANALYSIS* psa,
    SCRIPT_LOGATTR* psla
)

FUNCTION: HRESULT ScriptCPtoX (
    int iCP,
    BOOL fTrailing,
    int cChars,
    int cGlyphs,
    WORD* pwLogClust,
    SCRIPT_VISATTR* psva,
    int* piAdvance,
    SCRIPT_ANALYSIS* psa,
    int* piX
)

FUNCTION: HRESULT ScriptXtoCP (
    int iCP,
    BOOL fTrailing,
    int cChars,
    int cGlyphs,
    WORD* pwLogClust,
    SCRIPT_VISATTR* psva,
    int* piAdvance,
    SCRIPT_ANALYSIS* psa,
    int* piCP,
    int* piTrailing
)

FUNCTION: HRESULT ScriptGetLogicalWidths (
    SCRIPT_ANALYSIS* psa,
    int cChars,
    int cGlyphs,
    int* piGlyphWidth,
    WORD* pwLogClust,
    SCRIPT_VISATTR* psva,
    int* piDx
)

FUNCTION: HRESULT ScriptApplyLogicalWidth (
    int* piDx,
    int cChars,
    int cGlyphs,
    WORD* pwLogClust,
    SCRIPT_VISATTR* psva,
    int* piAdvance,
    SCRIPT_ANALYSIS* psa,
    ABC* pABC,
    int* piJustify
)

FUNCTION: HRESULT ScriptGetCMap (
    HDC hdc,
    SCRIPT_CACHE* psc,
    WCHAR* pwcInChars,
    int cChars,
    DWORD dwFlags,
    WORD* pwOutGlyphs
)

FUNCTION: HRESULT ScriptGetGlyphABCWidth (
    HDC hdc,
    SCRIPT_CACHE* psc,
    WORD wGlyph,
    ABC* pABC
)

STRUCT: SCRIPT_PROPERTIES
    { flags DWORD } ;

FUNCTION: HRESULT ScriptGetProperties (
    SCRIPT_PROPERTIES*** ppSp,
    int* piNumScripts
)

STRUCT: SCRIPT_FONTPROPERTIES
    { cBytes int }
    { wgBlank WORD }
    { wgDefault WORD }
    { wgInvalid WORD }
    { wgKashida WORD }
    { iKashidaWidth int } ;

FUNCTION: HRESULT ScriptGetFontProperties (
    HDC hdc,
    SCRIPT_CACHE* psc,
    SCRIPT_FONTPROPERTIES* sfp
)

FUNCTION: HRESULT ScriptCacheGetHeight (
    HDC hdc,
    SCRIPT_CACHE* psc,
    long* tmHeight
)

CONSTANT: SSA_PASSWORD 0x00000001
CONSTANT: SSA_TAB 0x00000002
CONSTANT: SSA_CLIP 0x00000004
CONSTANT: SSA_FIT 0x00000008
CONSTANT: SSA_DZWG 0x00000010
CONSTANT: SSA_FALLBACK 0x00000020
CONSTANT: SSA_BREAK 0x00000040
CONSTANT: SSA_GLYPHS 0x00000080
CONSTANT: SSA_RTL 0x00000100
CONSTANT: SSA_GCP 0x00000200
CONSTANT: SSA_HOTKEY 0x00000400
CONSTANT: SSA_METAFILE 0x00000800
CONSTANT: SSA_LINK 0x00001000
CONSTANT: SSA_HIDEHOTKEY 0x00002000
CONSTANT: SSA_HOTKEYONLY 0x00002400
CONSTANT: SSA_FULLMEASURE 0x04000000
CONSTANT: SSA_LPKANSIFALLBACK 0x08000000
CONSTANT: SSA_PIDX 0x10000000
CONSTANT: SSA_LAYOUTRTL 0x20000000
CONSTANT: SSA_DONTGLYPH 0x40000000
CONSTANT: SSA_NOKASHIDA 0x80000000

STRUCT: SCRIPT_TABDEF
    { cTabStops int }
    { iScale int }
    { pTabStops int* }
    { iTabOrigin int } ;

TYPEDEF: void* SCRIPT_STRING_ANALYSIS

FUNCTION: HRESULT ScriptStringAnalyse (
    HDC hdc,
    void* pString,
    int cString,
    int cGlyphs,
    int iCharset,
    DWORD dwFlags,
    int iReqWidth,
    SCRIPT_CONTROL* psControl,
    SCRIPT_STATE* psState,
    int* piDx,
    SCRIPT_TABDEF* pTabDef,
    BYTE* pbInClass,
    SCRIPT_STRING_ANALYSIS* pssa
)

FUNCTION: HRESULT ScriptStringFree (
    SCRIPT_STRING_ANALYSIS* pssa
)

DESTRUCTOR: ScriptStringFree

FUNCTION: SIZE* ScriptString_pSize ( SCRIPT_STRING_ANALYSIS ssa )

FUNCTION: int* ScriptString_pcOutChars ( SCRIPT_STRING_ANALYSIS ssa )

FUNCTION: SCRIPT_LOGATTR* ScriptString_pLogAttr ( SCRIPT_STRING_ANALYSIS ssa )

FUNCTION: HRESULT ScriptStringGetOrder (
    SCRIPT_STRING_ANALYSIS ssa,
    UINT* puOrder
)

FUNCTION: HRESULT ScriptStringCPtoX (
    SCRIPT_STRING_ANALYSIS ssa,
    int icp,
    BOOL fTrailing,
    int* pX
)

FUNCTION: HRESULT ScriptStringXtoCP (
    SCRIPT_STRING_ANALYSIS ssa,
    int iX,
    int* piCh,
    int* piTrailing
)

FUNCTION: HRESULT ScriptStringGetLogicalWidths (
    SCRIPT_STRING_ANALYSIS ssa,
    int* piDx
)

FUNCTION: HRESULT ScriptStringValidate (
    SCRIPT_STRING_ANALYSIS ssa
)

FUNCTION: HRESULT ScriptStringOut (
    SCRIPT_STRING_ANALYSIS ssa,
    int iX,
    int iY,
    UINT uOptions,
    RECT* prc,
    int iMinSel,
    int iMaxSel,
    BOOL fDisabled
)

CONSTANT: SIC_COMPLEX 1
CONSTANT: SIC_ASCIIDIGIT 2
CONSTANT: SIC_NEUTRAL 4

FUNCTION: HRESULT ScriptIsComplex (
    WCHAR* pwcInChars,
    int cInChars,
    DWORD dwFlags
)

STRUCT: SCRIPT_DIGITSUBSTITUTE
    { flags DWORD } ;

FUNCTION: HRESULT ScriptRecordDigitSubstitution (
    LCID Locale,
    SCRIPT_DIGITSUBSTITUTE* psds
)

CONSTANT: SCRIPT_DIGITSUBSTITUTE_CONTEXT 0
CONSTANT: SCRIPT_DIGITSUBSTITUTE_NONE 1
CONSTANT: SCRIPT_DIGITSUBSTITUTE_NATIONAL 2
CONSTANT: SCRIPT_DIGITSUBSTITUTE_TRADITIONAL 3

FUNCTION: HRESULT ScriptApplyDigitSubstitution (
    SCRIPT_DIGITSUBSTITUTE* psds,
    SCRIPT_CONTROL* psc,
    SCRIPT_STATE* pss
)
