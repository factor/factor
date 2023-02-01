! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs
classes classes.parser classes.struct classes.tuple
classes.tuple.private combinators combinators.tuple generic
generic.parser gpu.buffers gpu.framebuffers
gpu.framebuffers.private gpu.shaders gpu.shaders.private
gpu.textures gpu.textures.private kernel lexer math
math.parser math.vectors.simd opengl.gl parser quotations
sequences slots sorting specialized-arrays strings variants words ;
FROM: math => float ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS: c:float c:int c:uchar c:ushort c:uint c:void* ;
IN: gpu.render

VARIANT: uniform-type
    bool-uniform
    bvec2-uniform
    bvec3-uniform
    bvec4-uniform
    uint-uniform
    uvec2-uniform
    uvec3-uniform
    uvec4-uniform
    int-uniform
    ivec2-uniform
    ivec3-uniform
    ivec4-uniform
    float-uniform
    vec2-uniform
    vec3-uniform
    vec4-uniform

    mat2-uniform
    mat2x3-uniform
    mat2x4-uniform

    mat3x2-uniform
    mat3-uniform
    mat3x4-uniform

    mat4x2-uniform
    mat4x3-uniform
    mat4-uniform

    texture-uniform ;

ALIAS: mat2x2-uniform mat2-uniform
ALIAS: mat3x3-uniform mat3-uniform
ALIAS: mat4x4-uniform mat4-uniform

TUPLE: uniform
    { name         string   read-only initial: "" }
    { uniform-type class    read-only initial: float-uniform }
    { dim          maybe{ integer } read-only initial: f } ;

VARIANT: index-type
    ubyte-indexes
    ushort-indexes
    uint-indexes ;

TUPLE: index-range
    { start integer read-only }
    { count integer read-only } ;

C: <index-range> index-range

TUPLE: multi-index-range
    { starts uint-array read-only }
    { counts uint-array read-only } ;

C: <multi-index-range> multi-index-range

TUPLE: index-elements
    { ptr read-only }
    { count integer read-only }
    { index-type index-type read-only } ;

C: <index-elements> index-elements

TUPLE: multi-index-elements
    { buffer maybe{ buffer } read-only }
    { ptrs   read-only }
    { counts uint-array read-only }
    { index-type index-type read-only } ;

C: <multi-index-elements> multi-index-elements

UNION: vertex-indexes
    index-range
    multi-index-range
    index-elements
    multi-index-elements
    uchar-array
    ushort-array
    uint-array ;

VARIANT: primitive-mode
    points-mode
    lines-mode
    line-strip-mode
    lines-with-adjacency-mode
    line-strip-with-adjacency-mode
    line-loop-mode
    triangles-mode
    triangle-strip-mode
    triangles-with-adjacency-mode
    triangle-strip-with-adjacency-mode
    triangle-fan-mode ;

TUPLE: uniform-tuple ;

ERROR: invalid-uniform-type uniform ;

<PRIVATE

: gl-index-type ( index-type -- gl-index-type )
    {
        { ubyte-indexes  [ GL_UNSIGNED_BYTE  ] }
        { ushort-indexes [ GL_UNSIGNED_SHORT ] }
        { uint-indexes   [ GL_UNSIGNED_INT   ] }
    } case ; inline

: gl-primitive-mode ( primitive-mode -- gl-primitive-mode )
    {
        { points-mode         [ GL_POINTS         ] }
        { lines-mode          [ GL_LINES          ] }
        { line-strip-mode     [ GL_LINE_STRIP     ] }
        { line-loop-mode      [ GL_LINE_LOOP      ] }
        { triangles-mode      [ GL_TRIANGLES      ] }
        { triangle-strip-mode [ GL_TRIANGLE_STRIP ] }
        { triangle-fan-mode   [ GL_TRIANGLE_FAN   ] }
        { lines-with-adjacency-mode          [ GL_LINES_ADJACENCY          ] }
        { line-strip-with-adjacency-mode     [ GL_LINE_STRIP_ADJACENCY     ] }
        { triangles-with-adjacency-mode      [ GL_TRIANGLES_ADJACENCY      ] }
        { triangle-strip-with-adjacency-mode [ GL_TRIANGLE_STRIP_ADJACENCY ] }
    } case ; inline

GENERIC: render-vertex-indexes ( primitive-mode vertex-indexes -- )

GENERIC#: render-vertex-indexes-instanced 1 ( primitive-mode vertex-indexes instances -- )

GENERIC: gl-array-element-type ( array -- type )
M: uchar-array  gl-array-element-type drop GL_UNSIGNED_BYTE  ; inline
M: ushort-array gl-array-element-type drop GL_UNSIGNED_SHORT ; inline
M: uint-array   gl-array-element-type drop GL_UNSIGNED_INT   ; inline

M: index-range render-vertex-indexes
    [ gl-primitive-mode ] [ [ start>> ] [ count>> ] bi ] bi* glDrawArrays ;

M: index-range render-vertex-indexes-instanced
    [ gl-primitive-mode ] [ [ start>> ] [ count>> ] bi ] [ ] tri*
    glDrawArraysInstanced ;

M: multi-index-range render-vertex-indexes
    [ gl-primitive-mode ] [ [ starts>> ] [ counts>> dup length ] bi ] bi*
    glMultiDrawArrays ;

M: index-elements render-vertex-indexes
    [ gl-primitive-mode ]
    [ [ count>> ] [ index-type>> gl-index-type ] [ ptr>> ] tri ] bi*
    index-buffer [ glDrawElements ] with-gpu-data-ptr ;

M: index-elements render-vertex-indexes-instanced
    [ gl-primitive-mode ]
    [ [ count>> ] [ index-type>> gl-index-type ] [ ptr>> ] tri ]
    [ ] tri*
    swap index-buffer [ swap glDrawElementsInstanced ] with-gpu-data-ptr ;

M: specialized-array render-vertex-indexes
    GL_ELEMENT_ARRAY_BUFFER 0 glBindBuffer
    [ gl-primitive-mode ]
    [ [ length ] [ gl-array-element-type ] [ >c-ptr ] tri ] bi*
    glDrawElements ;

M: specialized-array render-vertex-indexes-instanced
    GL_ELEMENT_ARRAY_BUFFER 0 glBindBuffer
    [ gl-primitive-mode ]
    [ [ length ] [ gl-array-element-type ] [ >c-ptr ] tri ]
    [ ] tri* glDrawElementsInstanced ;

M: multi-index-elements render-vertex-indexes
    [ gl-primitive-mode ]
    [ { [ counts>> ] [ index-type>> gl-index-type ] [ ptrs>> dup length ] [ buffer>> ] } cleave ]
    bi*
    GL_ELEMENT_ARRAY_BUFFER swap [ handle>> ] [ 0 ] if* glBindBuffer glMultiDrawElements ;

: (bind-texture-unit) ( texture texture-unit -- )
    swap [ GL_TEXTURE0 + glActiveTexture ] [ bind-texture drop ] bi* ; inline

GENERIC: (bind-uniform-textures) ( program-instance uniform-tuple -- )
GENERIC: (bind-uniforms) ( program-instance uniform-tuple -- )

M: uniform-tuple (bind-uniform-textures)
    2drop ;
M: uniform-tuple (bind-uniforms)
    2drop ;

: uniform-slot-type ( uniform -- type )
    dup dim>> [ drop sequence ] [
        uniform-type>> {
            { bool-uniform    [ boolean ] }
            { uint-uniform    [ integer ] }
            { int-uniform     [ integer ] }
            { float-uniform   [ float   ] }
            { texture-uniform [ texture ] }
            [ drop sequence ]
        } case
    ] if ;

: uniform>slot ( uniform -- slot )
    [ name>> ] [ uniform-slot-type ] bi 2array ;

: uniform-type-texture-units ( uniform-type -- units )
    dup texture-uniform = [ drop 1 ] [ "uniform-tuple-texture-units" word-prop 0 or ] if ;

: all-uniform-tuple-slots ( class -- slots )
    dup "uniform-tuple-slots" word-prop
    [ [ superclass-of all-uniform-tuple-slots ] dip append ] [ drop { } ] if* ;

DEFER: uniform-texture-accessors

: uniform-type-texture-accessors ( uniform-type -- accessors )
    texture-uniform = [ { [ ] } ] [ { } ] if ;

: uniform-slot-texture-accessor ( uniform -- accessor )
    [ name>> reader-word ] [ [ uniform-type>> ] [ dim>> ] bi uniform-texture-accessors ] bi
    dup length 1 = [ first swap prefix ] [ [ ] 2sequence ] if ;

: uniform-tuple-texture-accessors ( uniform-type -- accessors )
    all-uniform-tuple-slots [ uniform-type>> uniform-type-texture-units zero? ] reject
    [ uniform-slot-texture-accessor ] map ;

: uniform-texture-accessors ( uniform-type dim -- accessors )
    [
        dup uniform-type?
        [ uniform-type-texture-accessors ]
        [ uniform-tuple-texture-accessors ] if
    ] [
        2dup swap empty? not and [
            <iota> [
                [ swap nth ] swap prefix
                over length 1 = [ swap first append ] [ swap suffix ] if
            ] with map
        ] [ drop ] if
    ] bi* ;

: texture-accessor>cleave ( unit accessors -- unit' cleaves )
    dup last sequence?
    [ [ last [ texture-accessor>cleave ] map ] [ but-last ] bi swap suffix \ cleave suffix ]
    [ over suffix \ (bind-texture-unit) suffix [ 1 + ] dip ] if ;

: [bind-uniform-textures] ( class -- quot )
    f uniform-texture-accessors
    0 swap [ texture-accessor>cleave ] map nip
    \ nip swap \ cleave [ ] 3sequence ;

UNION: binary-data
    c-ptr specialized-array struct simd-128 ;

GENERIC: >uniform-bool-array ( sequence -- c-array )
GENERIC: >uniform-int-array ( sequence -- c-array )
GENERIC: >uniform-uint-array ( sequence -- c-array )
GENERIC: >uniform-float-array  ( sequence -- c-array )

GENERIC#: >uniform-bvec-array 1 ( sequence dim -- c-array )
GENERIC#: >uniform-ivec-array 1 ( sequence dim -- c-array )
GENERIC#: >uniform-uvec-array 1 ( sequence dim -- c-array )
GENERIC#: >uniform-vec-array  1 ( sequence dim -- c-array )

GENERIC#: >uniform-matrix 2 ( sequence cols rows -- c-array )

GENERIC#: >uniform-matrix-array 2 ( sequence cols rows -- c-array )

GENERIC: bind-uniform-bvec2 ( index sequence -- )
GENERIC: bind-uniform-bvec3 ( index sequence -- )
GENERIC: bind-uniform-bvec4 ( index sequence -- )
GENERIC: bind-uniform-ivec2 ( index sequence -- )
GENERIC: bind-uniform-ivec3 ( index sequence -- )
GENERIC: bind-uniform-ivec4 ( index sequence -- )
GENERIC: bind-uniform-uvec2 ( index sequence -- )
GENERIC: bind-uniform-uvec3 ( index sequence -- )
GENERIC: bind-uniform-uvec4 ( index sequence -- )
GENERIC: bind-uniform-vec2  ( index sequence -- )
GENERIC: bind-uniform-vec3  ( index sequence -- )
GENERIC: bind-uniform-vec4  ( index sequence -- )

M: object >uniform-bool-array [ >c-bool ] int-array{ } map-as ; inline
M: binary-data >uniform-bool-array ; inline

M: object >uniform-int-array c:int >c-array ; inline
M: binary-data >uniform-int-array ; inline

M: object >uniform-uint-array c:uint >c-array ; inline
M: binary-data >uniform-uint-array ; inline

M: object >uniform-float-array c:float >c-array ; inline
M: binary-data >uniform-float-array ; inline

M: object >uniform-bvec-array '[ _ head-slice [ >c-bool ] int-array{ } map-as ] map concat ; inline
M: binary-data >uniform-bvec-array drop ; inline

M: object >uniform-ivec-array '[ _ head ] map int-array{ } concat-as ; inline
M: binary-data >uniform-ivec-array drop ; inline

M: object >uniform-uvec-array '[ _ head ] map uint-array{ } concat-as ; inline
M: binary-data >uniform-uvec-array drop ; inline

M: object >uniform-vec-array '[ _ head ] map float-array{ } concat-as ; inline
M: binary-data >uniform-vec-array drop ; inline

M:: object >uniform-matrix ( sequence cols rows -- c-array )
    sequence flip cols head-slice
    [ rows head-slice c:float >c-array ] { } map-as concat ; inline
M: binary-data >uniform-matrix 2drop ; inline

M: object >uniform-matrix-array
    '[ _ _ >uniform-matrix ] map concat ; inline
M: binary-data >uniform-matrix-array 2drop ; inline

M: object bind-uniform-bvec2 ( index sequence -- )
    1 swap 2 head-slice [ >c-bool ] int-array{ } map-as glUniform2iv ; inline
M: binary-data bind-uniform-bvec2 ( index sequence -- )
    1 swap glUniform2iv ; inline
M: object bind-uniform-bvec3 ( index sequence -- )
    1 swap 3 head-slice [ >c-bool ] int-array{ } map-as glUniform3iv ; inline
M: binary-data bind-uniform-bvec3 ( index sequence -- )
    1 swap glUniform3iv ; inline
M: object bind-uniform-bvec4 ( index sequence -- )
    1 swap 4 head-slice [ >c-bool ] int-array{ } map-as glUniform4iv ; inline
M: binary-data bind-uniform-bvec4 ( index sequence -- )
    1 swap glUniform4iv ; inline

M: object bind-uniform-ivec2 ( index sequence -- ) first2 glUniform2i ; inline
M: binary-data bind-uniform-ivec2 ( index sequence -- ) 1 swap glUniform2iv ; inline

M: object bind-uniform-ivec3 ( index sequence -- ) first3 glUniform3i ; inline
M: binary-data bind-uniform-ivec3 ( index sequence -- ) 1 swap glUniform3iv ; inline

M: object bind-uniform-ivec4 ( index sequence -- ) first4 glUniform4i ; inline
M: binary-data bind-uniform-ivec4 ( index sequence -- ) 1 swap glUniform4iv ; inline

M: object bind-uniform-uvec2 ( index sequence -- ) first2 glUniform2ui ; inline
M: binary-data bind-uniform-uvec2 ( index sequence -- ) 1 swap glUniform2uiv ; inline

M: object bind-uniform-uvec3 ( index sequence -- ) first3 glUniform3ui ; inline
M: binary-data bind-uniform-uvec3 ( index sequence -- ) 1 swap glUniform3uiv ; inline

M: object bind-uniform-uvec4 ( index sequence -- ) first4 glUniform4ui ; inline
M: binary-data bind-uniform-uvec4 ( index sequence -- ) 1 swap glUniform4uiv ; inline

M: object bind-uniform-vec2 ( index sequence -- ) first2 glUniform2f ; inline
M: binary-data bind-uniform-vec2 ( index sequence -- ) 1 swap glUniform2fv ; inline

M: object bind-uniform-vec3 ( index sequence -- ) first3 glUniform3f ; inline
M: binary-data bind-uniform-vec3 ( index sequence -- ) 1 swap glUniform3fv ; inline

M: object bind-uniform-vec4 ( index sequence -- ) first4 glUniform4f ; inline
M: binary-data bind-uniform-vec4 ( index sequence -- ) 1 swap glUniform4fv ; inline

DEFER: [bind-uniform-tuple]

:: [bind-uniform-array] ( value>>-quot type texture-unit name dim -- texture-unit' quot )
    { name uniform-index } >quotation :> index-quot
    { index-quot value>>-quot bi* } >quotation :> pre-quot

    type H{
        { bool-uniform  { dim swap >uniform-bool-array  glUniform1iv  } }
        { int-uniform   { dim swap >uniform-int-array   glUniform1iv  } }
        { uint-uniform  { dim swap >uniform-uint-array  glUniform1uiv } }
        { float-uniform { dim swap >uniform-float-array glUniform1fv  } }

        { bvec2-uniform { dim swap 2 >uniform-bvec-array glUniform2iv  } }
        { ivec2-uniform { dim swap 2 >uniform-ivec-array glUniform2i  } }
        { uvec2-uniform { dim swap 2 >uniform-uvec-array glUniform2ui } }
        { vec2-uniform  { dim swap 2 >uniform-vec-array  glUniform2f  } }

        { bvec3-uniform { dim swap 3 >uniform-bvec-array glUniform3iv  } }
        { ivec3-uniform { dim swap 3 >uniform-ivec-array glUniform3i  } }
        { uvec3-uniform { dim swap 3 >uniform-uvec-array glUniform3ui } }
        { vec3-uniform  { dim swap 3 >uniform-vec-array  glUniform3f  } }

        { bvec4-uniform { dim swap 4 >uniform-bvec-array glUniform4iv  } }
        { ivec4-uniform { dim swap 4 >uniform-ivec-array glUniform4iv  } }
        { uvec4-uniform { dim swap 4 >uniform-uvec-array glUniform4uiv } }
        { vec4-uniform  { dim swap 4 >uniform-vec-array  glUniform4fv  } }

        { mat2-uniform   { [ dim 0 ] dip 2 2 >uniform-matrix-array glUniformMatrix2fv   } }
        { mat2x3-uniform { [ dim 0 ] dip 2 3 >uniform-matrix-array glUniformMatrix2x3fv } }
        { mat2x4-uniform { [ dim 0 ] dip 2 4 >uniform-matrix-array glUniformMatrix2x4fv } }

        { mat3x2-uniform { [ dim 0 ] dip 3 2 >uniform-matrix-array glUniformMatrix3x2fv } }
        { mat3-uniform   { [ dim 0 ] dip 3 3 >uniform-matrix-array glUniformMatrix3fv   } }
        { mat3x4-uniform { [ dim 0 ] dip 3 4 >uniform-matrix-array glUniformMatrix3x4fv } }

        { mat4x2-uniform { [ dim 0 ] dip 4 2 >uniform-matrix-array glUniformMatrix4x2fv } }
        { mat4x3-uniform { [ dim 0 ] dip 4 3 >uniform-matrix-array glUniformMatrix4x3fv } }
        { mat4-uniform   { [ dim 0 ] dip 4 4 >uniform-matrix-array glUniformMatrix4fv   } }

        { texture-uniform { drop dim dup <iota> [ texture-unit + ] int-array{ } map-as glUniform1iv } }
    } at [ uniform invalid-uniform-type ] unless* >quotation :> value-quot

    type uniform-type-texture-units dim * texture-unit +
    pre-quot value-quot append ;

:: [bind-uniform-value] ( value>>-quot type texture-unit name -- texture-unit' quot )
    { name uniform-index } >quotation :> index-quot
    { index-quot value>>-quot bi* } >quotation :> pre-quot

    type H{
        { bool-uniform  [ >c-bool glUniform1i  ] }
        { int-uniform   [ glUniform1i  ] }
        { uint-uniform  [ glUniform1ui ] }
        { float-uniform [ glUniform1f  ] }

        { bvec2-uniform [ bind-uniform-bvec2 ] }
        { ivec2-uniform [ bind-uniform-ivec2 ] }
        { uvec2-uniform [ bind-uniform-uvec2 ] }
        { vec2-uniform  [ bind-uniform-vec2  ] }

        { bvec3-uniform [ bind-uniform-bvec3 ] }
        { ivec3-uniform [ bind-uniform-ivec3 ] }
        { uvec3-uniform [ bind-uniform-uvec3 ] }
        { vec3-uniform  [ bind-uniform-vec3  ] }

        { bvec4-uniform [ bind-uniform-bvec4 ] }
        { ivec4-uniform [ bind-uniform-ivec4 ] }
        { uvec4-uniform [ bind-uniform-uvec4 ] }
        { vec4-uniform  [ bind-uniform-vec4  ] }

        { mat2-uniform   [ [ 1 0 ] dip 2 2 >uniform-matrix glUniformMatrix2fv   ] }
        { mat2x3-uniform [ [ 1 0 ] dip 2 3 >uniform-matrix glUniformMatrix2x3fv ] }
        { mat2x4-uniform [ [ 1 0 ] dip 2 4 >uniform-matrix glUniformMatrix2x4fv ] }

        { mat3x2-uniform [ [ 1 0 ] dip 3 2 >uniform-matrix glUniformMatrix3x2fv ] }
        { mat3-uniform   [ [ 1 0 ] dip 3 3 >uniform-matrix glUniformMatrix3fv   ] }
        { mat3x4-uniform [ [ 1 0 ] dip 3 4 >uniform-matrix glUniformMatrix3x4fv ] }

        { mat4x2-uniform [ [ 1 0 ] dip 4 2 >uniform-matrix glUniformMatrix4x2fv ] }
        { mat4x3-uniform [ [ 1 0 ] dip 4 3 >uniform-matrix glUniformMatrix4x3fv ] }
        { mat4-uniform   [ [ 1 0 ] dip 4 4 >uniform-matrix glUniformMatrix4fv   ] }

        { texture-uniform { drop texture-unit glUniform1i } }
    } at [ uniform invalid-uniform-type ] unless* >quotation :> value-quot

    type uniform-type-texture-units texture-unit +
    pre-quot value-quot append ;

:: [bind-uniform-struct] ( value>>-quot type texture-unit name dim -- texture-unit' quot )
    dim
    [
        <iota>
        [ [ [ swap nth ] swap prefix ] map ]
        [ [ number>string name "[" append "]." surround ] map ] bi
    ] [
        { [ ] }
        name "." append 1array
    ] if* :> ( quot-prefixes name-prefixes )
    type all-uniform-tuple-slots :> uniforms

    texture-unit quot-prefixes name-prefixes [| quot-prefix name-prefix |
        uniforms name-prefix [bind-uniform-tuple]
        quot-prefix prepend
    ] 2map :> ( texture-unit' value-cleave )

    texture-unit'
    value>>-quot { value-cleave 2cleave } append ;

:: [bind-uniform] ( texture-unit uniform prefix -- texture-unit' quot )
    prefix uniform name>> append hyphens>underscores :> name
    uniform uniform-type>> :> type
    uniform dim>> :> dim
    uniform name>> reader-word 1quotation :> value>>-quot

    value>>-quot type texture-unit name {
        { [ type uniform-type? dim     and ] [ dim [bind-uniform-array] ] }
        { [ type uniform-type? dim not and ] [ [bind-uniform-value] ] }
        [ dim [bind-uniform-struct] ]
    } cond ;

:: [bind-uniform-tuple] ( texture-unit uniforms prefix -- texture-unit' quot )
    texture-unit uniforms [ prefix [bind-uniform] ] map :> ( texture-unit' uniforms-cleave )

    texture-unit'
    { uniforms-cleave 2cleave } >quotation ;

:: [bind-uniforms] ( superclass uniforms -- quot )
    superclass "uniform-tuple-texture-units" word-prop 0 or :> first-texture-unit
    superclass \ (bind-uniforms) lookup-method :> next-method
    first-texture-unit uniforms "" [bind-uniform-tuple] nip :> bind-quot

    { 2dup next-method } bind-quot [ ] append-as ;

: define-uniform-tuple-methods ( class superclass uniforms -- )
    [
        2drop
        [ \ (bind-uniform-textures) create-method-in ]
        [ [bind-uniform-textures] ] bi define
    ] [
        [ \ (bind-uniforms) create-method-in ] 2dip
        [bind-uniforms] define
    ] 3bi ;

: parse-uniform-tuple-definition ( -- class superclass uniforms )
    scan-new-class scan-token {
        { ";" [ uniform-tuple f ] }
        { "<" [ scan-word parse-array-def [ first3 uniform boa ] map ] }
        { "{" [
            uniform-tuple
            \ } parse-until parse-array-def swap prefix
            [ first3 uniform boa ] map
        ] }
    } case ;

: (define-uniform-tuple) ( class superclass uniforms -- )
    {
        [ [ uniform>slot ] map define-tuple-class ]
        [
            [ uniform-type-texture-units ]
            [
                [ [ uniform-type>> uniform-type-texture-units ] [ dim>> 1 or ] bi * ]
                [ + ] map-reduce
            ] bi* +
            "uniform-tuple-texture-units" set-word-prop
        ]
        [ nip "uniform-tuple-slots" set-word-prop ]
        [ define-uniform-tuple-methods ]
    } 3cleave ;

: true-subclasses ( class -- seq )
    [ subclasses ] keep [ = ] curry reject ;

PRIVATE>

: define-uniform-tuple ( class superclass uniforms -- )
    (define-uniform-tuple) ; inline

SYNTAX: UNIFORM-TUPLE:
    parse-uniform-tuple-definition define-uniform-tuple ;

<PRIVATE

: bind-unnamed-output-attachments ( framebuffer attachments -- )
    [ gl-attachment ] with map
    dup length 1 =
    [ first glDrawBuffer ]
    [ [ length ] [ c:int >c-array ] bi glDrawBuffers ] if ;

: bind-named-output-attachments ( program-instance framebuffer attachments -- )
    rot '[ first _ swap output-index ] sort-by values
    bind-unnamed-output-attachments ;

: bind-output-attachments ( program-instance framebuffer attachments -- )
    dup first sequence?
    [ bind-named-output-attachments ] [ nipd bind-unnamed-output-attachments ] if ;

GENERIC: bind-transform-feedback-output ( output -- )

M: buffer bind-transform-feedback-output
    [ GL_TRANSFORM_FEEDBACK_BUFFER 0 ] dip handle>> glBindBufferBase ; inline

M: buffer-range bind-transform-feedback-output
    [ GL_TRANSFORM_FEEDBACK_BUFFER 0 ] dip
    [ handle>> ] [ offset>> ] [ size>> ] tri glBindBufferRange ; inline

M: buffer-ptr bind-transform-feedback-output
    buffer-ptr>range bind-transform-feedback-output ; inline

: gl-feedback-primitive-mode ( primitive-mode -- gl-mode )
    {
        { points-mode         [ GL_POINTS    ] }
        { lines-mode          [ GL_LINES     ] }
        { line-strip-mode     [ GL_LINES     ] }
        { line-loop-mode      [ GL_LINES     ] }
        { triangles-mode      [ GL_TRIANGLES ] }
        { triangle-strip-mode [ GL_TRIANGLES ] }
        { triangle-fan-mode   [ GL_TRIANGLES ] }
    } case ;

PRIVATE>

UNION: transform-feedback-output buffer buffer-range POSTPONE: f ;

TUPLE: render-set
    { primitive-mode primitive-mode read-only }
    { vertex-array vertex-array initial: T{ vertex-array-collection } read-only }
    { uniforms uniform-tuple read-only }
    { indexes vertex-indexes initial: T{ index-range } read-only }
    { instances maybe{ integer } initial: f read-only }
    { framebuffer maybe{ any-framebuffer } initial: system-framebuffer read-only }
    { output-attachments sequence initial: { default-attachment } read-only }
    { transform-feedback-output transform-feedback-output initial: f read-only } ;

: <render-set> ( x quot-assoc -- render-set )
    render-set swap 1make-tuple ; inline

: 2<render-set> ( x y quot-assoc -- render-set )
    render-set swap 2make-tuple ; inline

: 3<render-set> ( x y z quot-assoc -- render-set )
    render-set swap 3make-tuple ; inline

: bind-uniforms ( program-instance uniforms -- )
    [ (bind-uniform-textures) ] [ (bind-uniforms) ] 2bi ; inline

: render ( render-set -- )
    {
        [ vertex-array>> program-instance>> handle>> glUseProgram ]
        [
            [ vertex-array>> program-instance>> ] [ uniforms>> ] bi
            bind-uniforms
        ]
        [
            framebuffer>>
            [ GL_DRAW_FRAMEBUFFER swap framebuffer-handle glBindFramebuffer ]
            [ GL_DRAW_FRAMEBUFFER 0 glBindFramebuffer GL_RASTERIZER_DISCARD glEnable ] if*
        ]
        [
            [ vertex-array>> program-instance>> ]
            [ framebuffer>> ]
            [ output-attachments>> ] tri
            bind-output-attachments
        ]
        [ vertex-array>> bind-vertex-array ]
        [
            dup transform-feedback-output>> [
                [ primitive-mode>> gl-feedback-primitive-mode glBeginTransformFeedback ]
                [ bind-transform-feedback-output ] bi*
            ] [ drop ] if*
        ]

        [
            [ primitive-mode>> ] [ indexes>> ] [ instances>> ] tri
            [ render-vertex-indexes-instanced ]
            [ render-vertex-indexes ] if*
        ]

        [ transform-feedback-output>> [ glEndTransformFeedback ] when ]
        [ framebuffer>> [ GL_RASTERIZER_DISCARD glDisable ] unless ]
    } cleave ; inline
