! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math sequences
sequences.deep sequences.extras strings unicode ;
IN: modern.slices

: >strings ( seq -- str )
    [ dup slice? [ >string ] when ] deep-map ;

: matching-delimiter ( ch -- ch' )
    H{
        { CHAR: ( CHAR: ) }
        { CHAR: [ CHAR: ] }
        { CHAR: { CHAR: } }
        { CHAR: < CHAR: > }
        { CHAR: : CHAR: ; }
    } ?at drop ;

: matching-delimiter-string ( string -- string' )
    [ matching-delimiter ] map ;

: matching-section-delimiter ( string -- string' )
    dup ":" tail? [
        rest but-last ";" ">" surround
    ] [
        rest ">" append
    ] if ;

ERROR: unexpected-end n string ;
: nth-check-eof ( n string -- nth )
    2dup ?nth [ 2nip ] [ unexpected-end ] if* ;

: peek-from ( n/f string -- ch )
    over [ ?nth ] [ 2drop f ] if ;

: previous-from ( n/f string -- ch )
    over [ [ 1 - ] dip ?nth ] [ 2drop f ] if ;

! Allow eof
: next-char-from ( n/f string -- n'/f string ch/f )
    over [
        2dup ?nth [ [ 1 + ] 2dip ] [ f ] if*
    ] [
        [ 2drop f ] [ nip ] 2bi f
    ] if ;

: prev-char-from-slice-end ( slice -- ch/f )
    [ to>> 2 - ] [ seq>> ] bi ?nth ;

: prev-char-from-slice ( slice -- ch/f )
    [ from>> 1 - ] [ seq>> ] bi ?nth ;

: next-char-from-slice ( slice -- ch/f )
    [ to>> ] [ seq>> ] bi ?nth ;

: char-before-slice ( slice -- ch/f )
    [ from>> 1 - ] [ seq>> ] bi ?nth ;

: char-after-slice ( slice -- ch/f )
    [ to>> ] [ seq>> ] bi ?nth ;

: find-from* ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt ? )
    [ find-from ] 2keep drop
    pick [ drop t ] [ length -rot nip f ] if ; inline

: skip-blank-from ( n string -- n' string )
    over [
        [ [ blank? not ] find-from* 2drop ] keep
    ] when ; inline

: skip-til-eol-from ( n string -- n' string )
    [ [ "\r\n" member? ] find-from* 2drop ] keep ; inline

! Don't include the whitespace in the slice
:: slice-til-whitespace ( n string -- n' string slice/f ch/f )
    n [
        n string [ "\s\r\n" member? ] find-from :> ( n' ch )
        n' string
        n n' string ?<slice>
        ch
    ] [
        f string f f
    ] if ; inline

:: (slice-until) ( n string quot -- n' string slice/f ch/f )
    n string quot find-from :> ( n' ch )
    n' string
    n n' string ?<slice>
    ch ; inline

: slice-until ( n string quot -- n' string slice/f )
    (slice-until) drop ; inline

:: slice-til-not-whitespace ( n string -- n' string slice/f ch/f )
    n [
        n string [ "\s\r\n" member? not ] find-from :> ( n' ch )
        n' string
        n n' string ?<slice>
        ch
    ] [
        n string f f
    ] if ; inline

: skip-whitespace ( n/f string -- n'/f string )
    slice-til-not-whitespace 2drop ;

: empty-slice-end ( seq -- slice )
    [ length dup ] [ ] bi <slice> ; inline

: empty-slice-from ( n seq -- slice )
    dupd <slice> ; inline

:: slice-til-eol ( n string -- n' string slice/f ch/f )
    n [
        n string '[ "\r\n" member? ] find-from :> ( n' ch )
        n' string
        n n' string ?<slice>
        ch
    ] [
        n string string empty-slice-end f
    ] if ; inline

:: merge-slice-til-eol-slash'' ( n string -- n' string slice/f ch/f )
    n [
        n string '[ "\r\n\\" member? ] find-from :> ( n' ch )
        n' string
        n n' string ?<slice>
        ch
    ] [
        n string string empty-slice-end f
    ] if ; inline

: merge-slice-til-whitespace ( n string slice --  n' string slice' )
    pick [
        [ slice-til-whitespace drop ] dip merge-slices
    ] when ;

: merge-slice-til-eol ( n string slice --  n' string slice' )
    [ slice-til-eol drop ] dip merge-slices ;

: slice-between ( slice1 slice2 -- slice )
    ! ensure-same-underlying
    slice-order-by-from
    [ to>> ]
    [ [ from>> 2dup < [ swap ] unless ] [ seq>> ] bi ] bi* <slice> ;

: slice-before ( slice -- slice' )
    [ drop 0 ] [ from>> ] [ seq>> ] tri <slice> ;

: (?nth) ( n/f string/f -- obj/f )
    over [ (?nth) ] [ 2drop f ] if ;

:: merge-slice-til-eol-slash' ( n string slice -- n' string slice/f ch/f )
    n string merge-slice-til-eol-slash'' :> ( n' string' slice' ch' )
    ch' CHAR: \\ = [
        n' 1 + string' (?nth) "\r\n" member? [
            n' 2 + string' slice slice' span-slices merge-slice-til-eol-slash'
        ] [
            "omg" throw
        ] if
    ] [
        n' string' slice slice' span-slices ch'
    ] if ;

! Supports \ at eol (with no space after it)
: slice-til-eol-slash ( n string -- n' string slice/f ch/f )
    2dup empty-slice-from merge-slice-til-eol-slash' ;

:: slice-til-separator-inclusive ( n string tokens -- n' string slice/f ch/f )
    n string '[ tokens member? ] find-from [ dup [ 1 + ] when ] dip  :> ( n' ch )
    n' string
    n n' string ?<slice>
    ch ; inline

: slice-til-separator-exclusive ( n string tokens -- n' string slice/f ch/f )
    slice-til-separator-inclusive dup [
        [ [ 1 - ] change-to ] dip
    ] when ;

! Takes at least one character if not whitespace
:: slice-til-either ( n string tokens -- n'/f string slice/f ch/f )
    n [
        n string '[ tokens member? ] find-from
        dup "\s\r\n" member? [
            :> ( n' ch )
            n' string
            n n' string ?<slice>
            ch
        ] [
            [ dup [ 1 + ] when ] dip :> ( n' ch )
            n' string
            n n' string ?<slice>
            ch
        ] if
    ] [
        f string f f
    ] if ; inline

ERROR: subseq-expected-but-got-eof n string expected ;

:: slice-til-string ( n string search --  n' string payload end-string )
    search string n subseq-start-from :> n'
    n' [ n string search subseq-expected-but-got-eof ] unless
    n' search length +  string
    n n' string ?<slice>
    n' dup search length + string ?<slice> ;

: modify-from ( slice n -- slice' )
    '[ from>> _ + ] [ to>> ] [ seq>> ] tri <slice> ;

: modify-to ( slice n -- slice' )
    [ [ from>> ] [ to>> ] [ seq>> ] tri ] dip
    swap [ + ] dip <slice> ;

! { CHAR: \] [ read-closing ] }
! { CHAR: \} [ read-closing ] }
! { CHAR: \) [ read-closing ] }
: read-closing ( n string tok -- n string tok )
    dup length 1 = [
        -1 modify-to [ 1 - ] 2dip
    ] unless ;

: rewind-slice ( n string slice -- n' string )
    pick [
        length swap [ - ] dip
    ] [
        [ nip ] dip [ [ length ] bi@ - ] 2keep drop
    ] if ; inline
