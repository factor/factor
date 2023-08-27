USING: alien.libraries.finder arrays assocs
combinators.short-circuit io io.encodings.utf8 io.files
io.files.info io.launcher kernel sequences sets splitting system
unicode ;
IN: alien.libraries.finder.freebsd
<PRIVATE

: parse-ldconfig-lines ( string -- triple )
    [
        ":-" split1 [ drop ] dip
        "=>" split1 [ [ unicode:blank? ] trim ] bi@
        2array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "/sbin/ldconfig -r" process-lines
    rest parse-ldconfig-lines ;

: name-matches? ( lib double -- ? )
    first swap ?head [ ?first CHAR: . = ] [ drop f ] if ;

PRIVATE>

M: freebsd find-library*
    "l" prepend load-ldconfig-cache
    [ name-matches? ] with find nip ?first [ ".so" append ] ?call ;

