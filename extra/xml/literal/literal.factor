USING: peg peg.ebnf kernel strings sequences combinators.lib arrays xml.data 
namespaces assocs xml.generator ;
IN: xml.literal

! EBNF-based XML generation syntax
! This is a terrible grammar for XML, only suitable for literals like this

: &ident ( -- parser )
    [ {
        [ printable? ]
        [ blank? not ]
        [ "<>" member? not ]
    } <-&& ] satisfy repeat1 [ >string ] action ;

: 2choice 2array choice ;

: &name ( -- parser )
    &ident ":" token &ident 3array seq [ first3 nip f <name> ] action
    &ident [ <name-tag> ] action
    2choice ;

: &quote ( quote -- parser )
    [ token ] keep [ = not ] curry satisfy dupd seq swap seq ;

DEFER: &quot
: &code ( -- parser )
    [ "[]" member? not ] satisfy [ &quot ] delay 2choice repeat0 ;

: &quot ( -- parser )
    ! This doesn't deal with "[" or "]" properly
    "[" token &code
    "]" token 3array seq [ second parse ] action ;

: &value ( -- parser )
    "'" &quote "\"" &quote &quot 3array choice ;

: &attr ( -- parser )
    &name "=" token &value sp 3array seq [ first3 nip 2array ] action ;

: &attrs ( -- parser )
    &attr repeat0 [
        [ swap [ set ] 2curry ] { } assoc>map concat
    ] action ;

: &tag-start ( -- parser )
    "<" token &name sp &attrs sp 3array seq
    [ first3 2array nip ] action ;

: tag-open-code ( {name,attrs} contents -- quot )
    swap first2 dup empty? [ drop swap [ tag, ] 3curry ]
    [ swap rot [ >r >r H{ } make-assoc r> r> swapd tag*, ] 3curry ] if ;

: &tag-open ( -- parser )
    &tag-start ">" token &quot 3array seq
    [ first3 nip tag-open-code ] action ;

: tag-contained-code ( {name,attrs} -- quot )
    first2 dup empty? [ drop [ contained, ] curry ]
    [ swap [ >r H{ } make-assoc r> swap contained*, ] 2curry ] if ;

: &tag-contained ( -- parser )
    &tag-start "/>" token 2array seq
    [ first tag-contained-code ] action ;

