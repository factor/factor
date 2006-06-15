IN: aim-internals
USING: kernel sequences prettyprint strings namespaces math threads vectors errors parser interpreter test io crypto arrays ;

SYMBOL: big-endian t big-endian set
SYMBOL: unscoped-stream
SYMBOL: unscoped-stack

! Examples:
! 1 2 3 4 4 >nvector .
! { 1 2 3 4 }

! { 1 2 3 4 } { >byte >short >int >long } papply .
! "\u0001\0\u0002\0\0\0\u0003\0\0\0\0\0\0\0\u0004"

! [ 1 >short  6 >long ] make-packet .
! "\0\u0001\0\0\0\0\0\0\0\u0006"

: int>ip ( n -- str )
    [ HEX: ff000000 over bitand -24 shift unparse % CHAR: . ,
    HEX: 00ff0000 over bitand -16 shift unparse % CHAR: . ,
    HEX: 0000ff00 over bitand -8 shift unparse % CHAR: . ,
    HEX: 000000ff bitand unparse % ] "" make ;


! doesn't compile
! : >nvector ( elems n -- )
    ! { } clone swap [ drop swap add ] each reverse ;

: 4vector ( elems -- )
    V{ } clone 4 [ drop swap add ] each reverse ;

! TODO: make this work for types other than ""
: papply ( seq seq -- seq )
    [ [ 2array >quotation call % ] 2each ] "" make ;

: writeln ( string -- )
    write terpri ;

! NEEDS REFACTORING, GOSH!
! Hexdump
: (print-offset) ( lineno -- )
	16 * >hex 8 CHAR: 0 pad-left write "h: " write ;

: (print-hex-digit) ( digit -- )
	>hex 2 CHAR: 0 pad-left write ;

: (print-hex-line) ( lineno string -- )
	over (print-offset)
	dup length dup 16 =
	[ [ 2dup swap nth (print-hex-digit) " " write ] repeat ] ! full line
	[ ! partial line
		[ 2dup swap nth (print-hex-digit) " " write ] repeat  
		dup length 16 swap - [ "   " write ] repeat
	] if
	dup length
	[ 2dup swap nth dup printable? [ write1 ] [ "." write drop ] if ] repeat
	terpri drop ;

: (num-full-lines) ( bytes -- )
	length 16 / floor ;

: (get-slice) ( lineno bytes -- <slice> )
	>r dup 16 * dup 16 + r> <slice> ;

: (get-last-slice) ( bytes -- <slice> )
	dup length dup 16 mod - over length rot <slice> ;

: (print-bytes) ( bytes -- )
	dup (num-full-lines) [ over (get-slice) (print-hex-line) ] repeat
	dup (num-full-lines) over (get-last-slice) dup empty? [ 3drop ] [ (print-hex-line) 2drop ] if ;
	
: (print-length) ( len -- )
    [
        "Length: " %
        dup unparse %
        ", " %
        >hex %
        "h\n" %
    ] "" make write ;

: hexdump ( str -- )
    dup length (print-length) (print-bytes) ;



: save-current-scope
    unscoped-stack get [ V{ } clone unscoped-stack set ] unless
    swap dup unscoped-stream set unscoped-stack get push ;

: set-previous-scope
    unscoped-stack get dup length 1 > [ 
        [ pop ] keep nip peek unscoped-stream set ] [
        pop drop
    ] if ;

: with-unscoped-stream ( stream quot -- )
    save-current-scope catch set-previous-scope
    [ dup [ unscoped-stream get stream-close ] when rethrow ] when ;

: close-unscoped-stream ( -- )
    unscoped-stream get stream-close ;

: >endian ( obj n -- str )
    big-endian get [ >be ] [ >le ] if ;

: endian> ( obj n -- str )
    big-endian get [ be> ] [ le> ] if ;

: (>byte) ( byte -- str )
    unit >string ;

: (>short) ( short -- str )
    2 >endian ;

: (>int) ( int -- str )
    4 >endian ;

: (>longlong) ( longlong -- str )
    8 >endian ;

: (>u128) ( u128 -- str )
    16 >endian ;

: (>cstring) ( str -- str )
    "\0" append ;

: >byte ( byte -- )
    (>byte) % ;

: >short ( short -- )
    (>short) % ;

: >int ( int -- )
    (>int) % ;

: >longlong ( longlong -- )
    (>longlong) % ;

: >u128 ( u128 -- )
    (>u128) % ;

: >cstring ( str -- )
    (>cstring) % ;


! doesn't compile
! : make-packet ( quot -- )
    ! depth >r call depth r> - [ drop append ] each ;
: make-packet
    "" make ;

: (head-short) ( str -- short )
    2 swap head endian> ;
: (head-int) ( str -- int )
    4 swap head endian> ;
: (head-longlong) ( str -- longlong )
    8 swap head endian> ;
: (head-u128) ( str -- u128 )
    16 swap head endian> ;

! 8 bits
: head-byte ( -- byte )
    1 unscoped-stream get stream-read first ;

! 16 bits
: head-short ( -- short )
    2 unscoped-stream get stream-read (head-short) ;

! 32 bits
: head-int ( -- int )
    4 unscoped-stream get stream-read (head-int) ;

! 64 bits
: head-longlong ( -- longlong )
    8 unscoped-stream get stream-read (head-longlong) ;

! 128 bits
: head-u128 ( -- u128 )
    16 unscoped-stream get stream-read (head-u128) ;

: head-string ( n -- str )
    unscoped-stream get stream-read >string ;

! : head-cstring ( -- str )
	! head-byte ] 

: head-contents ( -- str )
    unscoped-stream get contents ;

