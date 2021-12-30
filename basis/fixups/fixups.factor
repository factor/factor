! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations formatting kernel
sequences vocabs vocabs.parser ;
IN: fixups

CONSTANT: vocab-renames {
    { "math.intervals" { "intervals" ".99" } }
    { "math.ranges" { "ranges" ".99" } }
    { "asdfasdf" { "asdfasdf2" ".99" } }
}

CONSTANT: word-renames {
    { "lines" { "io:read-lines" ".99" } }
    { "lines" { "splitting:split-lines" ".99" } }
    { "words" { "splitting:split-words" ".99" } }
    { "contents" { "io:read-contents" ".99" } }
    { "exists?" { "io.files:file-exists?" ".99" } }
    { "string-lines" { "splitting:split-lines" ".99" } }
    { "split-lines" { "documents.private:?split-lines" ".99" } }
    { "[-inf,a)" { "math.intervals:[-inf,b)" ".99" } }
    { "[-inf,a]" { "math.intervals:[-inf,b]" ".99" } }
    { "(a,b)" { "math.ranges:(a..b)" ".99" } }
    { "(a,b]" { "math.ranges:(a..b]" ".99" } }
    { "[a,b)" { "math.ranges:[a..b)" ".99" } }
    { "[a,b]" { "math.ranges:[a..b]" ".99" } }
    { "assoc-merge" { "assocs.extras:assoc-collect" ".99" } }
    { "assoc-merge!" { "assocs.extras:assoc-collect!" ".99" } }
    { "peek-from" { "modern.html:peek1-from" ".99" } }
    { "in?" { "interval-sets:interval-in?" ".99" } }
    { "substitute" { "regexp.classes:(substitute)" ".99" } }
    { "combine" { "sets:union-all" ".99" } }
    { "refine" { "sets:intersect-all" ".99" } }
    { "read-json-objects" { "json.reader:read-json" ".99" } }
}

: compute-assoc-fixups ( continuation name assoc -- seq )
    swap '[ drop _ = ] assoc-filter [
        drop { }
    ] [
        swap '[
            first2 dupd first2 "Fixup: `%s` got renamed to `%s` in %s" sprintf
            swap drop f
            _ <restart>
        ] map
    ] if-empty ;

GENERIC: compute-fixups ( continuation error -- seq )

M: object compute-fixups
    error>> compute-fixups ;

M: f compute-fixups 2drop { } ;

M: no-vocab compute-fixups
    name>> vocab-renames compute-assoc-fixups ;

M: no-word-error compute-fixups
    name>> word-renames compute-assoc-fixups ;
