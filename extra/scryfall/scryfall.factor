! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
calendar.parser combinators combinators.short-circuit
combinators.smart formatting grouping http.download
images.loader images.viewer io io.directories json http.json
kernel math math.combinatorics math.order math.parser
math.statistics memoize namespaces random sequences
sequences.deep sequences.extras sequences.generalizations sets
sorting sorting.specification splitting splitting.extras strings
ui.gadgets.panes unicode urls ;
IN: scryfall

CONSTANT: scryfall-oracle-json-path "resource:scryfall-oracle.json"
CONSTANT: scryfall-artwork-json-path "resource:scryfall-artwork.json"
CONSTANT: scryfall-default-json-path "resource:scryfall-default.json"
CONSTANT: scryfall-all-json-path "resource:scryfall-all.json"
CONSTANT: scryfall-rulings-json-path "resource:scryfall-rulings.json"
CONSTANT: scryfall-images-path "resource:scryfall-images/"

: ?write ( str/f -- ) [ write ] when* ;
: ?print ( str/f -- ) [ print ] [ nl ] if* ;

: download-scryfall-bulk-json ( -- json )
    "https://api.scryfall.com/bulk-data" http-get-json nip ;

: find-scryfall-json ( type -- json/f )
    [ download-scryfall-bulk-json "data" of ] dip '[ "type" of _ = ] filter ?first ;

: load-scryfall-json ( type path -- uri )
    [ find-scryfall-json "download_uri" of ] dip
    30 days download-outdated-as path>json ;

MEMO: mtg-oracle-cards ( -- json )
    "oracle_cards" scryfall-oracle-json-path load-scryfall-json ;

: redownload-mtg-oracle-cards ( -- json )
    scryfall-oracle-json-path ?delete-file
    \ mtg-oracle-cards [ reset-memoized ] [ execute ] bi ;

MEMO: mtg-artwork-cards ( -- json )
    "unique_artwork" scryfall-artwork-json-path load-scryfall-json ;

: redownload-mtg-artwork-cards ( -- json )
    scryfall-artwork-json-path ?delete-file
    \ mtg-artwork-cards [ reset-memoized ] [ execute ] bi ;

MEMO: scryfall-default-cards-json ( -- json )
    "default_cards" scryfall-default-json-path load-scryfall-json ;

: redownload-mtg-default-cards ( -- json )
    scryfall-default-json-path ?delete-file
    \ scryfall-default-cards-json [ reset-memoized ] [ execute ] bi ;

MEMO: scryfall-all-cards-json ( -- json )
    "all_cards" scryfall-all-json-path load-scryfall-json ;

: redownload-mtg-all-cards ( -- json )
    scryfall-all-json-path ?delete-file
    \ scryfall-all-cards-json [ reset-memoized ] [ execute ] bi ;

MEMO: scryfall-rulings-json ( -- json )
    "rulings" scryfall-rulings-json-path load-scryfall-json ;

: redownload-mtg-rulings-cards ( -- json )
    scryfall-rulings-json-path ?delete-file
    \ scryfall-rulings-json [ reset-memoized ] [ execute ] bi ;

: ensure-scryfall-images-directory ( -- )
    scryfall-images-path make-directories ;

: scryfall-local-image-path ( string -- path )
    >url path>> "/" ?head drop "/" "-" replace
    scryfall-images-path "" prepend-as ;

: filter-multi-card-faces ( assoc -- seq )
    [ "card_faces" of length 1 > ] filter ; inline

: reject-multi-card-faces ( assoc -- seq )
    [ "card_faces" of length 1 > ] reject ; inline

: multi-card-faces? ( assoc -- seq )
    "card_faces" of length 1 > ; inline

: card>image-uris ( assoc -- seq )
    [ "image_uris" of ]
    [ 1array ]
    [ "card_faces" of [ "image_uris" of ] map ] ?if ;

: small-images ( seq -- seq' ) [ "small" of ] map ;
: normal-images ( seq -- seq' ) [ "normal" of ] map ;

: download-scryfall-image ( assoc -- path )
    dup scryfall-local-image-path dup delete-when-zero-size
    [ download-once-as ] [ nip ] if ;

: download-normal-images ( seq -- seq' )
    ensure-scryfall-images-directory
    normal-images [ download-scryfall-image load-image ] map ;

: download-small-images ( seq -- seq' )
    ensure-scryfall-images-directory
    small-images [ download-scryfall-image load-image ] map ;

: collect-cards-by-name ( seq -- assoc ) [ "name" of ] collect-by ;
: collect-cards-by-cmc ( seq -- assoc ) [ "cmc" of ] collect-by ;
: collect-cards-by-mana-cost ( seq -- assoc ) [ "mana_cost" of ] collect-by ;
: collect-cards-by-color-identity ( seq -- assoc ) [ "color_identity" of ] collect-by-multi ;
: red-color-identity ( seq -- seq' ) collect-cards-by-color-identity "R" of ;
: blue-color-identity ( seq -- seq' ) collect-cards-by-color-identity "U" of ;
: green-color-identity ( seq -- seq' ) collect-cards-by-color-identity "G" of ;
: black-color-identity ( seq -- seq' ) collect-cards-by-color-identity "B" of ;
: white-color-identity ( seq -- seq' ) collect-cards-by-color-identity "W" of ;

: find-card-by-color-identity-intersect ( cards colors -- cards' )
    [ collect-cards-by-color-identity ] dip [ of ] with map intersect-all ;

: find-any-color-identities ( cards colors -- cards' )
    [ collect-cards-by-color-identity ] dip [ of ] with map union-all ;

: color-identity-complement ( seq -- seq' ) [ { "B" "G" "R" "U" "W" } ] dip diff ;

: split-mana-cost ( string -- seq )
    f like [ " // " split1 swap ] { } loop>sequence nip ;

: casting-cost-combinations ( seq -- seq' )
    sequence-cartesian-product [ [ first ] sort-by ] map ;

: parse-mana-cost ( string -- seq )
    split-mana-cost
    [
        "{}" split harvest
        [ "/" split ] map
        sequence-cartesian-product
    ] map ;

: remove-color-identities ( cards colors -- cards' )
    dupd find-any-color-identities diff ;

: remove-other-color-identities ( cards colors -- cards' )
    color-identity-complement remove-color-identities ;

: find-only-color-identities ( cards colors -- cards' )
    [ find-any-color-identities ] keep remove-other-color-identities ;

: filter-color-identity-length= ( seq n -- seq' ) '[ "color_identity" of length _ = ] filter ;
: filter-color-identity-length<= ( seq n -- seq' ) '[ "color_identity" of length _ <= ] filter ;
: find-exact-color-identities ( cards seq -- cards' )
    [ find-card-by-color-identity-intersect ] keep length filter-color-identity-length= ;

: filter-azorius-any ( seq -- seq' ) { "W" "U" } find-any-color-identities ;
: filter-dimir-any ( seq -- seq' ) { "U" "B" } find-any-color-identities ;
: filter-orzhov-any ( seq -- seq' ) { "W" "B" } find-any-color-identities ;
: filter-boros-any ( seq -- seq' ) { "R" "W" } find-any-color-identities ;
: filter-selesnya-any ( seq -- seq' ) { "G" "W" } find-any-color-identities ;
: filter-simic-any ( seq -- seq' ) { "G" "U" } find-any-color-identities ;
: filter-izzet-any ( seq -- seq' ) { "R" "U" } find-any-color-identities ;
: filter-golgari-any ( seq -- seq' ) { "B" "G" } find-any-color-identities ;
: filter-rakdos-any ( seq -- seq' ) { "B" "R" } find-any-color-identities ;
: filter-gruul-any ( seq -- seq' ) { "G" "R" } find-any-color-identities ;

: filter-azorius-only ( seq -- seq' ) { "W" "U" } find-only-color-identities ;
: filter-dimir-only ( seq -- seq' ) { "U" "B" } find-only-color-identities ;
: filter-orzhov-only ( seq -- seq' ) { "W" "B" } find-only-color-identities ;
: filter-boros-only ( seq -- seq' ) { "R" "W" } find-only-color-identities ;
: filter-selesnya-only ( seq -- seq' ) { "G" "W" } find-only-color-identities ;
: filter-simic-only ( seq -- seq' ) { "G" "U" } find-only-color-identities ;
: filter-izzet-only ( seq -- seq' ) { "R" "U" } find-only-color-identities ;
: filter-golgari-only ( seq -- seq' ) { "B" "G" } find-only-color-identities ;
: filter-rakdos-only ( seq -- seq' ) { "B" "R" } find-only-color-identities ;
: filter-gruul-only ( seq -- seq' ) { "G" "R" } find-only-color-identities ;

: filter-azorius-exact ( seq -- seq' ) { "W" "U" } find-exact-color-identities ;
: filter-dimir-exact ( seq -- seq' ) { "U" "B" } find-exact-color-identities ;
: filter-orzhov-exact ( seq -- seq' ) { "W" "B" } find-exact-color-identities ;
: filter-boros-exact ( seq -- seq' ) { "R" "W" } find-exact-color-identities ;
: filter-selesnya-exact ( seq -- seq' ) { "G" "W" } find-exact-color-identities ;
: filter-simic-exact ( seq -- seq' ) { "G" "U" } find-exact-color-identities ;
: filter-izzet-exact ( seq -- seq' ) { "R" "U" } find-exact-color-identities ;
: filter-golgari-exact ( seq -- seq' ) { "B" "G" } find-exact-color-identities ;
: filter-rakdos-exact ( seq -- seq' ) { "B" "R" } find-exact-color-identities ;
: filter-gruul-exact ( seq -- seq' ) { "G" "R" } find-exact-color-identities ;

: filter-bant-any ( seq -- seq' ) { "G" "W" "U" } find-any-color-identities ;
: filter-esper-any ( seq -- seq' ) { "W" "U" "B" } find-any-color-identities ;
: filter-grixis-any ( seq -- seq' ) { "U" "B" "R" } find-any-color-identities ;
: filter-jund-any ( seq -- seq' ) { "B" "R" "G" } find-any-color-identities ;
: filter-naya-any ( seq -- seq' ) { "R" "G" "W" } find-any-color-identities ;
: filter-abzan-any ( seq -- seq' ) { "W" "B" "G" } find-any-color-identities ;
: filter-jeskai-any ( seq -- seq' ) { "U" "R" "W" } find-any-color-identities ;
: filter-mardu-any ( seq -- seq' ) { "R" "W" "B" } find-any-color-identities ;
: filter-sultai-any ( seq -- seq' ) { "B" "G" "U" } find-any-color-identities ;
: filter-temur-any ( seq -- seq' ) { "G" "U" "R" } find-any-color-identities ;

: filter-bant-only ( seq -- seq' ) { "G" "W" "U" } find-only-color-identities ;
: filter-esper-only ( seq -- seq' ) { "W" "U" "B" } find-only-color-identities ;
: filter-grixis-only ( seq -- seq' ) { "U" "B" "R" } find-only-color-identities ;
: filter-jund-only ( seq -- seq' ) { "B" "R" "G" } find-only-color-identities ;
: filter-naya-only ( seq -- seq' ) { "R" "G" "W" } find-only-color-identities ;
: filter-abzan-only ( seq -- seq' ) { "W" "B" "G" } find-only-color-identities ;
: filter-jeskai-only ( seq -- seq' ) { "U" "R" "W" } find-only-color-identities ;
: filter-mardu-only ( seq -- seq' ) { "R" "W" "B" } find-only-color-identities ;
: filter-sultai-only ( seq -- seq' ) { "B" "G" "U" } find-only-color-identities ;
: filter-temur-only ( seq -- seq' ) { "G" "U" "R" } find-only-color-identities ;

: filter-bant-exact ( seq -- seq' ) { "G" "W" "U" } find-exact-color-identities ;
: filter-esper-exact ( seq -- seq' ) { "W" "U" "B" } find-exact-color-identities ;
: filter-grixis-exact ( seq -- seq' ) { "U" "B" "R" } find-exact-color-identities ;
: filter-jund-exact ( seq -- seq' ) { "B" "R" "G" } find-exact-color-identities ;
: filter-naya-exact ( seq -- seq' ) { "R" "G" "W" } find-exact-color-identities ;
: filter-abzan-exact ( seq -- seq' ) { "W" "B" "G" } find-exact-color-identities ;
: filter-jeskai-exact ( seq -- seq' ) { "U" "R" "W" } find-exact-color-identities ;
: filter-mardu-exact ( seq -- seq' ) { "R" "W" "B" } find-exact-color-identities ;
: filter-sultai-exact ( seq -- seq' ) { "B" "G" "U" } find-exact-color-identities ;
: filter-temur-exact ( seq -- seq' ) { "G" "U" "R" } find-exact-color-identities ;

: filter-non-white ( seq -- seq' ) { "U" "B" "R" "G" } find-only-color-identities ;
: filter-non-blue ( seq -- seq' ) { "W" "B" "R" "G" } find-only-color-identities ;
: filter-non-black ( seq -- seq' ) { "W" "U" "R" "G" } find-only-color-identities ;
: filter-non-red ( seq -- seq' ) { "W" "U" "B" "G" } find-only-color-identities ;
: filter-non-green ( seq -- seq' ) { "W" "U" "B" "R" } find-only-color-identities ;

: filter-legalities ( seq name -- seq' ) '[ "legalities" of _ of "legal" = ] filter ;
: filter-standard ( seq -- seq' ) "standard" filter-legalities ;
: filter-future ( seq -- seq' ) "future" filter-legalities ;
: filter-historic ( seq -- seq' ) "historic" filter-legalities ;
: filter-timeless ( seq -- seq' ) "timeless" filter-legalities ;
: filter-gladiator ( seq -- seq' ) "gladiator" filter-legalities ;
: filter-pioneer ( seq -- seq' ) "pioneer" filter-legalities ;
: filter-explorer ( seq -- seq' ) "explorer" filter-legalities ;
: filter-modern ( seq -- seq' ) "modern" filter-legalities ;
: filter-legacy ( seq -- seq' ) "legacy" filter-legalities ;
: filter-pauper ( seq -- seq' ) "pauper" filter-legalities ;
: filter-vintage ( seq -- seq' ) "vintage" filter-legalities ;
: filter-penny ( seq -- seq' ) "penny" filter-legalities ;
: filter-commander ( seq -- seq' ) "commander" filter-legalities ;
: filter-oathbreaker ( seq -- seq' ) "oathbreaker" filter-legalities ;
: filter-standardbrawl ( seq -- seq' ) "standardbrawl" filter-legalities ;
: filter-brawl ( seq -- seq' ) "brawl" filter-legalities ;
: filter-alchemy ( seq -- seq' ) "alchemy" filter-legalities ;
: filter-paupercommander ( seq -- seq' ) "paupercommander" filter-legalities ;
: filter-duel ( seq -- seq' ) "duel" filter-legalities ;
: filter-oldschool ( seq -- seq' ) "oldschool" filter-legalities ;
: filter-premodern ( seq -- seq' ) "premodern" filter-legalities ;
: filter-predh ( seq -- seq' ) "predh" filter-legalities ;

: reject-color-identity-length= ( seq n -- seq' ) '[ "color_identity" of length _ = ] reject ;
: reject-color-identity-length<= ( seq n -- seq' ) '[ "color_identity" of length _ <= ] reject ;

: reject-azorius-any ( seq -- seq' ) { "W" "U" } find-any-color-identities ;
: reject-dimir-any ( seq -- seq' ) { "U" "B" } find-any-color-identities ;
: reject-orzhov-any ( seq -- seq' ) { "W" "B" } find-any-color-identities ;
: reject-boros-any ( seq -- seq' ) { "R" "W" } find-any-color-identities ;
: reject-selesnya-any ( seq -- seq' ) { "G" "W" } find-any-color-identities ;
: reject-simic-any ( seq -- seq' ) { "G" "U" } find-any-color-identities ;
: reject-izzet-any ( seq -- seq' ) { "R" "U" } find-any-color-identities ;
: reject-golgari-any ( seq -- seq' ) { "B" "G" } find-any-color-identities ;
: reject-rakdos-any ( seq -- seq' ) { "B" "R" } find-any-color-identities ;
: reject-gruul-any ( seq -- seq' ) { "G" "R" } find-any-color-identities ;

: reject-azorius-only ( seq -- seq' ) { "W" "U" } find-only-color-identities ;
: reject-dimir-only ( seq -- seq' ) { "U" "B" } find-only-color-identities ;
: reject-orzhov-only ( seq -- seq' ) { "W" "B" } find-only-color-identities ;
: reject-boros-only ( seq -- seq' ) { "R" "W" } find-only-color-identities ;
: reject-selesnya-only ( seq -- seq' ) { "G" "W" } find-only-color-identities ;
: reject-simic-only ( seq -- seq' ) { "G" "U" } find-only-color-identities ;
: reject-izzet-only ( seq -- seq' ) { "R" "U" } find-only-color-identities ;
: reject-golgari-only ( seq -- seq' ) { "B" "G" } find-only-color-identities ;
: reject-rakdos-only ( seq -- seq' ) { "B" "R" } find-only-color-identities ;
: reject-gruul-only ( seq -- seq' ) { "G" "R" } find-only-color-identities ;

: reject-azorius-exact ( seq -- seq' ) { "W" "U" } find-exact-color-identities ;
: reject-dimir-exact ( seq -- seq' ) { "U" "B" } find-exact-color-identities ;
: reject-orzhov-exact ( seq -- seq' ) { "W" "B" } find-exact-color-identities ;
: reject-boros-exact ( seq -- seq' ) { "R" "W" } find-exact-color-identities ;
: reject-selesnya-exact ( seq -- seq' ) { "G" "W" } find-exact-color-identities ;
: reject-simic-exact ( seq -- seq' ) { "G" "U" } find-exact-color-identities ;
: reject-izzet-exact ( seq -- seq' ) { "R" "U" } find-exact-color-identities ;
: reject-golgari-exact ( seq -- seq' ) { "B" "G" } find-exact-color-identities ;
: reject-rakdos-exact ( seq -- seq' ) { "B" "R" } find-exact-color-identities ;
: reject-gruul-exact ( seq -- seq' ) { "G" "R" } find-exact-color-identities ;

: reject-bant-any ( seq -- seq' ) { "G" "W" "U" } find-any-color-identities ;
: reject-esper-any ( seq -- seq' ) { "W" "U" "B" } find-any-color-identities ;
: reject-grixis-any ( seq -- seq' ) { "U" "B" "R" } find-any-color-identities ;
: reject-jund-any ( seq -- seq' ) { "B" "R" "G" } find-any-color-identities ;
: reject-naya-any ( seq -- seq' ) { "R" "G" "W" } find-any-color-identities ;
: reject-abzan-any ( seq -- seq' ) { "W" "B" "G" } find-any-color-identities ;
: reject-jeskai-any ( seq -- seq' ) { "U" "R" "W" } find-any-color-identities ;
: reject-mardu-any ( seq -- seq' ) { "R" "W" "B" } find-any-color-identities ;
: reject-sultai-any ( seq -- seq' ) { "B" "G" "U" } find-any-color-identities ;
: reject-temur-any ( seq -- seq' ) { "G" "U" "R" } find-any-color-identities ;

: reject-bant-only ( seq -- seq' ) { "G" "W" "U" } find-only-color-identities ;
: reject-esper-only ( seq -- seq' ) { "W" "U" "B" } find-only-color-identities ;
: reject-grixis-only ( seq -- seq' ) { "U" "B" "R" } find-only-color-identities ;
: reject-jund-only ( seq -- seq' ) { "B" "R" "G" } find-only-color-identities ;
: reject-naya-only ( seq -- seq' ) { "R" "G" "W" } find-only-color-identities ;
: reject-abzan-only ( seq -- seq' ) { "W" "B" "G" } find-only-color-identities ;
: reject-jeskai-only ( seq -- seq' ) { "U" "R" "W" } find-only-color-identities ;
: reject-mardu-only ( seq -- seq' ) { "R" "W" "B" } find-only-color-identities ;
: reject-sultai-only ( seq -- seq' ) { "B" "G" "U" } find-only-color-identities ;
: reject-temur-only ( seq -- seq' ) { "G" "U" "R" } find-only-color-identities ;

: reject-bant-exact ( seq -- seq' ) { "G" "W" "U" } find-exact-color-identities ;
: reject-esper-exact ( seq -- seq' ) { "W" "U" "B" } find-exact-color-identities ;
: reject-grixis-exact ( seq -- seq' ) { "U" "B" "R" } find-exact-color-identities ;
: reject-jund-exact ( seq -- seq' ) { "B" "R" "G" } find-exact-color-identities ;
: reject-naya-exact ( seq -- seq' ) { "R" "G" "W" } find-exact-color-identities ;
: reject-abzan-exact ( seq -- seq' ) { "W" "B" "G" } find-exact-color-identities ;
: reject-jeskai-exact ( seq -- seq' ) { "U" "R" "W" } find-exact-color-identities ;
: reject-mardu-exact ( seq -- seq' ) { "R" "W" "B" } find-exact-color-identities ;
: reject-sultai-exact ( seq -- seq' ) { "B" "G" "U" } find-exact-color-identities ;
: reject-temur-exact ( seq -- seq' ) { "G" "U" "R" } find-exact-color-identities ;

: reject-non-white ( seq -- seq' ) { "U" "B" "R" "G" } find-only-color-identities ;
: reject-non-blue ( seq -- seq' ) { "W" "B" "R" "G" } find-only-color-identities ;
: reject-non-black ( seq -- seq' ) { "W" "U" "R" "G" } find-only-color-identities ;
: reject-non-red ( seq -- seq' ) { "W" "U" "B" "G" } find-only-color-identities ;
: reject-non-green ( seq -- seq' ) { "W" "U" "B" "R" } find-only-color-identities ;

: reject-legalities ( seq name -- seq' ) '[ "legalities" of _ of "legal" = ] reject ;
: reject-standard ( seq -- seq' ) "standard" reject-legalities ;
: reject-future ( seq -- seq' ) "future" reject-legalities ;
: reject-historic ( seq -- seq' ) "historic" reject-legalities ;
: reject-timeless ( seq -- seq' ) "timeless" reject-legalities ;
: reject-gladiator ( seq -- seq' ) "gladiator" reject-legalities ;
: reject-pioneer ( seq -- seq' ) "pioneer" reject-legalities ;
: reject-explorer ( seq -- seq' ) "explorer" reject-legalities ;
: reject-modern ( seq -- seq' ) "modern" reject-legalities ;
: reject-legacy ( seq -- seq' ) "legacy" reject-legalities ;
: reject-pauper ( seq -- seq' ) "pauper" reject-legalities ;
: reject-vintage ( seq -- seq' ) "vintage" reject-legalities ;
: reject-penny ( seq -- seq' ) "penny" reject-legalities ;
: reject-commander ( seq -- seq' ) "commander" reject-legalities ;
: reject-oathbreaker ( seq -- seq' ) "oathbreaker" reject-legalities ;
: reject-standardbrawl ( seq -- seq' ) "standardbrawl" reject-legalities ;
: reject-brawl ( seq -- seq' ) "brawl" reject-legalities ;
: reject-alchemy ( seq -- seq' ) "alchemy" reject-legalities ;
: reject-paupercommander ( seq -- seq' ) "paupercommander" reject-legalities ;
: reject-duel ( seq -- seq' ) "duel" reject-legalities ;
: reject-oldschool ( seq -- seq' ) "oldschool" reject-legalities ;
: reject-premodern ( seq -- seq' ) "premodern" reject-legalities ;
: reject-predh ( seq -- seq' ) "predh" reject-legalities ;

: spanish-standard-cards ( -- seq )
    scryfall-all-cards-json
    filter-standard
    [ "lang" of "es" = ] filter ;

: filter-red-any ( seq -- seq' ) [ "colors" of "R" swap member? ] filter ;
: filter-red-only ( seq -- seq' ) [ "colors" of { "R" } = ] filter ;
: filter-blue-any ( seq -- seq' ) [ "colors" of "U" swap member? ] filter ;
: filter-blue-only ( seq -- seq' ) [ "colors" of { "U" } = ] filter ;
: filter-green-any ( seq -- seq' ) [ "colors" of "G" swap member? ] filter ;
: filter-green-only ( seq -- seq' ) [ "colors" of { "G" } = ] filter ;
: filter-black-any ( seq -- seq' ) [ "colors" of "B" swap member? ] filter ;
: filter-black-only ( seq -- seq' ) [ "colors" of { "B" } = ] filter ;
: filter-white-any ( seq -- seq' ) [ "colors" of "W" swap member? ] filter ;
: filter-white-only ( seq -- seq' ) [ "colors" of { "W" } = ] filter ;
: filter-multi-color ( seq -- seq' ) [ "colors" of length 1 > ] filter ;
: filter-cmc= ( seq n -- seq' ) >float '[ "cmc" of _ = ] filter ;
: filter-cmc< ( seq n -- seq' ) >float '[ "cmc" of _ < ] filter ;
: filter-cmc<= ( seq n -- seq' ) >float '[ "cmc" of _ <= ] filter ;
: filter-cmc> ( seq n -- seq' ) >float '[ "cmc" of _ > ] filter ;
: filter-cmc>= ( seq n -- seq' ) >float '[ "cmc" of _ >= ] filter ;

: reject-red-any ( seq -- seq' ) [ "colors" of "R" swap member? ] reject ;
: reject-red-only ( seq -- seq' ) [ "colors" of { "R" } = ] reject ;
: reject-blue-any ( seq -- seq' ) [ "colors" of "U" swap member? ] reject ;
: reject-blue-only ( seq -- seq' ) [ "colors" of { "U" } = ] reject ;
: reject-green-any ( seq -- seq' ) [ "colors" of "G" swap member? ] reject ;
: reject-green-only ( seq -- seq' ) [ "colors" of { "G" } = ] reject ;
: reject-black-any ( seq -- seq' ) [ "colors" of "B" swap member? ] reject ;
: reject-black-only ( seq -- seq' ) [ "colors" of { "B" } = ] reject ;
: reject-white-any ( seq -- seq' ) [ "colors" of "W" swap member? ] reject ;
: reject-white-only ( seq -- seq' ) [ "colors" of { "W" } = ] reject ;
: reject-multi-color ( seq -- seq' ) [ "colors" of length 1 > ] reject ;
: reject-cmc= ( seq n -- seq' ) >float '[ "cmc" of _ = ] reject ;
: reject-cmc< ( seq n -- seq' ) >float '[ "cmc" of _ < ] reject ;
: reject-cmc<= ( seq n -- seq' ) >float '[ "cmc" of _ <= ] reject ;
: reject-cmc> ( seq n -- seq' ) >float '[ "cmc" of _ > ] reject ;
: reject-cmc>= ( seq n -- seq' ) >float '[ "cmc" of _ >= ] reject ;

: parse-type-line ( string -- pairs )
    " // " split1
    [
        [
            " — " split1
            [ [ " " split ] ?call >array ] bi@ 2array
        ] ?call
    ] bi@ 2array sift ;

: type-line-of ( assoc -- string ) "type_line" of parse-type-line ;

: types-of ( assoc -- seq ) type-line-of [ first ] map concat ;
: subtypes-of ( assoc -- seq ) type-line-of [ second ] map concat ;

! cards can have several type lines (one for each face)
: any-type? ( json name -- ? )
    [ type-line-of ] dip >lower '[ first [ >lower ] map _ member-of? ] any? ;
: any-subtype? ( json name -- ? )
    [ type-line-of ] dip >lower '[ second [ >lower ] map _ member-of? ] any? ;

: type-intersects? ( json types -- ? )
    [ type-line-of ] dip [ >lower ] map '[ first [ >lower ] map _ intersects? ] any? ;
: subtype-intersects? ( json subtypes -- ? )
    [ type-line-of ] dip [ >lower ] map '[ second [ >lower ] map _ intersects? ] any? ;

: filter-type ( seq text -- seq' ) '[ _ any-type? ] filter ;
: filter-subtype ( seq text -- seq' ) '[ _ any-subtype? ] filter ;
: filter-type-intersects ( seq text -- seq' ) '[ _ type-intersects? ] filter ;
: filter-subtype-intersects ( seq text -- seq' ) '[ _ subtype-intersects? ] filter ;

: reject-type ( seq text -- seq' ) '[ _ any-type? ] reject ;
: reject-subtype ( seq text -- seq' ) '[ _ any-subtype? ] reject ;
: reject-type-intersects ( seq text -- seq' ) '[ _ type-intersects? ] reject ;
: reject-subtype-intersects ( seq text -- seq' ) '[ _ subtype-intersects? ] reject ;

: basic? ( json -- ? ) "Basic" any-type? ;
: filter-basic ( seq -- seq' ) [ basic? ] filter ;
: filter-basic-subtype ( seq text -- seq' ) [ filter-basic ] dip filter-subtype ;
: land? ( json -- ? ) "Land" any-type? ;
: filter-land ( seq -- seq' ) [ land? ] filter ;
: filter-land-subtype ( seq text -- seq' ) [ filter-land ] dip filter-subtype ;
: creature? ( json -- ? ) "Creature" any-type? ;
: filter-creature ( seq -- seq' ) [ creature? ] filter ;
: filter-creature-subtype ( seq text -- seq' ) [ filter-creature ] dip filter-subtype ;
: emblem? ( json -- ? ) "Emblem" any-type? ;
: filter-emblem ( seq -- seq' ) [ emblem? ] filter ;
: filter-emblem-subtype ( seq text -- seq' ) [ filter-emblem ] dip filter-subtype ;
: enchantment? ( json -- ? ) "Enchantment" any-type? ;
: filter-enchantment ( seq -- seq' ) [ enchantment? ] filter ;
: filter-enchantment-subtype ( seq text -- seq' ) [ filter-enchantment ] dip filter-subtype ;
: saga? ( json -- ? ) "saga" filter-enchantment-subtype ;
: filter-saga ( seq -- seq' ) [ saga? ] filter ;
: instant? ( json -- ? ) "Instant" any-type? ;
: filter-instant ( seq -- seq' ) [ instant? ] filter ;
: filter-instant-subtype ( seq text -- seq' ) [ filter-instant ] dip filter-subtype ;
: sorcery? ( json -- ? ) "Sorcery" any-type? ;
: filter-sorcery ( seq -- seq' ) [ sorcery? ] filter ;
: filter-sorcery-subtype ( seq text -- seq' ) [ filter-sorcery ] dip filter-subtype ;
: planeswalker? ( json -- ? ) "Planeswalker" any-type? ;
: filter-planeswalker ( seq -- seq' ) [ planeswalker? ] filter ;
: filter-planeswalker-subtype ( seq text -- seq' ) [ filter-planeswalker ] dip filter-subtype ;
: legendary? ( json -- ? ) "Legendary" any-type? ;
: filter-legendary ( seq -- seq' ) [ legendary? ] filter ;
: filter-legendary-subtype ( seq text -- seq' ) [ filter-legendary ] dip filter-subtype ;
: battle? ( json -- ? ) "Battle" any-type? ;
: filter-battle ( seq -- seq' ) [ battle? ] filter ;
: filter-battle-subtype ( seq text -- seq' ) [ filter-battle ] dip filter-subtype ;
: artifact? ( json -- ? ) "Artifact" any-type? ;
: filter-artifact ( seq -- seq' ) [ artifact? ] filter ;
: filter-artifact-subtype ( seq text -- seq' ) [ filter-artifact ] dip filter-subtype ;

: reject-basic ( seq -- seq' ) [ basic? ] reject ;
: reject-basic-subtype ( seq text -- seq' ) [ reject-basic ] dip reject-subtype ;
: reject-land ( seq -- seq' ) [ land? ] reject ;
: reject-land-subtype ( seq text -- seq' ) [ reject-land ] dip reject-subtype ;
: reject-creature ( seq -- seq' ) [ creature? ] reject ;
: reject-creature-subtype ( seq text -- seq' ) [ reject-creature ] dip reject-subtype ;
: reject-emblem ( seq -- seq' ) [ emblem? ] reject ;
: reject-emblem-subtype ( seq text -- seq' ) [ reject-emblem ] dip reject-subtype ;
: reject-enchantment ( seq -- seq' ) [ enchantment? ] reject ;
: reject-enchantment-subtype ( seq text -- seq' ) [ reject-enchantment ] dip reject-subtype ;
: reject-saga ( seq -- seq' ) [ saga? ] reject ;
: reject-instant ( seq -- seq' ) [ instant? ] reject ;
: reject-instant-subtype ( seq text -- seq' ) [ reject-instant ] dip reject-subtype ;
: reject-sorcery ( seq -- seq' ) [ sorcery? ] reject ;
: reject-sorcery-subtype ( seq text -- seq' ) [ reject-sorcery ] dip reject-subtype ;
: reject-planeswalker ( seq -- seq' ) [ planeswalker? ] reject ;
: reject-planeswalker-subtype ( seq text -- seq' ) [ reject-planeswalker ] dip reject-subtype ;
: reject-legendary ( seq -- seq' ) [ legendary? ] reject ;
: reject-legendary-subtype ( seq text -- seq' ) [ reject-legendary ] dip reject-subtype ;
: reject-battle ( seq -- seq' ) [ battle? ] reject ;
: reject-battle-subtype ( seq text -- seq' ) [ reject-battle ] dip reject-subtype ;
: reject-artifact ( seq -- seq' ) [ artifact? ] reject ;
: reject-artifact-subtype ( seq text -- seq' ) [ reject-artifact ] dip reject-subtype ;

: mount? ( json -- ? ) "mount" any-subtype? ;
: vehicle? ( json -- ? ) "vehicle" any-subtype? ;
: adventure? ( json -- ? ) "adventure" any-subtype? ;
: aura? ( json -- ? ) "aura" any-subtype? ;
: equipment? ( json -- ? ) "Equipment" any-subtype? ;

: filter-mounts ( seq -- seq' ) "mount" filter-subtype ;
: filter-vehicles ( seq -- seq' ) "vehicle" filter-subtype ;
: filter-adventure ( seq -- seq' ) "adventure" filter-subtype ;
: filter-aura ( seq -- seq' ) "aura" filter-subtype ;
: filter-aura-subtype ( seq text -- seq' ) [ filter-aura ] dip filter-subtype ;
: filter-equipment ( seq -- seq' ) "Equipment" filter-subtype ;
: filter-equipment-subtype ( seq text -- seq' ) [ filter-equipment ] dip filter-subtype ;

: reject-mounts ( seq -- seq' ) "mount" reject-subtype ;
: reject-vehicles ( seq -- seq' ) "vehicle" reject-subtype ;
: reject-adventure ( seq -- seq' ) "adventure" reject-subtype ;
: reject-aura ( seq -- seq' ) "aura" reject-subtype ;
: reject-aura-subtype ( seq text -- seq' ) [ reject-aura ] dip reject-subtype ;
: reject-equipment ( seq -- seq' ) "Equipment" reject-subtype ;
: reject-equipment-subtype ( seq text -- seq' ) [ reject-equipment ] dip reject-subtype ;

: filter-common ( seq -- seq' ) '[ "rarity" of "common" = ] filter ;
: filter-uncommon ( seq -- seq' ) '[ "rarity" of "uncommon" = ] filter ;
: filter-rare ( seq -- seq' ) '[ "rarity" of "rare" = ] filter ;
: filter-mythic ( seq -- seq' ) '[ "rarity" of "mythic" = ] filter ;

: reject-common ( seq -- seq' ) '[ "rarity" of "common" = ] reject ;
: reject-uncommon ( seq -- seq' ) '[ "rarity" of "uncommon" = ] reject ;
: reject-rare ( seq -- seq' ) '[ "rarity" of "rare" = ] reject ;
: reject-mythic ( seq -- seq' ) '[ "rarity" of "mythic" = ] reject ;

: paupercommander-cards ( -- seq' ) mtg-oracle-cards filter-paupercommander ;
: penny-cards ( -- seq' ) mtg-oracle-cards filter-penny ;
: standardbrawl-cards ( -- seq' ) mtg-oracle-cards filter-standardbrawl ;
: brawl-cards ( -- seq' ) mtg-oracle-cards filter-brawl ;
: oathbreaker-cards ( -- seq' ) mtg-oracle-cards filter-oathbreaker ;
: alchemy-cards ( -- seq' ) mtg-oracle-cards filter-alchemy ;
: explorer-cards ( -- seq' ) mtg-oracle-cards filter-explorer ;
: duel-cards ( -- seq' ) mtg-oracle-cards filter-duel ;
: timeless-cards ( -- seq' ) mtg-oracle-cards filter-timeless ;
: future-cards ( -- seq' ) mtg-oracle-cards filter-future ;
: gladiator-cards ( -- seq' ) mtg-oracle-cards filter-gladiator ;
: historic-cards ( -- seq' ) mtg-oracle-cards filter-historic ;
: standard-cards ( -- seq' ) mtg-oracle-cards filter-standard ;
: pioneer-cards ( -- seq' ) mtg-oracle-cards filter-pioneer ;
: premodern-cards ( -- seq' ) mtg-oracle-cards filter-premodern ;
: oldschool-cards ( -- seq' ) mtg-oracle-cards filter-oldschool ;
: modern-cards ( -- seq' ) mtg-oracle-cards filter-modern ;
: legacy-cards ( -- seq' ) mtg-oracle-cards filter-legacy ;
: commander-cards ( -- seq' ) mtg-oracle-cards filter-commander ;
: predh-cards ( -- seq' ) mtg-oracle-cards filter-predh ;
: pauper-cards ( -- seq' ) mtg-oracle-cards filter-pauper ;
: vintage-cards ( -- seq' ) mtg-oracle-cards filter-vintage ;

: sort-by-cmc ( assoc -- assoc' ) [ "cmc" of ] sort-by ;
: histogram-by-cmc ( assoc -- assoc' ) [ "cmc" of ] histogram-by sort-keys ;

: filter-by-itext-prop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] filter ;

: filter-by-text-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] filter ;

: reject-by-itext-prop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] reject ;

: reject-by-text-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] reject ;

: map-card-faces ( json quot -- seq )
    '[ [ "card_faces" of ] [ ] [ 1array ] ?if _ map ] map ; inline

: all-card-types ( seq -- seq' )
    [ "type_line" of ] map-card-faces
    concat members sort ;

: card>faces ( assoc -- seq )
    [ "card_faces" of ] [ ] [ 1array ] ?if ;

: filter-card-faces-sub-card ( seq quot -- seq )
    [ [ card>faces ] map concat ] dip filter ; inline

: filter-card-faces-sub-card-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] filter-card-faces-sub-card ;

: filter-card-faces-sub-card-iprop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] filter-card-faces-sub-card ;

: filter-card-faces-main-card ( seq quot -- seq )
    dup '[ [ "card_faces" of ] [ _ any? ] _ ?if ] filter ; inline

: filter-card-faces-main-card-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] filter-card-faces-main-card ;

: filter-card-faces-main-card-iprop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] filter-card-faces-main-card ;

: filter-card-faces-main-card-iprop-member ( seq string prop -- seq' )
    swap >lower '[ _ of [ >lower ] map _ member-of? ] filter-card-faces-main-card ;

: filter-by-flavor-text ( seq string -- seq' )
    "flavor_text" filter-card-faces-main-card-prop ;

: filter-by-flavor-itext ( seq string -- seq' )
    "flavor_text" filter-card-faces-main-card-iprop ;

: filter-by-oracle-text ( seq string -- seq' )
    "oracle_text" filter-card-faces-main-card-prop ;

: filter-by-oracle-itext ( seq string -- seq' )
    "oracle_text" filter-card-faces-main-card-iprop ;

: reject-card-faces-sub-card ( seq quot -- seq )
    [ [ card>faces ] map concat ] dip reject ; inline

: reject-card-faces-sub-card-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] reject-card-faces-sub-card ;

: reject-card-faces-sub-card-iprop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] reject-card-faces-sub-card ;

: reject-card-faces-main-card ( seq quot -- seq )
    dup '[ [ "card_faces" of ] [ _ any? ] _ ?if ] reject ; inline

: reject-card-faces-main-card-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] reject-card-faces-main-card ;

: reject-card-faces-main-card-iprop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] reject-card-faces-main-card ;

: reject-card-faces-main-card-iprop-member ( seq string prop -- seq' )
    swap >lower '[ _ of [ >lower ] map _ member-of? ] reject-card-faces-main-card ;

: reject-by-flavor-text ( seq string -- seq' )
    "flavor_text" reject-card-faces-main-card-prop ;

: reject-by-flavor-itext ( seq string -- seq' )
    "flavor_text" reject-card-faces-main-card-iprop ;

: reject-by-oracle-text ( seq string -- seq' )
    "oracle_text" reject-card-faces-main-card-prop ;

: reject-by-oracle-itext ( seq string -- seq' )
    "oracle_text" reject-card-faces-main-card-iprop ;

: reject-by-keyword ( seq string -- seq' )
    "keywords" reject-card-faces-main-card-iprop-member ;

: reject-by-name-text ( seq string -- seq' ) "name" reject-by-text-prop ;
: reject-by-name-itext ( seq string -- seq' ) "name" reject-by-itext-prop ;

: collect-keywords ( seq -- seq' )
    [ "keywords" of ] map concat members sort ;

: filter-any-keywords ( seq -- seq' ) [ "keywords" of f like ] filter ;
: reject-any-keywords ( seq -- seq' ) [ "keywords" of f like ] reject ;

: filter-any-tapped-ability ( seq -- seq' ) "{T}" filter-by-oracle-itext ;
: reject-any-tapped-ability ( seq -- seq' ) "{T}" reject-by-oracle-itext ;

: filter-any-activated-ability ( seq -- seq' )
    [ "oracle_text" of "" like string-lines [ "{" head? ] any? ] filter ;
: reject-any-activated-ability ( seq -- seq' )
    [ "oracle_text" of "" like string-lines [ "{" head? ] any? ] reject ;

: filter-sorcery-ability ( seq -- seq' )
    "activate only as a sorcery" filter-by-oracle-itext ;
: reject-sorcery-ability ( seq -- seq' )
    "activate only as a sorcery" reject-by-oracle-itext ;

: filter-by-keyword ( seq string -- seq' )
    "keywords" filter-card-faces-main-card-iprop-member ;

: filter-by-name-text ( seq string -- seq' ) "name" filter-by-text-prop ;
: filter-by-name-itext ( seq string -- seq' ) "name" filter-by-itext-prop ;

: filter-create-treasure ( seq -- seq' ) "create a treasure token" filter-by-oracle-itext ;
: filter-treasure-token ( seq -- seq' ) "treasure token" filter-by-oracle-itext ;
: filter-create-blood-token ( seq -- seq' ) "create a blood token" filter-by-oracle-itext ;
: filter-blood-token ( seq -- seq' ) "blood token" filter-by-oracle-itext ;
: filter-create-map-token ( seq -- seq' ) "create a map token" filter-by-oracle-itext ;
: filter-map-token ( seq -- seq' ) "map token" filter-by-oracle-itext ;

: filter-adamant-text ( seq -- seq' ) "adamant" filter-by-oracle-itext ;
: filter-adapt-text ( seq -- seq' ) "adapt" filter-by-oracle-itext ;
: filter-addendum-text ( seq -- seq' ) "addendum" filter-by-oracle-itext ;
: filter-affinity-text ( seq -- seq' ) "affinity" filter-by-oracle-itext ;
: filter-afflict-text ( seq -- seq' ) "afflict" filter-by-oracle-itext ;
: filter-afterlife-text ( seq -- seq' ) "afterlife" filter-by-oracle-itext ;
: filter-aftermath-text ( seq -- seq' ) "aftermath" filter-by-oracle-itext ;
: filter-alliance-text ( seq -- seq' ) "alliance" filter-by-oracle-itext ;
: filter-amass-text ( seq -- seq' ) "amass" filter-by-oracle-itext ;
: filter-amplify-text ( seq -- seq' ) "amplify" filter-by-oracle-itext ;
: filter-annihilator-text ( seq -- seq' ) "annihilator" filter-by-oracle-itext ;
: filter-ascend-text ( seq -- seq' ) "ascend" filter-by-oracle-itext ;
: filter-assemble-text ( seq -- seq' ) "assemble" filter-by-oracle-itext ;
: filter-assist-text ( seq -- seq' ) "assist" filter-by-oracle-itext ;
: filter-augment-text ( seq -- seq' ) "augment" filter-by-oracle-itext ;
: filter-awaken-text ( seq -- seq' ) "awaken" filter-by-oracle-itext ;
: filter-backup-text ( seq -- seq' ) "backup" filter-by-oracle-itext ;
: filter-banding-text ( seq -- seq' ) "banding" filter-by-oracle-itext ;
: filter-bargain-text ( seq -- seq' ) "bargain" filter-by-oracle-itext ;
: filter-basic-landcycling-text ( seq -- seq' ) "basic landcycling" filter-by-oracle-itext ;
: filter-battalion-text ( seq -- seq' ) "battalion" filter-by-oracle-itext ;
: filter-battle-cry-text ( seq -- seq' ) "battle cry" filter-by-oracle-itext ;
: filter-bestow-text ( seq -- seq' ) "bestow" filter-by-oracle-itext ;
: filter-blitz-text ( seq -- seq' ) "blitz" filter-by-oracle-itext ;
: filter-bloodrush-text ( seq -- seq' ) "bloodrush" filter-by-oracle-itext ;
: filter-bloodthirst-text ( seq -- seq' ) "bloodthirst" filter-by-oracle-itext ;
: filter-boast-text ( seq -- seq' ) "boast" filter-by-oracle-itext ;
: filter-bolster-text ( seq -- seq' ) "bolster" filter-by-oracle-itext ;
: filter-bushido-text ( seq -- seq' ) "bushido" filter-by-oracle-itext ;
: filter-buyback-text ( seq -- seq' ) "buyback" filter-by-oracle-itext ;
: filter-cascade-text ( seq -- seq' ) "cascade" filter-by-oracle-itext ;
: filter-casualty-text ( seq -- seq' ) "casualty" filter-by-oracle-itext ;
: filter-celebration-text ( seq -- seq' ) "celebration" filter-by-oracle-itext ;
: filter-champion-text ( seq -- seq' ) "champion" filter-by-oracle-itext ;
: filter-changeling-text ( seq -- seq' ) "changeling" filter-by-oracle-itext ;
: filter-channel-text ( seq -- seq' ) "channel" filter-by-oracle-itext ;
: filter-choose-a-background-text ( seq -- seq' ) "choose a background" filter-by-oracle-itext ;
: filter-chroma-text ( seq -- seq' ) "chroma" filter-by-oracle-itext ;
: filter-cipher-text ( seq -- seq' ) "cipher" filter-by-oracle-itext ;
: filter-clash-text ( seq -- seq' ) "clash" filter-by-oracle-itext ;
: filter-cleave-text ( seq -- seq' ) "cleave" filter-by-oracle-itext ;
: filter-cloak-text ( seq -- seq' ) "cloak" filter-by-oracle-itext ;
: filter-cohort-text ( seq -- seq' ) "cohort" filter-by-oracle-itext ;
: filter-collect-evidence-text ( seq -- seq' ) "collect evidence" filter-by-oracle-itext ;
: filter-companion-text ( seq -- seq' ) "companion" filter-by-oracle-itext ;
: filter-compleated-text ( seq -- seq' ) "compleated" filter-by-oracle-itext ;
: filter-conjure-text ( seq -- seq' ) "conjure" filter-by-oracle-itext ;
: filter-connive-text ( seq -- seq' ) "connive" filter-by-oracle-itext ;
: filter-conspire-text ( seq -- seq' ) "conspire" filter-by-oracle-itext ;
: filter-constellation-text ( seq -- seq' ) "constellation" filter-by-oracle-itext ;
: filter-converge-text ( seq -- seq' ) "converge" filter-by-oracle-itext ;
: filter-convert-text ( seq -- seq' ) "convert" filter-by-oracle-itext ;
: filter-convoke-text ( seq -- seq' ) "convoke" filter-by-oracle-itext ;
: filter-corrupted-text ( seq -- seq' ) "corrupted" filter-by-oracle-itext ;
: filter-council's-dilemma-text ( seq -- seq' ) "council's dilemma" filter-by-oracle-itext ;
: filter-coven-text ( seq -- seq' ) "coven" filter-by-oracle-itext ;
: filter-craft-text ( seq -- seq' ) "craft" filter-by-oracle-itext ;
: filter-crew-text ( seq -- seq' ) "crew" filter-by-oracle-itext ;
: filter-cumulative-upkeep-text ( seq -- seq' ) "cumulative upkeep" filter-by-oracle-itext ;
: filter-cycling-text ( seq -- seq' ) "cycling" filter-by-oracle-itext ;
: filter-dash-text ( seq -- seq' ) "dash" filter-by-oracle-itext ;
: filter-daybound-text ( seq -- seq' ) "daybound" filter-by-oracle-itext ;
: filter-deathtouch-text ( seq -- seq' ) "deathtouch" filter-by-oracle-itext ;
: filter-defender-text ( seq -- seq' ) "defender" filter-by-oracle-itext ;
: filter-delirium-text ( seq -- seq' ) "delirium" filter-by-oracle-itext ;
: filter-delve-text ( seq -- seq' ) "delve" filter-by-oracle-itext ;
: filter-descend-text ( seq -- seq' ) "descend" filter-by-oracle-itext ;
: filter-detain-text ( seq -- seq' ) "detain" filter-by-oracle-itext ;
: filter-dethrone-text ( seq -- seq' ) "dethrone" filter-by-oracle-itext ;
: filter-devoid-text ( seq -- seq' ) "devoid" filter-by-oracle-itext ;
: filter-devour-text ( seq -- seq' ) "devour" filter-by-oracle-itext ;
: filter-discover-text ( seq -- seq' ) "discover" filter-by-oracle-itext ;
: filter-disguise-text ( seq -- seq' ) "disguise" filter-by-oracle-itext ;
: filter-disturb-text ( seq -- seq' ) "disturb" filter-by-oracle-itext ;
: filter-doctor's-companion-text ( seq -- seq' ) "doctor's companion" filter-by-oracle-itext ;
: filter-domain-text ( seq -- seq' ) "domain" filter-by-oracle-itext ;
: filter-double-strike-text ( seq -- seq' ) "double strike" filter-by-oracle-itext ;
: filter-dredge-text ( seq -- seq' ) "dredge" filter-by-oracle-itext ;
: filter-echo-text ( seq -- seq' ) "echo" filter-by-oracle-itext ;
: filter-eerie-text ( seq -- seq' ) "eerie" filter-by-oracle-itext ;
: filter-embalm-text ( seq -- seq' ) "embalm" filter-by-oracle-itext ;
: filter-emerge-text ( seq -- seq' ) "emerge" filter-by-oracle-itext ;
: filter-eminence-text ( seq -- seq' ) "eminence" filter-by-oracle-itext ;
: filter-enchant-text ( seq -- seq' ) "enchant" filter-by-oracle-itext ;
: filter-encore-text ( seq -- seq' ) "encore" filter-by-oracle-itext ;
: filter-enlist-text ( seq -- seq' ) "enlist" filter-by-oracle-itext ;
: filter-enrage-text ( seq -- seq' ) "enrage" filter-by-oracle-itext ;
: filter-entwine-text ( seq -- seq' ) "entwine" filter-by-oracle-itext ;
: filter-equip-text ( seq -- seq' ) "equip" filter-by-oracle-itext ;
: filter-escalate-text ( seq -- seq' ) "escalate" filter-by-oracle-itext ;
: filter-escape-text ( seq -- seq' ) "escape" filter-by-oracle-itext ;
: filter-eternalize-text ( seq -- seq' ) "eternalize" filter-by-oracle-itext ;
: filter-evoke-text ( seq -- seq' ) "evoke" filter-by-oracle-itext ;
: filter-evolve-text ( seq -- seq' ) "evolve" filter-by-oracle-itext ;
: filter-exalted-text ( seq -- seq' ) "exalted" filter-by-oracle-itext ;
: filter-exert-text ( seq -- seq' ) "exert" filter-by-oracle-itext ;
: filter-exploit-text ( seq -- seq' ) "exploit" filter-by-oracle-itext ;
: filter-explore-text ( seq -- seq' ) "explore" filter-by-oracle-itext ;
: filter-extort-text ( seq -- seq' ) "extort" filter-by-oracle-itext ;
: filter-fabricate-text ( seq -- seq' ) "fabricate" filter-by-oracle-itext ;
: filter-fading-text ( seq -- seq' ) "fading" filter-by-oracle-itext ;
: filter-fateful-hour-text ( seq -- seq' ) "fateful hour" filter-by-oracle-itext ;
: filter-fathomless-descent-text ( seq -- seq' ) "fathomless descent" filter-by-oracle-itext ;
: filter-fear-text ( seq -- seq' ) "fear" filter-by-oracle-itext ;
: filter-ferocious-text ( seq -- seq' ) "ferocious" filter-by-oracle-itext ;
: filter-fight-text ( seq -- seq' ) "fight" filter-by-oracle-itext ;
: filter-first-strike-text ( seq -- seq' ) "first strike" filter-by-oracle-itext ;
: filter-flanking-text ( seq -- seq' ) "flanking" filter-by-oracle-itext ;
: filter-flash-text ( seq -- seq' ) "flash" filter-by-oracle-itext ;
: filter-flashback-text ( seq -- seq' ) "flashback" filter-by-oracle-itext ;
: filter-flying-text ( seq -- seq' ) "flying" filter-by-oracle-itext ;
: filter-food-text ( seq -- seq' ) "food" filter-by-oracle-itext ;
: filter-for-mirrodin!-text ( seq -- seq' ) "for mirrodin!" filter-by-oracle-itext ;
: filter-forecast-text ( seq -- seq' ) "forecast" filter-by-oracle-itext ;
: filter-forestcycling-text ( seq -- seq' ) "forestcycling" filter-by-oracle-itext ;
: filter-forestwalk-text ( seq -- seq' ) "forestwalk" filter-by-oracle-itext ;
: filter-foretell-text ( seq -- seq' ) "foretell" filter-by-oracle-itext ;
: filter-formidable-text ( seq -- seq' ) "formidable" filter-by-oracle-itext ;
: filter-friends-forever-text ( seq -- seq' ) "friends forever" filter-by-oracle-itext ;
: filter-fuse-text ( seq -- seq' ) "fuse" filter-by-oracle-itext ;
: filter-goad-text ( seq -- seq' ) "goad" filter-by-oracle-itext ;
: filter-graft-text ( seq -- seq' ) "graft" filter-by-oracle-itext ;
: filter-haste-text ( seq -- seq' ) "haste" filter-by-oracle-itext ;
: filter-haunt-text ( seq -- seq' ) "haunt" filter-by-oracle-itext ;
: filter-hellbent-text ( seq -- seq' ) "hellbent" filter-by-oracle-itext ;
: filter-hero's-reward-text ( seq -- seq' ) "hero's reward" filter-by-oracle-itext ;
: filter-heroic-text ( seq -- seq' ) "heroic" filter-by-oracle-itext ;
: filter-hexproof-text ( seq -- seq' ) "hexproof" filter-by-oracle-itext ;
: filter-hexproof-from-text ( seq -- seq' ) "hexproof from" filter-by-oracle-itext ;
: filter-hidden-agenda-text ( seq -- seq' ) "hidden agenda" filter-by-oracle-itext ;
: filter-hideaway-text ( seq -- seq' ) "hideaway" filter-by-oracle-itext ;
: filter-horsemanship-text ( seq -- seq' ) "horsemanship" filter-by-oracle-itext ;
: filter-impending-text ( seq -- seq' ) "impending" filter-by-oracle-itext ;
: filter-imprint-text ( seq -- seq' ) "imprint" filter-by-oracle-itext ;
: filter-improvise-text ( seq -- seq' ) "improvise" filter-by-oracle-itext ;
: filter-incubate-text ( seq -- seq' ) "incubate" filter-by-oracle-itext ;
: filter-indestructible-text ( seq -- seq' ) "indestructible" filter-by-oracle-itext ;
: filter-infect-text ( seq -- seq' ) "infect" filter-by-oracle-itext ;
: filter-ingest-text ( seq -- seq' ) "ingest" filter-by-oracle-itext ;
: filter-inspired-text ( seq -- seq' ) "inspired" filter-by-oracle-itext ;
: filter-intensity-text ( seq -- seq' ) "intensity" filter-by-oracle-itext ;
: filter-intimidate-text ( seq -- seq' ) "intimidate" filter-by-oracle-itext ;
: filter-investigate-text ( seq -- seq' ) "investigate" filter-by-oracle-itext ;
: filter-islandcycling-text ( seq -- seq' ) "islandcycling" filter-by-oracle-itext ;
: filter-islandwalk-text ( seq -- seq' ) "islandwalk" filter-by-oracle-itext ;
: filter-jump-start-text ( seq -- seq' ) "jump-start" filter-by-oracle-itext ;
: filter-kicker-text ( seq -- seq' ) "kicker" filter-by-oracle-itext ;
: filter-kinship-text ( seq -- seq' ) "kinship" filter-by-oracle-itext ;
: filter-landcycling-text ( seq -- seq' ) "landcycling" filter-by-oracle-itext ;
: filter-landfall-text ( seq -- seq' ) "landfall" filter-by-oracle-itext ;
: filter-landwalk-text ( seq -- seq' ) "landwalk" filter-by-oracle-itext ;
: filter-learn-text ( seq -- seq' ) "learn" filter-by-oracle-itext ;
: filter-level-up-text ( seq -- seq' ) "level up" filter-by-oracle-itext ;
: filter-lieutenant-text ( seq -- seq' ) "lieutenant" filter-by-oracle-itext ;
: filter-lifelink-text ( seq -- seq' ) "lifelink" filter-by-oracle-itext ;
: filter-living-metal-text ( seq -- seq' ) "living metal" filter-by-oracle-itext ;
: filter-living-weapon-text ( seq -- seq' ) "living weapon" filter-by-oracle-itext ;
: filter-madness-text ( seq -- seq' ) "madness" filter-by-oracle-itext ;
: filter-magecraft-text ( seq -- seq' ) "magecraft" filter-by-oracle-itext ;
: filter-manifest-text ( seq -- seq' ) "manifest" filter-by-oracle-itext ;
: filter-manifest-dread-text ( seq -- seq' ) "manifest dread" filter-by-oracle-itext ;
: filter-megamorph-text ( seq -- seq' ) "megamorph" filter-by-oracle-itext ;
: filter-meld-text ( seq -- seq' ) "meld" filter-by-oracle-itext ;
: filter-melee-text ( seq -- seq' ) "melee" filter-by-oracle-itext ;
: filter-menace-text ( seq -- seq' ) "menace" filter-by-oracle-itext ;
: filter-mentor-text ( seq -- seq' ) "mentor" filter-by-oracle-itext ;
: filter-metalcraft-text ( seq -- seq' ) "metalcraft" filter-by-oracle-itext ;
: filter-mill-text ( seq -- seq' ) "mill" filter-by-oracle-itext ;
: filter-miracle-text ( seq -- seq' ) "miracle" filter-by-oracle-itext ;
: filter-modular-text ( seq -- seq' ) "modular" filter-by-oracle-itext ;
: filter-monstrosity-text ( seq -- seq' ) "monstrosity" filter-by-oracle-itext ;
: filter-morbid-text ( seq -- seq' ) "morbid" filter-by-oracle-itext ;
: filter-more-than-meets-the-eye-text ( seq -- seq' ) "more than meets the eye" filter-by-oracle-itext ;
: filter-morph-text ( seq -- seq' ) "morph" filter-by-oracle-itext ;
: filter-mountaincycling-text ( seq -- seq' ) "mountaincycling" filter-by-oracle-itext ;
: filter-mountainwalk-text ( seq -- seq' ) "mountainwalk" filter-by-oracle-itext ;
: filter-multikicker-text ( seq -- seq' ) "multikicker" filter-by-oracle-itext ;
: filter-mutate-text ( seq -- seq' ) "mutate" filter-by-oracle-itext ;
: filter-myriad-text ( seq -- seq' ) "myriad" filter-by-oracle-itext ;
: filter-nightbound-text ( seq -- seq' ) "nightbound" filter-by-oracle-itext ;
: filter-ninjutsu-text ( seq -- seq' ) "ninjutsu" filter-by-oracle-itext ;
: filter-offering-text ( seq -- seq' ) "offering" filter-by-oracle-itext ;
: filter-offspring-text ( seq -- seq' ) "offspring" filter-by-oracle-itext ;
: filter-open-an-attraction-text ( seq -- seq' ) "open an attraction" filter-by-oracle-itext ;
: filter-outlast-text ( seq -- seq' ) "outlast" filter-by-oracle-itext ;
: filter-overload-text ( seq -- seq' ) "overload" filter-by-oracle-itext ;
: filter-pack-tactics-text ( seq -- seq' ) "pack tactics" filter-by-oracle-itext ;
: filter-paradox-text ( seq -- seq' ) "paradox" filter-by-oracle-itext ;
: filter-parley-text ( seq -- seq' ) "parley" filter-by-oracle-itext ;
: filter-partner-text ( seq -- seq' ) "partner" filter-by-oracle-itext ;
: filter-partner-with-text ( seq -- seq' ) "partner with" filter-by-oracle-itext ;
: filter-persist-text ( seq -- seq' ) "persist" filter-by-oracle-itext ;
: filter-phasing-text ( seq -- seq' ) "phasing" filter-by-oracle-itext ;
: filter-plainscycling-text ( seq -- seq' ) "plainscycling" filter-by-oracle-itext ;
: filter-plot-text ( seq -- seq' ) "plot" filter-by-oracle-itext ;
: filter-populate-text ( seq -- seq' ) "populate" filter-by-oracle-itext ;
: filter-proliferate-text ( seq -- seq' ) "proliferate" filter-by-oracle-itext ;
: filter-protection-text ( seq -- seq' ) "protection" filter-by-oracle-itext ;
: filter-prototype-text ( seq -- seq' ) "prototype" filter-by-oracle-itext ;
: filter-provoke-text ( seq -- seq' ) "provoke" filter-by-oracle-itext ;
: filter-prowess-text ( seq -- seq' ) "prowess" filter-by-oracle-itext ;
: filter-prowl-text ( seq -- seq' ) "prowl" filter-by-oracle-itext ;
: filter-radiance-text ( seq -- seq' ) "radiance" filter-by-oracle-itext ;
: filter-raid-text ( seq -- seq' ) "raid" filter-by-oracle-itext ;
: filter-rally-text ( seq -- seq' ) "rally" filter-by-oracle-itext ;
: filter-rampage-text ( seq -- seq' ) "rampage" filter-by-oracle-itext ;
: filter-ravenous-text ( seq -- seq' ) "ravenous" filter-by-oracle-itext ;
: filter-reach-text ( seq -- seq' ) "reach" filter-by-oracle-itext ;
: filter-read-ahead-text ( seq -- seq' ) "read ahead" filter-by-oracle-itext ;
: filter-rebound-text ( seq -- seq' ) "rebound" filter-by-oracle-itext ;
: filter-reconfigure-text ( seq -- seq' ) "reconfigure" filter-by-oracle-itext ;
: filter-recover-text ( seq -- seq' ) "recover" filter-by-oracle-itext ;
: filter-reinforce-text ( seq -- seq' ) "reinforce" filter-by-oracle-itext ;
: filter-renown-text ( seq -- seq' ) "renown" filter-by-oracle-itext ;
: filter-replicate-text ( seq -- seq' ) "replicate" filter-by-oracle-itext ;
: filter-retrace-text ( seq -- seq' ) "retrace" filter-by-oracle-itext ;
: filter-revolt-text ( seq -- seq' ) "revolt" filter-by-oracle-itext ;
: filter-riot-text ( seq -- seq' ) "riot" filter-by-oracle-itext ;
: filter-role-token-text ( seq -- seq' ) "role token" filter-by-oracle-itext ;
: filter-saddle-text ( seq -- seq' ) "saddle" filter-by-oracle-itext ;
: filter-scavenge-text ( seq -- seq' ) "scavenge" filter-by-oracle-itext ;
: filter-scry-text ( seq -- seq' ) "scry" filter-by-oracle-itext ;
: filter-seek-text ( seq -- seq' ) "seek" filter-by-oracle-itext ;
: filter-shadow-text ( seq -- seq' ) "shadow" filter-by-oracle-itext ;
: filter-shroud-text ( seq -- seq' ) "shroud" filter-by-oracle-itext ;
: filter-skulk-text ( seq -- seq' ) "skulk" filter-by-oracle-itext ;
: filter-soulbond-text ( seq -- seq' ) "soulbond" filter-by-oracle-itext ;
: filter-soulshift-text ( seq -- seq' ) "soulshift" filter-by-oracle-itext ;
: filter-specialize-text ( seq -- seq' ) "specialize" filter-by-oracle-itext ;
: filter-spectacle-text ( seq -- seq' ) "spectacle" filter-by-oracle-itext ;
: filter-spell-mastery-text ( seq -- seq' ) "spell mastery" filter-by-oracle-itext ;
: filter-splice-text ( seq -- seq' ) "splice" filter-by-oracle-itext ;
: filter-split-second-text ( seq -- seq' ) "split second" filter-by-oracle-itext ;
: filter-spree-text ( seq -- seq' ) "spree" filter-by-oracle-itext ;
: filter-squad-text ( seq -- seq' ) "squad" filter-by-oracle-itext ;
: filter-storm-text ( seq -- seq' ) "storm" filter-by-oracle-itext ;
: filter-strive-text ( seq -- seq' ) "strive" filter-by-oracle-itext ;
: filter-sunburst-text ( seq -- seq' ) "sunburst" filter-by-oracle-itext ;
: filter-support-text ( seq -- seq' ) "support" filter-by-oracle-itext ;
: filter-surge-text ( seq -- seq' ) "surge" filter-by-oracle-itext ;
: filter-surveil-text ( seq -- seq' ) "surveil" filter-by-oracle-itext ;
: filter-survival-text ( seq -- seq' ) "survival" filter-by-oracle-itext ;
: filter-suspect-text ( seq -- seq' ) "suspect" filter-by-oracle-itext ;
: filter-suspend-text ( seq -- seq' ) "suspend" filter-by-oracle-itext ;
: filter-swampcycling-text ( seq -- seq' ) "swampcycling" filter-by-oracle-itext ;
: filter-swampwalk-text ( seq -- seq' ) "swampwalk" filter-by-oracle-itext ;
: filter-threshold-text ( seq -- seq' ) "threshold" filter-by-oracle-itext ;
: filter-time-travel-text ( seq -- seq' ) "time travel" filter-by-oracle-itext ;
: filter-totem-armor-text ( seq -- seq' ) "totem armor" filter-by-oracle-itext ;
: filter-toxic-text ( seq -- seq' ) "toxic" filter-by-oracle-itext ;
: filter-training-text ( seq -- seq' ) "training" filter-by-oracle-itext ;
: filter-trample-text ( seq -- seq' ) "trample" filter-by-oracle-itext ;
: filter-transform-text ( seq -- seq' ) "transform" filter-by-oracle-itext ;
: filter-transmute-text ( seq -- seq' ) "transmute" filter-by-oracle-itext ;
: filter-treasure-text ( seq -- seq' ) "treasure" filter-by-oracle-itext ;
: filter-tribute-text ( seq -- seq' ) "tribute" filter-by-oracle-itext ;
: filter-typecycling-text ( seq -- seq' ) "typecycling" filter-by-oracle-itext ;
: filter-undergrowth-text ( seq -- seq' ) "undergrowth" filter-by-oracle-itext ;
: filter-undying-text ( seq -- seq' ) "undying" filter-by-oracle-itext ;
: filter-unearth-text ( seq -- seq' ) "unearth" filter-by-oracle-itext ;
: filter-unleash-text ( seq -- seq' ) "unleash" filter-by-oracle-itext ;
: filter-vanishing-text ( seq -- seq' ) "vanishing" filter-by-oracle-itext ;
: filter-venture-into-the-dungeon-text ( seq -- seq' ) "venture into the dungeon" filter-by-oracle-itext ;
: filter-vigilance-text ( seq -- seq' ) "vigilance" filter-by-oracle-itext ;
: filter-ward-text ( seq -- seq' ) "ward" filter-by-oracle-itext ;
: filter-will-of-the-council-text ( seq -- seq' ) "will of the council" filter-by-oracle-itext ;
: filter-wither-text ( seq -- seq' ) "wither" filter-by-oracle-itext ;

: filter-day ( seq -- seq' ) "day" filter-by-oracle-itext ;
: filter-night ( seq -- seq' ) "night" filter-by-oracle-itext ;
: filter-daybound ( seq -- seq' ) "daybound" filter-by-oracle-itext ;
: filter-nightbound ( seq -- seq' ) "nightbound" filter-by-oracle-itext ;

: filter-cave ( seq -- seq' ) "cave" filter-land-subtype ;
: filter-sphere ( seq -- seq' ) "sphere" filter-land-subtype ;

: filter-mount ( seq -- seq' ) "mount" filter-by-oracle-itext ;
: filter-outlaw ( seq -- seq' )
    { "Assassin" "Mercenary" "Pirate" "Rogue" "Warlock" } filter-subtype-intersects ;
: filter-plot ( seq -- seq' ) "plot" filter-by-oracle-itext ;
: filter-saddle ( seq -- seq' ) "saddle" filter-by-oracle-itext ;
: filter-spree ( seq -- seq' ) "saddle" filter-by-oracle-itext ;

: filter-adamant-keyword ( seq -- seq' ) "adamant" filter-by-keyword ;
: filter-adapt-keyword ( seq -- seq' ) "adapt" filter-by-keyword ;
: filter-addendum-keyword ( seq -- seq' ) "addendum" filter-by-keyword ;
: filter-affinity-keyword ( seq -- seq' ) "affinity" filter-by-keyword ;
: filter-afflict-keyword ( seq -- seq' ) "afflict" filter-by-keyword ;
: filter-afterlife-keyword ( seq -- seq' ) "afterlife" filter-by-keyword ;
: filter-aftermath-keyword ( seq -- seq' ) "aftermath" filter-by-keyword ;
: filter-alliance-keyword ( seq -- seq' ) "alliance" filter-by-keyword ;
: filter-amass-keyword ( seq -- seq' ) "amass" filter-by-keyword ;
: filter-amplify-keyword ( seq -- seq' ) "amplify" filter-by-keyword ;
: filter-annihilator-keyword ( seq -- seq' ) "annihilator" filter-by-keyword ;
: filter-ascend-keyword ( seq -- seq' ) "ascend" filter-by-keyword ;
: filter-assemble-keyword ( seq -- seq' ) "assemble" filter-by-keyword ;
: filter-assist-keyword ( seq -- seq' ) "assist" filter-by-keyword ;
: filter-augment-keyword ( seq -- seq' ) "augment" filter-by-keyword ;
: filter-awaken-keyword ( seq -- seq' ) "awaken" filter-by-keyword ;
: filter-backup-keyword ( seq -- seq' ) "backup" filter-by-keyword ;
: filter-banding-keyword ( seq -- seq' ) "banding" filter-by-keyword ;
: filter-bargain-keyword ( seq -- seq' ) "bargain" filter-by-keyword ;
: filter-basic-landcycling-keyword ( seq -- seq' ) "basic-landcycling" filter-by-keyword ;
: filter-battalion-keyword ( seq -- seq' ) "battalion" filter-by-keyword ;
: filter-battle-cry-keyword ( seq -- seq' ) "battle-cry" filter-by-keyword ;
: filter-bestow-keyword ( seq -- seq' ) "bestow" filter-by-keyword ;
: filter-blitz-keyword ( seq -- seq' ) "blitz" filter-by-keyword ;
: filter-bloodrush-keyword ( seq -- seq' ) "bloodrush" filter-by-keyword ;
: filter-bloodthirst-keyword ( seq -- seq' ) "bloodthirst" filter-by-keyword ;
: filter-boast-keyword ( seq -- seq' ) "boast" filter-by-keyword ;
: filter-bolster-keyword ( seq -- seq' ) "bolster" filter-by-keyword ;
: filter-bushido-keyword ( seq -- seq' ) "bushido" filter-by-keyword ;
: filter-buyback-keyword ( seq -- seq' ) "buyback" filter-by-keyword ;
: filter-cascade-keyword ( seq -- seq' ) "cascade" filter-by-keyword ;
: filter-casualty-keyword ( seq -- seq' ) "casualty" filter-by-keyword ;
: filter-celebration-keyword ( seq -- seq' ) "celebration" filter-by-keyword ;
: filter-champion-keyword ( seq -- seq' ) "champion" filter-by-keyword ;
: filter-changeling-keyword ( seq -- seq' ) "changeling" filter-by-keyword ;
: filter-channel-keyword ( seq -- seq' ) "channel" filter-by-keyword ;
: filter-choose-a-background-keyword ( seq -- seq' ) "choose-a-background" filter-by-keyword ;
: filter-chroma-keyword ( seq -- seq' ) "chroma" filter-by-keyword ;
: filter-cipher-keyword ( seq -- seq' ) "cipher" filter-by-keyword ;
: filter-clash-keyword ( seq -- seq' ) "clash" filter-by-keyword ;
: filter-cleave-keyword ( seq -- seq' ) "cleave" filter-by-keyword ;
: filter-cloak-keyword ( seq -- seq' ) "cloak" filter-by-keyword ;
: filter-cohort-keyword ( seq -- seq' ) "cohort" filter-by-keyword ;
: filter-collect-evidence-keyword ( seq -- seq' ) "collect-evidence" filter-by-keyword ;
: filter-companion-keyword ( seq -- seq' ) "companion" filter-by-keyword ;
: filter-compleated-keyword ( seq -- seq' ) "compleated" filter-by-keyword ;
: filter-conjure-keyword ( seq -- seq' ) "conjure" filter-by-keyword ;
: filter-connive-keyword ( seq -- seq' ) "connive" filter-by-keyword ;
: filter-conspire-keyword ( seq -- seq' ) "conspire" filter-by-keyword ;
: filter-constellation-keyword ( seq -- seq' ) "constellation" filter-by-keyword ;
: filter-converge-keyword ( seq -- seq' ) "converge" filter-by-keyword ;
: filter-convert-keyword ( seq -- seq' ) "convert" filter-by-keyword ;
: filter-convoke-keyword ( seq -- seq' ) "convoke" filter-by-keyword ;
: filter-corrupted-keyword ( seq -- seq' ) "corrupted" filter-by-keyword ;
: filter-council's-dilemma-keyword ( seq -- seq' ) "council's-dilemma" filter-by-keyword ;
: filter-coven-keyword ( seq -- seq' ) "coven" filter-by-keyword ;
: filter-craft-keyword ( seq -- seq' ) "craft" filter-by-keyword ;
: filter-crew-keyword ( seq -- seq' ) "crew" filter-by-keyword ;
: filter-cumulative-upkeep-keyword ( seq -- seq' ) "cumulative-upkeep" filter-by-keyword ;
: filter-cycling-keyword ( seq -- seq' ) "cycling" filter-by-keyword ;
: filter-dash-keyword ( seq -- seq' ) "dash" filter-by-keyword ;
: filter-daybound-keyword ( seq -- seq' ) "daybound" filter-by-keyword ;
: filter-deathtouch-keyword ( seq -- seq' ) "deathtouch" filter-by-keyword ;
: filter-defender-keyword ( seq -- seq' ) "defender" filter-by-keyword ;
: filter-delirium-keyword ( seq -- seq' ) "delirium" filter-by-keyword ;
: filter-delve-keyword ( seq -- seq' ) "delve" filter-by-keyword ;
: filter-descend-keyword ( seq -- seq' ) "descend" filter-by-keyword ;
: filter-detain-keyword ( seq -- seq' ) "detain" filter-by-keyword ;
: filter-dethrone-keyword ( seq -- seq' ) "dethrone" filter-by-keyword ;
: filter-devoid-keyword ( seq -- seq' ) "devoid" filter-by-keyword ;
: filter-devour-keyword ( seq -- seq' ) "devour" filter-by-keyword ;
: filter-discover-keyword ( seq -- seq' ) "discover" filter-by-keyword ;
: filter-disguise-keyword ( seq -- seq' ) "disguise" filter-by-keyword ;
: filter-disturb-keyword ( seq -- seq' ) "disturb" filter-by-keyword ;
: filter-doctor's-companion-keyword ( seq -- seq' ) "doctor's-companion" filter-by-keyword ;
: filter-domain-keyword ( seq -- seq' ) "domain" filter-by-keyword ;
: filter-double-strike-keyword ( seq -- seq' ) "double-strike" filter-by-keyword ;
: filter-dredge-keyword ( seq -- seq' ) "dredge" filter-by-keyword ;
: filter-echo-keyword ( seq -- seq' ) "echo" filter-by-keyword ;
: filter-eerie-keyword ( seq -- seq' ) "eerie" filter-by-keyword ;
: filter-embalm-keyword ( seq -- seq' ) "embalm" filter-by-keyword ;
: filter-emerge-keyword ( seq -- seq' ) "emerge" filter-by-keyword ;
: filter-eminence-keyword ( seq -- seq' ) "eminence" filter-by-keyword ;
: filter-enchant-keyword ( seq -- seq' ) "enchant" filter-by-keyword ;
: filter-encore-keyword ( seq -- seq' ) "encore" filter-by-keyword ;
: filter-enlist-keyword ( seq -- seq' ) "enlist" filter-by-keyword ;
: filter-enrage-keyword ( seq -- seq' ) "enrage" filter-by-keyword ;
: filter-entwine-keyword ( seq -- seq' ) "entwine" filter-by-keyword ;
: filter-equip-keyword ( seq -- seq' ) "equip" filter-by-keyword ;
: filter-escalate-keyword ( seq -- seq' ) "escalate" filter-by-keyword ;
: filter-escape-keyword ( seq -- seq' ) "escape" filter-by-keyword ;
: filter-eternalize-keyword ( seq -- seq' ) "eternalize" filter-by-keyword ;
: filter-evoke-keyword ( seq -- seq' ) "evoke" filter-by-keyword ;
: filter-evolve-keyword ( seq -- seq' ) "evolve" filter-by-keyword ;
: filter-exalted-keyword ( seq -- seq' ) "exalted" filter-by-keyword ;
: filter-exert-keyword ( seq -- seq' ) "exert" filter-by-keyword ;
: filter-exploit-keyword ( seq -- seq' ) "exploit" filter-by-keyword ;
: filter-explore-keyword ( seq -- seq' ) "explore" filter-by-keyword ;
: filter-extort-keyword ( seq -- seq' ) "extort" filter-by-keyword ;
: filter-fabricate-keyword ( seq -- seq' ) "fabricate" filter-by-keyword ;
: filter-fading-keyword ( seq -- seq' ) "fading" filter-by-keyword ;
: filter-fateful-hour-keyword ( seq -- seq' ) "fateful-hour" filter-by-keyword ;
: filter-fathomless-descent-keyword ( seq -- seq' ) "fathomless-descent" filter-by-keyword ;
: filter-fear-keyword ( seq -- seq' ) "fear" filter-by-keyword ;
: filter-ferocious-keyword ( seq -- seq' ) "ferocious" filter-by-keyword ;
: filter-fight-keyword ( seq -- seq' ) "fight" filter-by-keyword ;
: filter-first-strike-keyword ( seq -- seq' ) "first-strike" filter-by-keyword ;
: filter-flanking-keyword ( seq -- seq' ) "flanking" filter-by-keyword ;
: filter-flash-keyword ( seq -- seq' ) "flash" filter-by-keyword ;
: filter-flashback-keyword ( seq -- seq' ) "flashback" filter-by-keyword ;
: filter-flying-keyword ( seq -- seq' ) "flying" filter-by-keyword ;
: filter-food-keyword ( seq -- seq' ) "food" filter-by-keyword ;
: filter-forage-keyword ( seq -- seq' ) "forage" filter-by-keyword ;
: filter-for-mirrodin!-keyword ( seq -- seq' ) "for-mirrodin!" filter-by-keyword ;
: filter-forecast-keyword ( seq -- seq' ) "forecast" filter-by-keyword ;
: filter-forestcycling-keyword ( seq -- seq' ) "forestcycling" filter-by-keyword ;
: filter-forestwalk-keyword ( seq -- seq' ) "forestwalk" filter-by-keyword ;
: filter-foretell-keyword ( seq -- seq' ) "foretell" filter-by-keyword ;
: filter-formidable-keyword ( seq -- seq' ) "formidable" filter-by-keyword ;
: filter-friends-forever-keyword ( seq -- seq' ) "friends-forever" filter-by-keyword ;
: filter-fuse-keyword ( seq -- seq' ) "fuse" filter-by-keyword ;
: filter-gift-keyword ( seq -- seq' ) "gift" filter-by-keyword ;
: filter-goad-keyword ( seq -- seq' ) "goad" filter-by-keyword ;
: filter-graft-keyword ( seq -- seq' ) "graft" filter-by-keyword ;
: filter-haste-keyword ( seq -- seq' ) "haste" filter-by-keyword ;
: filter-haunt-keyword ( seq -- seq' ) "haunt" filter-by-keyword ;
: filter-hellbent-keyword ( seq -- seq' ) "hellbent" filter-by-keyword ;
: filter-hero's-reward-keyword ( seq -- seq' ) "hero's-reward" filter-by-keyword ;
: filter-heroic-keyword ( seq -- seq' ) "heroic" filter-by-keyword ;
: filter-hexproof-keyword ( seq -- seq' ) "hexproof" filter-by-keyword ;
: filter-hexproof-from-keyword ( seq -- seq' ) "hexproof-from" filter-by-keyword ;
: filter-hidden-agenda-keyword ( seq -- seq' ) "hidden-agenda" filter-by-keyword ;
: filter-hideaway-keyword ( seq -- seq' ) "hideaway" filter-by-keyword ;
: filter-horsemanship-keyword ( seq -- seq' ) "horsemanship" filter-by-keyword ;
: filter-impending-keyword ( seq -- seq' ) "impending" filter-by-keyword ;
: filter-imprint-keyword ( seq -- seq' ) "imprint" filter-by-keyword ;
: filter-improvise-keyword ( seq -- seq' ) "improvise" filter-by-keyword ;
: filter-incubate-keyword ( seq -- seq' ) "incubate" filter-by-keyword ;
: filter-indestructible-keyword ( seq -- seq' ) "indestructible" filter-by-keyword ;
: filter-infect-keyword ( seq -- seq' ) "infect" filter-by-keyword ;
: filter-ingest-keyword ( seq -- seq' ) "ingest" filter-by-keyword ;
: filter-inspired-keyword ( seq -- seq' ) "inspired" filter-by-keyword ;
: filter-intensity-keyword ( seq -- seq' ) "intensity" filter-by-keyword ;
: filter-intimidate-keyword ( seq -- seq' ) "intimidate" filter-by-keyword ;
: filter-investigate-keyword ( seq -- seq' ) "investigate" filter-by-keyword ;
: filter-islandcycling-keyword ( seq -- seq' ) "islandcycling" filter-by-keyword ;
: filter-islandwalk-keyword ( seq -- seq' ) "islandwalk" filter-by-keyword ;
: filter-jump-start-keyword ( seq -- seq' ) "jump-start" filter-by-keyword ;
: filter-kicker-keyword ( seq -- seq' ) "kicker" filter-by-keyword ;
: filter-kinship-keyword ( seq -- seq' ) "kinship" filter-by-keyword ;
: filter-landcycling-keyword ( seq -- seq' ) "landcycling" filter-by-keyword ;
: filter-landfall-keyword ( seq -- seq' ) "landfall" filter-by-keyword ;
: filter-landwalk-keyword ( seq -- seq' ) "landwalk" filter-by-keyword ;
: filter-learn-keyword ( seq -- seq' ) "learn" filter-by-keyword ;
: filter-level-up-keyword ( seq -- seq' ) "level-up" filter-by-keyword ;
: filter-lieutenant-keyword ( seq -- seq' ) "lieutenant" filter-by-keyword ;
: filter-lifelink-keyword ( seq -- seq' ) "lifelink" filter-by-keyword ;
: filter-living-metal-keyword ( seq -- seq' ) "living-metal" filter-by-keyword ;
: filter-living-weapon-keyword ( seq -- seq' ) "living-weapon" filter-by-keyword ;
: filter-madness-keyword ( seq -- seq' ) "madness" filter-by-keyword ;
: filter-magecraft-keyword ( seq -- seq' ) "magecraft" filter-by-keyword ;
: filter-manifest-keyword ( seq -- seq' ) "manifest" filter-by-keyword ;
: filter-manifest-dread-keyword ( seq -- seq' ) "manifest dread" filter-by-keyword ;
: filter-megamorph-keyword ( seq -- seq' ) "megamorph" filter-by-keyword ;
: filter-meld-keyword ( seq -- seq' ) "meld" filter-by-keyword ;
: filter-melee-keyword ( seq -- seq' ) "melee" filter-by-keyword ;
: filter-menace-keyword ( seq -- seq' ) "menace" filter-by-keyword ;
: filter-mentor-keyword ( seq -- seq' ) "mentor" filter-by-keyword ;
: filter-metalcraft-keyword ( seq -- seq' ) "metalcraft" filter-by-keyword ;
: filter-mill-keyword ( seq -- seq' ) "mill" filter-by-keyword ;
: filter-miracle-keyword ( seq -- seq' ) "miracle" filter-by-keyword ;
: filter-modular-keyword ( seq -- seq' ) "modular" filter-by-keyword ;
: filter-monstrosity-keyword ( seq -- seq' ) "monstrosity" filter-by-keyword ;
: filter-morbid-keyword ( seq -- seq' ) "morbid" filter-by-keyword ;
: filter-more-than-meets-the-eye-keyword ( seq -- seq' ) "more-than-meets-the-eye" filter-by-keyword ;
: filter-morph-keyword ( seq -- seq' ) "morph" filter-by-keyword ;
: filter-mountaincycling-keyword ( seq -- seq' ) "mountaincycling" filter-by-keyword ;
: filter-mountainwalk-keyword ( seq -- seq' ) "mountainwalk" filter-by-keyword ;
: filter-multikicker-keyword ( seq -- seq' ) "multikicker" filter-by-keyword ;
: filter-mutate-keyword ( seq -- seq' ) "mutate" filter-by-keyword ;
: filter-myriad-keyword ( seq -- seq' ) "myriad" filter-by-keyword ;
: filter-nightbound-keyword ( seq -- seq' ) "nightbound" filter-by-keyword ;
: filter-ninjutsu-keyword ( seq -- seq' ) "ninjutsu" filter-by-keyword ;
: filter-offering-keyword ( seq -- seq' ) "offering" filter-by-keyword ;
: filter-open-an-attraction-keyword ( seq -- seq' ) "open-an-attraction" filter-by-keyword ;
: filter-outlast-keyword ( seq -- seq' ) "outlast" filter-by-keyword ;
: filter-overload-keyword ( seq -- seq' ) "overload" filter-by-keyword ;
: filter-pack-tactics-keyword ( seq -- seq' ) "pack-tactics" filter-by-keyword ;
: filter-paradox-keyword ( seq -- seq' ) "paradox" filter-by-keyword ;
: filter-parley-keyword ( seq -- seq' ) "parley" filter-by-keyword ;
: filter-partner-keyword ( seq -- seq' ) "partner" filter-by-keyword ;
: filter-partner-with-keyword ( seq -- seq' ) "partner-with" filter-by-keyword ;
: filter-persist-keyword ( seq -- seq' ) "persist" filter-by-keyword ;
: filter-phasing-keyword ( seq -- seq' ) "phasing" filter-by-keyword ;
: filter-plainscycling-keyword ( seq -- seq' ) "plainscycling" filter-by-keyword ;
: filter-plot-keyword ( seq -- seq' ) "plot" filter-by-keyword ;
: filter-populate-keyword ( seq -- seq' ) "populate" filter-by-keyword ;
: filter-proliferate-keyword ( seq -- seq' ) "proliferate" filter-by-keyword ;
: filter-protection-keyword ( seq -- seq' ) "protection" filter-by-keyword ;
: filter-prototype-keyword ( seq -- seq' ) "prototype" filter-by-keyword ;
: filter-provoke-keyword ( seq -- seq' ) "provoke" filter-by-keyword ;
: filter-prowess-keyword ( seq -- seq' ) "prowess" filter-by-keyword ;
: filter-prowl-keyword ( seq -- seq' ) "prowl" filter-by-keyword ;
: filter-radiance-keyword ( seq -- seq' ) "radiance" filter-by-keyword ;
: filter-raid-keyword ( seq -- seq' ) "raid" filter-by-keyword ;
: filter-rally-keyword ( seq -- seq' ) "rally" filter-by-keyword ;
: filter-rampage-keyword ( seq -- seq' ) "rampage" filter-by-keyword ;
: filter-ravenous-keyword ( seq -- seq' ) "ravenous" filter-by-keyword ;
: filter-reach-keyword ( seq -- seq' ) "reach" filter-by-keyword ;
: filter-read-ahead-keyword ( seq -- seq' ) "read-ahead" filter-by-keyword ;
: filter-rebound-keyword ( seq -- seq' ) "rebound" filter-by-keyword ;
: filter-reconfigure-keyword ( seq -- seq' ) "reconfigure" filter-by-keyword ;
: filter-recover-keyword ( seq -- seq' ) "recover" filter-by-keyword ;
: filter-reinforce-keyword ( seq -- seq' ) "reinforce" filter-by-keyword ;
: filter-renown-keyword ( seq -- seq' ) "renown" filter-by-keyword ;
: filter-replicate-keyword ( seq -- seq' ) "replicate" filter-by-keyword ;
: filter-retrace-keyword ( seq -- seq' ) "retrace" filter-by-keyword ;
: filter-revolt-keyword ( seq -- seq' ) "revolt" filter-by-keyword ;
: filter-riot-keyword ( seq -- seq' ) "riot" filter-by-keyword ;
: filter-role-token-keyword ( seq -- seq' ) "role-token" filter-by-keyword ;
: filter-saddle-keyword ( seq -- seq' ) "saddle" filter-by-keyword ;
: filter-scavenge-keyword ( seq -- seq' ) "scavenge" filter-by-keyword ;
: filter-scry-keyword ( seq -- seq' ) "scry" filter-by-keyword ;
: filter-seek-keyword ( seq -- seq' ) "seek" filter-by-keyword ;
: filter-shadow-keyword ( seq -- seq' ) "shadow" filter-by-keyword ;
: filter-shroud-keyword ( seq -- seq' ) "shroud" filter-by-keyword ;
: filter-skulk-keyword ( seq -- seq' ) "skulk" filter-by-keyword ;
: filter-soulbond-keyword ( seq -- seq' ) "soulbond" filter-by-keyword ;
: filter-soulshift-keyword ( seq -- seq' ) "soulshift" filter-by-keyword ;
: filter-specialize-keyword ( seq -- seq' ) "specialize" filter-by-keyword ;
: filter-spectacle-keyword ( seq -- seq' ) "spectacle" filter-by-keyword ;
: filter-spell-mastery-keyword ( seq -- seq' ) "spell-mastery" filter-by-keyword ;
: filter-splice-keyword ( seq -- seq' ) "splice" filter-by-keyword ;
: filter-split-second-keyword ( seq -- seq' ) "split-second" filter-by-keyword ;
: filter-spree-keyword ( seq -- seq' ) "spree" filter-by-keyword ;
: filter-squad-keyword ( seq -- seq' ) "squad" filter-by-keyword ;
: filter-storm-keyword ( seq -- seq' ) "storm" filter-by-keyword ;
: filter-strive-keyword ( seq -- seq' ) "strive" filter-by-keyword ;
: filter-sunburst-keyword ( seq -- seq' ) "sunburst" filter-by-keyword ;
: filter-support-keyword ( seq -- seq' ) "support" filter-by-keyword ;
: filter-surge-keyword ( seq -- seq' ) "surge" filter-by-keyword ;
: filter-surveil-keyword ( seq -- seq' ) "surveil" filter-by-keyword ;
: filter-survival-keyword ( seq -- seq' ) "survival" filter-by-keyword ;
: filter-suspect-keyword ( seq -- seq' ) "suspect" filter-by-keyword ;
: filter-suspend-keyword ( seq -- seq' ) "suspend" filter-by-keyword ;
: filter-swampcycling-keyword ( seq -- seq' ) "swampcycling" filter-by-keyword ;
: filter-swampwalk-keyword ( seq -- seq' ) "swampwalk" filter-by-keyword ;
: filter-threshold-keyword ( seq -- seq' ) "threshold" filter-by-keyword ;
: filter-time-travel-keyword ( seq -- seq' ) "time-travel" filter-by-keyword ;
: filter-totem-armor-keyword ( seq -- seq' ) "totem-armor" filter-by-keyword ;
: filter-toxic-keyword ( seq -- seq' ) "toxic" filter-by-keyword ;
: filter-training-keyword ( seq -- seq' ) "training" filter-by-keyword ;
: filter-trample-keyword ( seq -- seq' ) "trample" filter-by-keyword ;
: filter-transform-keyword ( seq -- seq' ) "transform" filter-by-keyword ;
: filter-transmute-keyword ( seq -- seq' ) "transmute" filter-by-keyword ;
: filter-treasure-keyword ( seq -- seq' ) "treasure" filter-by-keyword ;
: filter-tribute-keyword ( seq -- seq' ) "tribute" filter-by-keyword ;
: filter-typecycling-keyword ( seq -- seq' ) "typecycling" filter-by-keyword ;
: filter-undergrowth-keyword ( seq -- seq' ) "undergrowth" filter-by-keyword ;
: filter-undying-keyword ( seq -- seq' ) "undying" filter-by-keyword ;
: filter-unearth-keyword ( seq -- seq' ) "unearth" filter-by-keyword ;
: filter-unleash-keyword ( seq -- seq' ) "unleash" filter-by-keyword ;
: filter-valiant-keyword ( seq -- seq' ) "valiant" filter-by-keyword ;
: filter-vanishing-keyword ( seq -- seq' ) "vanishing" filter-by-keyword ;
: filter-venture-into-the-dungeon-keyword ( seq -- seq' ) "venture-into-the-dungeon" filter-by-keyword ;
: filter-vigilance-keyword ( seq -- seq' ) "vigilance" filter-by-keyword ;
: filter-ward-keyword ( seq -- seq' ) "ward" filter-by-keyword ;
: filter-will-of-the-council-keyword ( seq -- seq' ) "will-of-the-council" filter-by-keyword ;
: filter-wither-keyword ( seq -- seq' ) "wither" filter-by-keyword ;

: discard-this? ( json -- ? )
    1array "Discard this" filter-by-oracle-itext empty? not ;

: discard-name? ( json -- ? )
    [ 1array ] [ "name" of "Discard " prepend ] bi filter-by-oracle-itext empty? not ;

: filter-discard-effect ( seq -- seq' )
    [ { [ discard-this? ] [ discard-name? ] } 1|| ] filter ;

: power>n ( string -- n/f )
    [ "*" = ] [ drop -1 ] [ string>number ] ?if ;

: mtg<  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ < ] } 2&& ;
: mtg<= ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ <= ] } 2&& ;
: mtg>  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ > ] } 2&& ;
: mtg>= ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ >= ] } 2&& ;
: mtg=  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ = ] } 2&& ;

: filter-power=* ( seq -- seq' ) [ "power" of "*" = ] filter-card-faces-main-card ;
: filter-toughness=* ( seq -- seq' ) [ "toughness" of "*" = ] filter-card-faces-main-card ;

: filter-power= ( seq n -- seq' ) '[ "power" of _ mtg= ] filter-card-faces-main-card ;
: filter-power< ( seq n -- seq' ) '[ "power" of _ mtg< ] filter-card-faces-main-card ;
: filter-power> ( seq n -- seq' ) '[ "power" of _ mtg> ] filter-card-faces-main-card ;
: filter-power<= ( seq n -- seq' ) '[ "power" of _ mtg<= ] filter-card-faces-main-card ;
: filter-power>= ( seq n -- seq' ) '[ "power" of _ mtg>= ] filter-card-faces-main-card ;

: filter-toughness= ( seq n -- seq' ) '[ "toughness" of _ mtg= ] filter-card-faces-main-card ;
: filter-toughness< ( seq n -- seq' ) '[ "toughness" of _ mtg< ] filter-card-faces-main-card ;
: filter-toughness> ( seq n -- seq' ) '[ "toughness" of _ mtg> ] filter-card-faces-main-card ;
: filter-toughness<= ( seq n -- seq' ) '[ "toughness" of _ mtg<= ] filter-card-faces-main-card ;
: filter-toughness>= ( seq n -- seq' ) '[ "toughness" of _ mtg>= ] filter-card-faces-main-card ;

: reject-create-treasure ( seq -- seq' ) "create a treasure token" reject-by-oracle-itext ;
: reject-treasure-token ( seq -- seq' ) "treasure token" reject-by-oracle-itext ;
: reject-create-blood-token ( seq -- seq' ) "create a blood token" reject-by-oracle-itext ;
: reject-blood-token ( seq -- seq' ) "blood token" reject-by-oracle-itext ;
: reject-create-map-token ( seq -- seq' ) "create a map token" reject-by-oracle-itext ;
: reject-map-token ( seq -- seq' ) "map token" reject-by-oracle-itext ;

: reject-adamant-text ( seq -- seq' ) "adamant" reject-by-oracle-itext ;
: reject-adapt-text ( seq -- seq' ) "adapt" reject-by-oracle-itext ;
: reject-addendum-text ( seq -- seq' ) "addendum" reject-by-oracle-itext ;
: reject-affinity-text ( seq -- seq' ) "affinity" reject-by-oracle-itext ;
: reject-afflict-text ( seq -- seq' ) "afflict" reject-by-oracle-itext ;
: reject-afterlife-text ( seq -- seq' ) "afterlife" reject-by-oracle-itext ;
: reject-aftermath-text ( seq -- seq' ) "aftermath" reject-by-oracle-itext ;
: reject-alliance-text ( seq -- seq' ) "alliance" reject-by-oracle-itext ;
: reject-amass-text ( seq -- seq' ) "amass" reject-by-oracle-itext ;
: reject-amplify-text ( seq -- seq' ) "amplify" reject-by-oracle-itext ;
: reject-annihilator-text ( seq -- seq' ) "annihilator" reject-by-oracle-itext ;
: reject-ascend-text ( seq -- seq' ) "ascend" reject-by-oracle-itext ;
: reject-assemble-text ( seq -- seq' ) "assemble" reject-by-oracle-itext ;
: reject-assist-text ( seq -- seq' ) "assist" reject-by-oracle-itext ;
: reject-augment-text ( seq -- seq' ) "augment" reject-by-oracle-itext ;
: reject-awaken-text ( seq -- seq' ) "awaken" reject-by-oracle-itext ;
: reject-backup-text ( seq -- seq' ) "backup" reject-by-oracle-itext ;
: reject-banding-text ( seq -- seq' ) "banding" reject-by-oracle-itext ;
: reject-bargain-text ( seq -- seq' ) "bargain" reject-by-oracle-itext ;
: reject-basic-landcycling-text ( seq -- seq' ) "basic landcycling" reject-by-oracle-itext ;
: reject-battalion-text ( seq -- seq' ) "battalion" reject-by-oracle-itext ;
: reject-battle-cry-text ( seq -- seq' ) "battle cry" reject-by-oracle-itext ;
: reject-bestow-text ( seq -- seq' ) "bestow" reject-by-oracle-itext ;
: reject-blitz-text ( seq -- seq' ) "blitz" reject-by-oracle-itext ;
: reject-bloodrush-text ( seq -- seq' ) "bloodrush" reject-by-oracle-itext ;
: reject-bloodthirst-text ( seq -- seq' ) "bloodthirst" reject-by-oracle-itext ;
: reject-boast-text ( seq -- seq' ) "boast" reject-by-oracle-itext ;
: reject-bolster-text ( seq -- seq' ) "bolster" reject-by-oracle-itext ;
: reject-bushido-text ( seq -- seq' ) "bushido" reject-by-oracle-itext ;
: reject-buyback-text ( seq -- seq' ) "buyback" reject-by-oracle-itext ;
: reject-cascade-text ( seq -- seq' ) "cascade" reject-by-oracle-itext ;
: reject-casualty-text ( seq -- seq' ) "casualty" reject-by-oracle-itext ;
: reject-celebration-text ( seq -- seq' ) "celebration" reject-by-oracle-itext ;
: reject-champion-text ( seq -- seq' ) "champion" reject-by-oracle-itext ;
: reject-changeling-text ( seq -- seq' ) "changeling" reject-by-oracle-itext ;
: reject-channel-text ( seq -- seq' ) "channel" reject-by-oracle-itext ;
: reject-choose-a-background-text ( seq -- seq' ) "choose a background" reject-by-oracle-itext ;
: reject-chroma-text ( seq -- seq' ) "chroma" reject-by-oracle-itext ;
: reject-cipher-text ( seq -- seq' ) "cipher" reject-by-oracle-itext ;
: reject-clash-text ( seq -- seq' ) "clash" reject-by-oracle-itext ;
: reject-cleave-text ( seq -- seq' ) "cleave" reject-by-oracle-itext ;
: reject-cloak-text ( seq -- seq' ) "cloak" reject-by-oracle-itext ;
: reject-cohort-text ( seq -- seq' ) "cohort" reject-by-oracle-itext ;
: reject-collect-evidence-text ( seq -- seq' ) "collect evidence" reject-by-oracle-itext ;
: reject-companion-text ( seq -- seq' ) "companion" reject-by-oracle-itext ;
: reject-compleated-text ( seq -- seq' ) "compleated" reject-by-oracle-itext ;
: reject-conjure-text ( seq -- seq' ) "conjure" reject-by-oracle-itext ;
: reject-connive-text ( seq -- seq' ) "connive" reject-by-oracle-itext ;
: reject-conspire-text ( seq -- seq' ) "conspire" reject-by-oracle-itext ;
: reject-constellation-text ( seq -- seq' ) "constellation" reject-by-oracle-itext ;
: reject-converge-text ( seq -- seq' ) "converge" reject-by-oracle-itext ;
: reject-convert-text ( seq -- seq' ) "convert" reject-by-oracle-itext ;
: reject-convoke-text ( seq -- seq' ) "convoke" reject-by-oracle-itext ;
: reject-corrupted-text ( seq -- seq' ) "corrupted" reject-by-oracle-itext ;
: reject-council's-dilemma-text ( seq -- seq' ) "council's dilemma" reject-by-oracle-itext ;
: reject-coven-text ( seq -- seq' ) "coven" reject-by-oracle-itext ;
: reject-craft-text ( seq -- seq' ) "craft" reject-by-oracle-itext ;
: reject-crew-text ( seq -- seq' ) "crew" reject-by-oracle-itext ;
: reject-cumulative-upkeep-text ( seq -- seq' ) "cumulative upkeep" reject-by-oracle-itext ;
: reject-cycling-text ( seq -- seq' ) "cycling" reject-by-oracle-itext ;
: reject-dash-text ( seq -- seq' ) "dash" reject-by-oracle-itext ;
: reject-daybound-text ( seq -- seq' ) "daybound" reject-by-oracle-itext ;
: reject-deathtouch-text ( seq -- seq' ) "deathtouch" reject-by-oracle-itext ;
: reject-defender-text ( seq -- seq' ) "defender" reject-by-oracle-itext ;
: reject-delirium-text ( seq -- seq' ) "delirium" reject-by-oracle-itext ;
: reject-delve-text ( seq -- seq' ) "delve" reject-by-oracle-itext ;
: reject-descend-text ( seq -- seq' ) "descend" reject-by-oracle-itext ;
: reject-detain-text ( seq -- seq' ) "detain" reject-by-oracle-itext ;
: reject-dethrone-text ( seq -- seq' ) "dethrone" reject-by-oracle-itext ;
: reject-devoid-text ( seq -- seq' ) "devoid" reject-by-oracle-itext ;
: reject-devour-text ( seq -- seq' ) "devour" reject-by-oracle-itext ;
: reject-discover-text ( seq -- seq' ) "discover" reject-by-oracle-itext ;
: reject-disguise-text ( seq -- seq' ) "disguise" reject-by-oracle-itext ;
: reject-disturb-text ( seq -- seq' ) "disturb" reject-by-oracle-itext ;
: reject-doctor's-companion-text ( seq -- seq' ) "doctor's companion" reject-by-oracle-itext ;
: reject-domain-text ( seq -- seq' ) "domain" reject-by-oracle-itext ;
: reject-double-strike-text ( seq -- seq' ) "double strike" reject-by-oracle-itext ;
: reject-dredge-text ( seq -- seq' ) "dredge" reject-by-oracle-itext ;
: reject-echo-text ( seq -- seq' ) "echo" reject-by-oracle-itext ;
: reject-eerie-text ( seq -- seq' ) "eerie" reject-by-oracle-itext ;
: reject-embalm-text ( seq -- seq' ) "embalm" reject-by-oracle-itext ;
: reject-emerge-text ( seq -- seq' ) "emerge" reject-by-oracle-itext ;
: reject-eminence-text ( seq -- seq' ) "eminence" reject-by-oracle-itext ;
: reject-enchant-text ( seq -- seq' ) "enchant" reject-by-oracle-itext ;
: reject-encore-text ( seq -- seq' ) "encore" reject-by-oracle-itext ;
: reject-enlist-text ( seq -- seq' ) "enlist" reject-by-oracle-itext ;
: reject-enrage-text ( seq -- seq' ) "enrage" reject-by-oracle-itext ;
: reject-entwine-text ( seq -- seq' ) "entwine" reject-by-oracle-itext ;
: reject-equip-text ( seq -- seq' ) "equip" reject-by-oracle-itext ;
: reject-escalate-text ( seq -- seq' ) "escalate" reject-by-oracle-itext ;
: reject-escape-text ( seq -- seq' ) "escape" reject-by-oracle-itext ;
: reject-eternalize-text ( seq -- seq' ) "eternalize" reject-by-oracle-itext ;
: reject-evoke-text ( seq -- seq' ) "evoke" reject-by-oracle-itext ;
: reject-evolve-text ( seq -- seq' ) "evolve" reject-by-oracle-itext ;
: reject-exalted-text ( seq -- seq' ) "exalted" reject-by-oracle-itext ;
: reject-exert-text ( seq -- seq' ) "exert" reject-by-oracle-itext ;
: reject-exploit-text ( seq -- seq' ) "exploit" reject-by-oracle-itext ;
: reject-explore-text ( seq -- seq' ) "explore" reject-by-oracle-itext ;
: reject-extort-text ( seq -- seq' ) "extort" reject-by-oracle-itext ;
: reject-fabricate-text ( seq -- seq' ) "fabricate" reject-by-oracle-itext ;
: reject-fading-text ( seq -- seq' ) "fading" reject-by-oracle-itext ;
: reject-fateful-hour-text ( seq -- seq' ) "fateful hour" reject-by-oracle-itext ;
: reject-fathomless-descent-text ( seq -- seq' ) "fathomless descent" reject-by-oracle-itext ;
: reject-fear-text ( seq -- seq' ) "fear" reject-by-oracle-itext ;
: reject-ferocious-text ( seq -- seq' ) "ferocious" reject-by-oracle-itext ;
: reject-fight-text ( seq -- seq' ) "fight" reject-by-oracle-itext ;
: reject-first-strike-text ( seq -- seq' ) "first strike" reject-by-oracle-itext ;
: reject-flanking-text ( seq -- seq' ) "flanking" reject-by-oracle-itext ;
: reject-flash-text ( seq -- seq' ) "flash" reject-by-oracle-itext ;
: reject-flashback-text ( seq -- seq' ) "flashback" reject-by-oracle-itext ;
: reject-flying-text ( seq -- seq' ) "flying" reject-by-oracle-itext ;
: reject-food-text ( seq -- seq' ) "food" reject-by-oracle-itext ;
: reject-for-mirrodin!-text ( seq -- seq' ) "for mirrodin!" reject-by-oracle-itext ;
: reject-forecast-text ( seq -- seq' ) "forecast" reject-by-oracle-itext ;
: reject-forestcycling-text ( seq -- seq' ) "forestcycling" reject-by-oracle-itext ;
: reject-forestwalk-text ( seq -- seq' ) "forestwalk" reject-by-oracle-itext ;
: reject-foretell-text ( seq -- seq' ) "foretell" reject-by-oracle-itext ;
: reject-formidable-text ( seq -- seq' ) "formidable" reject-by-oracle-itext ;
: reject-friends-forever-text ( seq -- seq' ) "friends forever" reject-by-oracle-itext ;
: reject-fuse-text ( seq -- seq' ) "fuse" reject-by-oracle-itext ;
: reject-goad-text ( seq -- seq' ) "goad" reject-by-oracle-itext ;
: reject-graft-text ( seq -- seq' ) "graft" reject-by-oracle-itext ;
: reject-haste-text ( seq -- seq' ) "haste" reject-by-oracle-itext ;
: reject-haunt-text ( seq -- seq' ) "haunt" reject-by-oracle-itext ;
: reject-hellbent-text ( seq -- seq' ) "hellbent" reject-by-oracle-itext ;
: reject-hero's-reward-text ( seq -- seq' ) "hero's reward" reject-by-oracle-itext ;
: reject-heroic-text ( seq -- seq' ) "heroic" reject-by-oracle-itext ;
: reject-hexproof-text ( seq -- seq' ) "hexproof" reject-by-oracle-itext ;
: reject-hexproof-from-text ( seq -- seq' ) "hexproof from" reject-by-oracle-itext ;
: reject-hidden-agenda-text ( seq -- seq' ) "hidden agenda" reject-by-oracle-itext ;
: reject-hideaway-text ( seq -- seq' ) "hideaway" reject-by-oracle-itext ;
: reject-horsemanship-text ( seq -- seq' ) "horsemanship" reject-by-oracle-itext ;
: reject-impending-text ( seq -- seq' ) "impending" reject-by-oracle-itext ;
: reject-imprint-text ( seq -- seq' ) "imprint" reject-by-oracle-itext ;
: reject-improvise-text ( seq -- seq' ) "improvise" reject-by-oracle-itext ;
: reject-incubate-text ( seq -- seq' ) "incubate" reject-by-oracle-itext ;
: reject-indestructible-text ( seq -- seq' ) "indestructible" reject-by-oracle-itext ;
: reject-infect-text ( seq -- seq' ) "infect" reject-by-oracle-itext ;
: reject-ingest-text ( seq -- seq' ) "ingest" reject-by-oracle-itext ;
: reject-inspired-text ( seq -- seq' ) "inspired" reject-by-oracle-itext ;
: reject-intensity-text ( seq -- seq' ) "intensity" reject-by-oracle-itext ;
: reject-intimidate-text ( seq -- seq' ) "intimidate" reject-by-oracle-itext ;
: reject-investigate-text ( seq -- seq' ) "investigate" reject-by-oracle-itext ;
: reject-islandcycling-text ( seq -- seq' ) "islandcycling" reject-by-oracle-itext ;
: reject-islandwalk-text ( seq -- seq' ) "islandwalk" reject-by-oracle-itext ;
: reject-jump-start-text ( seq -- seq' ) "jump-start" reject-by-oracle-itext ;
: reject-kicker-text ( seq -- seq' ) "kicker" reject-by-oracle-itext ;
: reject-kinship-text ( seq -- seq' ) "kinship" reject-by-oracle-itext ;
: reject-landcycling-text ( seq -- seq' ) "landcycling" reject-by-oracle-itext ;
: reject-landfall-text ( seq -- seq' ) "landfall" reject-by-oracle-itext ;
: reject-landwalk-text ( seq -- seq' ) "landwalk" reject-by-oracle-itext ;
: reject-learn-text ( seq -- seq' ) "learn" reject-by-oracle-itext ;
: reject-level-up-text ( seq -- seq' ) "level up" reject-by-oracle-itext ;
: reject-lieutenant-text ( seq -- seq' ) "lieutenant" reject-by-oracle-itext ;
: reject-lifelink-text ( seq -- seq' ) "lifelink" reject-by-oracle-itext ;
: reject-living-metal-text ( seq -- seq' ) "living metal" reject-by-oracle-itext ;
: reject-living-weapon-text ( seq -- seq' ) "living weapon" reject-by-oracle-itext ;
: reject-madness-text ( seq -- seq' ) "madness" reject-by-oracle-itext ;
: reject-magecraft-text ( seq -- seq' ) "magecraft" reject-by-oracle-itext ;
: reject-manifest-text ( seq -- seq' ) "manifest" reject-by-oracle-itext ;
: reject-manifest-dread-text ( seq -- seq' ) "manifest dread" reject-by-oracle-itext ;
: reject-megamorph-text ( seq -- seq' ) "megamorph" reject-by-oracle-itext ;
: reject-meld-text ( seq -- seq' ) "meld" reject-by-oracle-itext ;
: reject-melee-text ( seq -- seq' ) "melee" reject-by-oracle-itext ;
: reject-menace-text ( seq -- seq' ) "menace" reject-by-oracle-itext ;
: reject-mentor-text ( seq -- seq' ) "mentor" reject-by-oracle-itext ;
: reject-metalcraft-text ( seq -- seq' ) "metalcraft" reject-by-oracle-itext ;
: reject-mill-text ( seq -- seq' ) "mill" reject-by-oracle-itext ;
: reject-miracle-text ( seq -- seq' ) "miracle" reject-by-oracle-itext ;
: reject-modular-text ( seq -- seq' ) "modular" reject-by-oracle-itext ;
: reject-monstrosity-text ( seq -- seq' ) "monstrosity" reject-by-oracle-itext ;
: reject-morbid-text ( seq -- seq' ) "morbid" reject-by-oracle-itext ;
: reject-more-than-meets-the-eye-text ( seq -- seq' ) "more than meets the eye" reject-by-oracle-itext ;
: reject-morph-text ( seq -- seq' ) "morph" reject-by-oracle-itext ;
: reject-mountaincycling-text ( seq -- seq' ) "mountaincycling" reject-by-oracle-itext ;
: reject-mountainwalk-text ( seq -- seq' ) "mountainwalk" reject-by-oracle-itext ;
: reject-multikicker-text ( seq -- seq' ) "multikicker" reject-by-oracle-itext ;
: reject-mutate-text ( seq -- seq' ) "mutate" reject-by-oracle-itext ;
: reject-myriad-text ( seq -- seq' ) "myriad" reject-by-oracle-itext ;
: reject-nightbound-text ( seq -- seq' ) "nightbound" reject-by-oracle-itext ;
: reject-ninjutsu-text ( seq -- seq' ) "ninjutsu" reject-by-oracle-itext ;
: reject-offering-text ( seq -- seq' ) "offering" reject-by-oracle-itext ;
: reject-offspring-text ( seq -- seq' ) "offspring" reject-by-oracle-itext ;
: reject-open-an-attraction-text ( seq -- seq' ) "open an attraction" reject-by-oracle-itext ;
: reject-outlast-text ( seq -- seq' ) "outlast" reject-by-oracle-itext ;
: reject-overload-text ( seq -- seq' ) "overload" reject-by-oracle-itext ;
: reject-pack-tactics-text ( seq -- seq' ) "pack tactics" reject-by-oracle-itext ;
: reject-paradox-text ( seq -- seq' ) "paradox" reject-by-oracle-itext ;
: reject-parley-text ( seq -- seq' ) "parley" reject-by-oracle-itext ;
: reject-partner-text ( seq -- seq' ) "partner" reject-by-oracle-itext ;
: reject-partner-with-text ( seq -- seq' ) "partner with" reject-by-oracle-itext ;
: reject-persist-text ( seq -- seq' ) "persist" reject-by-oracle-itext ;
: reject-phasing-text ( seq -- seq' ) "phasing" reject-by-oracle-itext ;
: reject-plainscycling-text ( seq -- seq' ) "plainscycling" reject-by-oracle-itext ;
: reject-plot-text ( seq -- seq' ) "plot" reject-by-oracle-itext ;
: reject-populate-text ( seq -- seq' ) "populate" reject-by-oracle-itext ;
: reject-proliferate-text ( seq -- seq' ) "proliferate" reject-by-oracle-itext ;
: reject-protection-text ( seq -- seq' ) "protection" reject-by-oracle-itext ;
: reject-prototype-text ( seq -- seq' ) "prototype" reject-by-oracle-itext ;
: reject-provoke-text ( seq -- seq' ) "provoke" reject-by-oracle-itext ;
: reject-prowess-text ( seq -- seq' ) "prowess" reject-by-oracle-itext ;
: reject-prowl-text ( seq -- seq' ) "prowl" reject-by-oracle-itext ;
: reject-radiance-text ( seq -- seq' ) "radiance" reject-by-oracle-itext ;
: reject-raid-text ( seq -- seq' ) "raid" reject-by-oracle-itext ;
: reject-rally-text ( seq -- seq' ) "rally" reject-by-oracle-itext ;
: reject-rampage-text ( seq -- seq' ) "rampage" reject-by-oracle-itext ;
: reject-ravenous-text ( seq -- seq' ) "ravenous" reject-by-oracle-itext ;
: reject-reach-text ( seq -- seq' ) "reach" reject-by-oracle-itext ;
: reject-read-ahead-text ( seq -- seq' ) "read ahead" reject-by-oracle-itext ;
: reject-rebound-text ( seq -- seq' ) "rebound" reject-by-oracle-itext ;
: reject-reconfigure-text ( seq -- seq' ) "reconfigure" reject-by-oracle-itext ;
: reject-recover-text ( seq -- seq' ) "recover" reject-by-oracle-itext ;
: reject-reinforce-text ( seq -- seq' ) "reinforce" reject-by-oracle-itext ;
: reject-renown-text ( seq -- seq' ) "renown" reject-by-oracle-itext ;
: reject-replicate-text ( seq -- seq' ) "replicate" reject-by-oracle-itext ;
: reject-retrace-text ( seq -- seq' ) "retrace" reject-by-oracle-itext ;
: reject-revolt-text ( seq -- seq' ) "revolt" reject-by-oracle-itext ;
: reject-riot-text ( seq -- seq' ) "riot" reject-by-oracle-itext ;
: reject-role-token-text ( seq -- seq' ) "role token" reject-by-oracle-itext ;
: reject-saddle-text ( seq -- seq' ) "saddle" reject-by-oracle-itext ;
: reject-scavenge-text ( seq -- seq' ) "scavenge" reject-by-oracle-itext ;
: reject-scry-text ( seq -- seq' ) "scry" reject-by-oracle-itext ;
: reject-seek-text ( seq -- seq' ) "seek" reject-by-oracle-itext ;
: reject-shadow-text ( seq -- seq' ) "shadow" reject-by-oracle-itext ;
: reject-shroud-text ( seq -- seq' ) "shroud" reject-by-oracle-itext ;
: reject-skulk-text ( seq -- seq' ) "skulk" reject-by-oracle-itext ;
: reject-soulbond-text ( seq -- seq' ) "soulbond" reject-by-oracle-itext ;
: reject-soulshift-text ( seq -- seq' ) "soulshift" reject-by-oracle-itext ;
: reject-specialize-text ( seq -- seq' ) "specialize" reject-by-oracle-itext ;
: reject-spectacle-text ( seq -- seq' ) "spectacle" reject-by-oracle-itext ;
: reject-spell-mastery-text ( seq -- seq' ) "spell mastery" reject-by-oracle-itext ;
: reject-splice-text ( seq -- seq' ) "splice" reject-by-oracle-itext ;
: reject-split-second-text ( seq -- seq' ) "split second" reject-by-oracle-itext ;
: reject-spree-text ( seq -- seq' ) "spree" reject-by-oracle-itext ;
: reject-squad-text ( seq -- seq' ) "squad" reject-by-oracle-itext ;
: reject-storm-text ( seq -- seq' ) "storm" reject-by-oracle-itext ;
: reject-strive-text ( seq -- seq' ) "strive" reject-by-oracle-itext ;
: reject-sunburst-text ( seq -- seq' ) "sunburst" reject-by-oracle-itext ;
: reject-support-text ( seq -- seq' ) "support" reject-by-oracle-itext ;
: reject-surge-text ( seq -- seq' ) "surge" reject-by-oracle-itext ;
: reject-surveil-text ( seq -- seq' ) "surveil" reject-by-oracle-itext ;
: reject-survival-text ( seq -- seq' ) "survival" reject-by-oracle-itext ;
: reject-suspect-text ( seq -- seq' ) "suspect" reject-by-oracle-itext ;
: reject-suspend-text ( seq -- seq' ) "suspend" reject-by-oracle-itext ;
: reject-swampcycling-text ( seq -- seq' ) "swampcycling" reject-by-oracle-itext ;
: reject-swampwalk-text ( seq -- seq' ) "swampwalk" reject-by-oracle-itext ;
: reject-threshold-text ( seq -- seq' ) "threshold" reject-by-oracle-itext ;
: reject-time-travel-text ( seq -- seq' ) "time travel" reject-by-oracle-itext ;
: reject-totem-armor-text ( seq -- seq' ) "totem armor" reject-by-oracle-itext ;
: reject-toxic-text ( seq -- seq' ) "toxic" reject-by-oracle-itext ;
: reject-training-text ( seq -- seq' ) "training" reject-by-oracle-itext ;
: reject-trample-text ( seq -- seq' ) "trample" reject-by-oracle-itext ;
: reject-transform-text ( seq -- seq' ) "transform" reject-by-oracle-itext ;
: reject-transmute-text ( seq -- seq' ) "transmute" reject-by-oracle-itext ;
: reject-treasure-text ( seq -- seq' ) "treasure" reject-by-oracle-itext ;
: reject-tribute-text ( seq -- seq' ) "tribute" reject-by-oracle-itext ;
: reject-typecycling-text ( seq -- seq' ) "typecycling" reject-by-oracle-itext ;
: reject-undergrowth-text ( seq -- seq' ) "undergrowth" reject-by-oracle-itext ;
: reject-undying-text ( seq -- seq' ) "undying" reject-by-oracle-itext ;
: reject-unearth-text ( seq -- seq' ) "unearth" reject-by-oracle-itext ;
: reject-unleash-text ( seq -- seq' ) "unleash" reject-by-oracle-itext ;
: reject-vanishing-text ( seq -- seq' ) "vanishing" reject-by-oracle-itext ;
: reject-venture-into-the-dungeon-text ( seq -- seq' ) "venture into the dungeon" reject-by-oracle-itext ;
: reject-vigilance-text ( seq -- seq' ) "vigilance" reject-by-oracle-itext ;
: reject-ward-text ( seq -- seq' ) "ward" reject-by-oracle-itext ;
: reject-will-of-the-council-text ( seq -- seq' ) "will of the council" reject-by-oracle-itext ;
: reject-wither-text ( seq -- seq' ) "wither" reject-by-oracle-itext ;

: reject-day ( seq -- seq' ) "day" reject-by-oracle-itext ;
: reject-night ( seq -- seq' ) "night" reject-by-oracle-itext ;
: reject-daybound ( seq -- seq' ) "daybound" reject-by-oracle-itext ;
: reject-nightbound ( seq -- seq' ) "nightbound" reject-by-oracle-itext ;

: reject-cave ( seq -- seq' ) "cave" reject-land-subtype ;
: reject-sphere ( seq -- seq' ) "sphere" reject-land-subtype ;

: reject-mount ( seq -- seq' ) "mount" reject-by-oracle-itext ;
: reject-outlaw ( seq -- seq' )
    { "Assassin" "Mercenary" "Pirate" "Rogue" "Warlock" } reject-subtype-intersects ;
: reject-plot ( seq -- seq' ) "plot" reject-by-oracle-itext ;
: reject-saddle ( seq -- seq' ) "saddle" reject-by-oracle-itext ;
: reject-spree ( seq -- seq' ) "saddle" reject-by-oracle-itext ;

: reject-adamant-keyword ( seq -- seq' ) "adamant" reject-by-keyword ;
: reject-adapt-keyword ( seq -- seq' ) "adapt" reject-by-keyword ;
: reject-addendum-keyword ( seq -- seq' ) "addendum" reject-by-keyword ;
: reject-affinity-keyword ( seq -- seq' ) "affinity" reject-by-keyword ;
: reject-afflict-keyword ( seq -- seq' ) "afflict" reject-by-keyword ;
: reject-afterlife-keyword ( seq -- seq' ) "afterlife" reject-by-keyword ;
: reject-aftermath-keyword ( seq -- seq' ) "aftermath" reject-by-keyword ;
: reject-alliance-keyword ( seq -- seq' ) "alliance" reject-by-keyword ;
: reject-amass-keyword ( seq -- seq' ) "amass" reject-by-keyword ;
: reject-amplify-keyword ( seq -- seq' ) "amplify" reject-by-keyword ;
: reject-annihilator-keyword ( seq -- seq' ) "annihilator" reject-by-keyword ;
: reject-ascend-keyword ( seq -- seq' ) "ascend" reject-by-keyword ;
: reject-assemble-keyword ( seq -- seq' ) "assemble" reject-by-keyword ;
: reject-assist-keyword ( seq -- seq' ) "assist" reject-by-keyword ;
: reject-augment-keyword ( seq -- seq' ) "augment" reject-by-keyword ;
: reject-awaken-keyword ( seq -- seq' ) "awaken" reject-by-keyword ;
: reject-backup-keyword ( seq -- seq' ) "backup" reject-by-keyword ;
: reject-banding-keyword ( seq -- seq' ) "banding" reject-by-keyword ;
: reject-bargain-keyword ( seq -- seq' ) "bargain" reject-by-keyword ;
: reject-basic-landcycling-keyword ( seq -- seq' ) "basic-landcycling" reject-by-keyword ;
: reject-battalion-keyword ( seq -- seq' ) "battalion" reject-by-keyword ;
: reject-battle-cry-keyword ( seq -- seq' ) "battle-cry" reject-by-keyword ;
: reject-bestow-keyword ( seq -- seq' ) "bestow" reject-by-keyword ;
: reject-blitz-keyword ( seq -- seq' ) "blitz" reject-by-keyword ;
: reject-bloodrush-keyword ( seq -- seq' ) "bloodrush" reject-by-keyword ;
: reject-bloodthirst-keyword ( seq -- seq' ) "bloodthirst" reject-by-keyword ;
: reject-boast-keyword ( seq -- seq' ) "boast" reject-by-keyword ;
: reject-bolster-keyword ( seq -- seq' ) "bolster" reject-by-keyword ;
: reject-bushido-keyword ( seq -- seq' ) "bushido" reject-by-keyword ;
: reject-buyback-keyword ( seq -- seq' ) "buyback" reject-by-keyword ;
: reject-cascade-keyword ( seq -- seq' ) "cascade" reject-by-keyword ;
: reject-casualty-keyword ( seq -- seq' ) "casualty" reject-by-keyword ;
: reject-celebration-keyword ( seq -- seq' ) "celebration" reject-by-keyword ;
: reject-champion-keyword ( seq -- seq' ) "champion" reject-by-keyword ;
: reject-changeling-keyword ( seq -- seq' ) "changeling" reject-by-keyword ;
: reject-channel-keyword ( seq -- seq' ) "channel" reject-by-keyword ;
: reject-choose-a-background-keyword ( seq -- seq' ) "choose-a-background" reject-by-keyword ;
: reject-chroma-keyword ( seq -- seq' ) "chroma" reject-by-keyword ;
: reject-cipher-keyword ( seq -- seq' ) "cipher" reject-by-keyword ;
: reject-clash-keyword ( seq -- seq' ) "clash" reject-by-keyword ;
: reject-cleave-keyword ( seq -- seq' ) "cleave" reject-by-keyword ;
: reject-cloak-keyword ( seq -- seq' ) "cloak" reject-by-keyword ;
: reject-cohort-keyword ( seq -- seq' ) "cohort" reject-by-keyword ;
: reject-collect-evidence-keyword ( seq -- seq' ) "collect-evidence" reject-by-keyword ;
: reject-companion-keyword ( seq -- seq' ) "companion" reject-by-keyword ;
: reject-compleated-keyword ( seq -- seq' ) "compleated" reject-by-keyword ;
: reject-conjure-keyword ( seq -- seq' ) "conjure" reject-by-keyword ;
: reject-connive-keyword ( seq -- seq' ) "connive" reject-by-keyword ;
: reject-conspire-keyword ( seq -- seq' ) "conspire" reject-by-keyword ;
: reject-constellation-keyword ( seq -- seq' ) "constellation" reject-by-keyword ;
: reject-converge-keyword ( seq -- seq' ) "converge" reject-by-keyword ;
: reject-convert-keyword ( seq -- seq' ) "convert" reject-by-keyword ;
: reject-convoke-keyword ( seq -- seq' ) "convoke" reject-by-keyword ;
: reject-corrupted-keyword ( seq -- seq' ) "corrupted" reject-by-keyword ;
: reject-council's-dilemma-keyword ( seq -- seq' ) "council's-dilemma" reject-by-keyword ;
: reject-coven-keyword ( seq -- seq' ) "coven" reject-by-keyword ;
: reject-craft-keyword ( seq -- seq' ) "craft" reject-by-keyword ;
: reject-crew-keyword ( seq -- seq' ) "crew" reject-by-keyword ;
: reject-cumulative-upkeep-keyword ( seq -- seq' ) "cumulative-upkeep" reject-by-keyword ;
: reject-cycling-keyword ( seq -- seq' ) "cycling" reject-by-keyword ;
: reject-dash-keyword ( seq -- seq' ) "dash" reject-by-keyword ;
: reject-daybound-keyword ( seq -- seq' ) "daybound" reject-by-keyword ;
: reject-deathtouch-keyword ( seq -- seq' ) "deathtouch" reject-by-keyword ;
: reject-defender-keyword ( seq -- seq' ) "defender" reject-by-keyword ;
: reject-delirium-keyword ( seq -- seq' ) "delirium" reject-by-keyword ;
: reject-delve-keyword ( seq -- seq' ) "delve" reject-by-keyword ;
: reject-descend-keyword ( seq -- seq' ) "descend" reject-by-keyword ;
: reject-detain-keyword ( seq -- seq' ) "detain" reject-by-keyword ;
: reject-dethrone-keyword ( seq -- seq' ) "dethrone" reject-by-keyword ;
: reject-devoid-keyword ( seq -- seq' ) "devoid" reject-by-keyword ;
: reject-devour-keyword ( seq -- seq' ) "devour" reject-by-keyword ;
: reject-discover-keyword ( seq -- seq' ) "discover" reject-by-keyword ;
: reject-disguise-keyword ( seq -- seq' ) "disguise" reject-by-keyword ;
: reject-disturb-keyword ( seq -- seq' ) "disturb" reject-by-keyword ;
: reject-doctor's-companion-keyword ( seq -- seq' ) "doctor's-companion" reject-by-keyword ;
: reject-domain-keyword ( seq -- seq' ) "domain" reject-by-keyword ;
: reject-double-strike-keyword ( seq -- seq' ) "double-strike" reject-by-keyword ;
: reject-dredge-keyword ( seq -- seq' ) "dredge" reject-by-keyword ;
: reject-echo-keyword ( seq -- seq' ) "echo" reject-by-keyword ;
: reject-eerie-keyword ( seq -- seq' ) "eerie" reject-by-keyword ;
: reject-embalm-keyword ( seq -- seq' ) "embalm" reject-by-keyword ;
: reject-emerge-keyword ( seq -- seq' ) "emerge" reject-by-keyword ;
: reject-eminence-keyword ( seq -- seq' ) "eminence" reject-by-keyword ;
: reject-enchant-keyword ( seq -- seq' ) "enchant" reject-by-keyword ;
: reject-encore-keyword ( seq -- seq' ) "encore" reject-by-keyword ;
: reject-enlist-keyword ( seq -- seq' ) "enlist" reject-by-keyword ;
: reject-enrage-keyword ( seq -- seq' ) "enrage" reject-by-keyword ;
: reject-entwine-keyword ( seq -- seq' ) "entwine" reject-by-keyword ;
: reject-equip-keyword ( seq -- seq' ) "equip" reject-by-keyword ;
: reject-escalate-keyword ( seq -- seq' ) "escalate" reject-by-keyword ;
: reject-escape-keyword ( seq -- seq' ) "escape" reject-by-keyword ;
: reject-eternalize-keyword ( seq -- seq' ) "eternalize" reject-by-keyword ;
: reject-evoke-keyword ( seq -- seq' ) "evoke" reject-by-keyword ;
: reject-evolve-keyword ( seq -- seq' ) "evolve" reject-by-keyword ;
: reject-exalted-keyword ( seq -- seq' ) "exalted" reject-by-keyword ;
: reject-exert-keyword ( seq -- seq' ) "exert" reject-by-keyword ;
: reject-exploit-keyword ( seq -- seq' ) "exploit" reject-by-keyword ;
: reject-explore-keyword ( seq -- seq' ) "explore" reject-by-keyword ;
: reject-extort-keyword ( seq -- seq' ) "extort" reject-by-keyword ;
: reject-fabricate-keyword ( seq -- seq' ) "fabricate" reject-by-keyword ;
: reject-fading-keyword ( seq -- seq' ) "fading" reject-by-keyword ;
: reject-fateful-hour-keyword ( seq -- seq' ) "fateful-hour" reject-by-keyword ;
: reject-fathomless-descent-keyword ( seq -- seq' ) "fathomless-descent" reject-by-keyword ;
: reject-fear-keyword ( seq -- seq' ) "fear" reject-by-keyword ;
: reject-ferocious-keyword ( seq -- seq' ) "ferocious" reject-by-keyword ;
: reject-fight-keyword ( seq -- seq' ) "fight" reject-by-keyword ;
: reject-first-strike-keyword ( seq -- seq' ) "first-strike" reject-by-keyword ;
: reject-flanking-keyword ( seq -- seq' ) "flanking" reject-by-keyword ;
: reject-flash-keyword ( seq -- seq' ) "flash" reject-by-keyword ;
: reject-flashback-keyword ( seq -- seq' ) "flashback" reject-by-keyword ;
: reject-flying-keyword ( seq -- seq' ) "flying" reject-by-keyword ;
: reject-food-keyword ( seq -- seq' ) "food" reject-by-keyword ;
: reject-forage-keyword ( seq -- seq' ) "forage" reject-by-keyword ;
: reject-for-mirrodin!-keyword ( seq -- seq' ) "for-mirrodin!" reject-by-keyword ;
: reject-forecast-keyword ( seq -- seq' ) "forecast" reject-by-keyword ;
: reject-forestcycling-keyword ( seq -- seq' ) "forestcycling" reject-by-keyword ;
: reject-forestwalk-keyword ( seq -- seq' ) "forestwalk" reject-by-keyword ;
: reject-foretell-keyword ( seq -- seq' ) "foretell" reject-by-keyword ;
: reject-formidable-keyword ( seq -- seq' ) "formidable" reject-by-keyword ;
: reject-friends-forever-keyword ( seq -- seq' ) "friends-forever" reject-by-keyword ;
: reject-fuse-keyword ( seq -- seq' ) "fuse" reject-by-keyword ;
: reject-gift-keyword ( seq -- seq' ) "gift" reject-by-keyword ;
: reject-goad-keyword ( seq -- seq' ) "goad" reject-by-keyword ;
: reject-graft-keyword ( seq -- seq' ) "graft" reject-by-keyword ;
: reject-haste-keyword ( seq -- seq' ) "haste" reject-by-keyword ;
: reject-haunt-keyword ( seq -- seq' ) "haunt" reject-by-keyword ;
: reject-hellbent-keyword ( seq -- seq' ) "hellbent" reject-by-keyword ;
: reject-hero's-reward-keyword ( seq -- seq' ) "hero's-reward" reject-by-keyword ;
: reject-heroic-keyword ( seq -- seq' ) "heroic" reject-by-keyword ;
: reject-hexproof-keyword ( seq -- seq' ) "hexproof" reject-by-keyword ;
: reject-hexproof-from-keyword ( seq -- seq' ) "hexproof-from" reject-by-keyword ;
: reject-hidden-agenda-keyword ( seq -- seq' ) "hidden-agenda" reject-by-keyword ;
: reject-hideaway-keyword ( seq -- seq' ) "hideaway" reject-by-keyword ;
: reject-horsemanship-keyword ( seq -- seq' ) "horsemanship" reject-by-keyword ;
: reject-impending-keyword ( seq -- seq' ) "impending" reject-by-keyword ;
: reject-imprint-keyword ( seq -- seq' ) "imprint" reject-by-keyword ;
: reject-improvise-keyword ( seq -- seq' ) "improvise" reject-by-keyword ;
: reject-incubate-keyword ( seq -- seq' ) "incubate" reject-by-keyword ;
: reject-indestructible-keyword ( seq -- seq' ) "indestructible" reject-by-keyword ;
: reject-infect-keyword ( seq -- seq' ) "infect" reject-by-keyword ;
: reject-ingest-keyword ( seq -- seq' ) "ingest" reject-by-keyword ;
: reject-inspired-keyword ( seq -- seq' ) "inspired" reject-by-keyword ;
: reject-intensity-keyword ( seq -- seq' ) "intensity" reject-by-keyword ;
: reject-intimidate-keyword ( seq -- seq' ) "intimidate" reject-by-keyword ;
: reject-investigate-keyword ( seq -- seq' ) "investigate" reject-by-keyword ;
: reject-islandcycling-keyword ( seq -- seq' ) "islandcycling" reject-by-keyword ;
: reject-islandwalk-keyword ( seq -- seq' ) "islandwalk" reject-by-keyword ;
: reject-jump-start-keyword ( seq -- seq' ) "jump-start" reject-by-keyword ;
: reject-kicker-keyword ( seq -- seq' ) "kicker" reject-by-keyword ;
: reject-kinship-keyword ( seq -- seq' ) "kinship" reject-by-keyword ;
: reject-landcycling-keyword ( seq -- seq' ) "landcycling" reject-by-keyword ;
: reject-landfall-keyword ( seq -- seq' ) "landfall" reject-by-keyword ;
: reject-landwalk-keyword ( seq -- seq' ) "landwalk" reject-by-keyword ;
: reject-learn-keyword ( seq -- seq' ) "learn" reject-by-keyword ;
: reject-level-up-keyword ( seq -- seq' ) "level-up" reject-by-keyword ;
: reject-lieutenant-keyword ( seq -- seq' ) "lieutenant" reject-by-keyword ;
: reject-lifelink-keyword ( seq -- seq' ) "lifelink" reject-by-keyword ;
: reject-living-metal-keyword ( seq -- seq' ) "living-metal" reject-by-keyword ;
: reject-living-weapon-keyword ( seq -- seq' ) "living-weapon" reject-by-keyword ;
: reject-madness-keyword ( seq -- seq' ) "madness" reject-by-keyword ;
: reject-magecraft-keyword ( seq -- seq' ) "magecraft" reject-by-keyword ;
: reject-manifest-keyword ( seq -- seq' ) "manifest" reject-by-keyword ;
: reject-manifest-dread-keyword ( seq -- seq' ) "manifest dread" reject-by-keyword ;
: reject-megamorph-keyword ( seq -- seq' ) "megamorph" reject-by-keyword ;
: reject-meld-keyword ( seq -- seq' ) "meld" reject-by-keyword ;
: reject-melee-keyword ( seq -- seq' ) "melee" reject-by-keyword ;
: reject-menace-keyword ( seq -- seq' ) "menace" reject-by-keyword ;
: reject-mentor-keyword ( seq -- seq' ) "mentor" reject-by-keyword ;
: reject-metalcraft-keyword ( seq -- seq' ) "metalcraft" reject-by-keyword ;
: reject-mill-keyword ( seq -- seq' ) "mill" reject-by-keyword ;
: reject-miracle-keyword ( seq -- seq' ) "miracle" reject-by-keyword ;
: reject-modular-keyword ( seq -- seq' ) "modular" reject-by-keyword ;
: reject-monstrosity-keyword ( seq -- seq' ) "monstrosity" reject-by-keyword ;
: reject-morbid-keyword ( seq -- seq' ) "morbid" reject-by-keyword ;
: reject-more-than-meets-the-eye-keyword ( seq -- seq' ) "more-than-meets-the-eye" reject-by-keyword ;
: reject-morph-keyword ( seq -- seq' ) "morph" reject-by-keyword ;
: reject-mountaincycling-keyword ( seq -- seq' ) "mountaincycling" reject-by-keyword ;
: reject-mountainwalk-keyword ( seq -- seq' ) "mountainwalk" reject-by-keyword ;
: reject-multikicker-keyword ( seq -- seq' ) "multikicker" reject-by-keyword ;
: reject-mutate-keyword ( seq -- seq' ) "mutate" reject-by-keyword ;
: reject-myriad-keyword ( seq -- seq' ) "myriad" reject-by-keyword ;
: reject-nightbound-keyword ( seq -- seq' ) "nightbound" reject-by-keyword ;
: reject-ninjutsu-keyword ( seq -- seq' ) "ninjutsu" reject-by-keyword ;
: reject-offering-keyword ( seq -- seq' ) "offering" reject-by-keyword ;
: reject-open-an-attraction-keyword ( seq -- seq' ) "open-an-attraction" reject-by-keyword ;
: reject-outlast-keyword ( seq -- seq' ) "outlast" reject-by-keyword ;
: reject-overload-keyword ( seq -- seq' ) "overload" reject-by-keyword ;
: reject-pack-tactics-keyword ( seq -- seq' ) "pack-tactics" reject-by-keyword ;
: reject-paradox-keyword ( seq -- seq' ) "paradox" reject-by-keyword ;
: reject-parley-keyword ( seq -- seq' ) "parley" reject-by-keyword ;
: reject-partner-keyword ( seq -- seq' ) "partner" reject-by-keyword ;
: reject-partner-with-keyword ( seq -- seq' ) "partner-with" reject-by-keyword ;
: reject-persist-keyword ( seq -- seq' ) "persist" reject-by-keyword ;
: reject-phasing-keyword ( seq -- seq' ) "phasing" reject-by-keyword ;
: reject-plainscycling-keyword ( seq -- seq' ) "plainscycling" reject-by-keyword ;
: reject-plot-keyword ( seq -- seq' ) "plot" reject-by-keyword ;
: reject-populate-keyword ( seq -- seq' ) "populate" reject-by-keyword ;
: reject-proliferate-keyword ( seq -- seq' ) "proliferate" reject-by-keyword ;
: reject-protection-keyword ( seq -- seq' ) "protection" reject-by-keyword ;
: reject-prototype-keyword ( seq -- seq' ) "prototype" reject-by-keyword ;
: reject-provoke-keyword ( seq -- seq' ) "provoke" reject-by-keyword ;
: reject-prowess-keyword ( seq -- seq' ) "prowess" reject-by-keyword ;
: reject-prowl-keyword ( seq -- seq' ) "prowl" reject-by-keyword ;
: reject-radiance-keyword ( seq -- seq' ) "radiance" reject-by-keyword ;
: reject-raid-keyword ( seq -- seq' ) "raid" reject-by-keyword ;
: reject-rally-keyword ( seq -- seq' ) "rally" reject-by-keyword ;
: reject-rampage-keyword ( seq -- seq' ) "rampage" reject-by-keyword ;
: reject-ravenous-keyword ( seq -- seq' ) "ravenous" reject-by-keyword ;
: reject-reach-keyword ( seq -- seq' ) "reach" reject-by-keyword ;
: reject-read-ahead-keyword ( seq -- seq' ) "read-ahead" reject-by-keyword ;
: reject-rebound-keyword ( seq -- seq' ) "rebound" reject-by-keyword ;
: reject-reconfigure-keyword ( seq -- seq' ) "reconfigure" reject-by-keyword ;
: reject-recover-keyword ( seq -- seq' ) "recover" reject-by-keyword ;
: reject-reinforce-keyword ( seq -- seq' ) "reinforce" reject-by-keyword ;
: reject-renown-keyword ( seq -- seq' ) "renown" reject-by-keyword ;
: reject-replicate-keyword ( seq -- seq' ) "replicate" reject-by-keyword ;
: reject-retrace-keyword ( seq -- seq' ) "retrace" reject-by-keyword ;
: reject-revolt-keyword ( seq -- seq' ) "revolt" reject-by-keyword ;
: reject-riot-keyword ( seq -- seq' ) "riot" reject-by-keyword ;
: reject-role-token-keyword ( seq -- seq' ) "role-token" reject-by-keyword ;
: reject-saddle-keyword ( seq -- seq' ) "saddle" reject-by-keyword ;
: reject-scavenge-keyword ( seq -- seq' ) "scavenge" reject-by-keyword ;
: reject-scry-keyword ( seq -- seq' ) "scry" reject-by-keyword ;
: reject-seek-keyword ( seq -- seq' ) "seek" reject-by-keyword ;
: reject-shadow-keyword ( seq -- seq' ) "shadow" reject-by-keyword ;
: reject-shroud-keyword ( seq -- seq' ) "shroud" reject-by-keyword ;
: reject-skulk-keyword ( seq -- seq' ) "skulk" reject-by-keyword ;
: reject-soulbond-keyword ( seq -- seq' ) "soulbond" reject-by-keyword ;
: reject-soulshift-keyword ( seq -- seq' ) "soulshift" reject-by-keyword ;
: reject-specialize-keyword ( seq -- seq' ) "specialize" reject-by-keyword ;
: reject-spectacle-keyword ( seq -- seq' ) "spectacle" reject-by-keyword ;
: reject-spell-mastery-keyword ( seq -- seq' ) "spell-mastery" reject-by-keyword ;
: reject-splice-keyword ( seq -- seq' ) "splice" reject-by-keyword ;
: reject-split-second-keyword ( seq -- seq' ) "split-second" reject-by-keyword ;
: reject-spree-keyword ( seq -- seq' ) "spree" reject-by-keyword ;
: reject-squad-keyword ( seq -- seq' ) "squad" reject-by-keyword ;
: reject-storm-keyword ( seq -- seq' ) "storm" reject-by-keyword ;
: reject-strive-keyword ( seq -- seq' ) "strive" reject-by-keyword ;
: reject-sunburst-keyword ( seq -- seq' ) "sunburst" reject-by-keyword ;
: reject-support-keyword ( seq -- seq' ) "support" reject-by-keyword ;
: reject-surge-keyword ( seq -- seq' ) "surge" reject-by-keyword ;
: reject-surveil-keyword ( seq -- seq' ) "surveil" reject-by-keyword ;
: reject-survival-keyword ( seq -- seq' ) "survival" reject-by-keyword ;
: reject-suspect-keyword ( seq -- seq' ) "suspect" reject-by-keyword ;
: reject-suspend-keyword ( seq -- seq' ) "suspend" reject-by-keyword ;
: reject-swampcycling-keyword ( seq -- seq' ) "swampcycling" reject-by-keyword ;
: reject-swampwalk-keyword ( seq -- seq' ) "swampwalk" reject-by-keyword ;
: reject-threshold-keyword ( seq -- seq' ) "threshold" reject-by-keyword ;
: reject-time-travel-keyword ( seq -- seq' ) "time-travel" reject-by-keyword ;
: reject-totem-armor-keyword ( seq -- seq' ) "totem-armor" reject-by-keyword ;
: reject-toxic-keyword ( seq -- seq' ) "toxic" reject-by-keyword ;
: reject-training-keyword ( seq -- seq' ) "training" reject-by-keyword ;
: reject-trample-keyword ( seq -- seq' ) "trample" reject-by-keyword ;
: reject-transform-keyword ( seq -- seq' ) "transform" reject-by-keyword ;
: reject-transmute-keyword ( seq -- seq' ) "transmute" reject-by-keyword ;
: reject-treasure-keyword ( seq -- seq' ) "treasure" reject-by-keyword ;
: reject-tribute-keyword ( seq -- seq' ) "tribute" reject-by-keyword ;
: reject-typecycling-keyword ( seq -- seq' ) "typecycling" reject-by-keyword ;
: reject-undergrowth-keyword ( seq -- seq' ) "undergrowth" reject-by-keyword ;
: reject-undying-keyword ( seq -- seq' ) "undying" reject-by-keyword ;
: reject-unearth-keyword ( seq -- seq' ) "unearth" reject-by-keyword ;
: reject-unleash-keyword ( seq -- seq' ) "unleash" reject-by-keyword ;
: reject-valiant-keyword ( seq -- seq' ) "valiant" reject-by-keyword ;
: reject-vanishing-keyword ( seq -- seq' ) "vanishing" reject-by-keyword ;
: reject-venture-into-the-dungeon-keyword ( seq -- seq' ) "venture-into-the-dungeon" reject-by-keyword ;
: reject-vigilance-keyword ( seq -- seq' ) "vigilance" reject-by-keyword ;
: reject-ward-keyword ( seq -- seq' ) "ward" reject-by-keyword ;
: reject-will-of-the-council-keyword ( seq -- seq' ) "will-of-the-council" reject-by-keyword ;
: reject-wither-keyword ( seq -- seq' ) "wither" reject-by-keyword ;

: reject-power=* ( seq -- seq' ) [ "power" of "*" = ] reject-card-faces-main-card ;
: reject-toughness=* ( seq -- seq' ) [ "toughness" of "*" = ] reject-card-faces-main-card ;

: reject-power= ( seq n -- seq' ) '[ "power" of _ mtg= ] reject-card-faces-main-card ;
: reject-power< ( seq n -- seq' ) '[ "power" of _ mtg< ] reject-card-faces-main-card ;
: reject-power> ( seq n -- seq' ) '[ "power" of _ mtg> ] reject-card-faces-main-card ;
: reject-power<= ( seq n -- seq' ) '[ "power" of _ mtg<= ] reject-card-faces-main-card ;
: reject-power>= ( seq n -- seq' ) '[ "power" of _ mtg>= ] reject-card-faces-main-card ;

: reject-toughness= ( seq n -- seq' ) '[ "toughness" of _ mtg= ] reject-card-faces-main-card ;
: reject-toughness< ( seq n -- seq' ) '[ "toughness" of _ mtg< ] reject-card-faces-main-card ;
: reject-toughness> ( seq n -- seq' ) '[ "toughness" of _ mtg> ] reject-card-faces-main-card ;
: reject-toughness<= ( seq n -- seq' ) '[ "toughness" of _ mtg<= ] reject-card-faces-main-card ;
: reject-toughness>= ( seq n -- seq' ) '[ "toughness" of _ mtg>= ] reject-card-faces-main-card ;

: map-props ( seq props -- seq' ) '[ _ intersect-keys ] map ;

: gadgets. ( seq -- )
    1 cut*
    [ output-stream get '[ _ write-gadget ] each ]
    [ output-stream get '[ _ print-gadget ] each ] bi* ;

: images. ( seq -- ) [ <image-gadget> ] map gadgets. ;

: normal-images-grid. ( seq -- )
    4 group
    [ [ card>image-uris ] map concat download-normal-images images. ] each ;

: small-card. ( assoc -- )
    card>image-uris download-small-images images. ;

: small-cards. ( seq -- ) [ small-card. ] each ;

: normal-card. ( assoc -- )
    card>image-uris download-normal-images images. ;

: normal-cards. ( seq -- ) [ normal-card. ] each ;
: standard-cards. ( seq -- ) filter-standard normal-cards. ;
: historic-cards. ( seq -- ) filter-historic normal-cards. ;
: modern-cards. ( seq -- ) filter-modern normal-cards. ;

! rarity is only on main card `json` (if there are two faces)
: card-face-summary. ( json seq -- )
    {
        [ nip "name" of write bl ]
        [ nip "mana_cost" of ?print ]
        [ nip "type_line" of ?write ]
        [ drop bl "--" write bl "rarity" of >title ?print ]
        [ nip [ "power" of ] [ "toughness" of ] bi 2dup and [ "/" glue print ] [ 2drop ] if ]
        [ nip "oracle_text" of ?print ]
    } 2cleave nl ;

: card-face-summaries. ( json seq -- ) [ card-face-summary. ] with each ;

: card-summary. ( assoc -- )
    dup
    [ "card_faces" of ]
    [ [ length number>string "Card Faces: " prepend print ] [ card-face-summaries. ] bi ]
    [ card-face-summary. ] ?if nl nl nl ;

: card-summaries. ( seq -- ) [ card-summary. ] each ;

: card-summary-with-pic. ( assoc -- )
    [ normal-card. ]
    [ card-summary. ] bi ;

: card-summaries-with-pics. ( seq -- ) [ card-summary-with-pic. ] each ;

: standard-dragons. ( -- )
    standard-cards
    "Dragon" filter-creature-subtype
    sort-by-cmc
    normal-cards. ;

: collect-by-cmc ( seq -- seq' ) [ "cmc" of ] collect-by ;

MEMO: mtg-sets-by-abbrev ( -- assoc )
    scryfall-all-cards-json
    [ [ "set" of ] [ "set_name" of ] bi ] H{ } map>assoc ;

MEMO: mtg-sets-by-name ( -- assoc )
    scryfall-all-cards-json
    [ [ "set_name" of ] [ "set" of ] bi ] H{ } map>assoc ;

: filter-mtg-set ( seq abbrev -- seq ) '[ "set" of _ = ] filter ;
: reject-mtg-set ( seq abbrev -- seq ) '[ "set" of _ = ] filter ;

: unique-set-names ( seq -- seq' ) [ "set_name" of ] map members ;
: unique-set-abbrevs ( seq -- seq' ) [ "set" of ] map members ;

: standard-set-names ( -- seq ) standard-cards unique-set-names ;
: standard-set-abbrevs ( -- seq ) standard-cards unique-set-abbrevs ;


: sets-by-release-date ( -- assoc )
    scryfall-all-cards-json
    [ [ "set_name" of ] [ "released_at" of ] bi ] H{ } map>assoc
    sort-values ;

: collect-cards-by-set-abbrev ( seq -- assoc ) [ "set" of ] collect-by ;
: collect-cards-by-set-name ( seq -- assoc ) [ "set_name" of ] collect-by ;
: cards-by-set-abbrev ( -- assoc ) mtg-oracle-cards collect-cards-by-set-abbrev ;
: cards-by-set-name ( -- assoc ) mtg-oracle-cards collect-cards-by-set-name ;

: filter-set ( seq abbrev -- seq ) >lower '[ "set" of _ = ] filter ;
: filter-set-intersect ( seq abbrevs -- seq ) [ >lower ] map '[ "set" of _ member? ] filter ;

: released-after ( seq date -- seq' )
    '[ "released_at" of ymd>timestamp _ after? ] filter ;

: reject-set ( seq abbrev -- seq ) >lower '[ "set" of _ = ] reject ;
: reject-set-intersect ( seq abbrevs -- seq ) [ >lower ] map '[ "set" of _ member? ] reject ;

! standard
: mid-cards ( -- seq ) mtg-oracle-cards "mid" filter-set ;
: vow-cards ( -- seq ) mtg-oracle-cards "vow" filter-set ;
: neo-cards ( -- seq ) mtg-oracle-cards "neo" filter-set ;
: snc-cards ( -- seq ) mtg-oracle-cards "snc" filter-set ;
: dmu-cards ( -- seq ) mtg-oracle-cards "dmu" filter-set ;
: bro-cards ( -- seq ) mtg-oracle-cards "bro" filter-set ;
: one-cards ( -- seq ) mtg-oracle-cards "one" filter-set ;
: mom-cards ( -- seq ) mtg-oracle-cards "mom" filter-set ;
: mat-cards ( -- seq ) mtg-oracle-cards "mat" filter-set ;
: woe-cards ( -- seq ) mtg-oracle-cards "woe" filter-set ;
: woe-cards-bonus ( -- seq ) mtg-oracle-cards [ "set" of "wot" = ] filter-set ;
: woe-cards-all ( -- seq ) mtg-oracle-cards { "woe" "wot" } filter-set-intersect ;
: lci-cards ( -- seq ) mtg-oracle-cards "lci" filter-set ;
: mkm-cards ( -- seq ) mtg-oracle-cards "mkm" filter-set ;
: otj-cards ( -- seq ) mtg-oracle-cards "otj" filter-set ;
: otj-cards-bonus ( -- seq ) mtg-oracle-cards "big" filter-set ;
: otj-cards-all ( -- seq ) mtg-oracle-cards { "otj" "big" } filter-set-intersect ;
: blb-cards ( -- seq ) mtg-oracle-cards "blb" filter-set ;
: blb-cards-bonus ( -- seq ) mtg-oracle-cards "blc" filter-set ;
: blb-cards-all ( -- seq ) mtg-oracle-cards { "blb" "blc" } filter-set-intersect ;
: dsk-cards ( -- seq ) mtg-oracle-cards "dsk" filter-set ;

! modern
: mh3-cards ( -- seq ) mtg-oracle-cards "mh3" filter-set ;

: sort-by-colors ( seq -- seq' )
    {
        { [ "color_identity" of length ] <=> }
        { [ "color_identity" of sort ?first "A" or ] <=> }
        { [ "cmc" of ] <=> }
        { [ "mana_cost" of length ] <=> }
        { [ "creature" any-type? -1 1 ? ] <=> }
        { [ "power" of -1 1 ? ] <=> }
        { [ "toughness" of -1 1 ? ] <=> }
        { [ "name" of ] <=> }
    } sort-with-spec ;

: cards-by-color. ( seq -- ) sort-by-colors normal-cards. ;

CONSTANT: rarity-to-number H{
    { "common" 0 }
    { "uncommon" 1 }
    { "rare" 2 }
    { "mythic" 3 }
}

: sort-by-rarity ( seq -- seq' )
    {
        { [ "rarity" of rarity-to-number at ] <=> }
        { [ "color_identity" of length ] <=> }
        { [ "color_identity" of sort ?first "A" or ] <=> }
        { [ "cmc" of ] <=> }
        { [ "mana_cost" of length ] <=> }
        { [ "name" of ] <=> }
    } sort-with-spec ;

: cards-by-rarity. ( seq -- ) sort-by-rarity normal-cards. ;

: sort-by-release ( seq -- seq' )
    {
        { [ "released_at" of ymd>timestamp ] <=> }
        { [ "set" of ] <=> }
    } sort-with-spec ;

: cards-by-release. ( seq -- ) sort-by-release normal-cards. ;

: sort-by-set-colors ( seq -- seq' )
    {
        { [ "released_at" of ymd>timestamp ] <=> }
        { [ "set" of ] <=> }
        { [ "color_identity" of length ] <=> }
        { [ "color_identity" of sort ?first "A" or ] <=> }
        { [ "cmc" of ] <=> }
        { [ "mana_cost" of length ] <=> }
        { [ "creature" any-type? -1 1 ? ] <=> }
        { [ "power" of -1 1 ? ] <=> }
        { [ "toughness" of -1 1 ? ] <=> }
        { [ "rarity" of -1 1 ? ] <=> }
        { [ "name" of ] <=> }
    } sort-with-spec ;

: cards-by-set-colors. ( seq -- ) sort-by-set-colors normal-cards. ;

: cards-by-name ( name -- seq' ) [ mtg-oracle-cards ] dip filter-by-name-itext sort-by-release ;
: card-by-name ( name -- card )
    [ mtg-oracle-cards ] dip >lower
    [ '[ "name" of >lower _ = ] filter ?first ]
    [ '[ "name" of >lower _ head? ] filter ?first ] 2bi or ;
: cards-by-name. ( name -- ) cards-by-name normal-cards. ;
: standard-cards-by-name. ( name -- ) cards-by-name standard-cards. ;
: historic-cards-by-name. ( name -- ) cards-by-name historic-cards. ;
: modern-cards-by-name. ( name -- ) cards-by-name modern-cards. ;

: paren-set? ( string -- ? )
    { [ "(" head? ] [ ")" tail? ] [ length 5 = ] } 1&& ;

: remove-set-and-num ( string -- string' )
    " " split
    dup 2 ?lastn
    [ paren-set? ] [ string>number ] bi* and [
        2 head*
    ] when " " join ;

: assoc>cards ( assoc -- seq )
    [ card-by-name <array> ] { } assoc>map concat ;

: parse-mtga-card-line ( string -- array )
    [ blank? ] trim
    " " split1
    [ string>number ]
    [ remove-set-and-num card-by-name ] bi* <array> ;

: parse-mtga-cards ( strings -- seq )
    [ parse-mtga-card-line ] map concat ;

TUPLE: mtga-deck name deck sideboard section ;

: <mtga-deck> ( -- mtga-deck )
    mtga-deck new "Deck" >>section ;

: <moxfield-deck> ( name deck sideboard -- deck )
    mtga-deck new
        swap >>sideboard
        swap >>deck
        swap >>name ;

ERROR: unknown-mtga-deck-section section ;
: parse-mtga-deck ( string -- mtga-deck )
    string-lines [ [ blank? ] trim ] map harvest
    { "About" "Deck" "Sideboard" } split*
    [ <mtga-deck> ] dip
    [
        dup { "About" "Deck" "Sideboard" } intersects? [
            first >>section
        ] [
            over section>> {
                { "About" [ first "Name " ?head drop [ blank? ] trim >>name ] }
                { "Deck" [ parse-mtga-cards >>deck ] }
                { "Sideboard" [ parse-mtga-cards >>sideboard ] }
                [
                    unknown-mtga-deck-section
                ]
            } case
        ] if
    ] each ;

: sort-by-deck-order ( seq -- seq' )
    [ "Land" any-type? not ] partition
    [ sort-by-set-colors ] bi@ append ;

: cards. ( seq -- ) sort-by-deck-order normal-cards. ;

: sideboard. ( seq -- )
    sideboard>> [ "Sideboard" print sort-by-deck-order normal-cards. ] when* ;

GENERIC: deck. ( obj -- )

M: string deck. parse-mtga-deck deck. ;

M: mtga-deck deck. [ name>> ?print ] [ deck>> cards. ] bi ;

M: sequence deck. cards. ;

GENERIC: deck-and-sideboard. ( mtga-deck -- )

M: string deck-and-sideboard. parse-mtga-deck deck-and-sideboard. ;

M: mtga-deck deck-and-sideboard. [ deck. ] [ sideboard. ] bi ;

M: sequence deck-and-sideboard. deck. ;

: filter-mtg-cheat-sheet ( seq -- seq' )
    [
        {
            [ filter-instant ]
            [ filter-flash-keyword ]
            [ filter-cycling-keyword ]
            [ filter-disguise-keyword ]
            [ filter-madness-keyword ]
            [ filter-ninjutsu-keyword ]
            [ filter-channel-keyword ]
            [ filter-retrace-keyword ]
            [ filter-discard-effect ]
        } cleave
    ] { } append-outputs-as sort-by-colors ;

: mtg-cheat-sheet. ( seq -- ) filter-mtg-cheat-sheet normal-cards. ;
: mtg-cheat-sheet-text. ( seq -- ) filter-mtg-cheat-sheet card-summaries. ;

MEMO: get-moxfield-user ( username -- json )
    "https://api2.moxfield.com/v2/users/%s/decks?pageNumber=1&pageSize=100" sprintf http-get-json nip ;

MEMO: get-moxfield-deck ( public-id -- json )
    "https://api2.moxfield.com/v3/decks/all/" prepend http-get-json nip ;

: moxfield-board>cards ( board -- seq )
    "cards" of values [
        [ "quantity" of ] [ "card" of "name" of ] bi 2array
    ] map assoc>cards ;

: json>moxfield-deck ( json -- mtga-deck )
    [ "name" of ]
    [
        "boards" of
        [ "mainboard" of moxfield-board>cards ]
        [ "sideboard" of moxfield-board>cards ] bi
    ] bi
    <moxfield-deck> ;

: moxfield-decks-for-username ( username -- json )
    get-moxfield-user "data" of ;

: moxfield-random-deck-for-username ( username -- json )
    moxfield-decks-for-username
    random "publicId" of get-moxfield-deck
    json>moxfield-deck ;

: moxfield-latest-deck-for-username ( username -- json )
    get-moxfield-user
    "data" of ?first "publicId" of get-moxfield-deck
    json>moxfield-deck ;

: moxfield-latest-deck-for-username. ( username -- )
    moxfield-latest-deck-for-username deck. ;

: moxfield-latest-deck-and-sideboard-for-username. ( username -- )
    moxfield-latest-deck-for-username deck-and-sideboard. ;
