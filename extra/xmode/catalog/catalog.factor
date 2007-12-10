USING: xmode.loader xmode.utilities xmode.rules namespaces
strings splitting assocs sequences kernel io.files xml memoize
words globs ;
IN: xmode.catalog

TUPLE: mode file file-name-glob first-line-glob ;

<TAGS: parse-mode-tag

TAG: MODE
    "NAME" over at >r
    mode construct-empty {
        { "FILE" f set-mode-file }
        { "FILE_NAME_GLOB" f set-mode-file-name-glob }
        { "FIRST_LINE_GLOB" f set-mode-first-line-glob }
    } init-from-tag r>
    rot set-at ;

TAGS>

: parse-modes-tag ( tag -- modes )
    H{ } clone [
        swap child-tags [ parse-mode-tag ] curry* each
    ] keep ;

: load-catalog ( -- modes )
    "extra/xmode/modes/catalog" resource-path
    <file-reader> read-xml parse-modes-tag ;

: modes ( -- assoc )
    \ modes get-global [
        load-catalog dup \ modes set-global
    ] unless* ;

: reset-catalog ( -- )
    f \ modes set-global ;

MEMO: (load-mode) ( name -- rule-sets )
    modes at mode-file
    "extra/xmode/modes/" swap append
    resource-path <file-reader> parse-mode ;

DEFER: load-mode

SYMBOL: rule-sets

: get-rule-set ( name -- rules )
    dup string? [
        "::" split1 [ swap load-mode ] [ rule-sets get ] if* at
    ] when ;

: resolve-delegate ( rule -- )
    dup rule-delegate dup
    [ get-rule-set swap set-rule-delegate ] [ 2drop ] if ;

: each-rule ( rule-set quot -- )
    >r rule-set-rules values concat r> each ; inline

: resolve-delegates ( ruleset -- )
    [ resolve-delegate ] each-rule ;

: ?update ( keyword-map/f keyword-map -- keyword-map )
    over [ dupd update ] [ nip clone ] if ;

: import-keywords ( parent child -- )
    over >r [ rule-set-keywords ] 2apply ?update
    r> set-rule-set-keywords ;

: import-rules ( parent child -- )
    swap [ add-rule ] curry each-rule ;

: resolve-imports ( ruleset -- )
    dup rule-set-imports [
        get-rule-set
        dup resolve-delegates
        2dup import-keywords
        import-rules
    ] curry* each ;

: finalize-rule-set ( ruleset -- )
    dup rule-set-finalized? [ drop ] [
        t over set-rule-set-finalized?
        dup resolve-imports
        resolve-delegates
    ] if ;

: load-mode ( name -- rule-sets )
    (load-mode) dup rule-sets [
        dup [ nip finalize-rule-set ] assoc-each
    ] with-variable ;

: reset-modes ( -- )
    \ load-mode "memoize" word-prop clear-assoc ;

: ?glob-matches ( string glob/f -- ? )
    dup [ glob-matches? ] [ 2drop f ] if ;

: suitable-mode? ( file-name first-line mode -- ? )
    tuck mode-first-line-glob ?glob-matches
    [ 2drop t ] [ mode-file-name-glob ?glob-matches ] if ;

: find-mode ( file-name first-line -- mode )
    modes
    [ nip >r 2dup r> suitable-mode? ] assoc-find
    2drop >r 2drop r> [ "text" ] unless* ;
