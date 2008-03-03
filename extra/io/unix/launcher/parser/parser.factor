! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: peg peg.parsers kernel sequences strings words
memoize ;
IN: io.unix.launcher.parser

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! 'foo bar' -- quotation
! "foo bar" -- quotation
MEMO: 'escaped-char'
    "\\" token [ drop t ] satisfy 2seq [ second ] action ;

MEMO: 'quoted-char' ( delimiter -- parser' )
    'escaped-char'
    swap [ member? not ] curry satisfy
    2choice ; inline

MEMO: 'quoted' ( delimiter -- parser )
    dup 'quoted-char' repeat0 swap dup surrounded-by ;

MEMO: 'unquoted' ( -- parser ) " '\"" 'quoted-char' repeat1 ;

MEMO: 'argument' ( -- parser )
    "\"" 'quoted'
    "'" 'quoted'
    'unquoted' 3choice
    [ >string ] action ;

PEG: tokenize-command ( command -- ast/f )
    'argument' " " token repeat1 list-of
    " " token repeat0 swap over pack
    just ;
