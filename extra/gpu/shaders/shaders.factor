! (c)2009 Joe Groff bsd license
USING: accessors arrays assocs combinators
combinators.short-circuit definitions destructors gpu
io.encodings.ascii io.files io.pathnames kernel lexer
locals math math.parser memoize multiline namespaces
opengl.gl opengl.shaders parser sequences
specialized-arrays.int splitting strings ui.gadgets.worlds
variants hashtables vectors vocabs vocabs.loader words
words.constant ;
IN: gpu.shaders

VARIANT: shader-kind
    vertex-shader fragment-shader ;

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
    { instances hashtable read-only } ;

TUPLE: shader-instance < gpu-object
    { shader shader }
    { world world } ;

TUPLE: program-instance < gpu-object
    { program program }
    { world world } ;

<PRIVATE

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

TUPLE: compile-shader-error shader log ;
TUPLE: link-program-error program log ;

: compile-shader-error ( shader instance -- * )
    [ dup ] dip [ gl-shader-info-log ] [ delete-gl-shader ] bi replace-log-line-numbers
    \ compile-shader-error boa throw ;

: link-program-error ( program instance -- * )
    [ dup ] dip [ gl-program-info-log ] [ delete-gl-program ] bi replace-log-line-numbers
    \ link-program-error boa throw ;

DEFER: <shader-instance>

MEMO: uniform-index ( program-instance uniform-name -- index )
    [ handle>> ] dip glGetUniformLocation ;
MEMO: attribute-index ( program-instance attribute-name -- index )
    [ handle>> ] dip glGetAttribLocation ;
MEMO: output-index ( program-instance output-name -- index )
    [ handle>> ] dip glGetFragDataLocation ;

<PRIVATE

: valid-handle? ( handle -- ? )
    { [ ] [ zero? not ] } 1&& ;

: compile-shader ( shader -- instance )
    [ ] [ source>> ] [ kind>> gl-shader-kind ] tri <gl-shader>
    dup gl-shader-ok?
    [ swap world get \ shader-instance boa window-resource ]
    [ compile-shader-error ] if ;

: (link-program) ( program shader-instances -- program-instance )
    [ handle>> ] map <gl-program>
    dup gl-program-ok?
    [ swap world get \ program-instance boa window-resource ]
    [ link-program-error ] if ;

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

SYNTAX: GLSL-SHADER:
    CREATE-WORD dup
    scan-word
    f
    lexer get line>>
    parse-here
    H{ } clone
    shader boa
    define-constant ;

SYNTAX: GLSL-SHADER-FILE:
    CREATE-WORD dup
    scan-word execute( -- kind )
    scan-object in-word's-path
    0
    over ascii file-contents 
    H{ } clone
    shader boa
    define-constant ;

SYNTAX: GLSL-PROGRAM:
    CREATE-WORD dup
    f
    lexer get line>>
    \ ; parse-until >array [ def>> first ] map
    H{ } clone
    program boa
    define-constant ;

M: shader-instance dispose
    [ dup valid-handle? [ delete-gl-shader ] [ drop ] if f ] change-handle
    [ world>> ] [ shader>> instances>> ] [ ] tri ?delete-at ;

M: program-instance dispose
    [ dup valid-handle? [ delete-gl-program-only ] [ drop ] if f ] change-handle
    [ world>> ] [ program>> instances>> ] [ ] tri ?delete-at
    reset-memos ;

"prettyprint" vocab [ "gpu.shaders.prettyprint" require ] when
