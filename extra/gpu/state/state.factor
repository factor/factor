! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays byte-arrays
combinators combinators.short-circuit gpu kernel literals math
math.rectangles opengl opengl.gl sequences typed variants
specialized-arrays ;
QUALIFIED-WITH: alien.c-types c
FROM: math => float ;
SPECIALIZED-ARRAY: c:int
SPECIALIZED-ARRAY: c:float
IN: gpu.state

TUPLE: viewport-state
    { rect rect read-only } ;
C: <viewport-state> viewport-state

TUPLE: scissor-state
    { rect maybe{ rect } read-only } ;
C: <scissor-state> scissor-state

TUPLE: multisample-state
    { multisample? boolean read-only }
    { sample-alpha-to-coverage? boolean read-only }
    { sample-alpha-to-one? boolean read-only }
    { sample-coverage maybe{ float } read-only }
    { invert-sample-coverage? boolean read-only } ;
C: <multisample-state> multisample-state

VARIANT: comparison
    cmp-never cmp-always
    cmp-less cmp-less-equal cmp-equal
    cmp-greater-equal cmp-greater cmp-not-equal ;
VARIANT: stencil-op
    op-keep op-zero
    op-replace op-invert
    op-inc-sat op-dec-sat
    op-inc-wrap op-dec-wrap ;

TUPLE: stencil-mode
    { value integer initial: 0 read-only }
    { mask integer initial: 0xFFFFFFFF read-only }
    { comparison comparison initial: cmp-always read-only }
    { stencil-fail-op stencil-op initial: op-keep read-only }
    { depth-fail-op stencil-op initial: op-keep read-only }
    { depth-pass-op stencil-op initial: op-keep read-only } ;
C: <stencil-mode> stencil-mode

TUPLE: stencil-state
    { front-mode maybe{ stencil-mode } initial: f read-only }
    { back-mode maybe{ stencil-mode } initial: f read-only } ;
C: <stencil-state> stencil-state

TUPLE: depth-range-state
    { near float initial: 0.0 read-only }
    { far  float initial: 1.0 read-only } ;
C: <depth-range-state> depth-range-state

TUPLE: depth-state
    { comparison maybe{ comparison } initial: f read-only } ;
C: <depth-state> depth-state

VARIANT: blend-equation
    eq-add eq-subtract eq-reverse-subtract eq-min eq-max ;
VARIANT: blend-function
    func-zero func-one
    func-source func-one-minus-source
    func-dest func-one-minus-dest
    func-constant func-one-minus-constant
    func-source-alpha func-one-minus-source-alpha
    func-dest-alpha func-one-minus-dest-alpha
    func-constant-alpha func-one-minus-constant-alpha ;

VARIANT: source-only-blend-function
    func-source-alpha-saturate ;

UNION: source-blend-function blend-function source-only-blend-function ;

TUPLE: blend-mode
    { equation blend-equation initial: eq-add read-only }
    { source-function source-blend-function initial: func-source-alpha read-only }
    { dest-function blend-function initial: func-one-minus-source-alpha read-only } ;
C: <blend-mode> blend-mode

TUPLE: blend-state
    { constant-color sequence initial: f read-only }
    { rgb-mode maybe{ blend-mode } read-only }
    { alpha-mode maybe{ blend-mode } read-only } ;
C: <blend-state> blend-state

TUPLE: mask-state
    { color sequence initial: { t t t t } read-only }
    { depth boolean initial: t read-only }
    { stencil-front integer initial: 0xFFFFFFFF read-only }
    { stencil-back integer initial: 0xFFFFFFFF read-only } ;
C: <mask-state> mask-state

VARIANT: triangle-face
    face-ccw face-cw ;
VARIANT: triangle-cull
    cull-front cull-back cull-all ;
VARIANT: triangle-mode
    triangle-points triangle-lines triangle-fill ;

TUPLE: triangle-cull-state
    { front-face triangle-face initial: face-ccw read-only }
    { cull maybe{ triangle-cull } initial: f read-only } ;
C: <triangle-cull-state> triangle-cull-state

TUPLE: triangle-state
    { front-mode triangle-mode initial: triangle-fill read-only }
    { back-mode triangle-mode initial: triangle-fill read-only }
    { antialias? boolean initial: f read-only } ;
C: <triangle-state> triangle-state

VARIANT: point-sprite-origin
    origin-upper-left origin-lower-left ;

TUPLE: point-state
    { size maybe{ float } initial: 1.0 read-only }
    { sprite-origin point-sprite-origin initial: origin-upper-left read-only }
    { fade-threshold float initial: 1.0 read-only } ;
C: <point-state> point-state

TUPLE: line-state
    { width float initial: 1.0 read-only }
    { antialias? boolean initial: f read-only } ;
C: <line-state> line-state

UNION: gpu-state
    viewport-state
    triangle-cull-state
    triangle-state
    point-state
    line-state
    scissor-state
    multisample-state
    stencil-state
    depth-range-state
    depth-state
    blend-state
    mask-state ;

<PRIVATE

: gl-triangle-face ( triangle-face -- face )
    {
        { face-ccw [ GL_CCW ] }
        { face-cw  [ GL_CW  ] }
    } case ;

: gl-triangle-face> ( triangle-face -- face )
    {
        { $ GL_CCW [ face-ccw ] }
        { $ GL_CW  [ face-cw  ] }
    } case ;

: gl-triangle-cull ( triangle-cull -- cull )
    {
        { cull-front [ GL_FRONT          ] }
        { cull-back  [ GL_BACK           ] }
        { cull-all   [ GL_FRONT_AND_BACK ] }
    } case ;

: gl-triangle-cull> ( triangle-cull -- cull )
    {
        { $ GL_FRONT          [ cull-front ] }
        { $ GL_BACK           [ cull-back  ] }
        { $ GL_FRONT_AND_BACK [ cull-all   ] }
    } case ;

: gl-triangle-mode ( triangle-mode -- mode )
    {
        { triangle-points [ GL_POINT ] }
        { triangle-lines  [ GL_LINE  ] }
        { triangle-fill   [ GL_FILL  ] }
    } case ;

: gl-triangle-mode> ( triangle-mode -- mode )
    {
        { $ GL_POINT [ triangle-points ] }
        { $ GL_LINE  [ triangle-lines  ] }
        { $ GL_FILL  [ triangle-fill   ] }
    } case ;

: gl-point-sprite-origin ( point-sprite-origin -- sprite-origin )
    {
        { origin-upper-left [ GL_UPPER_LEFT ] }
        { origin-lower-left [ GL_LOWER_LEFT ] }
    } case ;

: gl-point-sprite-origin> ( point-sprite-origin -- sprite-origin )
    {
        { $ GL_UPPER_LEFT [ origin-upper-left ] }
        { $ GL_LOWER_LEFT [ origin-lower-left ] }
    } case ;

: gl-comparison ( comparison -- comparison )
    {
        { cmp-never         [ GL_NEVER    ] }
        { cmp-always        [ GL_ALWAYS   ] }
        { cmp-less          [ GL_LESS     ] }
        { cmp-less-equal    [ GL_LEQUAL   ] }
        { cmp-equal         [ GL_EQUAL    ] }
        { cmp-greater-equal [ GL_GEQUAL   ] }
        { cmp-greater       [ GL_GREATER  ] }
        { cmp-not-equal     [ GL_NOTEQUAL ] }
    } case ;

: gl-comparison> ( comparison -- comparison )
    {
        { $ GL_NEVER    [ cmp-never         ] }
        { $ GL_ALWAYS   [ cmp-always        ] }
        { $ GL_LESS     [ cmp-less          ] }
        { $ GL_LEQUAL   [ cmp-less-equal    ] }
        { $ GL_EQUAL    [ cmp-equal         ] }
        { $ GL_GEQUAL   [ cmp-greater-equal ] }
        { $ GL_GREATER  [ cmp-greater       ] }
        { $ GL_NOTEQUAL [ cmp-not-equal     ] }
    } case ;

: gl-stencil-op ( stencil-op -- op )
    {
        { op-keep [ GL_KEEP ] }
        { op-zero [ GL_ZERO ] }
        { op-replace [ GL_REPLACE ] }
        { op-invert [ GL_INVERT ] }
        { op-inc-sat [ GL_INCR ] }
        { op-dec-sat [ GL_DECR ] }
        { op-inc-wrap [ GL_INCR_WRAP ] }
        { op-dec-wrap [ GL_DECR_WRAP ] }
    } case ;

: gl-stencil-op> ( op -- op )
    {
        { $ GL_KEEP      [ op-keep     ] }
        { $ GL_ZERO      [ op-zero     ] }
        { $ GL_REPLACE   [ op-replace  ] }
        { $ GL_INVERT    [ op-invert   ] }
        { $ GL_INCR      [ op-inc-sat  ] }
        { $ GL_DECR      [ op-dec-sat  ] }
        { $ GL_INCR_WRAP [ op-inc-wrap ] }
        { $ GL_DECR_WRAP [ op-dec-wrap ] }
    } case ;

: (set-stencil-mode) ( gl-face stencil-mode -- )
    {
        [ [ comparison>> gl-comparison ] [ value>> ] [ mask>> ] tri glStencilFuncSeparate ]
        [
            [ stencil-fail-op>> ] [ depth-fail-op>> ] [ depth-pass-op>> ] tri
            [ gl-stencil-op ] tri@ glStencilOpSeparate
        ]
    } 2cleave ;

: gl-blend-equation ( blend-equation -- blend-equation )
    {
        { eq-add              [ GL_FUNC_ADD              ] }
        { eq-subtract         [ GL_FUNC_SUBTRACT         ] }
        { eq-reverse-subtract [ GL_FUNC_REVERSE_SUBTRACT ] }
        { eq-min              [ GL_MIN                   ] }
        { eq-max              [ GL_MAX                   ] }
    } case ;

: gl-blend-equation> ( blend-equation -- blend-equation )
    {
        { $ GL_FUNC_ADD              [ eq-add              ] }
        { $ GL_FUNC_SUBTRACT         [ eq-subtract         ] }
        { $ GL_FUNC_REVERSE_SUBTRACT [ eq-reverse-subtract ] }
        { $ GL_MIN                   [ eq-min              ] }
        { $ GL_MAX                   [ eq-max              ] }
    } case ;

: gl-blend-function ( blend-function -- blend-function )
    {
        { func-zero                     [ GL_ZERO                     ] }
        { func-one                      [ GL_ONE                      ] }
        { func-source                   [ GL_SRC_COLOR                ] }
        { func-one-minus-source         [ GL_ONE_MINUS_SRC_COLOR      ] }
        { func-dest                     [ GL_DST_COLOR                ] }
        { func-one-minus-dest           [ GL_ONE_MINUS_DST_COLOR      ] }
        { func-constant                 [ GL_CONSTANT_COLOR           ] }
        { func-one-minus-constant       [ GL_ONE_MINUS_CONSTANT_COLOR ] }
        { func-source-alpha             [ GL_SRC_ALPHA                ] }
        { func-one-minus-source-alpha   [ GL_ONE_MINUS_SRC_ALPHA      ] }
        { func-dest-alpha               [ GL_DST_ALPHA                ] }
        { func-one-minus-dest-alpha     [ GL_ONE_MINUS_DST_ALPHA      ] }
        { func-constant-alpha           [ GL_CONSTANT_ALPHA           ] }
        { func-one-minus-constant-alpha [ GL_ONE_MINUS_CONSTANT_ALPHA ] }
        { func-source-alpha-saturate    [ GL_SRC_ALPHA_SATURATE       ] }
    } case ;

: gl-blend-function> ( blend-function -- blend-function )
    {
        { $ GL_ZERO                     [ func-zero                     ] }
        { $ GL_ONE                      [ func-one                      ] }
        { $ GL_SRC_COLOR                [ func-source                   ] }
        { $ GL_ONE_MINUS_SRC_COLOR      [ func-one-minus-source         ] }
        { $ GL_DST_COLOR                [ func-dest                     ] }
        { $ GL_ONE_MINUS_DST_COLOR      [ func-one-minus-dest           ] }
        { $ GL_CONSTANT_COLOR           [ func-constant                 ] }
        { $ GL_ONE_MINUS_CONSTANT_COLOR [ func-one-minus-constant       ] }
        { $ GL_SRC_ALPHA                [ func-source-alpha             ] }
        { $ GL_ONE_MINUS_SRC_ALPHA      [ func-one-minus-source-alpha   ] }
        { $ GL_DST_ALPHA                [ func-dest-alpha               ] }
        { $ GL_ONE_MINUS_DST_ALPHA      [ func-one-minus-dest-alpha     ] }
        { $ GL_CONSTANT_ALPHA           [ func-constant-alpha           ] }
        { $ GL_ONE_MINUS_CONSTANT_ALPHA [ func-one-minus-constant-alpha ] }
        { $ GL_SRC_ALPHA_SATURATE       [ func-source-alpha-saturate    ] }
    } case ;

PRIVATE>

GENERIC: set-gpu-state* ( state -- )

M: viewport-state set-gpu-state*
    rect>> [ loc>> ] [ dim>> ] bi gl-viewport ;

M: triangle-cull-state set-gpu-state*
    {
        [ front-face>> gl-triangle-face glFrontFace ]
        [ GL_CULL_FACE swap cull>> [ gl-triangle-cull glCullFace glEnable ] [ glDisable ] if* ]
    } cleave ;

M: triangle-state set-gpu-state*
    {
        [ GL_FRONT swap front-mode>> gl-triangle-mode glPolygonMode ]
        [ GL_BACK swap back-mode>> gl-triangle-mode glPolygonMode ]
        [ GL_POLYGON_SMOOTH swap antialias?>> [ glEnable ] [ glDisable ] if ]
    } cleave ;

M: point-state set-gpu-state*
    {
        [ GL_VERTEX_PROGRAM_POINT_SIZE swap size>> [ glPointSize glDisable ] [ glEnable ] if* ]
        [ GL_POINT_SPRITE_COORD_ORIGIN swap sprite-origin>> gl-point-sprite-origin glPointParameteri ]
        [ GL_POINT_FADE_THRESHOLD_SIZE swap fade-threshold>> glPointParameterf ]
    } cleave ;

M: line-state set-gpu-state*
    {
        [ width>> glLineWidth ]
        [ GL_LINE_SMOOTH swap antialias?>> [ glEnable ] [ glDisable ] if ]
    } cleave ;

M: scissor-state set-gpu-state*
    GL_SCISSOR_TEST swap rect>>
    [ [ loc>> first2 ] [ dim>> first2 ] bi glViewport glEnable ]
    [ glDisable ] if* ;

M: multisample-state set-gpu-state*
    dup multisample?>> [
        GL_MULTISAMPLE glEnable
        {
            [ GL_SAMPLE_ALPHA_TO_COVERAGE swap sample-alpha-to-coverage?>>
                [ glEnable ] [ glDisable ] if
            ]
            [ GL_SAMPLE_ALPHA_TO_ONE swap sample-alpha-to-one?>>
                [ glEnable ] [ glDisable ] if
            ]
            [ GL_SAMPLE_COVERAGE swap [ invert-sample-coverage?>> >c-bool ] [ sample-coverage>> ] bi
                [ swap glSampleCoverage glEnable ] [ drop glDisable ] if*
            ]
        } cleave
    ] [ drop GL_MULTISAMPLE glDisable ] if ;

M: stencil-state set-gpu-state*
    dup { [ front-mode>> ] [ back-mode>> ] } 1|| [
        GL_STENCIL_TEST glEnable
        [ front-mode>> GL_FRONT swap (set-stencil-mode) ]
        [ back-mode>> GL_BACK swap (set-stencil-mode) ] bi
    ] [ drop GL_STENCIL_TEST glDisable ] if ;

M: depth-range-state set-gpu-state*
    [ near>> ] [ far>> ] bi glDepthRange ;

M: depth-state set-gpu-state*
    GL_DEPTH_TEST swap comparison>> [ gl-comparison glDepthFunc glEnable ] [ glDisable ] if* ;

M: blend-state set-gpu-state*
    [ ] [ rgb-mode>> ] [ alpha-mode>> ] tri or
    [
        GL_BLEND glEnable
        [ constant-color>> [ first4 glBlendColor ] when* ]
        [
            [ rgb-mode>> ] [ alpha-mode>> ] bi {
                [ [ equation>> gl-blend-equation ] bi@ glBlendEquationSeparate ]
                [
                    [
                        [ source-function>> gl-blend-function ]
                        [ dest-function>> gl-blend-function ] bi
                    ] bi@ glBlendFuncSeparate
                ]
            } 2cleave
        ] bi
    ] [ drop GL_BLEND glDisable ] if ;

M: mask-state set-gpu-state*
    {
        [ color>> [ >c-bool ] map first4 glColorMask ]
        [ depth>> >c-bool glDepthMask ]
        [ GL_FRONT swap stencil-front>> glStencilMaskSeparate ]
        [ GL_BACK  swap stencil-back>> glStencilMaskSeparate ]
    } cleave ;

: set-gpu-state ( states -- )
    dup sequence?
    [ [ set-gpu-state* ] each ]
    [ set-gpu-state* ] if ; inline

: get-gl-bool ( enum -- value )
    0 c:uchar <ref> [ glGetBooleanv ] keep c:uchar deref c-bool> ;
: get-gl-int ( enum -- value )
    0 c:int <ref> [ glGetIntegerv ] keep c:int deref ;
: get-gl-float ( enum -- value )
    0 c:float <ref> [ glGetFloatv ] keep c:float deref ;

: get-gl-bools ( enum count -- value )
    <byte-array> [ glGetBooleanv ] keep [ c-bool> ] { } map-as ;
: get-gl-ints ( enum count -- value )
    c:int <c-array> [ glGetIntegerv ] keep ;
: get-gl-floats ( enum count -- value )
    c:float <c-array> [ glGetFloatv ] keep ;

: get-gl-rect ( enum -- value )
    4 get-gl-ints first4 [ 2array ] 2bi@ <rect> ;

: gl-enabled? ( enum -- ? )
    glIsEnabled c-bool> ;

TYPED: get-viewport-state ( -- viewport-state: viewport-state )
    GL_VIEWPORT get-gl-rect <viewport-state> ;

TYPED: get-scissor-state ( -- scissor-state: scissor-state )
    GL_SCISSOR_TEST get-gl-bool
    [ GL_SCISSOR_BOX get-gl-rect ] [ f ] if
    <scissor-state> ;

TYPED: get-multisample-state ( -- multisample-state: multisample-state )
    GL_MULTISAMPLE gl-enabled?
    GL_SAMPLE_ALPHA_TO_COVERAGE gl-enabled?
    GL_SAMPLE_ALPHA_TO_ONE gl-enabled?
    GL_SAMPLE_COVERAGE gl-enabled? [
        GL_SAMPLE_COVERAGE_VALUE get-gl-float
        GL_SAMPLE_COVERAGE_INVERT get-gl-bool
    ] [ f f ] if
    <multisample-state> ;

TYPED: get-stencil-state ( -- stencil-state: stencil-state )
    GL_STENCIL_TEST gl-enabled? [
        GL_STENCIL_REF get-gl-int
        GL_STENCIL_VALUE_MASK get-gl-int
        GL_STENCIL_FUNC get-gl-int gl-comparison>
        GL_STENCIL_FAIL get-gl-int gl-stencil-op>
        GL_STENCIL_PASS_DEPTH_FAIL get-gl-int gl-stencil-op>
        GL_STENCIL_PASS_DEPTH_PASS get-gl-int gl-stencil-op>
        <stencil-mode>

        GL_STENCIL_BACK_REF get-gl-int
        GL_STENCIL_BACK_VALUE_MASK get-gl-int
        GL_STENCIL_BACK_FUNC get-gl-int gl-comparison>
        GL_STENCIL_BACK_FAIL get-gl-int gl-stencil-op>
        GL_STENCIL_BACK_PASS_DEPTH_FAIL get-gl-int gl-stencil-op>
        GL_STENCIL_BACK_PASS_DEPTH_PASS get-gl-int gl-stencil-op>
        <stencil-mode>
    ] [ f f ] if
    <stencil-state> ;

TYPED: get-depth-range-state ( -- depth-range-state: depth-range-state )
    GL_DEPTH_RANGE 2 get-gl-floats first2 <depth-range-state> ;

TYPED: get-depth-state ( -- depth-state: depth-state )
    GL_DEPTH_TEST gl-enabled?
    [ GL_DEPTH_FUNC get-gl-int gl-comparison> ] [ f ] if
    <depth-state> ;

TYPED: get-blend-state ( -- blend-state: blend-state )
    GL_BLEND gl-enabled? [
        GL_BLEND_COLOR 4 get-gl-floats

        GL_BLEND_EQUATION_RGB get-gl-int gl-blend-equation>
        GL_BLEND_SRC_RGB get-gl-int gl-blend-function>
        GL_BLEND_DST_RGB get-gl-int gl-blend-function>
        <blend-mode>

        GL_BLEND_EQUATION_ALPHA get-gl-int gl-blend-equation>
        GL_BLEND_SRC_ALPHA get-gl-int gl-blend-function>
        GL_BLEND_DST_ALPHA get-gl-int gl-blend-function>
        <blend-mode>
    ] [ f f f ] if
    <blend-state> ;

TYPED: get-mask-state ( -- mask-state: mask-state )
    GL_COLOR_WRITEMASK 4 get-gl-bools
    GL_DEPTH_WRITEMASK get-gl-bool
    GL_STENCIL_WRITEMASK get-gl-int
    GL_STENCIL_BACK_WRITEMASK get-gl-int
    <mask-state> ;

TYPED: get-triangle-cull-state ( -- triangle-cull-state: triangle-cull-state )
    GL_FRONT_FACE get-gl-int gl-triangle-face>
    GL_CULL_FACE gl-enabled?
    [ GL_CULL_FACE_MODE get-gl-int gl-triangle-cull> ]
    [ f ] if
    <triangle-cull-state> ;

TYPED: get-triangle-state ( -- triangle-state: triangle-state )
    GL_POLYGON_MODE 2 get-gl-ints
    first2 [ gl-triangle-mode> ] bi@
    GL_POLYGON_SMOOTH gl-enabled?
    <triangle-state> ;

TYPED: get-point-state ( -- point-state: point-state )
    GL_VERTEX_PROGRAM_POINT_SIZE gl-enabled?
    [ f ] [ GL_POINT_SIZE get-gl-float ] if
    GL_POINT_SPRITE_COORD_ORIGIN get-gl-int gl-point-sprite-origin>
    GL_POINT_FADE_THRESHOLD_SIZE get-gl-float
    <point-state> ;

TYPED: get-line-state ( -- line-state: line-state )
    GL_LINE_WIDTH get-gl-float
    GL_LINE_SMOOTH gl-enabled?
    <line-state> ;
