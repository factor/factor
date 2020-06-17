! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry hashtables io io.directories
io.files.types io.pathnames kernel namespaces prettyprint
sequences sequences.extras sets splitting system vocabs
vocabs.loader words ;
IN: sections

! <{ private linux }
! { private linux }>
! <private <linux linux> private>
! <"private" <"linux" "linux"> "private">

: word-sections ( word -- hs ) "sections" word-prop ;

: add-word-section ( obj word -- ) word-sections adjoin ;

: remove-word-section ( obj word -- ) word-sections delete ;

: in-section? ( obj word -- ? ) word-sections member? ;

: private-words ( vocab -- words )
    vocab-words [ word-sections "private" swap in? ] filter ;

ERROR: not-a-vocab-root string ;

: vocab-root? ( string -- ? )
    trim-tail-separators vocab-roots get member? ;

: check-root ( string -- string )
    dup vocab-root? [ not-a-vocab-root ] unless ;

: check-vocab-root/vocab ( vocab-root string -- vocab-root string )
    [ check-root ] [ check-vocab-name ] bi* ;

: replace-vocab-separators ( vocab -- path )
    path-separator first CHAR: . associate substitute ;

: vocab-root/vocab>path ( vocab-root vocab -- path )
    check-vocab-root/vocab
    [ ] [ replace-vocab-separators ] bi* append-path ;

: vocab>path ( vocab -- path )
    ! check-vocab
    [ find-vocab-root ] keep vocab-root/vocab>path ;

: ?vocab>path ( vocab -- path )
    ! check-vocab
    [ find-vocab-root ] keep
    over [ vocab-root/vocab>path ] [ 2drop f ] if ;

: vocab-entries ( vocab -- entries )
    vocab>path qualified-directory-entries ;

: ?vocab-entries ( vocab -- entries )
    ?vocab>path [ qualified-directory-entries ] [ { } ] if* ;

: vocab-name-last ( vocab-name -- last )
    vocab-name "." split1-last swap or ;

: vocab-section-paths ( vocab -- paths )
    [
        ?vocab-entries
        [ type>> +regular-file+ = ] filter
        [ name>> ] map
        [ ".factor" tail? ] filter
    ] [ vocab-name-last ] bi
    [ head? ] curry
    [ file-stem ] prepose filter ;

: vocab/stem>sections ( vocab stem -- sections )
    ?head drop "-" ?head drop "," split harvest ;

: vocab>section-paths ( vocab -- assoc )
    [ vocab-section-paths ]
    [ vocab-name-last ] bi
    [ vocab/stem>sections ] curry
    [ file-stem ] prepose map-zip ;

HOOK: platform-sections os ( -- seq )
M: linux platform-sections HS{ "linux" "unix" } ;
M: macosx platform-sections HS{ "macosx" "unix" } ;
M: freebsd platform-sections HS{ "freebsd" "unix" } ;

: default-load-sections ( -- seq )
    platform-sections { "docs" "private" } over adjoin-all ;

: default-test-sections ( -- seq )
    platform-sections { "docs" "private" "tests" } over adjoin-all ;

: default-use-sections ( -- seq )
    platform-sections { "docs" "tests" } over adjoin-all ;

: load-section-file? ( required-sections -- ? )
    default-load-sections diff null? ;

: vocab>loadable-paths ( vocab-name -- paths )
    vocab>section-paths
    [ nip load-section-file? ] assoc-filter keys ;

: load-section ( vocab path -- vocab )
    "loading section: " write . flush ;

: load-sections ( vocab-name -- vocab/f )
    dup vocab>loadable-paths [
        drop f
    ] [
        [ create-vocab ] dip [ load-section ] each
    ] if-empty ;
