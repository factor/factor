! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes.predicate fry generic io.pathnames kernel
macros sequences vocabs words words.symbol words.constant
lexer parser help.topics help.markup namespaces sorting ;
IN: definitions.icons

GENERIC: definition-icon ( definition -- path )

: definition-icon-path ( string -- string' )
    "vocab:definitions/icons/" prepend-path ".tiff" append ;

<<

SYMBOL: icons

icons [ H{ } clone ] initialize

: define-icon ( class name -- )
    [ swap icons get set-at ]
    [
        [ \ definition-icon create-method ]
        [ '[ drop _ definition-icon-path ] ] bi*
        define
    ] 2bi ;

SYNTAX: ICON: scan-word scan define-icon ;

>>

ICON: predicate-class class-predicate-word
ICON: generic generic-word
ICON: macro macro-word
ICON: parsing-word parsing-word
ICON: primitive primitive-word
ICON: symbol symbol-word
ICON: constant constant-word
ICON: word normal-word
ICON: word-link word-help-article
ICON: link help-article
ICON: runnable-vocab runnable-vocab
ICON: vocab open-vocab
ICON: vocab-link unopen-vocab

: $definition-icons ( element -- )
    drop
    icons get >alist sort-keys
    [ [ <$link> ] [ definition-icon-path <$image> ] bi* swap ] assoc-map
    { "" "Definition class" } prefix
    $table ;