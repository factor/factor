! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: peg peg.parsers kernel sequences strings words ;
IN: io.launcher.unix.parser

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! 'foo bar' -- quotation
! "foo bar" -- quotation
: 'escaped-char' ( -- parser )
    "\\" token any-char 2seq [ second ] action ;

: 'quoted-char' ( delimiter -- parser' )
    'escaped-char'
    swap [ member? not ] curry satisfy
    2choice ; inline

: 'quoted' ( delimiter -- parser )
    dup 'quoted-char' repeat0 swap dup surrounded-by ;

: 'unquoted' ( -- parser ) " '\"" 'quoted-char' repeat1 ;

: 'argument' ( -- parser )
    "\"" 'quoted'
    "'" 'quoted'
    'unquoted' 3choice
    [ >string ] action ;

PEG: tokenize-command ( command -- ast/f )
    'argument' " " token repeat1 list-of
    " " token repeat0 tuck pack
    just ;
