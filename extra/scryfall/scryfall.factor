! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras calendar
calendar.parser combinators combinators.short-circuit
combinators.smart grouping http.download images.loader
images.viewer io io.directories json json.http kernel math
math.combinatorics math.order math.parser math.statistics
namespaces sequences sequences.deep sequences.extras sets
sorting sorting.specification splitting strings ui.gadgets.panes
unicode urls ;
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
    6 hours download-outdated-to path>json ;

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
    [ download-once-to ] [ nip ] if ;

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

: filter-card-faces ( json quot -- seq )
    dup '[ [ "card_faces" of ] [ _ any? ] _ ?if ] filter ; inline

: filter-card-faces-prop ( seq string prop -- seq' )
    swap '[ _ of _ subseq-of? ] filter-card-faces ;

: filter-card-faces-iprop ( seq string prop -- seq' )
    swap >lower '[ _ of >lower _ subseq-of? ] filter-card-faces ;

: filter-by-flavor-text ( seq string -- seq' )
    "flavor_text" filter-card-faces-prop ;

: filter-by-flavor-itext ( seq string -- seq' )
    "flavor_text" filter-card-faces-iprop ;

: filter-by-oracle-text ( seq string -- seq' )
    "oracle_text" filter-card-faces-prop ;

: filter-by-oracle-itext ( seq string -- seq' )
    "oracle_text" filter-card-faces-iprop ;

: filter-by-name-text ( seq string -- seq' ) "name" filter-by-text-prop ;
: filter-by-name-itext ( seq string -- seq' ) "name" filter-by-itext-prop ;

: filter-create-treasure ( seq -- seq' ) "create a treasure token" filter-by-oracle-itext ;
: filter-treasure-token ( seq -- seq' ) "treasure token" filter-by-oracle-itext ;
: filter-create-blood-token ( seq -- seq' ) "create a blood token" filter-by-oracle-itext ;
: filter-blood-token ( seq -- seq' ) "blood token" filter-by-oracle-itext ;
: filter-create-map-token ( seq -- seq' ) "create a map token" filter-by-oracle-itext ;
: filter-map-token ( seq -- seq' ) "map token" filter-by-oracle-itext ;

: filter-affinity ( seq -- seq' ) "affinity" filter-by-oracle-itext ;
: filter-backup ( seq -- seq' ) "backup" filter-by-oracle-itext ;
: filter-blitz ( seq -- seq' ) "blitz" filter-by-oracle-itext ;
: filter-compleated ( seq -- seq' ) "compleated" filter-by-oracle-itext ;
: filter-corrupted ( seq -- seq' ) "corrupted" filter-by-oracle-itext ;
: filter-counter ( seq -- seq' ) "counter" filter-by-oracle-itext ;
: filter-crew ( seq -- seq' ) "crew" filter-by-oracle-itext ;
: filter-cycling ( seq -- seq' ) "cycling" filter-by-oracle-itext ;
: filter-deathtouch ( seq -- seq' ) "deathtouch" filter-by-oracle-itext ;
: filter-defender ( seq -- seq' ) "defender" filter-by-oracle-itext ;
: filter-descend ( seq -- seq' ) "descend" filter-by-oracle-itext ;
: filter-destroy-target ( seq -- seq' ) "destroy target" filter-by-oracle-itext ;
: filter-discover ( seq -- seq' ) "discover" filter-by-oracle-itext ;
: filter-disguise ( seq -- seq' ) "disguise" filter-by-oracle-itext ;
: filter-domain ( seq -- seq' ) "domain" filter-by-oracle-itext ;
: filter-double-strike ( seq -- seq' ) "double strike" filter-by-oracle-itext ;
: filter-equip ( seq -- seq' ) "equip" filter-by-oracle-itext ;
: filter-equip-n ( seq -- seq' ) "equip {" filter-by-oracle-itext ;
: filter-exile ( seq -- seq' ) "exile" filter-by-oracle-itext ;
: filter-fights ( seq -- seq' ) "fights" filter-by-oracle-itext ;
: filter-first-strike ( seq -- seq' ) "first strike" filter-by-oracle-itext ;
: filter-flash ( seq -- seq' ) "flash" filter-by-oracle-itext ;
: filter-flying ( seq -- seq' ) "flying" filter-by-oracle-itext ;
: filter-for-mirrodin ( seq -- seq' ) "for mirrodin!" filter-by-oracle-itext ;
: filter-graveyard ( seq -- seq' ) "graveyard" filter-by-oracle-itext ;
: filter-haste ( seq -- seq' ) "haste" filter-by-oracle-itext ;
: filter-hideaway ( seq -- seq' ) "hideaway" filter-by-oracle-itext ;
: filter-hexproof ( seq -- seq' ) "hexproof" filter-by-oracle-itext ;
: filter-indestructible ( seq -- seq' ) "indestructible" filter-by-oracle-itext ;
: filter-investigate ( seq -- seq' ) "investigate" filter-by-oracle-itext ;
: filter-lifelink ( seq -- seq' ) "lifelink" filter-by-oracle-itext ;
: filter-madness ( seq -- seq' ) "madness" filter-by-oracle-itext ;
: filter-menace ( seq -- seq' ) "menace" filter-by-oracle-itext ;
: filter-mill ( seq -- seq' ) "mill" filter-by-oracle-itext ;
: filter-ninjutsu ( seq -- seq' ) "ninjutsu" filter-by-oracle-itext ;
: filter-proliferate ( seq -- seq' ) "proliferate" filter-by-oracle-itext ;
: filter-protection ( seq -- seq' ) "protection" filter-by-oracle-itext ;
: filter-prowess ( seq -- seq' ) "prowess" filter-by-oracle-itext ;
: filter-reach ( seq -- seq' ) "reach" filter-by-oracle-itext ;
: filter-read-ahead ( seq -- seq' ) "read ahead" filter-by-oracle-itext ;
: filter-reconfigure ( seq -- seq' ) "reconfigure" filter-by-oracle-itext ;
: filter-role ( seq -- seq' ) "role" filter-by-oracle-itext ;
: filter-sacrifice ( seq -- seq' ) "sacrifice" filter-by-oracle-itext ;
: filter-scry ( seq -- seq' ) "scry" filter-by-oracle-itext ;
: filter-shroud ( seq -- seq' ) "shroud" filter-by-oracle-itext ;
: filter-token ( seq -- seq' ) "token" filter-by-oracle-itext ;
: filter-toxic ( seq -- seq' ) "toxic" filter-by-oracle-itext ;
: filter-trample ( seq -- seq' ) "trample" filter-by-oracle-itext ;
: filter-vehicle ( seq -- seq' ) "vehicle" filter-by-oracle-itext ;
: filter-vigilance ( seq -- seq' ) "vigilance" filter-by-oracle-itext ;
: filter-ward ( seq -- seq' ) "ward" filter-by-oracle-itext ;

: filter-day ( seq -- seq' ) "day" filter-by-oracle-itext ;
: filter-night ( seq -- seq' ) "night" filter-by-oracle-itext ;
: filter-daybound ( seq -- seq' ) "daybound" filter-by-oracle-itext ;
: filter-nightbound ( seq -- seq' ) "nightbound" filter-by-oracle-itext ;

: filter-mount ( seq -- seq' ) "mount" filter-by-oracle-itext ;
: filter-outlaw ( seq -- seq' )
    { "Assassin" "Mercenary" "Pirate" "Rogue" "Warlock" } filter-subtype-intersects ;
: filter-plot ( seq -- seq' ) "plot" filter-by-oracle-itext ;
: filter-saddle ( seq -- seq' ) "saddle" filter-by-oracle-itext ;
: filter-spree ( seq -- seq' ) "saddle" filter-by-oracle-itext ;

: power>n ( string -- n/f )
    [ "*" = ] [ drop -1 ] [ string>number ] ?if ;

: mtg<  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ < ] } 2&& ;
: mtg<= ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ <= ] } 2&& ;
: mtg>  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ > ] } 2&& ;
: mtg>= ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ >= ] } 2&& ;
: mtg=  ( string/n/f n -- seq' ) [ power>n ] dip { [ and ] [ = ] } 2&& ;

: filter-power=* ( seq -- seq' ) [ "power" of "*" = ] filter-card-faces ;
: filter-toughness=* ( seq -- seq' ) [ "toughness" of "*" = ] filter-card-faces ;

: filter-power= ( seq n -- seq' ) '[ "power" of _ mtg= ] filter-card-faces ;
: filter-power< ( seq n -- seq' ) '[ "power" of _ mtg< ] filter-card-faces ;
: filter-power> ( seq n -- seq' ) '[ "power" of _ mtg> ] filter-card-faces ;
: filter-power<= ( seq n -- seq' ) '[ "power" of _ mtg<= ] filter-card-faces ;
: filter-power>= ( seq n -- seq' ) '[ "power" of _ mtg>= ] filter-card-faces ;

: filter-toughness= ( seq n -- seq' ) '[ "toughness" of _ mtg= ] filter-card-faces ;
: filter-toughness< ( seq n -- seq' ) '[ "toughness" of _ mtg< ] filter-card-faces ;
: filter-toughness> ( seq n -- seq' ) '[ "toughness" of _ mtg> ] filter-card-faces ;
: filter-toughness<= ( seq n -- seq' ) '[ "toughness" of _ mtg<= ] filter-card-faces ;
: filter-toughness>= ( seq n -- seq' ) '[ "toughness" of _ mtg>= ] filter-card-faces ;

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
        { [ "name" of ] <=> }
    } sort-with-spec ;

: cards-by-set-colors. ( seq -- ) sort-by-set-colors normal-cards. ;

: cards-by-name ( seq name -- seq' ) filter-by-name-itext sort-by-release ;
: cards-by-name. ( seq name -- ) cards-by-name [ "name" of ] sort-by normal-cards. ;

: filter-mtg-cheat-sheet ( seq -- seq' )
    [
        {
            [ filter-instant ]
            [ filter-flash ]
            [ filter-cycling ]
            [ filter-disguise ]
            [ filter-madness ]
        } cleave
    ] { } append-outputs-as sort-by-colors ;

: mtg-cheat-sheet. ( seq -- ) filter-mtg-cheat-sheet normal-cards. ;
: mtg-cheat-sheet-text. ( seq -- ) filter-mtg-cheat-sheet card-summaries. ;
