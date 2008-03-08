USING: assocs html.parser kernel math sequences strings ascii
arrays shuffle unicode.case namespaces splitting http
sequences.lib ;
IN: html.parser.analyzer

: (find-relative)
    [ >r + dup r> ?nth* [ 2drop f f ] unless ] [ 2drop f ] if ;

: find-relative ( seq quot n -- i elt )
    >r over [ find drop ] dip r> swap pick
    (find-relative) ;

: (find-all) ( n seq quot -- )
    2dup >r >r find* [
        dupd 2array , 1+ r> r> (find-all)
    ] [
        r> r> 3drop
    ] if* ;

: find-all ( seq quot -- alist )
    [ 0 -rot (find-all) ] { } make ;

: (find-nth) ( offset seq quot n count -- obj )
    >r >r [ find* ] 2keep 4 npick [
        r> r> 1+ 2dup <= [
            4drop
        ] [
            >r >r >r >r drop 1+ r> r> r> r>
            (find-nth)
        ] if
    ] [
        2drop r> r> 2drop
    ] if ;

: find-nth ( seq quot n -- i elt )
    0 -roll 0 (find-nth) ;

: find-nth-relative ( seq quot n offest -- i elt )
    >r [ find-nth ] 3keep 2drop nip r> swap pick
    (find-relative) ;

: remove-blank-text ( vector -- vector' )
    [
        dup tag-name text = [
            tag-text [ blank? ] all? not
        ] [
            drop t
        ] if
    ] subset ;

: trim-text ( vector -- vector' )
    [
        dup tag-name text = [
            [ tag-text [ blank? ] trim ] keep
            [ set-tag-text ] keep
        ] when
    ] map ;

: find-by-id ( id vector -- vector )
    [ tag-attributes "id" swap at = ] with subset ;

: find-by-class ( id vector -- vector )
    [ tag-attributes "class" swap at = ] with subset ;

: find-by-name ( str vector -- vector )
    >r >lower r>
    [ tag-name = ] with subset ;

: find-first-name ( str vector -- i/f tag/f )
    >r >lower r>
    [ tag-name = ] with find ;

: find-matching-close ( str vector -- i/f tag/f )
    >r >lower r>
    [ [ tag-name = ] keep tag-closing? and ] with find ;

: find-by-attribute-key ( key vector -- vector )
    >r >lower r>
    [ tag-attributes at ] with subset
    [ ] subset ;

: find-by-attribute-key-value ( value key vector -- vector )
    >r >lower r>
    [ tag-attributes at over = ] with subset nip
    [ ] subset ;

: find-first-attribute-key-value ( value key vector -- i/f tag/f )
    >r >lower r>
    [ tag-attributes at over = ] with find rot drop ;

: find-between* ( i/f tag/f vector -- vector )
    pick integer? [
        rot tail-slice
        >r tag-name r>
        [ find-matching-close drop 1+ ] keep swap head
    ] [
        3drop V{ } clone
    ] if ;
    
: find-between ( i/f tag/f vector -- vector )
    find-between* dup length 3 >= [
        [ 1 tail-slice 1 head-slice* ] keep like
    ] when ;

: find-between-first ( string vector -- vector' )
    [ find-first-name ] keep find-between ;

: tag-link ( tag -- link/f )
    tag-attributes [ "href" swap at ] [ f ] if* ;

: find-links ( vector -- vector )
    [ tag-name "a" = ] subset
    [ tag-link ] subset ;


: find-by-text ( seq quot -- tag )
    [ dup tag-name text = ] swap compose find drop ;

: find-opening-tags-by-name ( name seq -- seq )
    [ [ tag-name = ] keep tag-closing? not and ] with find-all ;

: href-contains? ( str tag -- ? )
    tag-attributes "href" swap at* [ subseq? ] [ 2drop f ] if ;

: query>assoc* ( str -- hash )
    "?" split1 nip query>assoc ;

! clear "http://fark.com" http-get parse-html find-links [ "go.pl" swap start ] subset [ "=" split peek ] map

! clear "http://www.sailwx.info/shiptrack/cruiseships.phtml" http-get parse-html remove-blank-text
! "a" over find-opening-tags-by-name
! [ nip "shipposition.phtml?call=GBTT" swap href-contains? ] assoc-subset
! first first 8 + over nth
! tag-attributes "href" swap at query>assoc*
! "lat" over at "lon" rot at
