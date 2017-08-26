! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit continuations fry io.encodings.utf8
io.files kernel locals make math math.order modern.paths
modern.slices namespaces sequences sequences.extras shuffle
splitting strings unicode ;
IN: modern

ERROR: string-expected-got-eof n string ;
ERROR: long-opening-mismatch tag open n string ch ;

SYMBOL: strict-upper

! (( )) [[ ]] {{ }}
MACRO:: read-double-matched ( open-ch -- quot: ( n string tag ch -- n' string seq ) )
    open-ch dup matching-delimiter {
        [ drop 2 swap <string> ]
        [ drop 1string ]
        [ nip 2 swap <string> ]
    } 2cleave :> ( openstr2 openstr1 closestr2 )
    [| n string tag! ch |
        ch {
            { CHAR: = [
                tag 1 cut-slice* drop tag! ! tag of (=( is ( here, fix it
                n string openstr1 slice-til-separator-inclusive [ -1 modify-from ] dip :> ( n' string' opening ch )
                ch open-ch = [ tag openstr2 n string ch long-opening-mismatch ] unless
                opening matching-delimiter-string :> needle

                n' string' needle slice-til-string :> ( n'' string'' payload closing )
                n'' string
                tag opening payload closing 4array
            ] }
            { open-ch [
                tag 1 cut-slice* swap tag! 1 modify-to :> opening
                n 1 + string closestr2 slice-til-string :> ( n' string' payload closing )
                n' string
                tag opening payload closing 4array
            ] }
            [ [ tag openstr2 n string ] dip long-opening-mismatch ]
        } case
     ] ;

: read-double-matched-paren ( n string tag ch -- n' string seq ) CHAR: \( read-double-matched ;
: read-double-matched-bracket ( n string tag ch -- n' string seq ) CHAR: \[ read-double-matched ;
: read-double-matched-brace ( n string tag ch -- n' string seq ) CHAR: \{ read-double-matched ;

DEFER: lex-factor
ERROR: lex-expected-but-got-eof n string expected ;
! For implementing [ { (
: lex-until ( n string tag-sequence -- n' string payload )
    3dup '[
        [
            lex-factor dup [ , ] when* [
                dup [
                    ! } gets a chance, but then also full seq { } after recursion...
                    [ _ ] dip '[ _ sequence= ] any? not
                ] [
                    drop t ! loop again?
                ] if
            ] [
                _ _ _ lex-expected-but-got-eof
            ] if*
        ] loop
    ] { } make ;

: lex-colon-until ( n string tag-sequence -- n' string payload )
    '[
        [
            lex-factor dup [ , ] when* [
                dup [
                    ! } gets a chance, but then also full seq { } after recursion...
                    [ _ ] dip '[ _ sequence= ] any? not
                ] [
                    drop t ! loop again?
                ] if
            ] [
                f ! need to error here if { } unmatched
            ] if*
        ] loop
    ] { } make ;

: split-double-dash ( seq -- seqs )
    dup [ { [ "--" sequence= ] } 1&& ] split-when
    dup length 1 > [ nip ] [ drop ] if ;

MACRO:: read-matched ( ch -- quot: ( n string tag -- n' string slice' ) )
    ch dup matching-delimiter {
        [ drop "=" swap prefix ]
        [ nip 1string ]
    } 2cleave :> ( openstreq closestr1 )  ! [= ]
    [| n string tag |
        n string tag
        2over nth-check-eof {
            { [ dup openstreq member? ] [ ch read-double-matched ] } ! (=( or ((
            { [ dup blank? ] [
                drop dup '[ _ matching-delimiter-string closestr1 2array lex-until ] dip
                swap unclip-last 3array ] } ! ( foo )
            [ drop [ slice-til-whitespace drop ] dip span-slices ]  ! (foo)
        } cond
    ] ;

: read-bracket ( n string slice -- n' string slice' ) CHAR: \[ read-matched ;
: read-brace ( n string slice -- n' string slice' ) CHAR: \{ read-matched ;
: read-paren ( n string slice -- n' string slice' ) CHAR: \( read-matched ;
: read-string-payload ( n string -- n' string )
    over [
        { CHAR: \\ CHAR: \" } slice-til-separator-inclusive {
            { f [ drop ] }
            { CHAR: \" [ drop ] }
            { CHAR: \\ [ drop next-char-from drop read-string-payload ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

:: read-string ( n string tag -- n' string seq )
    n string read-string-payload drop :> n'
    n' string
    n' [ n string string-expected-got-eof ] unless
    n n' 1 - string <slice>
    n' 1 - n' string <slice>
    tag 1 cut-slice* 4array ;

: take-comment ( n string slice -- n' string comment )
    2over ?nth CHAR: \[ = [
        [ 1 + ] 2dip 2over ?nth read-double-matched-bracket
    ] [
        [ slice-til-eol drop ] dip swap 2array
    ] if ;

: read-til-semicolon ( n string slice -- n' string semi )
    dup '[ but-last ";" append ";" 2array lex-colon-until ] dip
    swap
    ! Remove the ; from the paylaod if present
    dup ?last ";" sequence= [
        unclip-last 3array
    ] [
        2array
    ] if ;

: read-word-or-til-semicolon ( n string slice -- n' string obj )
    2over next-char-from* "\s\r\n" member? [
        read-til-semicolon
    ] [
        merge-slice-til-whitespace
    ] if ;

: terminator? ( slice -- ? )
    {
        [ ";" sequence= ]
        [ "]" sequence= ]
        [ "}" sequence= ]
        [ ")" sequence= ]
    } 1|| ;

ERROR: token-expected n string obj ;
ERROR: unexpected-terminator n string slice ;
: read-lowercase-colon ( n string slice -- n' string lowercase-colon )
    [
        lex-factor dup [ token-expected ] unless
        dup terminator? [ unexpected-terminator ] when
    ] dip swap 2array ;

: strict-upper? ( string -- ? )
    [ { [ CHAR: A CHAR: Z between? ] [ ":-" member? ] } 1|| ] all? ;

! <a <a: but not <a>
: section-open? ( string -- ? )
    {
        [ "<" head? ]
        [ length 2 >= ]
        [ rest strict-upper? ]
        [ ">" tail? not ]
    } 1&& ;

: section-close? ( string -- ? )
    {
        [ length 2 >= ]
        [ but-last strict-upper? ]
        [ ">" tail? ]
    } 1&& ;

ERROR: colon-word-must-be-all-uppercase-or-lowercase n string word ;
: read-colon ( n string slice -- n' string colon )
    
    {
        { [ dup strict-upper? ] [ strict-upper on read-til-semicolon strict-upper off ] }
        { [ dup ":" tail? ] [ dup ":" head? [ read-lowercase-colon ] unless ] } ! :foo: vs foo:
        [ ]
    } cond ;

: read-acute ( n string slice -- n' string acute )
    [ matching-section-delimiter 1array lex-until ] keep swap unclip-last 3array ;

! Words like append! and suffix! are allowed for now.
: read-exclamation ( n string slice -- n' string obj )
    dup { [ "!" sequence= ] [ "#!" sequence= ] } 1||
    [ take-comment ] [ merge-slice-til-whitespace ] if ;

ERROR: backslash-expects-whitespace slice ;
ERROR: no-backslash-payload n string slice ;
: read-backslash ( n string slice -- n' string obj )
    merge-slice-til-whitespace dup "\\" tail? [
        ! \ foo, M\ foo
        [
                skip-blank-from slice-til-whitespace drop
                dup [ no-backslash-payload ] unless
        ] dip swap 2array
    ] when ;

! If the slice is 0 width, we stopped on whitespace.
! Advance the index and read again!
: read-token-or-whitespace ( n string slice -- n' string slice )
    dup length 0 =
    [ drop [ 1 + ] dip lex-factor ] when ;

ERROR: mismatched-terminator n string slice ;
: read-terminator ( n string slice -- n' string slice ) ;

: lex-factor ( n/f string -- n'/f string literal )
    over [
        skip-whitespace "\"!:[{(<>\s\r\n" slice-til-either {
            { CHAR: \" [ read-string ] }
            { CHAR: \! [ read-exclamation ] }
            { CHAR: \: [
                merge-slice-til-whitespace
                dup strict-upper? strict-upper get and [
                    length swap [ - ] dip f
                    strict-upper off
                ] [
                    read-colon
                ] if
            ] }
            { CHAR: < [
                ! FOO: a b <BAR: ;BAR>
                ! FOO: a b <BAR BAR>
                ! FOO: a b <asdf>
                ! FOO: a b <asdf asdf>
                [ slice-til-whitespace drop ] dip span-slices

                ! if we are in a FOO: and we hit a <BAR or <BAR:
                ! then end the FOO:
                dup section-open? [
                    strict-upper get [
                        length swap [ - ] dip f strict-upper off
                    ] [
                        read-acute
                    ] if
                ] when
            ] }
            { CHAR: > [
                dup section-close? [
                    strict-upper get [
                        length swap [ - ] dip f strict-upper off
                    ] when
                ] [
                    [ slice-til-whitespace drop ] dip span-slices ! >= >> etc
                ] if
            ] }
            { CHAR: \[ [ read-bracket ] }
            { CHAR: \{ [ read-brace ] }
            { CHAR: \( [ read-paren ] }
            { CHAR: \s [ read-token-or-whitespace ] }
            { CHAR: \r [ read-token-or-whitespace ] }
            { CHAR: \n [ read-token-or-whitespace ] }
            { f [ f like ] }
        } case dup "\\" tail? [ read-backslash ] when
    ] [
        f
    ] if ; inline

: string>literals ( string -- sequence )
    [ 0 ] dip [ lex-factor ] loop>array 2nip ;

: vocab>literals ( vocab -- sequence )
    ".private" ?tail drop
    modern-source-path utf8 file-contents string>literals ;

: path>literals ( path -- sequence )
    utf8 file-contents string>literals ;

: lex-vocabs ( vocabs -- assoc )
    [ [ vocab>literals ] [ nip ] recover ] map-zip ;

: failing-vocabs ( assoc -- assoc' ) [ nip array? ] assoc-reject ;

: lex-core ( -- assoc ) core-bootstrap-vocabs lex-vocabs ;
: lex-basis ( -- assoc ) basis-vocabs lex-vocabs ;
: lex-extra ( -- assoc ) extra-vocabs lex-vocabs ;
: lex-all ( -- assoc ) lex-core lex-basis lex-extra 3append ;
