! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.


IN: isequences.base
USING: generic kernel math math.functions sequences
isequences.interface shuffle ;        

: index-error ( -- * )
    "index out of bounds" throw ; foldable

: traversal-error ( -- * )
    "traversal error" throw ; foldable

: to-sequence ( s -- s )
    dup i-length 0 <
    [ -- to-sequence reverse ]
    [ dup [ swap i-at ] swap add* swap i-length swap map ]
    if ; inline

: neg? ( s -- ? ) i-length 0 < ; foldable
    
: is-atom? ( seq -- ? )
    dup 0 i-at eq? ;

: twice ( n -- n )
    dup + ; inline

: 2size ( s1 s2 -- s1 s2 size1 size2 )
    2dup [ i-length ] 2apply ; inline

: rindex ( s n -- s n )
    swap dup i-length rot - ; inline

: left-right ( s -- left right )
    [ ileft ] keep iright ; inline

: (i-at) ( s i -- v )
    i-length swap dup ileft dup i-length roll 2dup <=
    [ swap - rot iright swap ]
    [ nip ]
    if i-at nip ; inline

: (ihead2) ( s i -- h )
    swap dup ileft dup i-length roll 2dup =
    [ 2drop nip ]
    [ 2dup < [ swap - rot iright swap ihead ++ ] [ nip ihead nip ] if ]
    if ; inline
    
: (ihead) ( s i -- h ) 
    dup pick i-length = [ drop ] [ (ihead2) ] if ; inline
    
: (itail3) ( s i -- h )
    swap left-right swap dup i-length roll 2dup =
    [ 3drop ]
    [ 2dup < [ swap - nip itail ] [ nip itail swap ++ ] if ]
    if ; inline

: (itail2) ( s sl i -- t )
    tuck = [ 2drop 0 ] [ (itail3) ] if ; inline

: (itail) ( s i -- t )
    over i-length dup >r 1 = 
    [ r> drop 1 = [ drop 0 ] when ] [ r> swap (itail2) ] if ;


: PRIME1 ( -- prime1 ) HEX: 58ea12c9 ; foldable
: PRIME2 ( -- prime2 ) HEX: 79af7bc3 ; foldable
    
: hh ( fixnum-h -- fixnum-h )
    PRIME1 * PRIME2 + >fixnum ; inline

: quick-hash ( fixnum-h1 fixnum-h2 -- fixnum-h )
    [ hh ] 2apply bitxor hh ; inline

: ($$) ( s -- hash )
    left-right [ $$ ] 2apply quick-hash ; inline

: (ig1) ( s1 s2 -- s )
    >r left-right 2size <
    [ dup >r ileft ipair r> iright r> ++ ipair ]
    [ r> ++ ipair ] if ; inline

: (ig2) ( s1 s2 -- s )
    left-right 2size >
    [ >r dup >r ileft ++ r> iright r> ipair ipair ]
    [ >r ++ r> ipair ] if ; inline

: (ig3) ( s1 s2 size1 size2 -- s )
    2dup twice >=
    [ 2drop (ig1) ]
    [ swap twice >= [ (ig2) ] [ ipair ] if ] if ; inline

: ++g++ ( s1 s2 -- s )
    dup i-length dup zero? 
    [ 2drop ]
    [ pick i-length dup zero? [ 2drop nip ] [ swap (ig3) ] if ] if ; inline 

: ++g+- ( s1 s2 -- s )
    2size + dup 0 <
    [ neg swap -- swap rindex itail -- nip ]
    [ nip ihead ]
    if ; inline

: ++g-+ ( s1 s2 -- s )
    2size + dup 0 <
    [ nip swap -- swap neg ihead -- ]
    [ rindex itail nip ]
    if ; inline

: ++g-- ( s1 s2 -- s )
    -- swap -- swap ++ -- ; inline

: ++g ( s1 s2 -- s )
    2dup [ neg? ] 2apply
    [ [ ++g-- ] [ ++g+- ] if ] [ [ ++g-+ ] [ ++g++ ] if ] if ;


! #### lazy negative isequence ####
!
TUPLE: ineg sequence ;

M: ineg -- ineg-sequence ;
M: ineg i-length ineg-sequence i-length neg ;
M: ineg i-at i-length dup 0 <= [ neg swap -- swap i-at ] [ index-error ] if ;
M: ineg ileft -- iright -- ;
M: ineg iright -- ileft -- ;
M: ineg ihead [ -- ] 2apply ihead -- ;
M: ineg itail [ -- ] 2apply itail -- ;
M: ineg $$ ineg-sequence $$ neg ;

TUPLE: irev sequence ;

: <i-rev> 
    dup i-length 1 > [ <irev> ] when ; inline

M: irev i-at swap irev-sequence swap i-length over i-length - 1+ neg i-at ;
M: irev i-length irev-sequence i-length ;
M: irev ileft irev-sequence iright `` ;
M: irev iright irev-sequence ileft `` ;
M: irev ihead >r irev-sequence r> rindex itail `` ;  
M: irev itail >r irev-sequence r> rindex ihead `` ;
M: irev $$ irev-sequence neg hh ;

M: irev descending? irev-sequence ascending? ;
M: irev ascending? irev-sequence descending? ;

M: object `` <i-rev> ;
M: ineg `` -- `` -- ; 
M: integer `` ;
M: irev `` irev-sequence ;

! #### composite isequence (size-balanced binary tree) ####
!
TUPLE: ibranch left right size ;

: <isequence> ( s1 s2 -- s )
    2size + <ibranch> ; inline

M: ibranch i-length ibranch-size ;
M: ibranch i-at (i-at) ;
M: ibranch iright ibranch-right ;
M: ibranch ileft ibranch-left ;
M: ibranch ihead (ihead) ;
M: ibranch itail (itail) ;
M: ibranch $$ ($$) ;


! #### object isequence ####
!
GENERIC: object/++ ( s1 s2 -- s )
GENERIC: object/ipair ( s1 s2 -- s )

M: object object/++ swap ++g ;
M: object object/ipair swap <isequence> ;
M: object ++ swap object/++ ;
M: object ipair swap object/ipair ;

M: object i-length drop 1 ;
M: object -- <ineg> ;
M: object i-at i-length zero? [ index-error ] unless ;
M: object ileft drop 0 ;
M: object iright drop 0 ;
M: object ihead dup zero? [ 2drop 0 ] [ 1 = [ index-error ] unless ] if ;
M: object itail dup zero? [ drop ] [ 1 = [ drop 0 ] [ index-error ] if ] if ;


! #### single element isequence ####
!
TUPLE: ileaf value ;

: <i> ( v -- s ) <ileaf> ; inline

M: ileaf i-at i-length zero? [ ileaf-value ] [ index-error ] if ;
M: ileaf $$ 0 i-at $$ ;


! #### integer isequence ####
!

GENERIC: integer/++ ( s1 s2 -- v )
M: object integer/++ object/++ ;
M: integer ++ swap integer/++ ;

GENERIC: integer/ipair ( s1 s2 -- s )
M: object integer/ipair swap <isequence> ;
M: integer ipair swap integer/ipair ;

M: integer integer/++ + ;
M: integer integer/ipair + ;

M: integer i-length ;
M: integer -- neg ;
M: integer i-at i-length dup 0 >= [ > [ 0 ] [ index-error ] if ] [ index-error ] if ;
M: integer ileft
    dup zero? [ traversal-error ] [ 2/ ] if ;
M: integer iright
    dup zero? [ traversal-error ] [ 1+ 2/ ] if ;
M: integer ihead swap drop ;
M: integer itail - ;
M: integer $$ >fixnum ;


! #### negative integers ####
!
PREDICATE: integer ninteger 0 < ;

M: ninteger i-at i-length dup 0 <= [ < [ 0 ] [ index-error ] if ] [ index-error ] if ;


! #### sequence -> isequence ####
!

: chk-index dup zero? [ traversal-error ] [ 2/ ] if ; inline

M: sequence i-length length ;
M: sequence i-at i-length swap nth ;
M: sequence ileft dup length chk-index head ;
M: sequence iright dup length chk-index tail ;
M: sequence ihead head ;
M: sequence itail tail ;
M: sequence $$ [ $$ ] map unclip [ quick-hash ] reduce ;


! #### (natural) compare/ordering ####

DEFER: (i-eq?)

: (i-eq4?) ( s1 s2 -- ? )
   2dup [ is-atom? ] 2apply
   [ [ = ] [ 2drop f ] if ]
   [ [ 2drop f ] [ [ 0 i-at ] 2apply (i-eq?) ] if ] if ;

: (i-eq3?) ( s1 s2 -- ? )
    dup ileft pick over i-length tuck ihead rot (i-eq?)
    [ itail swap iright swap (i-eq?) ]
    [ 3drop f ]
    if ;
 
: (i-eq2?) ( s1 s2 sl -- ? )
    dup zero? [ 3drop 0 ]
    [ 1 = [ (i-eq4?) ] [ (i-eq3?) ] if ]
    if ; inline

: (i-eq?) ( s1 s2 -- ? )
    2dup eq? [ 2drop t ]
    [ 2dup [ i-length ] 2apply tuck = [ (i-eq2?) ] [ 3drop f ] if ]
    if ; inline

: (i-cmp5) ( s1 s2 -- i )
    dup ileft pick over i-length tuck ihead rot i-cmp dup zero?
    [ drop itail swap iright swap i-cmp ]
    [ -roll 3drop ] if ; inline

: (i-cmp4) ( s1 s2 s -- i )
    dup zero? [ 3drop 0 ]
    [ 1 = [ [ 0 i-at ] 2apply i-cmp ] [ (i-cmp5) ] if ]
    if ; inline 

: (i-cmp3) ( s1 s2 ls1 ls2 -- i )
    2dup = [ drop (i-cmp4) ]
    [ min dup >r ihead r> (i-cmp4) dup zero? [ drop -1 ] when ]
    if ; inline

: (i-cmp2) ( s1 s2 ls1 ls2 -- i )
     2dup > [ swap 2swap swap 2swap (i-cmp2) neg ] [ (i-cmp3) ] if ; inline
    
: cmp-g++ ( s1 s2 -- i )
      2dup (i-eq?) [ 2drop 0 ]
      [ 2dup [ i-length ] 2apply (i-cmp2) ] if ; inline

: cmp-g-- ( s1 s2 -- i )
    [ -- ] 2apply swap cmp-g++ ; inline
    
: cmp-g+- ( s1 s2 -- i ) 2drop 1 ; inline

: cmp-g-+ ( s1 s2 -- i ) 2drop -1 ; inline

: cmp-gg ( s1 s2 -- i )
  2dup [ neg? ] 2apply [ [ cmp-g-- ] [ cmp-g+- ] if ]
  [ [ cmp-g-+ ] [ cmp-g++ ] if ] if ;


GENERIC: object/i-cmp ( s2 s1 -- s )
M: object object/i-cmp swap cmp-gg ;
M: object i-cmp swap object/i-cmp ;

: ifirst ( s1 -- v )
    dup i-length 1 = [ 0 i-at ] [ ileft ifirst ] if ; inline

: ilast ( s1 -- v )
    dup i-length 1 = [ 0 i-at ] [ iright ilast ] if ; inline

: (ascending2?) ( s1 s2 -- ? )
    ifirst swap ilast i-cmp 0 >= ;

: (ascending?) ( s -- ? )
    dup i-length 1 <=
    [ drop t ]
    [ left-right 2dup [ ascending? ] both? [ (ascending2?) ] [ 2drop f ] if ]
    if ;

: (descending2?) ( s1 s2 -- ? )
    ifirst swap ilast i-cmp 0 <= ;

: (descending?) ( s -- ? )
    dup i-length 1 <=
    [ drop t ]
    [ left-right 2dup [ descending? ] both? [ (descending2?) ] [ 2drop f ] if ]
    if ;

M: object ascending? (ascending?) ;
M: object descending? (descending?) ;
M: integer ascending? drop t ;
M: integer descending? drop t ;


! **** dual-sided isequences ****
!

TUPLE: iturned sequence ;
TUPLE: iright-sided value ;
TUPLE: idual-sided left right ;

M: iturned i-length iturned-sequence i-length ;
M: iturned i-at >r iturned-sequence r> i-at :v: ;
M: iturned ileft iturned-sequence ileft <iturned> ;
M: iturned iright iturned-sequence iright <iturned> ;
M: iturned ihead >r iturned-sequence r> ihead <iturned> ;
M: iturned itail >r iturned-sequence r> itail <iturned> ;
M: iturned $$ iturned-sequence dup -- [ $$ ] 2apply quick-hash ;

: <i-right-sided> ( v -- lv )
    dup i-length zero? [ drop 0 ] [ <iright-sided> ] if ; inline

: <i-dual-sided> ( v1 v2 -- dv )
    2dup [ i-length ] 2apply zero?
    [ zero? [ 2drop 0 ] [ drop ] if ]
    [ zero? [ nip <i-right-sided> ] [ <idual-sided> ] if ]
    if ; 

: i-cmp-left-right ( s1 s2 -- i )
    2dup [ left-side ] 2apply i-cmp dup zero?
    [ drop [ right-side ] 2apply i-cmp ]
    [ -rot 2drop ]
    if ; inline
    
: ::g ( s -- s ) 
    dup i-length 0 < [ -- <iturned> -- ] [ <iturned> ] if ; inline

M: object :: ::g ;
M: iturned :: iturned-sequence ;
M: integer :: ;

GENERIC: iright-sided/i-cmp ( s1 s2 -- i )
GENERIC: idual-sided/i-cmp ( s1 s2 -- i )

M: object iright-sided/i-cmp swap i-cmp-left-right ;
M: object idual-sided/i-cmp swap i-cmp-left-right ;
M: iright-sided object/i-cmp swap i-cmp-left-right ;
M: idual-sided object/i-cmp swap i-cmp-left-right ;
M: iright-sided i-cmp swap iright-sided/i-cmp ;
M: idual-sided i-cmp swap idual-sided/i-cmp ;


M: object left-side ;
M: object right-side drop 0 ;
M: iright-sided left-side drop 0 ;
M: iright-sided right-side iright-sided-value ;
M: idual-sided left-side idual-sided-left ;
M: idual-sided right-side idual-sided-right ;
M: object :v: <i-right-sided> ;
M: idual-sided :v: dup idual-sided-right swap idual-sided-left <i-dual-sided> ;
M: iright-sided :v: iright-sided-value ;

: dual++ ( v2 v1 -- v ) swap 0 <i-dual-sided> ++ ; inline

M: iright-sided object/++ iright-sided-value swap <i-dual-sided> ;
M: idual-sided object/++ dual++ ;
M: iright-sided integer/++ iright-sided-value swap <i-dual-sided> ;
M: idual-sided integer/++ dual++ ;

GENERIC: iright-sided/++ ( s1 s2 -- s )
GENERIC: idual-sided/++ ( s1 s2 -- s )

M: iright-sided idual-sided/++
    swap dup idual-sided-left swap idual-sided-right
    rot iright-sided-value ++ <i-dual-sided> ;

M: iright-sided iright-sided/++
    swap [ iright-sided-value ] 2apply ++ <i-right-sided> ;

M: idual-sided iright-sided/++
    dup idual-sided-left swap idual-sided-right
    rot iright-sided-value swap ++ <i-dual-sided> ;
    
M: idual-sided idual-sided/++
        swap 2dup [ idual-sided-left ] 2apply ++
        >r [ idual-sided-right ] 2apply ++ r> <i-dual-sided> ;

M: iright-sided ++ swap iright-sided/++ ;
M: idual-sided ++ swap idual-sided/++ ;

M: object iright-sided/++
    >r iright-sided-value r> swap <i-dual-sided> ;
M: object idual-sided/++
    >r dup idual-sided-left swap idual-sided-right r> ++ <i-dual-sided> ;


! **** lazy left product of an isequence ****
!

TUPLE: imul sequence multiplier ;

: <i-muls> ( seq mul -- imul ) <imul> ; foldable

: *_g++ ( s n -- s ) i-length dup zero? [ nip ] [ <i-muls> ] if ; inline

: *_g+- ( s n -- s ) -- *_ ; inline

: *_g-+ ( s n -- s ) swap -- swap *_ -- ; inline

: *_g-- ( s n -- s ) [ -- ] 2apply *_ ; inline
    

: imul-unpack ( imul -- m s )
    dup imul-multiplier swap imul-sequence ; inline

: imul-ileft ( imul -- imul )
    imul-unpack dup i-length 1 =
    [ swap ileft *_ ] 
    [ ileft swap *_ ]
    if ; inline

: imul-iright ( imul -- imul )
    imul-unpack dup i-length 1 =
    [ swap iright *_ ]
    [ iright swap *_ ]
    if ; inline 
    
: check-bounds ( s i -- s i )
    2dup swap i-length >= [ index-error ] when ; inline

: imul-i-at ( imul i -- v  )
    i-length check-bounds swap dup imul-multiplier swap imul-sequence
    -rot /i i-at ; inline

: *_g ( s n -- s )
    2dup [ neg? ] 2apply [ [ *_g-- ] [ *_g+- ] if ]
    [ [ *_g-+ ] [ *_g++ ] if ] if ; inline

M: object *_ *_g ;

M: integer *_ i-length abs * ;
M: imul i-at imul-i-at ;
M: imul i-length imul-unpack i-length swap * ;
M: imul ileft imul-ileft ;
M: imul iright imul-iright ;
M: imul ihead (ihead) ;
M: imul itail (itail) ;
M: imul $$ imul-unpack [ $$ 2/ ] 2apply quick-hash ;

M: imul ascending? imul-sequence ascending? ;
M: imul descending? imul-sequence descending? ;
    

! **** sort, union, intersect and diff ****
!

DEFER: (ifind2)

: (ifind3) ( s1 v s e -- i )
    2dup >r >r + 2/ pick swap i-at over i-cmp 0 <
    [ r> r> swap over + 1+ 2/ swap (ifind2) ]
    [ r> r> over + 2/ (ifind2) ]
    if ; inline

: (ifind2) ( s1 v s e -- i )
    2dup = [ -roll 3drop ] [ (ifind3) ] if ; inline

: ifind ( s1 v -- i )
    over i-length 0 swap (ifind2) ; inline

: icontains? ( s1 v -- ? )
    2dup ifind pick i-length dupd <
    [ rot swap i-at i-cmp zero? ] [ 3drop f ] if ; inline

: icut ( s v -- s2 s2 )
     dupd ifind 2dup ihead -rot itail ; inline

DEFER: (union)
    
: (union6) ( s1 s2 -- s )
    2dup [ 0 i-at ] 2apply i-cmp 0 >
    [ swap ] when ++ ; inline
    
: (union5) ( s1 s2 -- s )
    over ileft i-length pick swap i-at icut rot left-right
    swap roll (union) -rot swap (union) ++ ;

: (union4) ( s1 s2 -- s )
    2dup ifirst swap ilast i-cmp 0 >= [ ++ ] [ (union5) ] if ; inline
    
: (union3) ( s1 s2 ls1 ls2 -- s )
    1 = 
    [ 1 = [ (union6) ] [ (union4) ] if ]
    [ 1 = [ swap ] when (union4) ] if ; inline

: (union2) ( s1 s2 -- s )
    2dup [ i-length ] 2apply 2dup zero?
    [ 3drop drop ] [ zero? [ 2drop nip ] [ (union3) ] if ] if ; inline
    
: (union) ( s1 s2 -- s )
    2dup eq? [ drop 2 *_ ] [ (union2) ] if ; inline

DEFER: i-sort

: (i-sort) ( s -- s )
    dup i-length 1 >
    [ left-right [ i-sort ] 2apply (union) ]
    when ; inline

DEFER: (diff)

: (diff7) ( s1 s2 -- s )
    dupd swap 0 i-at icontains? [ drop 0 ] when ; inline

: (diff6) ( s1 s2 -- s )
    2dup [ 0 i-at ] 2apply i-cmp zero?
    [ 2drop 0 ] [ drop ] if ; inline

: (diff5) ( s1 s2 -- s )
    over ileft i-length pick swap i-at icut rot left-right
    swap roll (diff) -rot swap (diff) ++ ; inline

: (diff4) ( s1 s2 -- s )
    2dup [ i-length ] 2apply 1 =
    [ 1 = [ (diff6) ] [ (diff5) ] if ]
    [ 1 = [ (diff7) ] [ (diff5) ] if ] if ; inline
    
: (diff3) ( s1 s2 -- s )
    2dup ifirst swap ilast i-cmp 0 >
    [ drop ] [ (diff4) ] if ; inline

: (diff2) ( s1 s2 -- s )
    2dup [ i-length zero? ] either?
    [ drop ] [ (diff3) ] if ; inline
    
: (diff) ( s1 s2 -- s )
    2dup eq? [ 2drop 0 ] [ (diff2) ] if ; inline


! **** sort, diff, union and intersect assumes positive isequences ****

: i-sort ( s -- s )
    dup ascending? [ dup descending? [ `` ] [ (i-sort) ] if ] unless ;

: i-diff ( s1 s2 -- s )
   [ i-sort ] 2apply (diff) ; inline

: i-union ( s1 s2 -- s )
    [ i-sort ] 2apply (union) ; inline

: i-intersect ( s1 s2 -- s )
    [ i-sort ] 2apply over -rot i-diff i-diff ;

