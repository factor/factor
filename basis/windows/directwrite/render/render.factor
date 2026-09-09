! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays classes.struct colors
combinators destructors fonts fonts.shaping images init kernel locals
math math.functions math.order namespaces sequences
windows.com windows.directwrite windows.directx.d2d1 windows.directx.d2dbasetypes
windows.directx.dxgiformat windows.offscreen windows.ole32 windows.types ;
IN: windows.directwrite.render
SYMBOL: text-color-fonts-disabled?
SYMBOL: text-selection-rects
SYMBOL: text-selection-color
SYMBOL: text-selection-background
SYMBOL: cached-text-dc-target

CONSTANT: D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT 4

: <text-render-factory> ( -- factory )
    D2D1_FACTORY_TYPE_SINGLE_THREADED ID2D1Factory-iid f
    { void* } [ D2D1CreateFactory check-ole32-error ] with-out-parameters
    &com-release ;

: <text-render-properties> ( -- properties )
    D2D1_RENDER_TARGET_PROPERTIES new
    D2D1_PIXEL_FORMAT new
        DXGI_FORMAT_B8G8R8A8_UNORM >>format
        D2D1_ALPHA_MODE_IGNORE >>alphaMode >>pixelFormat
    96.0 >>dpiX 96.0 >>dpiY ;

: <text-dc-target> ( -- target )
    <text-render-factory> <text-render-properties>
    { void* } [ ID2D1Factory::CreateDCRenderTarget check-ole32-error ]
    with-out-parameters ;

: release-text-dc-target ( -- )
    cached-text-dc-target get-global [ com-release ] when*
    f cached-text-dc-target set-global ;

: check-text-target-error ( hresult -- )
    dup 0 < [ release-text-dc-target ] when check-ole32-error ;

: text-dc-target ( -- target )
    ! Creating a software target costs about 100ms. Rebind this target to
    ! each temporary DIB; native drawing is synchronous on Factor's thread.
    cached-text-dc-target get-global [
        <text-dc-target> dup cached-text-dc-target set-global
    ] unless* ;

STARTUP-HOOK: [ f cached-text-dc-target set-global ]
SHUTDOWN-HOOK: [ release-text-dc-target ]

:: color>d2d ( color -- struct )
    color >rgba-components :> a :> b :> g :> r
    D3DCOLORVALUE new r >>r g >>g b >>b a >>a ;

:: <text-brush> ( target color -- brush )
    target color color>d2d f { void* }
    [ ID2D1RenderTarget::CreateSolidColorBrush check-ole32-error ]
    with-out-parameters &com-release ;

:: draw-layout-to-dc ( pointer dim origin foreground background dc -- )
    text-dc-target :> target
    target dc { 0 0 } dim <RECT>
    ID2D1DCRenderTarget::BindDC check-text-target-error
    target D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE
    ID2D1RenderTarget::SetTextAntialiasMode
    target foreground <text-brush> :> brush
    target ID2D1RenderTarget::BeginDraw
    target background color>d2d ID2D1RenderTarget::Clear
    target D2D_POINT_2F new origin first >>x origin second >>y pointer brush
    text-color-fonts-disabled? get [ 0 ] [ D2D1_DRAW_TEXT_OPTIONS_ENABLE_COLOR_FONT ] if
    ID2D1RenderTarget::DrawTextLayout
    target f f ID2D1RenderTarget::EndDraw check-text-target-error ;

:: render-layout-on ( pointer dim origin foreground background -- image )
    [ :> dc dim dc [ pointer dim origin foreground background dc draw-layout-to-dc ]
      make-bitmap-image ] with-memory-dc ;

! Recover glyph coverage from two opaque renders, including layered color
! glyphs. The image protocol expects straight RGBA, whereas D2D composites
! premultiplied colors. This also preserves translucent font backgrounds.
:: composite-text-channel ( channel color behind alpha opacity -- value )
    alpha 0.0 >
    [ channel 255.0 / opacity * color behind * + alpha / 255.0 * round >integer 0 max 255 min ]
    [ 0 ] if ; inline

:: composite-bitmap-pixel ( offset black white background opacity -- )
    offset black nth :> blue
    offset 1 + black nth :> green
    offset 2 + black nth :> red
    1.0 offset white nth blue - 255.0 / - 0.0 max 1.0 min opacity * :> coverage
    background >rgba-components :> ba :> bb :> bg :> br
    ba 1.0 coverage - * :> behind
    coverage behind + :> alpha

    red br behind alpha opacity composite-text-channel offset black set-nth
    green bg behind alpha opacity composite-text-channel offset 1 + black set-nth
    blue bb behind alpha opacity composite-text-channel offset 2 + black set-nth
    alpha 255.0 * round >integer offset 3 + black set-nth ; inline

:: selection-background ( background -- color )
    text-selection-color get >rgba-components :> sa :> sb :> sg :> sr
    background >rgba-components :> ba :> bb :> bg :> br
    ba 1.0 sa - * :> behind
    sa behind + :> alpha
    alpha 0.0 > [
        sr sa * br behind * + alpha /
        sg sa * bg behind * + alpha /
        sb sa * bb behind * + alpha / alpha <rgba>
    ] [ 0.0 0.0 0.0 0.0 <rgba> ] if ;

:: pixel-background ( index dim origin background -- color )
    text-selection-rects get [
        index dim first mod 0.5 + origin first - :> x
        dim second 1 - index dim first /i - 0.5 + origin second - :> y
        [| rect |
            x rect first >= x rect first rect third + < and
            y rect second >= y rect second rect fourth + < and and
        ] any? [ text-selection-background get ] [ background ] if
    ] [ background ] if* ;
:: render-directwrite-image ( pointer dim origin foreground background -- image )
    foreground >rgba alpha>> :> opacity
    foreground >rgba-components drop 1.0 <rgba> :> solid
    pointer dim origin solid COLOR: black render-layout-on :> black
    pointer dim origin solid COLOR: white render-layout-on :> white
    black bitmap>> :> blacks
    white bitmap>> :> whites
    text-selection-color get [ background selection-background text-selection-background set ] when
    blacks length 4 /i [| index |
        index 4 * blacks whites index dim origin background pixel-background
        opacity composite-bitmap-pixel
    ] each-integer
    black RGBA >>component-order ;

:: directwrite-layout>image ( layout -- image )
    layout image>> [
        [ layout font>> font-color-fonts? not text-color-fonts-disabled? set
        layout directwrite-selection-rects
        [ { [ left>> ] [ top>> ] [ width>> ] [ height>> ] } cleave 4array ] map
        dup empty? [ drop f ] when text-selection-rects set
        layout string>> dup selection? [ color>> text-selection-color set ] [ drop ] if
        layout pointer>> layout size>> layout origin>>
        layout font>> [ foreground>> ] [ background>> ] bi
        render-directwrite-image layout swap >>image drop ] with-scope
    ] unless
    layout image>> ;
