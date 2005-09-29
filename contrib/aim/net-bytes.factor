IN: aim
USING: kernel sequences lists stdio prettyprint strings namespaces math unparser threads vectors errors parser interpreter test io crypto ;

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



! doesn't compile
! : >nvector ( elems n -- )
    ! { } clone swap [ drop swap add ] each reverse ;

: 4vector ( elems -- )
    { } clone 4 [ drop swap add ] each reverse ;

! TODO: make this work for types other than ""
: papply ( seq seq -- seq )
    [ [ 2list call % ] 2each ] "" make ;

: writeln ( string -- )
    write terpri ;

! wrote this months and months ago..
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
    unscoped-stack get [ { } clone unscoped-stack set ] unless
    swap dup unscoped-stream set unscoped-stack get push ;

: set-previous-scope
    ! unscoped-stream get contents 
    ! [
        ! "UNREAD BYTES" writeln
        ! hexdump
    ! ] when
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

: >byte ( byte -- str )
    unit >string ;

: >short ( short -- str )
    2 >endian ;

: >int ( int -- str )
    4 >endian ;

: >long ( long -- str )
    8 >endian ;

: >cstring ( str -- str )
    "\0" append ;

! doesn't compile
: make-packet ( quot -- )
    depth >r call depth r> - [ drop append ] each ;

: (head-short) ( str -- short )
    2 swap head endian> ;
: (head-int) ( str -- int )
    4 swap head endian> ;
: (head-long) ( str -- long )
    8 swap head endian> ;


: head-byte ( -- byte )
    1 unscoped-stream get stream-read first ;

: head-short ( -- short )
    2 unscoped-stream get stream-read (head-short) ;

: head-int ( -- int )
    4 unscoped-stream get stream-read (head-int) ;

: head-long ( -- long )
    8 unscoped-stream get stream-read (head-long) ;

: head-string ( n -- str )
    unscoped-stream get stream-read >string ;


