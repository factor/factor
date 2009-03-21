! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes.predicate fry generic io.pathnames kernel
macros sequences vocabs words words.symbol words.constant
lexer parser help.topics ;
IN: definitions.icons

GENERIC: definition-icon ( definition -- path )

<PRIVATE

: definition-icon-path ( string -- string' )
    "resource:basis/definitions/icons/" prepend-path ".tiff" append ;

<<

SYNTAX: ICON:
    scan-word \ definition-icon create-method
    scan '[ drop _ definition-icon-path ]
    define ;

>>

ICON: predicate-class class-predicate-word
ICON: generic generic-word
ICON: macro macro-word
ICON: parsing-word parsing-word
ICON: primitive primitive-word
ICON: symbol symbol-word
ICON: constant constant-word
ICON: word normal-word
ICON: vocab-link unopen-vocab
ICON: word-link word-help-article
ICON: link help-article

PRIVATE>

M: vocab definition-icon
    vocab-main "runnable-vocab" "open-vocab" ? definition-icon-path ;
    