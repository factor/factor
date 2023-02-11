! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel make sequences
sequences.deep strings xml.data ;
IN: xml.traversal

<PRIVATE

: (children>string) ( children -- string )
    {
        { [ dup empty? ] [ drop "" ] }
        {
            [ dup [ string? not ] any? ]
            [ "XML tag unexpectedly contains non-text children" throw ]
        }
        [ concat ]
    } cond ;

PRIVATE>

: children>string ( tag -- string )
    children>> (children>string) ;

: deep-children>string ( tag -- string )
    children>> [
        [ dup tag? [ deep-children>string ] when % ] each
    ] "" make ;

: children-tags ( tag -- sequence )
    children>> [ tag? ] filter ;

: first-child-tag ( tag -- child )
    children>> [ tag? ] find nip ;

: tag-named? ( name elem -- ? )
    dup tag? [ names-match? ] [ 2drop f ] if ;

: tag-named ( tag name/string -- matching-tag )
    assure-name '[ _ swap tag-named? ] find nip ;

: tags-named ( tag name/string -- tags-seq )
    assure-name '[ _ swap tag-named? ] { } filter-as ;

<PRIVATE

: prepare-deep ( xml name/string -- tag name/string )
    [ dup xml? [ body>> ] when ] [ assure-name ] bi* ;

PRIVATE>

: deep-tag-named ( tag name/string -- matching-tag )
    prepare-deep '[ _ swap tag-named? ] deep-find ;

: deep-tags-named ( tag name/string -- tags-seq )
    prepare-deep '[ _ swap tag-named? ] { } deep-filter-as ;

: tag-with-attr? ( elem attr-value attr-name -- ? )
    rot dup tag? [ swap attr = ] [ 3drop f ] if ;

: tag-with-attr ( tag attr-value attr-name -- matching-tag )
    assure-name '[ _ _ tag-with-attr? ] find nip ;

: tag-named-with-attr ( tag tag-name attr-value attr-name -- matching-tag )
    [ tags-named ] 2dip '[ _ _ tag-with-attr? ] find nip ;

: tags-with-attr ( tag attr-value attr-name -- tags-seq )
    assure-name '[ _ _ tag-with-attr? ] { } filter-as ;

: deep-tag-with-attr ( tag attr-value attr-name -- matching-tag )
    assure-name '[ _ _ tag-with-attr? ] deep-find ;

: deep-tags-with-attr ( tag attr-value attr-name -- tags-seq )
    assure-name '[ _ _ tag-with-attr? ] deep-filter ;

: get-id ( tag id -- elem )
    "id" deep-tag-with-attr ;

: deep-tags-named-with-attr ( tag tag-name attr-value attr-name -- tags )
    [ deep-tags-named ] 2dip tags-with-attr ;

: assert-tag ( name name -- )
    names-match? [ "Unexpected XML tag found" throw ] unless ;
