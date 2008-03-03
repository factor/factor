! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.launcher.parser
USING: peg peg.parsers kernel sequences strings qualified
words ;
QUALIFIED: compiler.units

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! 'foo bar' -- quotation
! "foo bar" -- quotation
: 'escaped-char'
    "\\" token [ drop t ] satisfy 2seq [ second ] action ;

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

: 'arguments' ( -- parser )
    'argument' " " token repeat1 list-of
    " " token repeat0 swap over pack
    just ;

DEFER: argument-parser

[
    \ argument-parser
    'arguments' compile
    define
] compiler.units:with-compilation-unit

: tokenize-command ( command -- arguments )
    argument-parser
    dup [ parse-result-ast ] [ "Parse failed" throw ] if ;
