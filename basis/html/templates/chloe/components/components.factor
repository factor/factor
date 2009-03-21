! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences kernel parser fry quotations
classes.tuple classes.singleton
html.components
html.templates.chloe.compiler
html.templates.chloe.syntax ;
IN: html.templates.chloe.components
  
GENERIC: component-tag ( tag class -- )

M: singleton-class component-tag ( tag class -- )
    [ "name" required-attr compile-attr ]
    [ literalize [ render ] [code-with] ]
    bi* ;

: compile-component-attrs ( tag class -- )
    [ attrs>> [ drop main>> "name" = not ] assoc-filter ] dip
    [ all-slots swap '[ name>> _ at compile-attr ] each ]
    [ [ boa ] [code-with] ]
    bi ;

M: tuple-class component-tag ( tag class -- )
    [ drop "name" required-attr compile-attr ]
    [ compile-component-attrs ] 2bi
    [ render ] [code] ;

SYNTAX: COMPONENT:
    scan-word
    [ name>> ] [ '[ _ component-tag ] ] bi
    define-chloe-tag ;
