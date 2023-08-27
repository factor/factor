! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel present io math sequences assocs ranges
math.order tools.time smalltalk.selectors smalltalk.ast ;
IN: smalltalk.library

SELECTOR: print
SELECTOR: asString

M: object selector-print dup present print ;
M: object selector-asString present ;

SELECTOR: print:
SELECTOR: nextPutAll:
SELECTOR: tab
SELECTOR: nl

M: object selector-print: [ present ] dip stream-print nil ;
M: object selector-nextPutAll: selector-print: ;
M: object selector-tab "    " swap selector-print: ;
M: object selector-nl stream-nl nil ;

SELECTOR: +
SELECTOR: -
SELECTOR: *
SELECTOR: /
SELECTOR: <
SELECTOR: >
SELECTOR: <=
SELECTOR: >=
SELECTOR: =

M: object selector-+  swap +  ;
M: object selector--  swap -  ;
M: object selector-*  swap *  ;
M: object selector-/  swap /  ;
M: object selector-<  swap <  ;
M: object selector->  swap >  ;
M: object selector-<= swap <= ;
M: object selector->= swap >= ;
M: object selector-=  swap =  ;

SELECTOR: min:
SELECTOR: max:

M: object selector-min: min ;
M: object selector-max: max ;

SELECTOR: ifTrue:
SELECTOR: ifFalse:
SELECTOR: ifTrue:ifFalse:

M: object selector-ifTrue: [ call( -- result ) ] [ drop nil ] if ;
M: object selector-ifFalse: [ drop nil ] [ call( -- result ) ] if ;
M: object selector-ifTrue:ifFalse: [ drop call( -- result ) ] [ nip call( -- result ) ] if ;

SELECTOR: isNil

M: object selector-isNil nil eq? ;

SELECTOR: at:
SELECTOR: at:put:

M: sequence selector-at: nth ;
M: sequence selector-at:put: ( key value receiver -- receiver ) [ swapd set-nth ] keep ;

M: assoc selector-at: at ;
M: assoc selector-at:put: ( key value receiver -- receiver ) [ swapd set-at ] keep ;

SELECTOR: do:

M:: object selector-do: ( quot receiver -- nil )
    receiver [ quot call( elt -- result ) drop ] each nil ;

SELECTOR: to:
SELECTOR: to:do:

M: object selector-to: swap [a..b] ;
M:: object selector-to:do: ( to quot from -- nil )
    from to [a..b] [ quot call( i -- result ) drop ] each nil ;

SELECTOR: value
SELECTOR: value:
SELECTOR: value:value:
SELECTOR: value:value:value:
SELECTOR: value:value:value:value:

M: object selector-value call( -- result ) ;
M: object selector-value: call( input -- result ) ;
M: object selector-value:value: call( input input -- result ) ;
M: object selector-value:value:value: call( input input input -- result ) ;
M: object selector-value:value:value:value: call( input input input input -- result ) ;

SELECTOR: new

M: object selector-new new ;

SELECTOR: time

M: object selector-time '[ _ call( -- result ) ] time ;
