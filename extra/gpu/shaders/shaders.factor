! (c)2009 Joe Groff bsd license
USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs byte-arrays classes.mixin classes.parser
classes.singleton classes.struct combinators combinators.short-circuit
definitions destructors generic.parser gpu gpu.buffers hashtables
images io.encodings.ascii io.files io.pathnames kernel lexer
literals locals math math.parser memoize multiline namespaces
opengl opengl.gl opengl.shaders parser quotations sequences
specialized-arrays splitting strings tr ui.gadgets.worlds
variants vectors vocabs vocabs.loader vocabs.parser words
words.constant half-floats ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: void*
IN: gpu.shaders

VARIANT: shader-kind
    vertex-shader fragment-shader ;

UNION: ?string string POSTPONE: f ;

ERROR: too-many-feedback-formats-error formats ;
ERROR: invalid-link-feedback-format-error format ;
ERROR: inaccurate-feedback-attribute-error attribute ;

TUPLE: vertex-attribute
    { name            ?string        read-only initial: f }
    { component-type  component-type read-only initial: float-components }
    { dim             integer        read-only initial: 4 }
    { normalize?      boolean        read-only initial: f } ;

MIXIN: vertex-format
UNION: ?vertex-format vertex-format POSTPONE: f ;

TUPLE: shader
    { name word read-only initial: t }
    { kind shader-kind read-only }
    { filename read-only }
    { line integer read-only }
    { source string }
    { instances hashtable read-only } ;

TUPLE: program
    { name word read-only initial: t }
    { filename read-only }
    { line integer read-only }
    { shaders array read-only }
    { feedback-format ?vertex-format read-only }
    { instances hashtable read-only } ;

TUPLE: shader-instance < gpu-object
    { shader shader }
    { world world } ;

TUPLE: program-instance < gpu-object
    { program program }
    { world world } ;

GENERIC: vertex-format-size ( format -- size )

MEMO: uniform-index ( program-instance uniform-name -- index )
    [ handle>> ] dip glGetUniformLocation ;
MEMO: attribute-index ( program-instance attribute-name -- index )
    [ handle>> ] dip glGetAttribLocation ;
MEMO: output-index ( program-instance output-name -- index )
    [ handle>> ] dip glGetFragDataLocation ;

<PRIVATE

TR: hyphens>underscores "-" "_" ;

: gl-vertex-type ( component-type -- gl-type )
    {
        { ubyte-components          [ GL_UNSIGNED_BYTE  ] }
        { ushort-components         [ GL_UNSIGNED_SHORT ] }
        { uint-components           [ GL_UNSIGNED_INT   ] }
        { half-components           [ GL_HALF_FLOAT     ] }
        { float-components          [ GL_FLOAT          ] }
        { byte-integer-components   [ GL_BYTE           ] }
        { short-integer-components  [ GL_SHORT          ] }
        { int-integer-components    [ GL_INT            ] }
        { ubyte-integer-components  [ GL_UNSIGNED_BYTE  ] }
        { ushort-integer-components [ GL_UNSIGNED_SHORT ] }
        { uint-integer-components   [ GL_UNSIGNED_INT   ] }
    } case ;

: vertex-type-size ( component-type -- size ) 
    {
        { ubyte-components          [ 1 ] }
        { ushort-components         [ 2 ] }
        { uint-components           [ 4 ] }
        { half-components           [ 2 ] }
        { float-components          [ 4 ] }
        { byte-integer-components   [ 1 ] }
        { short-integer-components  [ 2 ] }
        { int-integer-components    [ 4 ] }
        { ubyte-integer-components  [ 1 ] }
        { ushort-integer-components [ 2 ] }
        { uint-integer-components   [ 4 ] }
    } case ;

: vertex-attribute-size ( vertex-attribute -- size )
    [ component-type>> vertex-type-size ] [ dim>> ] bi * ;

: vertex-attributes-size ( vertex-attributes -- size )
    [ vertex-attribute-size ] [ + ] map-reduce ;

: feedback-type= ( component-type dim gl-type -- ? )
    [ 2array ] dip {
        { $ GL_FLOAT             [ { float-components 1 } ] }
        { $ GL_FLOAT_VEC2        [ { float-components 2 } ] }
        { $ GL_FLOAT_VEC3        [ { float-components 3 } ] }
        { $ GL_FLOAT_VEC4        [ { float-components 4 } ] }
        { $ GL_INT               [ { int-integer-components 1 } ] }
        { $ GL_INT_VEC2          [ { int-integer-components 2 } ] }
        { $ GL_INT_VEC3          [ { int-integer-components 3 } ] }
        { $ GL_INT_VEC4          [ { int-integer-components 4 } ] }
        { $ GL_UNSIGNED_INT      [ { uint-integer-components 1 } ] }
        { $ GL_UNSIGNED_INT_VEC2 [ { uint-integer-components 2 } ] }
        { $ GL_UNSIGNED_INT_VEC3 [ { uint-integer-components 3 } ] }
        { $ GL_UNSIGNED_INT_VEC4 [ { uint-integer-components 4 } ] }
    } case = ;

:: assert-feedback-attribute ( size gl-type name vertex-attribute -- )
    {
        [ vertex-attribute name>> name = ] 
        [ size 1 = ]
        [ gl-type vertex-attribute [ component-type>> ] [ dim>> ] bi feedback-type= ]
    } 0&& [ vertex-attribute inaccurate-feedback-attribute-error ] unless ;

:: [bind-vertex-attribute] ( stride offset vertex-attribute -- stride offset' quot )
    vertex-attribute name>> hyphens>underscores :> name
    vertex-attribute component-type>>           :> type
    type gl-vertex-type                         :> gl-type
    vertex-attribute dim>>                      :> dim
    vertex-attribute normalize?>> >c-bool       :> normalize?
    vertex-attribute vertex-attribute-size      :> size

    stride offset size +
    {
        { [ name not ] [ [ 2drop ] ] }
        {
            [ type unnormalized-integer-components? ]
            [
                {
                    name attribute-index [ glEnableVertexAttribArray ] keep
                    dim gl-type stride offset
                } >quotation :> dip-block
                
                { dip-block dip <displaced-alien> glVertexAttribIPointer } >quotation
            ]
        }
        [
            {
                name attribute-index [ glEnableVertexAttribArray ] keep
                dim gl-type normalize? stride offset
            } >quotation :> dip-block

            { dip-block dip <displaced-alien> glVertexAttribPointer } >quotation
        ]
    } cond ;

:: [bind-vertex-format] ( vertex-attributes -- quot )
    vertex-attributes vertex-attributes-size :> stride
    stride 0 vertex-attributes [ [bind-vertex-attribute] ] { } map-as 2nip :> attributes-cleave
    { attributes-cleave 2cleave } >quotation :> with-block

    { drop vertex-buffer with-block with-buffer-ptr } >quotation ; 

:: [link-feedback-format] ( vertex-attributes -- quot )
    vertex-attributes [ name>> not ] any?
    [ [ nip invalid-link-feedback-format-error ] ] [
        vertex-attributes
        [ name>> ascii malloc-string ]
        void*-array{ } map-as :> varying-names
        vertex-attributes length :> varying-count
        { drop varying-count varying-names GL_INTERLEAVED_ATTRIBS glTransformFeedbackVaryings }
        >quotation
    ] if ;

:: [verify-feedback-attribute] ( vertex-attribute index -- quot )
    vertex-attribute name>> :> name
    name length 1 + :> name-buffer-length
    {
        index name-buffer-length dup
        [ f 0 <int> 0 <int> ] dip <byte-array>
        [ glGetTransformFeedbackVarying ] 3keep
        ascii alien>string
        vertex-attribute assert-feedback-attribute    
    } >quotation ;

:: [verify-feedback-format] ( vertex-attributes -- quot )
    vertex-attributes [ [verify-feedback-attribute] ] map-index :> verify-cleave
    { drop verify-cleave cleave } >quotation ;

GENERIC: bind-vertex-format ( program-instance buffer-ptr format -- )

GENERIC: link-feedback-format ( program-handle format -- )

M: f link-feedback-format
    2drop ;

GENERIC: (verify-feedback-format) ( program-instance format -- )

M: f (verify-feedback-format)
    2drop ;

: verify-feedback-format ( program-instance -- )
    dup program>> feedback-format>> (verify-feedback-format) ;

: define-vertex-format-methods ( class vertex-attributes -- )
    {
        [
            [ \ bind-vertex-format create-method-in ] dip
            [bind-vertex-format] define
        ] [
            [ \ link-feedback-format create-method-in ] dip
            [link-feedback-format] define
        ] [
            [ \ (verify-feedback-format) create-method-in ] dip
            [verify-feedback-format] define
        ] [
            [ \ vertex-format-size create-method-in ] dip
            [ \ drop ] dip vertex-attributes-size [ ] 2sequence define
        ]
    } 2cleave ;

: component-type>c-type ( component-type -- c-type )
    {
        { ubyte-components [ c:uchar ] }
        { ushort-components [ c:ushort ] }
        { uint-components [ c:uint ] }
        { half-components [ half ] }
        { float-components [ c:float ] }
        { byte-integer-components [ c:char ] }
        { ubyte-integer-components [ c:uchar ] }
        { short-integer-components [ c:short ] }
        { ushort-integer-components [ c:ushort ] }
        { int-integer-components [ c:int ] }
        { uint-integer-components [ c:uint ] }
    } case ;

: c-array-dim ( type dim -- type' )
    dup 1 = [ drop ] [ 2array ] if ;

SYMBOL: padding-no
padding-no [ 0 ] initialize

: padding-name ( -- name )
    "padding-"
    padding-no get number>string append
    "(" ")" surround
    padding-no inc ;

: vertex-attribute>struct-slot ( vertex-attribute -- struct-slot-spec )
    [ name>> [ padding-name ] unless* ]
    [ [ component-type>> component-type>c-type ] [ dim>> c-array-dim ] bi ] bi
    { } <struct-slot-spec> ;

: shader-filename ( shader/program -- filename )
    dup filename>> [ nip ] [ name>> where first ] if* file-name ;

: numbered-log-line? ( log-line-components -- ? )
    {
        [ length 4 >= ]
        [ third string>number ]
    } 1&& ;

: replace-log-line-number ( object log-line -- log-line' )
    ":" split dup numbered-log-line? [
        {
            [ nip first ]
            [ drop shader-filename " " prepend ]
            [ [ line>> ] [ third string>number ] bi* + number>string ]
            [ nip 3 tail ]
        } 2cleave [ 3array ] dip append
    ] [ nip ] if ":" join ;

: replace-log-line-numbers ( object log -- log' )
    "\n" split [ empty? not ] filter
    [ replace-log-line-number ] with map
    "\n" join ;

: gl-shader-kind ( shader-kind -- shader-kind )
    {
        { vertex-shader [ GL_VERTEX_SHADER ] }
        { fragment-shader [ GL_FRAGMENT_SHADER ] }
    } case ;

PRIVATE>

: define-vertex-format ( class vertex-attributes -- )
    [
        [
            [ define-singleton-class ]
            [ vertex-format add-mixin-instance ]
            [ ] tri
        ] [ define-vertex-format-methods ] bi*
    ]
    [ "vertex-format-attributes" set-word-prop ] 2bi ;

SYNTAX: VERTEX-FORMAT:
    CREATE-CLASS parse-definition
    [ first4 vertex-attribute boa ] map
    define-vertex-format ;

: define-vertex-struct ( class vertex-format -- )
    "vertex-format-attributes" word-prop [ vertex-attribute>struct-slot ] map
    define-struct-class ;

SYNTAX: VERTEX-STRUCT:
    CREATE-CLASS scan-word define-vertex-struct ;

TUPLE: vertex-array < gpu-object
    { program-instance program-instance read-only }
    { vertex-buffers sequence read-only } ;

M: vertex-array dispose
    [ [ delete-vertex-array ] when* f ] change-handle drop ;

: <vertex-array> ( program-instance vertex-formats -- vertex-array )
    gen-vertex-array
    [ glBindVertexArray [ first2 bind-vertex-format ] with each ]
    [ -rot [ first buffer>> ] map vertex-array boa ] 3bi
    window-resource ;

: buffer>vertex-array ( vertex-buffer program-instance format -- vertex-array )
    [ swap ] dip
    [ 0 <buffer-ptr> ] dip 2array 1array <vertex-array> ; inline

: vertex-array-buffer ( vertex-array -- vertex-buffer )
    vertex-buffers>> first ;

TUPLE: compile-shader-error shader log ;
TUPLE: link-program-error program log ;

: compile-shader-error ( shader instance -- * )
    [ dup ] dip [ gl-shader-info-log ] [ delete-gl-shader ] bi replace-log-line-numbers
    \ compile-shader-error boa throw ;

: link-program-error ( program instance -- * )
    [ dup ] dip [ gl-program-info-log ] [ delete-gl-program ] bi replace-log-line-numbers
    \ link-program-error boa throw ;

DEFER: <shader-instance>

<PRIVATE

: valid-handle? ( handle -- ? )
    { [ ] [ zero? not ] } 1&& ;

: compile-shader ( shader -- instance )
    [ ] [ source>> ] [ kind>> gl-shader-kind ] tri <gl-shader>
    dup gl-shader-ok?
    [ swap world get \ shader-instance boa window-resource ]
    [ compile-shader-error ] if ;

: (link-program) ( program shader-instances -- program-instance )
    [ [ handle>> ] map ] curry
    [ feedback-format>> [ link-feedback-format ] curry ] bi (gl-program)
    dup gl-program-ok?  [
        [ swap world get \ program-instance boa |dispose dup verify-feedback-format ]
        with-destructors window-resource
    ] [ link-program-error ] if ;

: link-program ( program -- program-instance )
    dup shaders>> [ <shader-instance> ] map (link-program) ;

: in-word's-path ( word kind filename -- word kind filename' )
    [ over ] dip [ where first parent-directory ] dip append-path ;

: become-shader-instance ( shader-instance new-shader-instance -- )
    handle>> [ swap delete-gl-shader ] curry change-handle drop ;

: refresh-shader-source ( shader -- )
    dup filename>>
    [ ascii file-contents >>source drop ]
    [ drop ] if* ;

: become-program-instance ( program-instance new-program-instance -- )
    handle>> [ swap delete-gl-program-only ] curry change-handle drop ;

: reset-memos ( -- )
    \ uniform-index reset-memoized
    \ attribute-index reset-memoized
    \ output-index reset-memoized ;

: ?delete-at ( key assoc value -- )
    2over at = [ delete-at ] [ 2drop ] if ;

: find-shader-instance ( shader -- instance )
    world get over instances>> at*
    [ nip ] [ drop compile-shader ] if ;

: find-program-instance ( program -- instance )
    world get over instances>> at*
    [ nip ] [ drop link-program ] if ;

: shaders-and-feedback-format ( words -- shaders feedback-format )
    [ vertex-format? ] partition swap
    [ [ def>> first ] map ] [
        dup length 1 <=
        [ [ f ] [ first ] if-empty ]
        [ too-many-feedback-formats-error ] if
    ] bi* ;

PRIVATE>

:: refresh-program ( program -- )
    program shaders>> [ refresh-shader-source ] each
    program instances>> [| world old-instance |
        old-instance valid-handle? [
            world [
                [
                    program shaders>> [ compile-shader |dispose ] map :> new-shader-instances
                    program new-shader-instances (link-program) |dispose :> new-program-instance

                    old-instance new-program-instance become-program-instance
                    new-shader-instances [| new-shader-instance |
                        world new-shader-instance shader>> instances>> at
                            new-shader-instance become-shader-instance
                    ] each
                ] with-destructors
            ] with-gl-context
        ] when
    ] assoc-each
    reset-memos ;

: <shader-instance> ( shader -- instance )
    [ find-shader-instance dup world get ] keep instances>> set-at ;

: <program-instance> ( program -- instance )
    [ find-program-instance dup world get ] keep instances>> set-at ;

<PRIVATE

: old-instances ( name -- instances )
    dup constant? [
        execute( -- s/p ) dup { [ shader? ] [ program? ] } 1||
        [ instances>> ] [ drop H{ } clone ] if
    ] [ drop H{ } clone ] if ;

PRIVATE>

SYNTAX: GLSL-SHADER:
    CREATE dup
    dup old-instances [
        scan-word
        f
        lexer get line>>
        parse-here
    ] dip
    shader boa
    over reset-generic
    define-constant ;

SYNTAX: GLSL-SHADER-FILE:
    CREATE dup
    dup old-instances [
        scan-word execute( -- kind )
        scan-object in-word's-path
        0
        over ascii file-contents 
    ] dip
    shader boa
    over reset-generic
    define-constant ;

SYNTAX: GLSL-PROGRAM:
    CREATE dup
    dup old-instances [
        f
        lexer get line>>
        \ ; parse-until >array shaders-and-feedback-format
    ] dip
    program boa
    over reset-generic
    define-constant ;

M: shader-instance dispose
    [ dup valid-handle? [ delete-gl-shader ] [ drop ] if f ] change-handle
    [ world>> ] [ shader>> instances>> ] [ ] tri ?delete-at ;

M: program-instance dispose
    [ dup valid-handle? [ delete-gl-program-only ] [ drop ] if f ] change-handle
    [ world>> ] [ program>> instances>> ] [ ] tri ?delete-at
    reset-memos ;

"prettyprint" vocab [ "gpu.shaders.prettyprint" require ] when
