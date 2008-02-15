USING: assocs html.parser kernel math sequences strings ascii
arrays shuffle unicode.case namespaces splitting
http.server.responders ;
IN: html.parser.analyzer

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

: find-between ( i/f tag/f vector -- vector )
    pick integer? [
        rot 1+ tail-slice
        >r tag-name r>
        [ find-matching-close drop ] keep swap head
    ] [
        3drop V{ } clone
    ] if ;

: find-links ( vector -- vector )
    [ tag-name "a" = ] subset
    [ tag-attributes "href" swap at ] map
    [ ] subset ;

: (find-all) ( n seq quot -- )
    2dup >r >r find* [
        dupd 2array , 1+ r> r> (find-all)
    ] [
        r> r> 3drop
    ] if* ;

: find-all ( seq quot -- alist )
    [ 0 -rot (find-all) ] { } make ;

: find-opening-tags-by-name ( name seq -- seq )
    [ [ tag-name = ] keep tag-closing? not and ] with find-all ;

: href-contains? ( str tag -- ? )
    tag-attributes "href" swap at* [ subseq? ] [ 2drop f ] if ;

: query>hash* ( str -- hash )
    "?" split1 nip query>hash ;

! clear "http://fark.com" http-get parse-html find-links [ "go.pl" swap start ] subset [ "=" split peek ] map

! clear "http://www.sailwx.info/shiptrack/cruiseships.phtml" http-get parse-html remove-blank-text
! "a" over find-opening-tags-by-name
! [ nip "shipposition.phtml?call=GBTT" swap href-contains? ] assoc-subset
! first first 8 + over nth
! tag-attributes "href" swap at query>hash*
! "lat" over at "lon" rot at
