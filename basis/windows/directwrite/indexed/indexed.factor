! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types alien.data arrays
byte-arrays classes.struct combinators continuations destructors generalizations kernel libc
locals math math.order namespaces sequences sorting vectors windows.com
windows.com.wrapper windows.directx.d2d1 windows.directx.d2dbasetypes
windows.directx.dcommon windows.directx.dwrite windows.ole32 windows.types ;
IN: windows.directwrite.indexed

! Capture the native shaping once. Tiles then draw bounded glyph runs,
! with their baselines rebased before conversion to Direct2D floats.
TUPLE: directwrite-glyph-index < disposable runs regions owners error width ;
TUPLE: directwrite-glyph-region run x y left right order max-right ;

M: directwrite-glyph-index dispose*
    runs>> [
        { [ fontFace>> com-release ] [ glyphIndices>> free ]
          [ glyphAdvances>> free ] [ glyphOffsets>> >c-ptr free ] } cleave
    ] each ;

: retain-glyph-index ( index -- index )
    [ 1 + ] change-owners ;

: release-glyph-index ( index -- )
    dup [ 1 - ] change-owners owners>> zero? [ dispose ] [ drop ] if ;

:: copy-glyph-run ( run -- copy )
    [
        run clone
        run fontFace>> com-add-ref |com-release >>fontFace
        run glyphIndices>> run glyphCount>> 2 * memory>byte-array malloc-byte-array |free >>glyphIndices
        run glyphAdvances>> run glyphCount>> 4 * memory>byte-array malloc-byte-array |free >>glyphAdvances
        run glyphOffsets>> [ >c-ptr run glyphCount>> 8 * memory>byte-array ]
        [ run glyphCount>> 8 * <byte-array> ] if* malloc-byte-array |free >>glyphOffsets
    ] with-destructors ;

:: glyph-metrics-table ( face -- table scale )
    face IDWriteFontFace::GetGlyphCount :> count
    count ushort <c-array> :> indices
    count [ dup indices set-nth ] each-integer
    count DWRITE_GLYPH_METRICS heap-size * <byte-array> :> table
    face indices count table FALSE IDWriteFontFace::GetDesignGlyphMetrics check-ole32-error
    face DWRITE_FONT_METRICS new [ IDWriteFontFace::GetMetrics ] keep
    table swap designUnitsPerEm>> ;

:: glyph-region-run ( run start count -- part )
    run clone count >>glyphCount
        start 2 * run glyphIndices>> <displaced-alien> >>glyphIndices
        start 4 * run glyphAdvances>> <displaced-alien> >>glyphAdvances
        start 8 * run glyphOffsets>> >c-ptr <displaced-alien> >>glyphOffsets ;

:: index-glyph-run ( index x y run -- )
    run copy-glyph-run :> saved
    saved index runs>> push
    saved fontFace>> glyph-metrics-table :> ( table units )
    saved fontEmSize>> units / :> scale
    x :> pen!
    saved glyphCount>> 255 + 256 /i [| block |
        block 256 * :> start
        saved glyphCount>> start - 256 min :> count
        pen :> baseline
        1/0. :> left! -1/0. :> right!
        count [| j |
            start j + :> i
            saved glyphIndices>> i 2 * alien-unsigned-2 :> glyph
            glyph DWRITE_GLYPH_METRICS heap-size * table <displaced-alien>
            DWRITE_GLYPH_METRICS memory>struct :> metrics
            saved glyphOffsets>> >c-ptr i 8 * alien-float pen + :> pos
            pos metrics leftSideBearing>> scale * + left min left!
            pos metrics advanceWidth>> metrics rightSideBearing>> - scale * + right max right!
            pen saved glyphAdvances>> i 4 * alien-float + pen!
        ] each-integer
        directwrite-glyph-region new
            saved start count glyph-region-run >>run baseline >>x y >>y
            left 2 - >>left right 2 + >>right
            index regions>> length >>order index regions>> push
    ] each-integer
    index index width>> pen max >>width drop ;

:: capture-glyph-run ( index context x y mode run description effect -- result )
    context mode description effect 4drop
    [ index x y run index-glyph-run S_OK ]
    [ index swap >>error drop E_FAIL ] recover ;

SYMBOL: glyph-index-wrapper

! Only horizontal, left-to-right ASCII layouts use this renderer. Other
! scripts and color glyphs keep the native DrawTextLayout path.
{
    { IDWriteTextRenderer {
        [ nip TRUE swap 0 set-alien-signed-4 drop S_OK ]
        [ nip DWRITE_MATRIX memory>struct 1.0 >>m11 1.0 >>m22
          0.0 >>m12 0.0 >>m21 0.0 >>dx 0.0 >>dy 2drop S_OK ]
        [ nip 1.0 swap 0 set-alien-float drop S_OK ]
        [ capture-glyph-run ]
        [ 6 ndrop E_NOTIMPL ]
        [ 6 ndrop E_NOTIMPL ]
        [ 8 ndrop E_NOTIMPL ]
    } }
} <com-wrapper> glyph-index-wrapper set-global

:: <directwrite-glyph-index> ( pointer -- index )
    [
        directwrite-glyph-index new-disposable |dispose
            V{ } clone >>runs V{ } clone >>regions 1 >>owners 0 >>width :> index
        index glyph-index-wrapper get-global com-wrap [| renderer |
            pointer f renderer 0.0 0.0 IDWriteTextLayout::Draw :> result
            index error>> [ rethrow ] when*
            result check-ole32-error
        ] with-com-interface
        index regions>> [ left>> ] sort-by :> regions
        -1/0. :> right!
        regions [| region |
            right region right>> max right!
            region right >>max-right drop
        ] each
        index regions >>regions
    ] with-destructors ;

:: visible-directwrite-regions ( index left right -- regions )
    index regions>> :> regions
    0 :> lo! regions length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid regions nth max-right>> left <
        [ mid 1 + lo! ] [ mid hi! ] if
    ] while
    V{ } clone :> visible
    [ lo regions length < [ lo regions nth left>> right <= ] [ f ] if ] [
        lo regions nth :> region
        region right>> left >= [ region visible push ] when
        lo 1 + lo!
    ] while
    visible [ order>> ] sort-by ;

:: draw-directwrite-regions ( target index origin width brush -- )
    index origin first neg width origin first - visible-directwrite-regions [| region |
        target D2D_POINT_2F new
            region x>> origin first + >>x region y>> origin second + >>y
            region run>> brush DWRITE_MEASURING_MODE_NATURAL
            ID2D1RenderTarget::DrawGlyphRun
    ] each ;
