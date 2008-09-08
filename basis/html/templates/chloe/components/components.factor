! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences kernel parser fry quotations
classes.tuple
html.components
html.templates.chloe.compiler
html.templates.chloe.syntax ;
IN: html.templates.chloe.components

: singleton-component-tag ( tag class -- )
    [ "name" required-attr compile-attr ]
    [ literalize [ render ] [code-with] ]
    bi* ;

: CHLOE-SINGLETON:
    scan-word
    [ name>> ] [ '[ , singleton-component-tag ] ] bi
    define-chloe-tag ;
    parsing

: compile-component-attrs ( tag class -- )
    [ attrs>> [ drop main>> "name" = not ] assoc-filter ] dip
    [ all-slots swap '[ name>> , at compile-attr ] each ]
    [ [ boa ] [code-with] ]
    bi ;

: tuple-component-tag ( tag class -- )
    [ drop "name" required-attr compile-attr ] [ compile-component-attrs ] 2bi
    [ render ] [code] ;

: CHLOE-TUPLE:
    scan-word
    [ name>> ] [ '[ , tuple-component-tag ] ] bi
    define-chloe-tag ;
    parsing
