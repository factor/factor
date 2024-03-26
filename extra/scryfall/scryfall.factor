! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
combinators http.download images.loader images.viewer io
io.directories json json.http kernel math math.parser
math.statistics namespaces sequences sequences.extras sets
sorting splitting ui.gadgets.panes unicode urls ;
IN: scryfall

CONSTANT: scryfall-oracle-json-path "resource:scryfall-oracle-json"
CONSTANT: scryfall-artwork-json-path "resource:scryfall-artwork-json"
CONSTANT: scryfall-default-json-path "resource:scryfall-default-json"
CONSTANT: scryfall-all-json-path "resource:scryfall-all-json"
CONSTANT: scryfall-rulings-json-path "resource:scryfall-rulings-json"
CONSTANT: scryfall-images-path "resource:scryfall-images/"

: ?print ( str/f -- ) [ print ] [ nl ] if* ;

: download-scryfall-bulk-json ( -- json )
    "https://api.scryfall.com/bulk-data" http-get-json nip ;

: find-scryfall-json ( type -- json/f )
    [ download-scryfall-bulk-json "data" of ] dip '[ "type" of _ = ] filter ?first ;

: load-scryfall-json ( type path -- uri )
    [ find-scryfall-json "download_uri" of ] dip
    120 hours download-outdated-to path>json ;

MEMO: mtg-oracle-cards ( -- json )
    "oracle_cards" scryfall-oracle-json-path load-scryfall-json ;

: mtg-artwork-cards ( -- json )
    "unique_artwork" scryfall-artwork-json-path load-scryfall-json ;

MEMO: scryfall-default-cards-json ( -- json )
    "default_cards" scryfall-default-json-path load-scryfall-json ;

MEMO: scryfall-all-cards-json ( -- json )
    "all_cards" scryfall-all-json-path load-scryfall-json ;

MEMO: scryfall-rulings-json ( -- json )
    "rulings" scryfall-rulings-json-path load-scryfall-json ;

: ensure-scryfall-images-directory ( -- )
    scryfall-images-path make-directories ;

: scryfall-local-image-path ( string -- path )
    >url path>> "/" ?head drop "/" "-" replace
    scryfall-images-path "" prepend-as ;

: map-card-faces ( assoc quot -- seq )
    [ "card_faces" of ] dip map ; inline

: card>image-uris ( assoc -- seq )
    [ "image_uris" of ]
    [ 1array ]
    [ "card_faces" of [ "image_uris" of ] map ] ?if ;

: small-images ( seq -- seq' ) [ "small" of ] map ;
: normal-images ( seq -- seq' ) [ "normal" of ] map ;

: download-scryfall-image ( assoc -- path )
    dup scryfall-local-image-path dup delete-when-zero-size
    [ download-once-to ] [ nip ] if ;

: download-normal-images ( seq -- seq' )
    ensure-scryfall-images-directory
    normal-images [ download-scryfall-image load-image ] map ;

: download-small-images ( seq -- seq' )
    ensure-scryfall-images-directory
    small-images [ download-scryfall-image load-image ] map ;

MEMO: all-cards-by-name ( -- assoc )
    mtg-oracle-cards
    [ "name" of ] collect-by
    [ first ] map-values ;

: find-card-by-name ( seq name -- card ) '[ "name" of _ = ] filter ;
: cards-by-name ( seq -- assoc ) [ "name" of ] collect-by ;
: cards-by-cmc ( seq -- assoc ) [ "cmc" of ] collect-by ;
: cards-by-color-identity ( seq -- assoc ) [ "color_identity" of ] collect-by-multi ;
: red-color-identity ( seq -- seq' ) cards-by-color-identity "R" of ;
: blue-color-identity ( seq -- seq' ) cards-by-color-identity "U" of ;
: green-color-identity ( seq -- seq' ) cards-by-color-identity "G" of ;
: black-color-identity ( seq -- seq' ) cards-by-color-identity "B" of ;
: white-color-identity ( seq -- seq' ) cards-by-color-identity "W" of ;

: find-card-by-color-identity-intersect ( cards colors -- cards' )
    [ cards-by-color-identity ] dip [ of ] with map intersect-all ;

: find-any-color-identities ( cards colors -- cards' )
    [ cards-by-color-identity ] dip [ of ] with map union-all ;

: color-identity-complement ( seq -- seq' ) [ { "W" "U" "B" "R" "G" } ] dip diff ;

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

: filter-non-white ( seq -- seq' ) { "U" "B" "R" "G" } find-any-color-identities ;
: filter-non-blue ( seq -- seq' ) { "W" "B" "R" "G" } find-any-color-identities ;
: filter-non-black ( seq -- seq' ) { "W" "U" "R" "G" } find-any-color-identities ;
: filter-non-red ( seq -- seq' ) { "W" "U" "B" "G" } find-any-color-identities ;
: filter-non-green ( seq -- seq' ) { "W" "U" "B" "R" } find-any-color-identities ;

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

: parse-type-line ( string -- pairs )
    " // " split1
    [
        [
            " — " split1
            [ [ " " split ] ?call >array ] bi@ 2array
        ] ?call
    ] bi@ 2array sift ;

: type-line-of ( assoc -- string ) "type_line" of parse-type-line ;
: any-type? ( seq name -- ? ) [ type-line-of ] dip '[ first _ member-of? ] any? ;
: any-subtype? ( seq name -- ? ) [ type-line-of ] dip '[ second _ member-of? ] any? ;

: filter-creature-type ( seq type -- seq' ) '[ _ any-subtype? ] filter ;

: filter-land ( seq -- seq' ) [ "Land" any-type? ] filter ;
: filter-creature ( seq -- seq' ) [ "Creature" any-type? ] filter ;
: filter-enchantment ( seq -- seq' ) [ "Enchantment" any-type? ] filter ;
: filter-instant ( seq -- seq' ) [ "Instant" any-type? ] filter ;
: filter-sorcery ( seq -- seq' ) [ "Sorcery" any-type? ] filter ;
: filter-planeswalker ( seq -- seq' ) [ "Planeswalker" any-type? ] filter ;

: filter-common ( seq -- seq' ) '[ "rarity" of "common" = ] filter ;
: filter-uncommon ( seq -- seq' ) '[ "rarity" of "uncommon" = ] filter ;
: filter-rare ( seq -- seq' ) '[ "rarity" of "rare" = ] filter ;
: filter-mythic ( seq -- seq' ) '[ "rarity" of "mythic" = ] filter ;

: standard-cards ( -- seq' ) mtg-oracle-cards filter-standard ;

: sort-by-cmc ( assoc -- assoc' ) [ "cmc" of ] sort-by ;
: histogram-by-cmc ( assoc -- assoc' ) [ "cmc" of ] histogram-by sort-keys ;

: filter-by-oracle-text ( seq string -- seq' )
    '[ "oracle_text" of _ subseq-of? ] filter ;

: filter-by-oracle-itext ( seq string -- seq' )
    >lower
    '[ "oracle_text" of >lower _ subseq-of? ] filter ;

: filter-flash ( seq -- seq' ) "Flash" filter-by-oracle-text ;

: map-props ( seq props -- seq' ) '[ _ intersect-keys ] map ;

: gadgets. ( seq -- )
    1 cut*
    [ output-stream get '[ _ write-gadget ] each ]
    [ output-stream get '[ _ print-gadget ] each ] bi* ;

: images. ( seq -- ) [ <image-gadget> ] map gadgets. ;

: small-card. ( assoc -- )
    card>image-uris download-small-images images. ;

: small-cards. ( seq -- ) [ small-card. ] each ;

: normal-card. ( assoc -- )
    card>image-uris download-normal-images images. ;

: normal-cards. ( seq -- ) [ normal-card. ] each ;

: card-face-summary. ( seq -- )
    {
        [ "name" of write bl ]
        [ "mana_cost" of ?print ]
        [ "type_line" of ?print ]
        [ [ "power" of ] [ "toughness" of ] bi 2dup and [ "/" glue print ] [ 2drop ] if ]
        [ "oracle_text" of ?print ]
    } cleave nl ;

: card-face-summaries. ( seq -- ) [ card-face-summary. ] each ;

: card-summary. ( assoc -- )
    {
        [
            [ "card_faces" of ]
            [ [ length number>string "Card Faces: " prepend print ] [ card-face-summaries. ] bi ]
            [ card-face-summary. ] ?if
        ]
    } cleave nl nl nl ;

: card-summaries. ( seq -- ) [ card-summary. ] each ;

: card-summary-with-pic. ( assoc -- )
    [ normal-card. ]
    [ card-summary. ] bi ;

: card-summaries-with-pics. ( seq -- ) [ card-summary-with-pic. ] each ;

: standard-dragons. ( -- )
    standard-cards
    "Dragon" filter-creature-type
    sort-by-cmc
    normal-cards. ;

: collect-by-cmc ( seq -- seq' ) [ "cmc" of ] collect-by ;
