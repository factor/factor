! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.singleton classes.tuple
html.components html.templates.chloe.compiler
html.templates.chloe.syntax kernel namespaces parser quotations
sequences ;
IN: html.templates.chloe.components

: render-quot ( -- quot )
    string-context? get
    [ render-string ]
    [ render ]
    ? ;

GENERIC: component-tag ( tag class -- )

M: singleton-class component-tag
    [ "name" required-attr compile-attr ]
    [ literalize render-quot [code-with] ]
    bi* ;

: compile-component-attrs ( tag class -- )
    [ attrs>> [ drop main>> "name" = ] assoc-reject ] dip
    [ all-slots swap '[ name>> _ at compile-attr ] each ]
    [ [ boa ] [code-with] ]
    bi ;

M: tuple-class component-tag
    [ drop "name" required-attr compile-attr ]
    [ compile-component-attrs ] 2bi
    render-quot [code] ;

SYNTAX: COMPONENT:
    scan-word
    [ name>> ] [ '[ _ component-tag ] ] bi
    define-chloe-tag ;
