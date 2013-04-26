! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators formatting fry grouping io
io.binary io.directories io.encodings.binary io.files kernel
math math.parser memoize pack sequences
sequences.generalizations splitting strings ;

IN: terminfo

! Reads compiled terminfo files
! typically located in /usr/share/terminfo

<PRIVATE

CONSTANT: MAGIC 0o432

ERROR: bad-magic ;

: check-magic ( n -- )
    MAGIC = [ bad-magic ] unless ;

TUPLE: terminfo-header names-bytes boolean-bytes #numbers
#strings string-bytes ;

C: <terminfo-header> terminfo-header

: read-header ( -- header )
    12 read "ssssss" unpack-le unclip check-magic
    5 firstn <terminfo-header> ;

: read-names ( header -- names )
    names-bytes>>
    [ read 1 head* "|" split [ >string ] map ]
    [ odd? [ read1 drop ] when ] bi ;

: read-booleans ( header -- booleans )
    boolean-bytes>> read [ 1 = ] { } map-as ;

: parse-shorts ( seq -- seq' )
    [ le> dup 65535 = [ drop f ] when ] map ;

: read-numbers ( header -- numbers )
    #numbers>> 2 * read 2 <groups> parse-shorts ;

: read-strings ( header -- strings )
    #strings>> 2 * read 2 <groups> parse-shorts ;

: read-string-table ( header -- string-table )
    string-bytes>> read ;

: parse-strings ( strings string-table -- strings )
    '[
        [ _ 0 2over index-from swap subseq >string ] [ f ] if*
    ] map ;

TUPLE: terminfo names booleans numbers strings ;

C: <terminfo> terminfo

: read-terminfo ( -- terminfo )
    read-header {
        [ read-names ]
        [ read-booleans ]
        [ read-numbers ]
        [ read-strings ]
        [ read-string-table ]
    } cleave parse-strings <terminfo> ;

PRIVATE>

: file>terminfo ( path -- terminfo )
    binary [ read-terminfo ] with-file-reader ;

: terminfo-path ( name -- path )
    [ first >hex ] keep "/usr/share/terminfo/%s/%s" sprintf ;

MEMO: terminfo-names ( -- names )
    "/usr/share/terminfo" [
        [ directory-files ] map concat
    ] with-directory-files ;

: max-colors ( name -- n )
    terminfo-path file>terminfo numbers>> 13 swap nth ;
