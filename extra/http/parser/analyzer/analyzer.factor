USING: assocs browser.parser kernel math sequences strings ;
IN: http.parser.analyzer

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
    [ tag-attributes "id" swap at = ] curry* subset ;

: find-by-class ( id vector -- vector )
    [ tag-attributes "class" swap at = ] curry* subset ;

: find-by-name ( str vector -- vector )
    >r >lower r>
    [ tag-name = ] curry* subset ;

: find-first-name ( str vector -- i/f tag/f )
    >r >lower r>
    [ tag-name = ] curry* find ;

: find-matching-close ( str vector -- i/f tag/f )
    >r >lower r>
    [ [ tag-name = ] keep tag-closing? and ] curry* find ;

: find-by-attribute-key ( key vector -- vector )
    >r >lower r>
    [ tag-attributes at ] curry* subset
    [ ] subset ;

: find-by-attribute-key-value ( value key vector -- vector )
    >r >lower r>
    [ tag-attributes at over = ] curry* subset nip
    [ ] subset ;

: find-first-attribute-key-value ( value key vector -- i/f tag/f )
    >r >lower r>
    [ tag-attributes at over = ] curry* find rot drop ;

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



! : find-last-tag ( name vector -- index tag )
    ! [
        ! dup tag-matched? [ 2drop f ] [ tag-name = ] if
    ! ] curry* find-last ;

! : find-last-tag* ( name n vector -- tag )
    ! 0 -rot <slice> find-last-tag ;

! : find-matching-tag ( tag -- tag )
    ! dup tag-closing? [
        ! find-last-tag
    ! ] [
    ! ] if ;


! clear "/Users/erg/web/fark.html" <file-reader> contents parse-html find-links [ "go.pl" swap start ] subset [ "=" split peek ] map
! clear "http://fark.com" http-get parse-html find-links [ "go.pl" swap start ] subset [ "=" split peek ] map

! clear "/Users/erg/web/hostels.html" <file-reader> contents parse-html "Currency" "name" pick find-first-attribute-key-value

! clear "/Users/erg/web/hostels.html" <file-reader> contents parse-html
! "Currency" "name" pick find-first-attribute-key-value 
! pick find-between remove-blank-text
