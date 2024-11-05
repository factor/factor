USING: accessors globs io.encodings.utf8 io.files io.pathnames
kernel ranges regexp sequences splitting strings unicode ;

IN: gitignore

TUPLE: gitignore glob negated? ;

C: <gitignore> gitignore

GENERIC: parse-gitignore ( obj -- gitignore )

M: string parse-gitignore
    split-lines parse-gitignore ;

M: object parse-gitignore
    [ [ blank? ] trim ] map harvest  ! ignore blank lines
    [ "#" head? ] reject             ! ignore comments
    [
        "!" ?head [
            "\\#" ?head [ "#" prepend ] when
            "\\!" ?head [ "!" prepend ] when
            CHAR: / over but-last-slice index
            [ "**/" prepend ] unless <glob>
        ] dip <gitignore>
    ] map ;

: load-gitignore ( path -- gitignore )
    utf8 file-lines parse-gitignore ;

: split-path ( path -- paths )
    path-separator split dup length [1..b] [
        head path-separator join
    ] with map ;

: gitignored? ( path gitignore -- ? )
    [ split-path ] dip '[
        f swap _ [
            [ glob>> matches? ] [ negated?>> ] bi
            [ [ drop f ] when ] [ or ] if
        ] with each
    ] any? ;
