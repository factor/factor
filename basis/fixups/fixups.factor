! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple continuations kernel sequences
slots.private vocabs vocabs.parser ;
IN: fixups

CONSTANT: vocab-renames {
    { "math.intervals" { "intervals" "0.99" } }
    { "math.ranges" { "ranges" "0.99" } }
    { "sorting.slots" { "sorting.specification" "0.99" } }
    { "json.reader" { "json" "0.99" } }
    { "json.writer" { "json" "0.99" } }
    { "math.trig" { "math.functions" "0.100" } }
    { "math.functions.integer-logs" { "math.functions" "0.100" } }
    { "tools.image-analyzer" { "tools.image.analyzer" "0.100" } }
}

CONSTANT: word-renames {
    { "32bit?" { "layouts:32-bit?" "0.99" } }
    { "64bit?" { "layouts:64-bit?" "0.99" } }
    { "lines" { "io:read-lines" "0.99" } }
    { "words" { "splitting:split-words" "0.99" } }
    { "contents" { "io:read-contents" "0.99" } }
    { "exists?" { "io.files:file-exists?" "0.99" } }
    { "string-lines" { "splitting:split-lines" "0.99" } }
    { "[-inf,a)" { "math.intervals:[-inf,b)" "0.99" } }
    { "[-inf,a]" { "math.intervals:[-inf,b]" "0.99" } }
    { "(a,b)" { "ranges:(a..b)" "0.99" } }
    { "(a,b]" { "ranges:(a..b]" "0.99" } }
    { "[a,b)" { "ranges:[a..b)" "0.99" } }
    { "[a,b]" { "ranges:[a..b]" "0.99" } }
    { "[0,b)" { "ranges:[0..b)" "0.99" } }
    { "[0,b]" { "ranges:[0..b]" "0.99" } }
    { "[1,b)" { "ranges:[1..b)" "0.99" } }
    { "[1,b]" { "ranges:[1..b]" "0.99" } }
    { "assoc-combine" { "assocs:assoc-union-all" "0.99" } }
    { "assoc-refine" { "assocs:assoc-intersect-all" "0.99" } }
    { "assoc-merge" { "assocs.extras:assoc-collect" "0.99" } }
    { "assoc-merge!" { "assocs.extras:assoc-collect!" "0.99" } }
    { "peek-from" { "modern.html:peek1-from" "0.99" } }
    { "in?" { "interval-sets:interval-in?" "0.99" } }
    { "substitute" { "regexp.classes:(substitute)" "0.99" } }
    { "combine" { "sets:union-all" "0.99" } }
    { "refine" { "sets:intersect-all" "0.99" } }
    { "read-json-objects" { "json:read-json" "0.99" } }
    { "init-namespaces" { "namespaces:init-namestack" "0.99" } }
    { "iota" { "sequences:<iota>" ".98" } }
    { "git-checkout-existing-branch" { "git-checkout-existing" "0.99" } }
    { "git-checkout-existing-branch*" { "git-checkout-existing*" "0.99" } }
    { "tags" { "chloe-tags" "0.99" } }
    { "(each)" { "sequence-operator" "0.99" } }
    { "(each-integer)" { "each-integer-from" "0.99" } }
    { "(find-integer)" { "find-integer-from" "0.99" } }
    { "(all-integers?)" { "all-integers-from?" "0.99" } }
    { "short" { "index-or-length" "0.99" } }
    { "map-integers" { "map-integers-as" "0.99" } }
    { "deep-subseq?" { "deep-subseq-of?" "0.99" } }
    { "overtomorrow" { "overmorrow" "0.99" } }
    { "INITIALIZE:" { "INITIALIZED-SYMBOL:" "0.99" } }
    { "natural-sort" { "sort" "0.99" } }
    { "sort-by-with" { "sort-with-spec-by" "0.99" } }
    { "sort-keys-by" { "sort-keys-with-spec" "0.99" } }
    { "sort-values-by" { "sort-values-with-spec" "0.99" } }
    { "compare-slots" { "compare-with-spec" "0.99" } }
    { "natural-sort!" { "sort!" "0.99" } }
    { "natural-bubble-sort!" { "bubble-sort!" "0.99" } }
    { "random-integers" { "randoms" "0.99" } }
    { "count*" { "percent-of" "0.99" } }
    { "more?" { "deref?" "0.99" } }
    { "plox" { "?call" "0.99" } }
    { "ensure-non-negative" { "assert-non-negative" "0.99" } }
    { "order" { "dispatch-order" "0.99" } }
    { "TEST:" { "DEFINE-TEST-WORD:" "0.99" } }
    { "assoc-all-key?" { "all-keys?" "0.100" } }
    { "assoc-all-value?" { "all-values?" "0.100" } }
    { "assoc-any-key?" { "any-key?" "0.100" } }
    { "assoc-any-value?" { "any-value?" "0.100" } }
    { "?download-to" { "download-once-into" "0.100" } }
    { "download-to" { "download-into" "0.100" } }
}

: compute-assoc-fixups ( continuation name assoc -- seq )
    swap '[ _ = ] filter-keys [
        drop { }
    ] [
        swap '[
            first2 dupd first2
            " in Factor " glue " renamed to " glue "Fixup: " prepend
            swap drop no-op-restart
            _ <restart>
        ] map
    ] if-empty ;

GENERIC: compute-fixups ( continuation error -- seq )

M: object compute-fixups
    "error" over ?offset-of-slot
    [ slot compute-fixups ] [ 2drop { } ] if* ;

M: f compute-fixups 2drop { } ;

M: no-vocab compute-fixups
    [ name>> vocab-renames compute-assoc-fixups ] [ drop { } ] if* ;

M: no-word-error compute-fixups
    [ name>> word-renames compute-assoc-fixups ] [ drop { } ] if* ;
