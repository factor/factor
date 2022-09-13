! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors code combinators combinators.smart effects
kernel locals math math.parser quotations sequences splitting
stack-checker strings vectors words ;
FROM: code => call word ;
IN: code.factor-abstraction

:: call-from-factor ( factor-word -- call )
    call new factor-word name>> >>name factor-word >>target ;

: make-tree ( nodes -- tree )
    dup [ introduce new ] [ pop ] if-empty dup
    [ quoted-node? ] [ drop 0 ] [ in-out drop length ] smart-if
    swapd [ dup make-tree ] replicate reverse nip [ add-element ] each ;

: node-from-factor ( factor-word -- node )
    { { [ dup words:word? ] [ call-from-factor ] }
      { [ dup string? ] [ text new >>name ] }
      { [ dup number? ] [ call new swap [ number>string >>name ] keep >>target ] }
      { [ dup quotation? ] [ [ node-from-factor ] map >vector make-tree t >>quoted? ] } 
    } cond ;

:: word-from-factor ( factor-word -- word )
    factor-word stack-effect
    [ in>> [ introduce new swap >>name ] map ]
    [ out>> [ return new swap >>name ] map ] bi
    factor-word def>> [ node-from-factor ] map
    swap 3append >vector make-tree
    word new swap add-element ;
