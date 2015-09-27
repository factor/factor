! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs assocs.extras combinators kernel literals locals
math math.parser sequences splitting unicode.case
unicode.categories ;

IN: english

<PRIVATE

<<
! Irregular pluralizations
CONSTANT: singular-to-plural H{

    ! us -> i
    { "alumnus" "alumni" }
    { "cactus" "cacti" }
    { "focus" "foci" }
    { "fungus" "fungi" }
    { "nucleus" "nuclei" }
    { "radius" "radii" }
    { "stimulus" "stimuli" }

    ! is -> es
    { "analysis" "analyses" }
    { "axis" "axes" }
    { "basis" "bases" }
    { "crisis" "crises" }
    { "diagnosis" "diagnoses" }
    { "ellipsis" "ellipses" }
    { "hypothesis" "hypotheses" }
    { "oasis" "oases" }
    { "paralysis" "paralyses" }
    { "parenthesis" "parentheses" }
    { "synopsis" "synopses" }
    { "synthesis" "syntheses" }
    { "thesis" "theses" }

    ! ix -> ices
    { "appendix" "appendices" }
    { "index" "indices" }
    { "matrix" "matrices" }

    ! eau -> eaux
    { "beau" "beaux" }
    { "bureau" "bureaus" }
    { "tableau" "tableaux" }

    ! ? -> en
    { "child" "children" }
    { "man" "men" }
    { "ox" "oxen" }
    { "woman" "women" }

    ! ? -> a
    { "bacterium" "bacteria" }
    { "corpus" "corpora" }
    { "criterion" "criteria" }
    { "curriculum" "curricula" }
    { "datum" "data" }
    { "genus" "genera" }
    { "medium" "media" }
    { "memorandum" "memoranda" }
    { "phenomenon" "phenomena" }
    { "stratum" "strata" }

    ! no change
    { "bison" "bison" }
    { "deer" "deer" }
    { "fish" "fish" }
    { "means" "means" }
    { "moose" "moose" }
    { "offspring" "offspring" }
    { "series" "series" }
    { "sheep" "sheep" }
    { "species" "species" }
    { "swine" "swine" }

    ! oo -> ee
    { "foot" "feet" }
    { "goose" "geese" }
    { "tooth" "teeth" }

    ! a -> ae
    { "antenna" "antennae" }
    { "formula" "formulae" }
    { "nebula" "nebulae" }
    { "vertebra" "vertebrae" }
    { "vita" "vitae" }

    ! ouse -> ice
    { "louse" "lice" }
    { "mouse" "mice" }
}
>>

CONSTANT: plural-to-singular $[ singular-to-plural assoc-invert ]

:: match-case ( master disciple -- master' )
    {
        { [ master >lower master = ] [ disciple >lower ] }
        { [ master >upper master = ] [ disciple >upper ] }
        { [ master >title master = ] [ disciple >title ] }
        [ disciple ]
    } cond ;

PRIVATE>

: singularize ( word -- singular )
    dup >lower {
        { [ dup empty? ] [ ] }
        { [ dup singular-to-plural key? ] [ ] }
        { [ plural-to-singular ?at ] [ ] }
        { [ dup "s" tail? not ] [ ] }
        {
            [
                dup "ies" ?tail [
                    last "aeiou" member? not
                ] [ drop f ] if
            ] [ 3 head* "y" append ]
        }
        { [ dup "es" tail? ] [ 2 head* ] }
        [ but-last ]
    } cond match-case ;

: pluralize ( word -- plural )
    dup >lower {
        { [ dup empty? ] [ ] }
        { [ dup plural-to-singular key? ] [ ] }
        { [ singular-to-plural ?at ] [ ] }
        {
            [
                dup "y" ?tail [
                    last "aeiou" member? not
                ] [ drop f ] if
            ] [ but-last "ies" append ]
        }
        {
            [ dup { "s" "ch" "sh" } [ tail? ] with any? ]
            [ dup "es" tail? [ "es" append ] unless ]
        }
        [ "s" append ]
    } cond match-case ;

: a10n ( str -- str' )
    dup length 3 > [
        [ 1 head ] [ length 2 - number>string ] [ 1 tail* ] tri
        3append
    ] when ;
