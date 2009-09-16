! (c)2009 Joe Groff bsd license
USING: accessors alien alien.c-types arrays
assocs classes classes.mixin classes.parser classes.singleton
classes.tuple classes.tuple.private combinators combinators.tuple destructors fry
generic generic.parser gpu gpu.buffers gpu.framebuffers
gpu.framebuffers.private gpu.shaders gpu.shaders.private gpu.state
gpu.textures gpu.textures.private half-floats images kernel
lexer locals math math.order math.parser namespaces opengl
opengl.gl parser quotations sequences slots sorting
specialized-arrays strings ui.gadgets.worlds variants
vocabs.parser words ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: void*
IN: gpu.render

UNION: ?integer integer POSTPONE: f ;

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
    { dim          ?integer read-only initial: f } ;

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

UNION: ?buffer buffer POSTPONE: f ;

TUPLE: multi-index-elements
    { buffer ?buffer read-only }
    { ptrs   read-only }
    { counts uint-array read-only }
    { index-type index-type read-only } ;

C: <multi-index-elements> multi-index-elements

UNION: vertex-indexes
    index-range
    multi-index-range
    index-elements
    multi-index-elements ;

VARIANT: primitive-mode
    points-mode
    lines-mode
    line-strip-mode
    line-loop-mode
    triangles-mode
    triangle-strip-mode
    triangle-fan-mode ;

TUPLE: uniform-tuple ;

ERROR: invalid-uniform-type uniform ;

<PRIVATE

: gl-index-type ( index-type -- gl-index-type )
    {
        { ubyte-indexes  [ GL_UNSIGNED_BYTE  ] }
        { ushort-indexes [ GL_UNSIGNED_SHORT ] }
        { uint-indexes   [ GL_UNSIGNED_INT   ] }
    } case ;

: gl-primitive-mode ( primitive-mode -- gl-primitive-mode ) 
    {
        { points-mode         [ GL_POINTS         ] }
        { lines-mode          [ GL_LINES          ] }
        { line-strip-mode     [ GL_LINE_STRIP     ] }
        { line-loop-mode      [ GL_LINE_LOOP      ] }
        { triangles-mode      [ GL_TRIANGLES      ] }
        { triangle-strip-mode [ GL_TRIANGLE_STRIP ] }
        { triangle-fan-mode   [ GL_TRIANGLE_FAN   ] }
    } case ;

GENERIC: render-vertex-indexes ( primitive-mode vertex-indexes -- )

GENERIC# render-vertex-indexes-instanced 1 ( primitive-mode vertex-indexes instances -- )

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

M: multi-index-elements render-vertex-indexes
    [ gl-primitive-mode ]
    [ { [ counts>> ] [ index-type>> gl-index-type ] [ ptrs>> dup length ] [ buffer>> ] } cleave ]
    bi*
    GL_ELEMENT_ARRAY_BUFFER swap [ handle>> ] [ 0 ] if* glBindBuffer glMultiDrawElements ;

: (bind-texture-unit) ( texture texture-unit -- )
    swap [ GL_TEXTURE0 + glActiveTexture ] [ bind-texture drop ] bi* ; inline

GENERIC: bind-uniform-textures ( program-instance uniform-tuple -- )
GENERIC: bind-uniforms ( program-instance uniform-tuple -- )

M: uniform-tuple bind-uniform-textures
    2drop ;
M: uniform-tuple bind-uniforms
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
    [ swap superclass all-uniform-tuple-slots prepend ] [ drop { } ] if* ;

DEFER: uniform-texture-accessors

: uniform-type-texture-accessors ( uniform-type -- accessors )
    texture-uniform = [ { [ ] } ] [ { } ] if ;

: uniform-slot-texture-accessor ( uniform -- accessor )
    [ name>> reader-word ] [ [ uniform-type>> ] [ dim>> ] bi uniform-texture-accessors ] bi
    dup length 1 = [ first swap prefix ] [ [ ] 2sequence ] if ;

: uniform-tuple-texture-accessors ( uniform-type -- accessors )
    all-uniform-tuple-slots [ uniform-type>> uniform-type-texture-units zero? not ] filter
    [ uniform-slot-texture-accessor ] map ;

: uniform-texture-accessors ( uniform-type dim -- accessors )
    [
        dup uniform-type?
        [ uniform-type-texture-accessors ]
        [ uniform-tuple-texture-accessors ] if
    ] [
        2dup swap empty? not and [
            iota [
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

DEFER: [bind-uniform-tuple]

:: [bind-uniform-array] ( value>>-quot type texture-unit name dim -- texture-unit' quot )
    { name uniform-index } >quotation :> index-quot
    { index-quot value>>-quot bi* } >quotation :> pre-quot

    type H{
        { bool-uniform  { dim swap [ >c-bool ] int-array{ } map-as glUniform1iv  } }
        { int-uniform   { dim swap >int-array   glUniform1iv  } }
        { uint-uniform  { dim swap >uint-array  glUniform1uiv } }
        { float-uniform { dim swap >float-array glUniform1fv  } }

        { bvec2-uniform { dim swap [ [ >c-bool ] map ] map int-array{ } concat-as glUniform2iv  } }
        { ivec2-uniform { dim swap int-array{ }   concat-as glUniform2i  } }
        { uvec2-uniform { dim swap uint-array{ }  concat-as glUniform2ui } }
        { vec2-uniform  { dim swap float-array{ } concat-as glUniform2f  } }

        { bvec3-uniform { dim swap [ [ >c-bool ] map ] map int-array{ } concat-as glUniform3iv  } }
        { ivec3-uniform { dim swap int-array{ }   concat-as glUniform3i  } }
        { uvec3-uniform { dim swap uint-array{ }  concat-as glUniform3ui } }
        { vec3-uniform  { dim swap float-array{ } concat-as glUniform3f  } }

        { bvec4-uniform { dim swap [ [ >c-bool ] map ] map int-array{ } concat-as glUniform4iv  } }
        { ivec4-uniform { dim swap int-array{ }   concat-as glUniform4iv  } }
        { uvec4-uniform { dim swap uint-array{ }  concat-as glUniform4uiv } }
        { vec4-uniform  { dim swap float-array{ } concat-as glUniform4fv  } }

        { mat2-uniform   { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix2fv   } }
        { mat2x3-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix2x3fv } }
        { mat2x4-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix2x4fv } }
                                                                 
        { mat3x2-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix3x2fv } }
        { mat3-uniform   { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix3fv   } }
        { mat3x4-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix3x4fv } }
                                                                  
        { mat4x2-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix4x2fv } }
        { mat4x3-uniform { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix4x3fv } }
        { mat4-uniform   { [ dim 1 ] dip float-array{ } concat-as concat glUniformMatrix4fv   } }

        { texture-uniform { drop dim dup iota [ texture-unit + ] int-array{ } map-as glUniform1iv } }
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

        { bvec2-uniform [ [ >c-bool ] map first2 glUniform2i  ] }
        { ivec2-uniform [ first2 glUniform2i  ] }
        { uvec2-uniform [ first2 glUniform2ui ] }
        { vec2-uniform  [ first2 glUniform2f  ] }

        { bvec3-uniform [ [ >c-bool ] map first3 glUniform3i  ] }
        { ivec3-uniform [ first3 glUniform3i  ] }
        { uvec3-uniform [ first3 glUniform3ui ] }
        { vec3-uniform  [ first3 glUniform3f  ] }

        { bvec4-uniform [ [ >c-bool ] map first4 glUniform4i  ] }
        { ivec4-uniform [ first4 glUniform4i  ] }
        { uvec4-uniform [ first4 glUniform4ui ] }
        { vec4-uniform  [ first4 glUniform4f  ] }

        { mat2-uniform   [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix2fv   ] }
        { mat2x3-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix2x3fv ] }
        { mat2x4-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix2x4fv ] }

        { mat3x2-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix3x2fv ] }
        { mat3-uniform   [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix3fv   ] }
        { mat3x4-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix3x4fv ] }

        { mat4x2-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix4x2fv ] }
        { mat4x3-uniform [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix4x3fv ] }
        { mat4-uniform   [ [ 1 1 ] dip float-array{ } concat-as glUniformMatrix4fv   ] }

        { texture-uniform { drop texture-unit glUniform1i } }
    } at [ uniform invalid-uniform-type ] unless* >quotation :> value-quot

    type uniform-type-texture-units texture-unit +
    pre-quot value-quot append ;

:: [bind-uniform-struct] ( value>>-quot type texture-unit name dim -- texture-unit' quot )
    dim
    [
        iota
        [ [ [ swap nth ] swap prefix ] map ]
        [ [ number>string name "[" append "]." surround ] map ] bi
    ] [
        { [ ] }
        name "." append 1array
    ] if* :> name-prefixes :> quot-prefixes
    type all-uniform-tuple-slots :> uniforms

    texture-unit quot-prefixes name-prefixes [| quot-prefix name-prefix |
        uniforms name-prefix [bind-uniform-tuple]
        quot-prefix prepend
    ] 2map :> value-cleave :> texture-unit'

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
    texture-unit uniforms [ prefix [bind-uniform] ] map :> uniforms-cleave :> texture-unit'

    texture-unit'
    { uniforms-cleave 2cleave } >quotation ;

:: [bind-uniforms] ( superclass uniforms -- quot )
    superclass "uniform-tuple-texture-units" word-prop 0 or :> first-texture-unit
    superclass \ bind-uniforms method :> next-method
    first-texture-unit uniforms "" [bind-uniform-tuple] nip :> bind-quot

    { 2dup next-method } bind-quot [ ] append-as ;

: define-uniform-tuple-methods ( class superclass uniforms -- )
    [
        2drop
        [ \ bind-uniform-textures create-method-in ]
        [ [bind-uniform-textures] ] bi define
    ] [
        [ \ bind-uniforms create-method-in ] 2dip
        [bind-uniforms] define
    ] 3bi ;

: parse-uniform-tuple-definition ( -- class superclass uniforms )
    CREATE-CLASS scan {
        { ";" [ uniform-tuple f ] }
        { "<" [ scan-word parse-definition [ first3 uniform boa ] map ] }
        { "{" [
            uniform-tuple
            \ } parse-until parse-definition swap prefix
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
    [ subclasses ] keep [ = not ] curry filter ;

PRIVATE>

: define-uniform-tuple ( class superclass uniforms -- )
    (define-uniform-tuple) ; inline

SYNTAX: UNIFORM-TUPLE:
    parse-uniform-tuple-definition define-uniform-tuple ;

<PRIVATE 

: bind-vertex-array ( vertex-array -- )
    handle>> glBindVertexArray ;

: bind-unnamed-output-attachments ( framebuffer attachments -- )
    [ gl-attachment ] with map
    dup length 1 =
    [ first glDrawBuffer ]
    [ [ length ] [ >int-array ] bi glDrawBuffers ] if ;

: bind-named-output-attachments ( program-instance framebuffer attachments -- )
    rot '[ first _ swap output-index ] sort-with [ second ] map
    bind-unnamed-output-attachments ;

: bind-output-attachments ( program-instance framebuffer attachments -- )
    dup first sequence?
    [ bind-named-output-attachments ] [ [ drop ] 2dip bind-unnamed-output-attachments ] if ;

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

UNION: ?any-framebuffer any-framebuffer POSTPONE: f ;
UNION: transform-feedback-output buffer buffer-range POSTPONE: f ;

TUPLE: render-set
    { primitive-mode primitive-mode read-only }
    { vertex-array vertex-array read-only }
    { uniforms uniform-tuple read-only }
    { indexes vertex-indexes initial: T{ index-range } read-only } 
    { instances ?integer initial: f read-only }
    { framebuffer ?any-framebuffer initial: system-framebuffer read-only }
    { output-attachments sequence initial: { default-attachment } read-only }
    { transform-feedback-output transform-feedback-output initial: f read-only } ;

: <render-set> ( x quot-assoc -- render-set )
    render-set swap make-tuple ; inline

: 2<render-set> ( x y quot-assoc -- render-set )
    render-set swap 2make-tuple ; inline

: 3<render-set> ( x y z quot-assoc -- render-set )
    render-set swap 3make-tuple ; inline

: render ( render-set -- )
    {
        [ vertex-array>> program-instance>> handle>> glUseProgram ]
        [
            [ vertex-array>> program-instance>> ] [ uniforms>> ] bi
            [ bind-uniform-textures ] [ bind-uniforms ] 2bi
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

