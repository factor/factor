! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: lazy-isequences
USING: generic kernel math sequences isequences isequences-internals errors ;


! ** An strict isequence that caches values of its delegate isequence **
!
! Creates a side effect on icache for ileft, iright, ## and $$

GENERIC: CC ( s -- cached-s )

TUPLE: icache left right size hash ;

: <i-cache> ( s -- cs )
    ! only cache sequences with size > 16
    dup ## 16 > [ f f f f <icache> tuck set-delegate ] when ; inline
    
: cached-## ( s -- n )
    dup icache-size dup f = [ drop dup delegate ## tuck swap set-icache-size ] [ nip ] if ; inline
: cached-ileft ( s -- s ) 
    dup icache-left dup f = [ drop dup delegate ileft CC tuck swap set-icache-left ] [ nip ] if ; inline
: cached-iright ( s -- s )
    dup icache-right dup f = [ drop dup delegate iright CC tuck swap set-icache-right ] [ nip ] if ; inline
: cached-$$ ( s -- hash ) 
    dup icache-hash dup f = [ drop dup delegate $$ tuck swap set-icache-hash ] [ nip ] if ; inline

M: object CC <i-cache> ;
M: integer CC ;
M: icache CC ;

M: icache @@ (@@) ;
M: icache ## cached-## ;
M: icache ileft cached-ileft ;
M: icache iright cached-iright ;
M: icache ihead (ihead) ;
M: icache itail (itail) ;
M: icache $$ ($$) ;


! **** lazy left product of an isequence ****
!
TUPLE: imuls sequence multiplier ;

G: *_ ( s m -- s*m ) 1 standard-combination ;

: <i-muls> ( seq mul -- imuls ) <imuls> CC ; foldable

: *_g++ ( s n -- s ) ## dup 0 = [ nip ] [ <i-muls> ] if ; inline

: *_g+- ( s n -- s ) -- *_ ; inline

: *_g-+ ( s n -- s ) swap -- swap *_ -- ; inline

: *_g-- ( s n -- s ) [ -- ] 2apply *_ ; inline
    

: imuls-unpack ( imuls -- m s )
    dup imuls-multiplier swap imuls-sequence ; inline

: imuls-ileft ( imuls -- imuls )
    imuls-unpack dup ## 1 =
    [ swap ileft *_ ] 
    [ ileft swap *_ ]
    if ; inline

: imuls-iright ( imuls -- imuls )
    imuls-unpack dup ## 1 =
    [ swap iright *_ ]
    [ iright swap *_ ]
    if ; inline 

: check-bounds ( s i -- s i )
	2dup swap ## < [ ] [ index-error ] if ; inline

: *_g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ *_g-- ] [ *_g+- ] if ] [ [ *_g-+ ] [ *_g++ ] if ] if ; inline

M: object *_ *_g ;

M: integer *_ ## abs * ;
M: imuls @@ ## check-bounds swap imuls-sequence dup -rot ## mod @@ ;
M: imuls ## imuls-unpack ## swap * ;
M: imuls ileft imuls-ileft ;
M: imuls iright imuls-iright ;
M: imuls ihead (ihead) ;
M: imuls itail (itail) ;
M: imuls $$ imuls-unpack [ $$ -1 shift ] 2apply quick-hash ;

! **** strict right product of an isequence ****
!
GENERIC: _* ( m s -- m*s )

: _*g++ ( s n -- s )
    swap ## dup 0 =
    [ 2drop 0 ]
    [ dup odd? [ over ] [ 0 ] if -rot -1 shift swap _*g++ dup ++ ++ ]
    if ;

: _*g+- ( s n -- s ) -- _* -- ; inline

: _*g-+ ( s n -- s ) swap -- swap _* ; inline

: _*g-- ( s n -- s ) [ -- ] 2apply _* ; inline

: _*g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ _*g-- ] [ _*g+- ] if ] [ [ _*g-+ ] [ _*g++ ] if ] if ; inline

M: object _* _*g ;
M: integer _* swap ## abs * ;


! **** lazy full product of two isequences
!
GENERIC: ** ( s1 s2 -- ms1 ms2 )

M: object ** 
    2dup [ neg? ] 2apply and [ [ -- ] 2apply ] when 2dup *_ -rot _* ;

! **** lazy reversal of an isequence
!
GENERIC: `` ( s -- rs )

TUPLE: irev sequence ;

: <i-rev> <irev> ; foldable
    
M: object `` <i-rev> ;
M: ineg `` -- `` -- ; 
M: integer `` ;
M: irev `` irev-sequence ;

M: irev @@ swap irev-sequence swap ## over ## - 1+ neg @@ ;
M: irev ## irev-sequence ## ;
M: irev ileft irev-sequence iright `` ;
M: irev iright irev-sequence ileft `` ;
M: irev ihead swap irev-sequence swap rindex itail `` ;  
M: irev itail swap irev-sequence swap rindex ihead `` ;
M: irev $$ irev-sequence neg hh ;
    
! **** lazy maximum of two isequences
!
GENERIC: || ( s1 s2 -- imax )

TUPLE: imax left right ;

: imax-unpack ( imax -- left right )
    dup imax-left swap imax-right ; inline

: nmax ( s n -- s )
    ## over ## - dup 0 <= [ drop ] [ ++ ] if ; inline

: <i-max>
    dup ## pick swap nmax -rot swap nmax <imax> CC ; inline
    
: min## ( s1 s2 -- minimum )
    [ ## ] 2apply min ;
    
: ||g++ ( s1 s2 -- imax )
    2dup [ ## ] 2apply 0 = [ 2drop ] [ 0 = [ nip ] [ <i-max> ] if ] if ; inline

: ||g-+ ( s1 s2 -- imax )
    swap -- `` swap 2dup min## -rot || swap ihead ; inline

: ||g+- ( s1 s2 -- imax )
   -- `` 2dup min## -rot || swap ihead ; inline

: ||g-- ( s1 s2 -- imax )
    [ -- `` ] 2apply 2dup min## -rot || swap ihead `` -- ; inline

: mcut-point ( imax -- i )
    imax-unpack [ ileft ## ] 2apply 2dup < [ drop ] [ nip ] if ; inline
    
: imax-ileft ( imax -- imax ) 
    dup ## 1 =
    [ drop 0 ]
    [ dup mcut-point swap imax-unpack pick ihead -rot swap ihead swap || ]
    if ; inline

: imax-iright ( imax -- imax )
    dup ## 1 =
    [ drop 0 ]
    [ dup mcut-point swap imax-unpack pick itail -rot swap itail swap || ]
    if ; inline


: ||g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ ||g-- ] [ ||g+- ] if ] [ [ ||g-+ ] [ ||g++ ] if ] if ; inline

M: object || ||g ;

! double dispatch integer/||
GENERIC: integer/|| ( s1 s2 -- v )
M: object integer/|| swap ||g ;
M: integer || swap integer/|| ;
! integer optimization
M: integer integer/|| max ;

M: imax @@ swap imax-unpack pick @@ -rot swap @@ swap ++ ;
M: imax ## imax-left ## ;
M: imax ileft imax-ileft ;
M: imax iright imax-iright ;
M: imax ihead (ihead) ;  
M: imax itail (itail) ;
M: imax $$ imax-unpack [ $$ -2 shift ] 2apply quick-hash ;
