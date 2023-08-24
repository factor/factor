! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.encodings.utf8 io.files kernel sequences sets
splitting vectors ;
IN: rosetta-code.inverted-index

! https://rosettacode.org/wiki/Inverted_index

! An Inverted Index is a data structure used to create full text
! search.

! Given a set of text files, implement a program to create an
! inverted index. Also create a user interface to do a search
! using that inverted index which returns a list of files that
! contain the query term / terms. The search index can be in
! memory.

: file-words ( file -- assoc )
    utf8 file-contents " ,;:!?.()[]{}\n\r" split harvest ;

: add-to-file-list ( files file -- files )
    over [ swap [ adjoin ] keep ] [ nip 1vector ] if ;

: add-to-index ( words index file -- )
    '[ _ [ _ add-to-file-list ] change-at ] each ;

: (index-files) ( files index -- )
    [ [ [ file-words ] keep ] dip swap add-to-index ] curry each ;

: index-files ( files -- index )
    H{ } clone [ (index-files) ] keep ;

: query ( terms index -- files )
    [ at ] curry map [ ] [ intersect ] map-reduce ;
