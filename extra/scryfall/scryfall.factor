! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
calendar.parser combinators combinators.short-circuit
combinators.smart formatting grouping http.download
images.loader images.viewer io io.directories json json.http
kernel math math.combinatorics math.order math.parser
math.statistics namespaces random sequences sequences.deep
sequences.extras sequences.generalizations sets sorting
sorting.specification splitting splitting.extras strings
ui.gadgets.panes unicode urls ;
IN: scryfall

CONSTANT: scryfall-oracle-json-path "resource:scryfall-oracle-json"
CONSTANT: scryfall-artwork-json-path "resource:scryfall-artwork-json"
CONSTANT: scryfall-default-json-path "resource:scryfall-default-json"
CONSTANT: scryfall-all-json-path "resource:scryfall-all-json"
CONSTANT: scryfall-rulings-json-path "resource:scryfall-rulings-json"
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

MEMO: mtg-artwork-cards ( -- json )
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

: filter-multi-card-faces ( assoc -- seq )
    [ "card_faces" of length 1 > ] filter ; inline

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
        casting-cost-combinations
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

: filter-basic ( seq -- seq' ) [ "Basic" any-type? ] filter ;
: filter-basic-subtype ( seq text -- seq' ) [ filter-basic ] dip filter-subtype ;
: filter-land ( seq -- seq' ) [ "Land" any-type? ] filter ;
: filter-land-subtype ( seq text -- seq' ) [ filter-land ] dip filter-subtype ;
: filter-creature ( seq -- seq' ) [ "Creature" any-type? ] filter ;
: filter-creature-subtype ( seq text -- seq' ) [ filter-creature ] dip filter-subtype ;
: filter-emblem ( seq -- seq' ) [ "Emblem" any-type? ] filter ;
: filter-emblem-subtype ( seq text -- seq' ) [ filter-emblem ] dip filter-subtype ;
: filter-enchantment ( seq -- seq' ) [ "Enchantment" any-type? ] filter ;
: filter-enchantment-subtype ( seq text -- seq' ) [ filter-enchantment ] dip filter-subtype ;
: filter-saga ( seq -- seq' ) "saga" filter-enchantment-subtype ;
: filter-instant ( seq -- seq' ) [ "Instant" any-type? ] filter ;
: filter-instant-subtype ( seq text -- seq' ) [ filter-instant ] dip filter-subtype ;
: filter-sorcery ( seq -- seq' ) [ "Sorcery" any-type? ] filter ;
: filter-sorcery-subtype ( seq text -- seq' ) [ filter-sorcery ] dip filter-subtype ;
: filter-planeswalker ( seq -- seq' ) [ "Planeswalker" any-type? ] filter ;
: filter-planeswalker-subtype ( seq text -- seq' ) [ filter-planeswalker ] dip filter-subtype ;
: filter-legendary ( seq -- seq' ) [ "Legendary" any-type? ] filter ;
: filter-legendary-subtype ( seq text -- seq' ) [ filter-legendary ] dip filter-subtype ;
: filter-battle ( seq -- seq' ) [ "Battle" any-type? ] filter ;
: filter-battle-subtype ( seq text -- seq' ) [ filter-battle ] dip filter-subtype ;
: filter-artifact ( seq -- seq' ) [ "Artifact" any-type? ] filter ;
: filter-artifact-subtype ( seq text -- seq' ) [ filter-artifact ] dip filter-subtype ;

: reject-basic ( seq -- seq' ) [ "Basic" any-type? ] reject ;
: reject-land ( seq -- seq' ) [ "Land" any-type? ] reject ;
: reject-creature ( seq -- seq' ) [ "Creature" any-type? ] reject ;
: reject-emblem ( seq -- seq' ) [ "Emblem" any-type? ] reject ;
: reject-enchantment ( seq -- seq' ) [ "Enchantment" any-type? ] reject ;
: reject-instant ( seq -- seq' ) [ "Instant" any-type? ] reject ;
: reject-sorcery ( seq -- seq' ) [ "Sorcery" any-type? ] reject ;
: reject-planeswalker ( seq -- seq' ) [ "Planeswalker" any-type? ] reject ;
: reject-legendary ( seq -- seq' ) [ "Legendary" any-type? ] reject ;
: reject-battle ( seq -- seq' ) [ "Battle" any-type? ] reject ;
: reject-artifact ( seq -- seq' ) [ "Artifact" any-type? ] reject ;

: filter-mounts ( seq -- seq' ) "mount" filter-subtype ;
: filter-vehicles ( seq -- seq' ) "vehicle" filter-subtype ;
: filter-adventure ( seq -- seq' ) "adventure" filter-subtype ;
: filter-aura ( seq -- seq' ) "aura" filter-subtype ;
: filter-aura-subtype ( seq text -- seq' ) [ filter-aura ] dip filter-subtype ;
: filter-equipment ( seq -- seq' ) "Equipment" filter-subtype ;
: filter-equipment-subtype ( seq text -- seq' ) [ filter-equipment ] dip filter-subtype ;

: filter-common ( seq -- seq' ) '[ "rarity" of "common" = ] filter ;
: filter-uncommon ( seq -- seq' ) '[ "rarity" of "uncommon" = ] filter ;
: filter-rare ( seq -- seq' ) '[ "rarity" of "rare" = ] filter ;
: filter-mythic ( seq -- seq' ) '[ "rarity" of "mythic" = ] filter ;

: standard-cards ( -- seq' ) mtg-oracle-cards filter-standard ;
: historic-cards ( -- seq' ) mtg-oracle-cards filter-historic ;
: modern-cards ( -- seq' ) mtg-oracle-cards filter-modern ;

: sort-by-cmc ( assoc -- assoc' ) [ "cmc" of ] sort-by ;
: histogram-by-cmc ( assoc -- assoc' ) [ "cmc" of ] histogram-by sort-keys ;

: filter-by-itext-prop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] filter ;

: filter-by-text-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] filter ;

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
: filter-for-mirrodin!-keyword ( seq -- seq' ) "for-mirrodin!" filter-by-keyword ;
: filter-forecast-keyword ( seq -- seq' ) "forecast" filter-by-keyword ;
: filter-forestcycling-keyword ( seq -- seq' ) "forestcycling" filter-by-keyword ;
: filter-forestwalk-keyword ( seq -- seq' ) "forestwalk" filter-by-keyword ;
: filter-foretell-keyword ( seq -- seq' ) "foretell" filter-by-keyword ;
: filter-formidable-keyword ( seq -- seq' ) "formidable" filter-by-keyword ;
: filter-friends-forever-keyword ( seq -- seq' ) "friends-forever" filter-by-keyword ;
: filter-fuse-keyword ( seq -- seq' ) "fuse" filter-by-keyword ;
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
: filter-vanishing-keyword ( seq -- seq' ) "vanishing" filter-by-keyword ;
: filter-venture-into-the-dungeon-keyword ( seq -- seq' ) "venture-into-the-dungeon" filter-by-keyword ;
: filter-vigilance-keyword ( seq -- seq' ) "vigilance" filter-by-keyword ;
: filter-ward-keyword ( seq -- seq' ) "ward" filter-by-keyword ;
: filter-will-of-the-council-keyword ( seq -- seq' ) "will-of-the-council" filter-by-keyword ;
: filter-wither-keyword ( seq -- seq' ) "wither" filter-by-keyword ;

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
