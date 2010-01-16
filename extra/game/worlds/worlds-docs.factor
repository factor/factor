! (c)2009 Joe Groff bsd license
USING: game.loop help.markup help.syntax kernel math ui ui.gadgets.worlds words ;
IN: game.worlds

HELP: GAME:
{ $syntax """GAME: word { attributes }
    attribute-code ;""" }
{ $description "Similar to " { $link POSTPONE: MAIN-WINDOW: } ", defines a main entry point " { $snippet "word" } " for the current vocabulary that opens a UI window with the provided " { $snippet "attributes" } ". In addition to the standard " { $link world-attributes } ", additional " { $link game-attributes } " can be specified to specify game-specific attributes. Unlike " { $link POSTPONE: MAIN-WINDOW: } ", the " { $snippet "attributes" } " for " { $snippet "GAME:" } " must provide values for the " { $snippet "world-class" } " and " { $snippet "tick-interval-micros" } " slots." } ;

HELP: game-attributes
{ $class-description "Extends the " { $link world-attributes } " tuple class with extra attributes for " { $link game-world } "s:" }
{ $list
{ { $snippet "tick-interval-micros" } " specifies the number of microseconds between consecutive calls to the world's " { $link tick* } " method by the game loop." }
} ;

HELP: game-world
{ $class-description "" } ;

HELP: tick-interval-micros
{ $values
    { "world" game-world }
    { "micros" integer }
}
{ $description "Subclasses of " { $link game-world } " can override this class to specify the number of microseconds between consecutive calls to the game world's " { $link tick* } " method by the game loop. Using the " { $link POSTPONE: GAME: } " syntax will define this method for you." } ;

ARTICLE: "game.worlds" "Game worlds"
"The " { $vocab-link "game.worlds" } " vocabulary provides a " { $link world } " subclass that integrates with " { $vocab-link "game.loop" } " and " { $vocab-link "game.input" } " to quickly provide game infrastructure." 
{ $subsections
    game-world
    game-attributes
    POSTPONE: GAME:
}
;

ABOUT: "game.worlds"
