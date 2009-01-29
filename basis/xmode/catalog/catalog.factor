USING: xmode.loader xmode.utilities xmode.rules namespaces
strings splitting assocs sequences kernel io.files xml memoize
words globs combinators io.encodings.utf8 sorting accessors xml.data ;
IN: xmode.catalog

TUPLE: mode file file-name-glob first-line-glob ;

<TAGS: parse-mode-tag ( modes tag -- )

TAG: MODE
    dup "NAME" attr [
        mode new {
            { "FILE" f (>>file) }
            { "FILE_NAME_GLOB" f (>>file-name-glob) }
            { "FIRST_LINE_GLOB" f (>>first-line-glob) }
        } init-from-tag
    ] dip
    rot set-at ;

TAGS>

: parse-modes-tag ( tag -- modes )
    H{ } clone [
        swap child-tags [ parse-mode-tag ] with each
    ] keep ;

MEMO: modes ( -- modes )
    "resource:basis/xmode/modes/catalog"
    file>xml parse-modes-tag ;

MEMO: mode-names ( -- modes )
    modes keys natural-sort ;

: reset-catalog ( -- )
    \ modes reset-memoized ;

MEMO: (load-mode) ( name -- rule-sets )
    modes at [
        file>>
        "resource:basis/xmode/modes/" prepend
        utf8 <file-reader> parse-mode
    ] [
        "text" (load-mode)
    ] if* ;

SYMBOL: rule-sets

: no-such-rule-set ( name -- * )
    "No such rule set: " prepend throw ;

: get-rule-set ( name -- rule-sets rules )
    dup "::" split1 [ swap (load-mode) ] [ rule-sets get ] if*
    dup -roll at* [ nip ] [ drop no-such-rule-set ] if ;

: resolve-delegate ( rule -- )
    dup delegate>> dup string?
    [ get-rule-set nip swap (>>delegate) ] [ 2drop ] if ;

: each-rule ( rule-set quot -- )
    [ rules>> values concat ] dip each ; inline

: resolve-delegates ( ruleset -- )
    [ resolve-delegate ] each-rule ;

: ?update ( keyword-map/f keyword-map -- keyword-map )
    over [ dupd update ] [ nip clone ] if ;

: import-keywords ( parent child -- )
    over [ [ keywords>> ] bi@ ?update ] dip (>>keywords) ;

: import-rules ( parent child -- )
    swap [ add-rule ] curry each-rule ;

: resolve-imports ( ruleset -- )
    dup imports>> [
        get-rule-set swap rule-sets [
            dup resolve-delegates
            2dup import-keywords
            import-rules
        ] with-variable
    ] with each ;

ERROR: mutually-recursive-rulesets ruleset ;
: finalize-rule-set ( ruleset -- )
    dup finalized?>> {
        { f [
            {
                [ 1 >>finalized? drop ]
                [ resolve-imports ]
                [ resolve-delegates ]
                [ t >>finalized? drop ]
            } cleave
        ] }
        { t [ drop ] }
        { 1 [ mutually-recursive-rulesets ] }
    } case ;

: finalize-mode ( rulesets -- )
    rule-sets [
        dup [ nip finalize-rule-set ] assoc-each
    ] with-variable ;

: load-mode ( name -- rule-sets )
    (load-mode) dup finalize-mode ;

: reset-modes ( -- )
    \ (load-mode) reset-memoized ;

: ?glob-matches ( string glob/f -- ? )
    dup [ glob-matches? ] [ 2drop f ] if ;

: suitable-mode? ( file-name first-line mode -- ? )
    tuck first-line-glob>> ?glob-matches
    [ 2drop t ] [ file-name-glob>> ?glob-matches ] if ;

: find-mode ( file-name first-line -- mode )
    modes
    [ nip [ 2dup ] dip suitable-mode? ] assoc-find
    2drop [ 2drop ] dip [ "text" ] unless* ;
