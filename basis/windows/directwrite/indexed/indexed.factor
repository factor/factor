! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types alien.data arrays assocs
byte-arrays classes.struct combinators continuations destructors generalizations kernel kernel.private libc
locals math math.order namespaces sequences sorting vectors windows.com
windows.com.wrapper windows.directx.d2d1 windows.directx.d2dbasetypes
windows.directx.dcommon windows.directx.dwrite windows.ole32 windows.types ;
FROM: windows.directx.dwrite => DWRITE_GLYPH_RUN ;
IN: windows.directwrite.indexed

! Capture the native shaping once. Tiles then draw bounded glyph runs,
! with their baselines rebased before conversion to Direct2D floats.
TUPLE: directwrite-glyph-index < disposable runs regions owners error width logical font-tables left right top bottom ;
TUPLE: directwrite-glyph-region run x y left right order max-right ;
TUPLE: directwrite-logical-run run start length clusters blocks x end-x ;

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

:: index-glyph-run ( index y run description -- )
    run copy-glyph-run { DWRITE_GLYPH_RUN } declare :> saved
    saved index runs>> push
    saved fontFace>> index font-tables>> [ glyph-metrics-table 2array ] cache first2 :> units
    { byte-array } declare :> table
    saved fontEmSize>> units /f :> scale
    saved glyphIndices>> :> indices
    saved glyphAdvances>> :> advances
    saved glyphOffsets>> >c-ptr :> offsets
    y >float :> baseline-y
    index width>> >float :> pen!
    directwrite-logical-run new saved >>run
        description textPosition>> >>start description stringLength>> >>length
        description clusterMap>> description stringLength>> 2 * memory>byte-array >>clusters
        V{ } clone >>blocks pen >>x :> logical
    saved glyphCount>> 255 + 256 /i [| block |
        block 256 * :> start
        saved glyphCount>> start - 256 min :> count
        pen :> baseline
        1/0. :> left! -1/0. :> right!
        1/0. :> top! -1/0. :> bottom!
        count [| j |
            start j + :> i
            indices i 2 * alien-unsigned-2 :> glyph
            glyph DWRITE_GLYPH_METRICS heap-size * :> offset
            offsets i 8 * alien-float pen + :> pos
            pos table offset alien-signed-4 scale * + left min left!
            pos table offset 4 + alien-unsigned-4 table offset 8 + alien-signed-4 - scale * + right max right!
            baseline-y offsets i 8 * 4 + alien-float - :> base-y
            table offset 24 + alien-signed-4 :> vertical-origin
            base-y table offset 12 + alien-signed-4 vertical-origin - scale * + top min top!
            base-y table offset 16 + alien-unsigned-4 table offset 20 + alien-signed-4 - vertical-origin - scale * + bottom max bottom!
            pen advances i 4 * alien-float + pen!
        ] each-integer
        directwrite-glyph-region new
            saved start count glyph-region-run >>run baseline >>x y >>y
            left 2 - >>left right 2 + >>right
            index regions>> length >>order
            dup index regions>> push logical blocks>> push
        index
            index left>> left 2 - min >>left index right>> right 2 + max >>right
            index top>> top 2 - min >>top index bottom>> bottom 2 + max >>bottom drop
    ] each-integer
    logical pen >>end-x index logical>> push
    index index width>> pen max >>width drop ;

:: capture-glyph-run ( index context x y mode run description effect -- result )
    context x mode effect 4drop
    [ index y run description index-glyph-run S_OK ]
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
            V{ } clone >>runs V{ } clone >>regions 1 >>owners 0 >>width
            V{ } clone >>logical H{ } clone >>font-tables :> index
        index 0 >>left 0 >>right 0 >>top 0 >>bottom drop
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
        index regions >>regions f >>font-tables
    ] with-destructors ;

! Native FLOAT hit testing accumulates the same run-position error as
! painting. Keep ASCII caret and selection positions in the indexed space.
:: glyph-index-floor ( value seq quot -- i )
    0 :> lo! seq length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid seq nth quot call value <=
        [ mid 1 + lo! ] [ mid hi! ] if
    ] while lo 1 - 0 max ; inline

:: run-cluster ( n logical -- glyph )
    logical clusters>> n 2 * alien-unsigned-2 ; inline

:: run-glyph-x ( glyph logical -- x )
    glyph logical run>> glyphCount>> >= [ logical end-x>> ] [
        glyph 256 /i logical blocks>> nth x>> :> x!
        glyph 256 /i 256 * :> start
        glyph start - [| i |
            x logical run>> glyphAdvances>> start i + 4 * alien-float + x!
        ] each-integer x
    ] if ;

:: directwrite-indexed-offset>x ( n index -- x )
    n 0 max :> offset
    index logical>> :> runs
    offset runs [ start>> ] glyph-index-floor runs nth :> logical
    offset logical start>> - :> local
    local logical length>> >= [ logical end-x>> ] [
        local logical run-cluster logical run-glyph-x
    ] if ;

:: clusters-through ( glyph logical -- n )
    0 :> lo! logical length>> :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid logical run-cluster glyph <= [ mid 1 + lo! ] [ mid hi! ] if
    ] while lo ;

:: directwrite-indexed-x>offset ( x index -- n )
    index logical>> :> runs
    x 0 <= [ 0 ] [
        x index width>> >= [ runs last [ start>> ] [ length>> ] bi + ] [
            x runs [ x>> ] glyph-index-floor runs nth :> logical
            x logical blocks>> [ x>> ] glyph-index-floor :> block
            block 256 * :> glyph!
            block logical blocks>> nth x>> :> pen!
            [ glyph logical run>> glyphCount>> < [
                pen logical run>> glyphAdvances>> glyph 4 * alien-float + x <=
            ] [ f ] if ] [
                pen logical run>> glyphAdvances>> glyph 4 * alien-float + pen!
                glyph 1 + glyph!
            ] while
            glyph logical clusters-through 1 - 0 max logical run-cluster :> first-glyph
            first-glyph 1 - logical clusters-through :> start
            first-glyph logical clusters-through :> end
            first-glyph logical run-glyph-x :> left
            end logical length>> = [ logical end-x>> ] [
                end logical run-cluster logical run-glyph-x
            ] if :> right
            x left right + 2 / >= end start ? logical start>> +
        ] if
    ] if ;

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
