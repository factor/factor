! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data assocs byte-arrays
byte-vectors colors compiler.units definitions
editors effects effects.parser
extensions fonts fry help.vocabs hints io endian
io.encodings.utf8 io.files io.standard-paths kernel
kernel.private lexer locals macros make math math.order
math.parser namespaces parser prettyprint.sections regexp
sequences sequences.private serialize slots.private sorting
splitting.extras strings.parser system tr typed ui.commands
ui.gestures ui.text ui.tools.common ui.tools.listener ui.tools.browser
variables vocabs.loader
vocabs.parser words tools.scaffold ;

os macosx? [
    USE: cocoa.classes
    USE: core-graphics.types
    IN: cocoa

: screen-size ( -- size )
    { }
      NSScreen -> mainScreen -> frame
      size>> dup
      [ w>> prefix ] dip
      h>> suffix ;

! : auto-position ( window loc -- )
!     ! Note: if this is the initial window, the length of the windows
!     ! vector should be 1, since (open-window) calls auto-position
!     ! after register-window.
!     dup { 0 0 } =
!     [ 2drop ] [ first2 <CGPoint> -> setFrameTopLeftPoint: ] if ;

! ! setup tool dimensions to be half screen size
! : set-tool-dimensions ( -- )
!     screen-size [ 2 / ] map
!     listener-gadget swap set-tool-dim ;

! set-tool-dimensions
   listener-gadget [ get-tool-dim first screen-size second 1.5 / { } 2sequence ] keep  swap set-tool-dim
   browser-gadget [ get-tool-dim first screen-size second 1.5 / { } 2sequence ] keep  swap set-tool-dim
] when

IN: ui
FROM: ui.private => worlds ;
: (title-is=?) ( world string -- bool )
    swap title>>  = ;

: window-find-title ( string -- handle )
    worlds get
    [ second over (title-is=?) ] filter
    first first swap drop ;

: listener-get ( -- handle )
    "Listener" window-find-title ;

: focus-until ( object -- object )
    dup focus>> dup
    [ swap drop focus-until ]
    [ drop ] if ;

: gadget-font-size ( gadget -- size )
    focus-until font>> size>> ;

: gadget-window-size ( gadget -- size )
    dim>> ;

IN: listener
: listener-window-size ( -- size )
    get-listener gadget-window-size ;

: listener-font ( -- font )
    get-listener input>> font>> ;

: listener-font-size ( -- size )
    get-listener gadget-font-size ;

: listener-window-char-width ( -- size )
    get-listener dup
    gadget-window-size first ! width
    swap gadget-font-size / ;

! IN: folder
! M: folder-entry pprint* pprint-object ;

IN: syntax.terse
: 0= ( n -- ? )   0 = ;
: 0≠ ( n -- ? )   0 = not ;
: ≠ ( n n -- ? )   = not ;
: != ( n n -- ? )   = not ;
: 1+ ( n -- n )   1 + ;
: 1- ( n -- n )   1 - ;
: 2+ ( n -- n )   2 + ;
: 2- ( n -- n )   2 - ;
: 3+ ( n -- n )   3 + ;
: 3- ( n -- n )   3 - ;
: 4+ ( n -- n )   4 + ;
: 4- ( n -- n )   4 - ;
: 8+ ( n -- n )   8 + ;
: 8- ( n -- n )   8 - ;

: retain  (  x quot -- x )
    keep swap ; inline

IN: strings
FROM: splitting => split ;

M: string underlying>>  2 slot { string } declare ; inline
! : to-string ( obj -- string )
!     "%@" sprintf ;
: string>seq ( string -- seq )   " " split ;
: string-expand ( string -- seq ) [ 1string ] { } map-as ; 
: bool>string ( ? -- s )   [ "t" ] [ "f" ] if ;

!  CHAR: \" = 34
: dequote ( string -- 'string )
    34 swap [ = not ] with filter ;

: string-trim-head ( str -- str )
    R/ ^\s+/ "" re-replace ;

: string-trim-tail ( str -- str )
    reverse  string-trim-head  reverse ;

: string-squeeze-spaces ( str -- str )
    ! squezze inside spaces to one
    R/ \s+/ " " re-replace
    ;

: +colon-space ( string -- string' )  ": " append ;
: +space ( string -- string' )   " " append ; 

TR: tabs>spaces "\t" "\s" ;
    
FROM: assocs => values ;
IN: ui.gadgets.world
: front-window ( -- world )
    worlds get
    [ second focused?>> ] map-find nip
    second ; 

: window-width ( world -- width )
    dim>> first ;

IN: io.styles
: with-window ( quot -- )
    { } make , ; inline

IN: prettyprint.config
: hex ( -- )
    16 number-base set ;

: decimal ( -- )
    10 number-base set ;

: octal ( -- )
    8 number-base set ;

IN: sequences
:: unique-filter ( seq quot -- seq )
    H{ } :> buckets
    seq
    [ dup quot call( element -- key ) :> aKey
      aKey buckets at*
      [ 2drop ]
      [ drop aKey buckets set-at ]
      if
    ] each
    buckets values
    ;

! IN: variables
! SYNTAX: VARIABLE!: scan-new-word define-variable last-word variable-setter suffix! ; 
SYNTAX: VARIABLE:  scan-new-word define-variable scan-object suffix! last-word variable-setter suffix! ; 
! SYNTAX: QUOTE:  scan-new-word define-variable last-word scan-object change-global  last-word variable-setter suffix! ; 

IN: splitting
: split-nth ( seq n -- seq )
    0 swap
    [ drop 1 + 2dup = [ drop 0 t ] [ f ] if ] split*-when 2nip
    ;

: detach-nth ( seq n -- rest head )  [ tail ] 2keep  head ;

IN: prettyprint
: abullet ( -- )
    "•" write ;

: bullets ( n -- )
    <iota>  [ drop abullet ] each ;

: column-numbers ( n -- )
    <iota> [ 10 mod number>string write ] each ;

: space ( -- )
    "\s" write ;

: spaces ( n -- )
    <iota>  [ drop space ] each ;

<PRIVATE

: (max-length) ( seq -- seq columnSize )
    ! dup dup length "entries: %s: %d" printf
    0 over [ length max ] each 1+
    ;

: (printx) ( seq -- seq columnSize columns )
    (max-length) dup
    ! dup " colsize: %d" printf
    front-window window-width
    ! dup " window-width: %d" printf
    ! [ listener-font-size /i  " window-chars: %d" printf ] keep
    swap  "*" <repetition> concat  monospace-font swap  text-width  /i
    ! dup " columns: %d \n" printf
    1 max
    ;

: (assemble-word) ( len seq -- string )
    dup [ length - ] dip
    [ " " <repetition> concat ] dip
    prepend ;

: (assemble-line) ( colsize seq -- line )
    "" -rot [ (assemble-word) append ] with each ;

PRIVATE>

: printx-split ( seq -- columnSize rows )
    (printx) rot split-nth ;

: tablex ( seq -- )
    printx-split nip
    H{
        { font-name "monospace" }
        { font-size 9 }
        ! { foreground COLOR: DarkOrange4 }
        ! { table-gap { 20 2 } }
        { table-border COLOR: black }
        ! { inset { 5 5 } }
        ! { wrap-margin 100 }
    }
    [
        0 swap [ [ [ [ over pprint pprint 1 + ] with-cell output-stream get stream-flush ] each ] with-row ] each
        drop
    ] tabular-output
    ;

: printx ( seq -- )
    printx-split
    H{
        ! { font-name "Monaco" }
        ! { font-size 12 }
        { foreground COLOR: DarkRed }
        ! { table-gap { 20 2 } }
        ! { table-border COLOR: black }
        ! { inset { 5 5 } }
        ! { wrap-margin 300 }
        ! { nesting-limit f }
        ! { length-limit f }
        ! { line-limit f }
        ! { string-limit? f }
        ! { c-object-pointers? f }
    }
    [ [ [ (assemble-line) write nl ] with each
        ] with with-pprint
    ] with-style
    ;

SYMBOL: streamed-out

: streamed-out? ( -- n )
    streamed-out get
    [ streamed-out get ] 
    [ 0 streamed-out set  0 ] if
;

: printh ( string -- )
    streamed-out? over length +
    listener-window-char-width >
    [ nl 0 streamed-out set ]
    [ streamed-out? over length + streamed-out set ]
    if 
    output-stream get stream-write ;

IN: vocabs
: current-vocab-str ( -- str )
    current-vocab name>> ;

: (vwords) ( -- seq )
    current-vocab-str vocab-words
    ;

: .vwords ( seq -- )
    [ . ] unless-empty
    ;

: vwords ( -- )
    current-vocab-str words. ; 

: vwords-sorted ( -- )
    (vwords) natural-sort .vwords ;

: forget-named-vocab ( vocab-spec -- )
    [ lookup-vocab forget-vocab ] with-compilation-unit ;

: forget-vocab-words ( vocab-spec -- )
    [ lookup-vocab vocab-words [ forget-all ] when* ] with-compilation-unit ;

: reload-current-vocab ( -- )
    current-vocab name>> reload ;

IN: random
GENERIC: random-characters* ( n tuple -- byte-array )

M: object random-characters* ( n tuple -- byte-array )
    [ [ <byte-vector> ] keep 4 /mod ] dip
    [ pick '[ _ random-32* int <ref> _ push-all ] times ]
    [
        over zero?
        [ 2drop ] [ random-32* int <ref> swap head append! ] if
    ] bi-curry bi*
    [ dup 32 < [ 32 + ] when
        [ dup 127 > ] [ 32 - ]  while
    ] map
    B{ } like
    ;

HINTS: M\ object random-characters* { fixnum object } ;

TYPED: random-characters ( n: fixnum -- byte-array: byte-array )
    random-generator get random-characters* ; inline

IN: classes.struct
: detach>number ( seq n -- seq number )  detach-nth be> ;

IN: struct
: sizeof ( struct -- size )
    props>> "struct-size" swap at ;

IN: c-type
: sizeof ( ctype -- size )
    props>> "c-type" swap at size>> ;

IN: words
SYNTAX: _WORD_ last-word name>> suffix! ;

: (.here) ( name -- )  +colon-space print ;
: (here.) ( obj name -- )  [ unparse ] dip +colon-space prepend  print ;
: (here.s) ( name -- )  +colon-space print .s ;
SYNTAX: .HERE last-word name>> suffix!  \ (.here) suffix! ;
SYNTAX: HERE. last-word name>> suffix!  \ (here.) suffix! ;
SYNTAX: HERE.S last-word name>> suffix!  \ (here.s) suffix! ;
SYNTAX: HERE" last-word name>> +colon-space  ! "for the editors sake
    lexer get skip-blank parse-string append suffix!
    \ print suffix! ;

IN: serialize
: save-fstore ( obj path -- )
    utf8 <file-writer> [ serialize ] with-output-stream ;

: load-fstore ( path -- obj )
    dup file-exists? [
        utf8 <file-reader> [ deserialize ] with-input-stream
    ] [
        drop f  ! >r H{ } clone r>
    ] if
    ;

USING: strings ;
IN: math.parser
: >number ( string|number -- number )
    dup string? [ string>number ] when ;




