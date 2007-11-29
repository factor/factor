USING: xmode.loader xmode.utilities namespaces
assocs sequences kernel io.files xml memoize words globs ;
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

: modes ( -- )
    \ modes get-global [
        load-catalog dup \ modes set-global
    ] unless* ;

: reset-catalog ( -- )
    f \ modes set-global ;

MEMO: load-mode ( name -- rule-sets )
    modes at mode-file
    "extra/xmode/modes/" swap append
    resource-path <file-reader> parse-mode ;

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
