! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays ascii combinators endian grouping ip-parser kernel
literals math sequences splitting ;

IN: hipku

<PRIVATE

CONSTANT: animal-adjectives {
    "agile" "bashful" "clever" "clumsy" "drowsy" "fearful"
    "graceful" "hungry" "lonely" "morose" "placid" "ruthless"
    "silent" "thoughtful" "vapid" "weary"
}

CONSTANT: animal-colors {
    "beige" "black" "blue" "bright" "bronze" "brown" "dark"
    "drab" "green" "gold" "grey" "jade" "pale" "pink" "red"
    "white"
}

CONSTANT: animal-nouns {
    "ape" "bear" "crow" "dove" "frog" "goat" "hawk" "lamb"
    "mouse" "newt" "owl" "pig" "rat" "snake" "toad" "wolf"
}

CONSTANT: animal-verbs {
    "aches" "basks" "cries" "dives" "eats" "fights" "groans"
    "hunts" "jumps" "lies" "prowls" "runs" "sleeps" "thrives"
    "wakes" "yawns"
}

CONSTANT: nature-adjectives {
    "ancient" "barren" "blazing" "crowded" "distant" "empty"
    "foggy" "fragrant" "frozen" "moonlit" "peaceful" "quiet"
    "rugged" "serene" "sunlit" "wind-swept"
}

CONSTANT: nature-nouns {
    "canyon" "clearing" "desert" "foothills" "forest"
    "grasslands" "jungle" "meadow" "mountains" "prairie" "river"
    "rockpool" "sand-dune" "tundra" "valley" "wetlands"
}

CONSTANT: plant-nouns {
    "autumn colors"
    "cherry blossoms"
    "chrysanthemums"
    "crabapple blooms"
    "dry palm fronds"
    "fat horse chestnuts"
    "forget-me-nots"
    "jasmine petals"
    "lotus flowers"
    "ripe blackberries"
    "the maple seeds"
    "the pine needles"
    "tiger lillies"
    "water lillies"
    "willow branches"
    "yellowwood leaves"
}

CONSTANT: plant-verbs {
    "blow" "crunch" "dance" "drift" "drop" "fall" "grow" "pile"
    "rest" "roll" "show" "spin" "stir" "sway" "turn" "twist"
}

CONSTANT: adjectives {
    "ace" "apt" "arched" "ash" "bad" "bare" "beige" "big"
    "black" "bland" "bleak" "blond" "blue" "blunt" "blush" "bold"
    "bone" "both" "bound" "brash" "brass" "brave" "brief" "brisk"
    "broad" "bronze" "brushed" "burned" "calm" "ceil" "chaste"
    "cheap" "chilled" "clean" "coarse" "cold" "cool" "corn" "crass"
    "crazed" "cream" "crisp" "crude" "cruel" "cursed" "cute" "daft"
    "damp" "dark" "dead" "deaf" "dear" "deep" "dense" "dim" "drab"
    "dry" "dull" "faint" "fair" "fake" "false" "famed" "far" "fast"
    "fat" "fierce" "fine" "firm" "flat" "flawed" "fond" "foul"
    "frail" "free" "fresh" "full" "fun" "glum" "good" "grave" "gray"
    "great" "green" "grey" "grim" "gruff" "hard" "harsh" "high"
    "hoarse" "hot" "huge" "hurt" "ill" "jade" "jet" "jinxed" "keen"
    "kind" "lame" "lank" "large" "last" "late" "lean" "lewd" "light"
    "limp" "live" "loath" "lone" "long" "loose" "lost" "louche"
    "loud" "low" "lush" "mad" "male" "masked" "mean" "meek" "mild"
    "mint" "moist" "mute" "near" "neat" "new" "nice" "nude" "numb"
    "odd" "old" "pained" "pale" "peach" "pear" "peeved" "pink"
    "piqued" "plain" "plum" "plump" "plush" "poor" "posed" "posh"
    "prim" "prime" "prompt" "prone" "proud" "prune" "puce" "pure"
    "quaint" "quartz" "quick" "rare" "raw" "real" "red" "rich"
    "ripe" "rough" "rude" "rushed" "rust" "sad" "safe" "sage" "sane"
    "scortched" "shaped" "sharp" "sheared" "short" "shrewd" "shrill"
    "shrunk" "shy" "sick" "skilled" "slain" "slick" "slight" "slim"
    "slow" "small" "smart" "smooth" "smug" "snide" "snug" "soft"
    "sore" "sought" "sour" "spare" "sparse" "spent" "spoilt" "spry"
    "squat" "staid" "stale" "stary" "staunch" "steep" "stiff"
    "strange" "straw" "stretched" "strict" "striped" "strong"
    "suave" "sure" "svelte" "swank" "sweet" "swift" "tall" "tame"
    "tan" "tart" "taut" "teal" "terse" "thick" "thin" "tight" "tiny"
    "tired" "toothed" "torn" "tough" "trim" "trussed" "twin" "used"
    "vague" "vain" "vast" "veiled" "vexed" "vile" "warm" "weak"
    "webbed" "wrong" "wry" "young"
}

CONSTANT: nouns {
    "ants" "apes" "asps" "balls" "barb" "barbs" "bass" "bats"
    "beads" "beaks" "bears" "bees" "bells" "belts" "birds" "blades"
    "blobs" "blooms" "boars" "boats" "bolts" "books" "bowls" "boys"
    "bream" "brides" "broods" "brooms" "brutes" "bucks" "bulbs"
    "bulls" "busks" "cakes" "calfs" "calves" "cats" "char" "chests"
    "choirs" "clams" "clans" "clouds" "clowns" "cod" "coins" "colts"
    "cones" "cords" "cows" "crabs" "cranes" "crows" "cults" "czars"
    "darts" "dates" "deer" "dholes" "dice" "discs" "does" "dogs"
    "doors" "dopes" "doves" "dreams" "drones" "ducks" "dunes"
    "dwarves" "eels" "eggs" "elk" "elks" "elms" "elves" "ewes"
    "eyes" "faces" "facts" "fawns" "feet" "ferns" "fish" "fists"
    "flames" "fleas" "flocks" "flutes" "foals" "foes" "fools" "fowl"
    "frogs" "fruits" "gangs" "gar" "geese" "gems" "germs" "ghosts"
    "gnomes" "goats" "grapes" "grooms" "grouse" "grubs" "guards"
    "gulls" "hands" "hares" "hawks" "heads" "hearts" "hens" "herbs"
    "hills" "hogs" "holes" "hordes" "ide" "jars" "jays" "kids"
    "kings" "kites" "lads" "lakes" "lambs" "larks" "lice" "lights"
    "limbs" "looms" "loons" "mares" "masks" "mice" "mimes" "minks"
    "mists" "mites" "mobs" "molds" "moles" "moons" "moths" "newts"
    "nymphs" "orbs" "orcs" "owls" "pearls" "pears" "peas" "perch"
    "pigs" "pikes" "pines" "plains" "plants" "plums" "pools"
    "prawns" "prunes" "pugs" "punks" "quail" "quails" "queens"
    "quills" "rafts" "rains" "rams" "rats" "rays" "ribs" "rocks"
    "rooks" "ruffs" "runes" "sands" "seals" "seas" "seeds" "serfs"
    "shards" "sharks" "sheep" "shells" "ships" "shoals" "shrews"
    "shrimp" "skate" "skies" "skunks" "sloths" "slugs" "smew"
    "smiles" "snails" "snakes" "snipes" "sole" "songs" "spades"
    "sprats" "sprouts" "squabs" "squads" "squares" "squid" "stars"
    "stoats" "stones" "storks" "strays" "suns" "swans" "swarms"
    "swells" "swifts" "tars" "teams" "teeth" "terns" "thorns"
    "threads" "thrones" "ticks" "toads" "tools" "trees" "tribes"
    "trolls" "trout" "tunes" "tusks" "veins" "verbs" "vines" "voles"
    "wasps" "waves" "wells" "whales" "whelks" "whiffs" "winds"
    "wolves" "worms" "wraiths" "wrens" "yaks"
}

CONSTANT: verbs {
    "aid" "arm" "awe" "axe" "bag" "bait" "bare" "bash" "bathe"
    "beat" "bid" "bilk" "blame" "bleach" "bleed" "bless" "bluff"
    "blur" "boast" "boost" "boot" "bore" "botch" "breed" "brew"
    "bribe" "brief" "brine" "broil" "browse" "bruise" "build" "burn"
    "burst" "call" "calm" "carve" "chafe" "chant" "charge" "chart"
    "cheat" "check" "cheer" "chill" "choke" "chomp" "choose" "churn"
    "cite" "clamp" "clap" "clasp" "claw" "clean" "cleanse" "clip"
    "cloack" "clone" "clutch" "coax" "crack" "crave" "crunch" "cry"
    "cull" "cure" "curse" "cuss" "dare" "daze" "dent" "dig" "ding"
    "doubt" "dowse" "drag" "drain" "drape" "draw" "dread" "dredge"
    "drill" "drink" "drip" "drive" "drop" "drown" "dry" "dump" "eat"
    "etch" "face" "fail" "fault" "fear" "feed" "feel" "fetch"
    "fight" "find" "fix" "flap" "flay" "flee" "fling" "flip" "float"
    "foil" "forge" "free" "freeze" "frisk" "gain" "glimpse" "gnaw"
    "goad" "gouge" "grab" "grasp" "graze" "grieve" "grip" "groom"
    "guard" "guards" "guide" "gulp" "gush" "halt" "harm" "hate"
    "haul" "haunt" "have" "heal" "hear" "help" "herd" "hex" "hire"
    "hit" "hoist" "hound" "hug" "hurl" "irk" "jab" "jeer" "join"
    "jolt" "keep" "kick" "kill" "kiss" "lash" "leash" "leave" "lift"
    "like" "love" "lugg" "lure" "maim" "make" "mask" "meet" "melt"
    "mend" "miss" "mould" "move" "nab" "name" "need" "oust" "paint"
    "paw" "pay" "peck" "peeve" "pelt" "please" "pluck" "poach"
    "poll" "praise" "prick" "print" "probe" "prod" "prompt" "punch"
    "quash" "quell" "quote" "raid" "raise" "raze" "ride" "roast"
    "rouse" "rule" "scald" "scalp" "scar" "scathe" "score" "scorn"
    "scour" "scuff" "sear" "see" "seek" "seize" "send" "sense"
    "serve" "shake" "shear" "shift" "shoot" "shun" "slap" "slay"
    "slice" "smack" "smash" "smell" "smite" "snare" "snatch" "sniff"
    "snub" "soak" "spare" "splash" "split" "spook" "spray" "squash"
    "squeeze" "stab" "stain" "starve" "steal" "steer" "sting"
    "strike" "stun" "tag" "tame" "taste" "taunt" "teach" "tend"
}

SYMBOLS: Octet octet octet. ;

CONSTANT: ipv4-key ${
    animal-adjectives animal-colors animal-nouns animal-verbs
    nature-adjectives nature-nouns plant-nouns plant-verbs
}

CONSTANT: ipv4-schema ${
    "The" octet octet octet f
    octet "in the" octet octet. f
    Octet octet.
}

CONSTANT: ipv6-key ${
    adjectives nouns adjectives nouns verbs adjectives
    adjectives adjectives adjectives adjectives nouns
    adjectives nouns verbs adjectives nouns
}

CONSTANT: ipv6-schema ${
    Octet octet "and" octet octet f
    octet octet octet octet octet octet octet. f
    Octet octet octet octet octet.
}

: split-octets ( byte-array -- octets )
    [ 16 /mod 2array ] { } map-as concat ;

: join-octets ( octets -- byte-array )
    2 <groups> [ first2 [ 16 * ] [ + ] bi* ] map ;

: split-bytes ( short-array -- byte-array )
    [ 256 /mod 2array ] { } map-as concat ;

: encode-key ( octets key -- key' )
    [ nth ] V{ } 2map-as reverse ;

: encode-hipku ( key schema -- hipku )
    [
        {
            { Octet [ dup pop unclip ch>upper prefix ] }
            { octet [ dup pop ] }
            { octet. [ dup pop "." append ] }
            [ ]
        } case
    ] map nip
    { f } split [ " " join ] map "\n" join ;

: clean-hipku ( hipku extra -- words )
    [ >lower " .\n" split harvest ]
    [ '[ _ member? ] reject " " join ] bi* ;

: decode-key ( hipku key -- seq )
    [ [ ?head ] find drop [ [ CHAR: \s = ] trim-head ] dip ] map nip ;

: decode-hipku ( hipku extra key -- seq )
    [ clean-hipku ] [ decode-key ] bi* ;

: ipv4>hipku ( ipv4 -- hipku )
    parse-ipv4 split-octets
    ipv4-key encode-key
    ipv4-schema encode-hipku ;

: hipku>ipv4 ( hipku -- ipv4 )
    { "in" "the" } ipv4-key decode-hipku join-octets be> ipv4-ntoa ;

: ipv6>hipku ( ipv6 -- hipku )
    parse-ipv6 split-bytes
    ipv6-key encode-key
    ipv6-schema encode-hipku ;

: hipku>ipv6 ( hipku -- ipv6 )
    { "and" } ipv6-key decode-hipku be> ipv6-ntoa ;

PRIVATE>

: hipku> ( hipku -- ipv4/ipv6 )
    " and " over subseq? [ hipku>ipv6 ] [ hipku>ipv4 ] if ;

: >hipku ( ipv4/ipv6 -- hipku )
    CHAR: : over index [ ipv6>hipku ] [ ipv4>hipku ] if ;
