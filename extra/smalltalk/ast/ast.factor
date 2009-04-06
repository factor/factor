! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays memoize kernel sequences accessors combinators ;
IN: smalltalk.ast

SINGLETONS: nil self super ;

TUPLE: ast-comment { string string } ;
TUPLE: ast-block { arguments array } { temporaries array } { body array } ;
TUPLE: ast-message-send receiver { selector string } { arguments array } ;
TUPLE: ast-message { selector string } { arguments array } ;
TUPLE: ast-cascade receiver { messages array } ;
TUPLE: ast-name { name string } ;
TUPLE: ast-return value ;
TUPLE: ast-assignment { name ast-name } value ;
TUPLE: ast-local-variables { names array } ;
TUPLE: ast-method { name string } { body ast-block } ;
TUPLE: ast-class { name string } { superclass string } { ivars array } { methods array } ;
TUPLE: ast-foreign { class string } { name string } ;
TUPLE: ast-sequence { temporaries array } { body array } ;

! We treat a sequence of statements like a block in a few places to
! simplify handling of top-level forms
M: ast-sequence arguments>> drop { } ;

: unclip-temporaries ( statements -- temporaries statements' )
    {
        { [ dup empty? ] [ { } ] }
        { [ dup first ast-local-variables? not ] [ { } ] }
        [ unclip names>> ]
    } cond swap ;

: <ast-block> ( arguments body -- block )
    unclip-temporaries ast-block boa ;

: <ast-sequence> ( body -- block )
    unclip-temporaries ast-sequence boa ;

! The parser parses normal message sends as cascades with one message, but
! we represent them differently in the AST to simplify generated code in
! the common case
: <ast-cascade> ( receiver messages -- ast )
    dup length 1 =
    [ first [ selector>> ] [ arguments>> ] bi ast-message-send boa ]
    [ ast-cascade boa ]
    if ;

! Methods return self by default
: <ast-method> ( class arguments body -- method )
    self suffix <ast-block> ast-method boa ;

TUPLE: symbol { name string } ;
MEMO: intern ( name -- symbol ) symbol boa ;