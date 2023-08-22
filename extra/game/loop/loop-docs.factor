! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math ui.gadgets.worlds ;
IN: game.loop

HELP: fps
{ $values { "fps" real } { "nanos" integer } }
{ $description "Converts a frames per second value into an interval length in nanoseconds." } ;

HELP: <game-loop>
{ $values
    { "tick-interval-nanos" integer } { "delegate" "a " { $link "game.loop-delegates" } }
    { "loop" game-loop }
}
{ $description "Constructs a new stopped " { $link game-loop } " object. When started, the game loop will call the " { $link tick* } " method on the " { $snippet "delegate" } " every " { $snippet "tick-interval-nanos" } " nanoseconds, and " { $link draw* } " on the same delegate object as frequently as possible. The " { $link start-loop } " and " { $link stop-loop } " words start and stop the game loop."
$nl
"To initialize the game loop with separate tick and draw delegates, use " { $link <game-loop*> } "." } ;

HELP: <game-loop*>
{ $values
    { "tick-interval-nanos" integer } { "tick-delegate" "a " { $link "game.loop-delegates" } } { "draw-delegate" "a " { $link "game.loop-delegates" } }
    { "loop" game-loop }
}
{ $description "Constructs a new stopped " { $link game-loop } " object. When started, the game loop will call the " { $link tick* } " method on the " { $snippet "tick-delegate" } " every " { $snippet "tick-interval-nanos" } " nanoseconds, and " { $link draw* } " on the " { $snippet "draw-delegate" } " as frequently as possible. The " { $link start-loop } " and " { $link stop-loop } " words start and stop the game loop."
$nl
"The " { $link <game-loop> } " word provides a shorthand for initializing a game loop that uses the same object for the " { $snippet "tick-delegate" } " and " { $snippet "draw-delegate" } "." } ;

{ <game-loop> <game-loop*> } related-words

HELP: draw*
{ $values
    { "tick-slice" float } { "delegate" "a " { $link "game.loop-delegates" } }
}
{ $description "This generic word is called by a " { $link game-loop } " on its " { $snippet "draw-delegate" } " object in a tight loop while the game loop is running. The " { $snippet "tick-slice" } " value represents what fraction of the game loop's " { $snippet "tick-interval-nanos" } " time period has passed since " { $link tick* } " was most recently called on the " { $snippet "tick-delegate" } "." } ;

HELP: game-loop
{ $class-description "Objects of the " { $snippet "game-loop" } " class manage game loops. See " { $link "game.loop" } " for an overview of the game loop library. To construct a game loop, use " { $link <game-loop> } ". To start and stop a game loop, use the " { $link start-loop } " and " { $link stop-loop } " words."
$nl
"The " { $snippet "tick-delegate" } " and " { $snippet "draw-delegate" } " slots of a game loop object determine where the loop sends its " { $link tick* } " and " { $link draw* } " events. These slots can be changed while the game loop is running." } ;

HELP: game-loop-error
{ $values
    { "error" "an error object" } { "game-loop" game-loop }
}
{ $description "If an uncaught error is thrown from inside a game loop delegate's " { $link tick* } " or " { $link draw* } ", the game loop will catch the error, stop the game loop, and rethrow an error of this class." } ;

HELP: start-loop
{ $values
    { "loop" game-loop }
}
{ $description "Starts running a " { $link game-loop } "." } ;

HELP: stop-loop
{ $values
    { "loop" game-loop }
}
{ $description "Stops running a " { $link game-loop } "." } ;

{ start-loop stop-loop } related-words

HELP: tick*
{ $values
    { "delegate" "a " { $link "game.loop-delegates" } }
}
{ $description "This generic word is called by a " { $link game-loop } " on its " { $snippet "tick-delegate" } " object at regular intervals while the game loop is running. The game loop's " { $snippet "tick-interval-nanos" } " attribute determines the number of nanoseconds between invocations of " { $snippet "tick*" } "." } ;

{ draw* tick* } related-words

ARTICLE: "game.loop-delegates" "Game loop delegate"
"A " { $link game-loop } " object requires a " { $snippet "tick-delegate" } " and " { $snippet "draw-delegate" } " that together implement the logic that controls the game. Both delegates can also be the same object. A game loop delegate can be any object that provides two methods for the following generic words:"
{ $subsections
    tick*
    draw*
}
{ $snippet "tick*" } " will be called at a regular interval determined by the game loop's " { $snippet "tick-interval-nanos" } " attribute on the tick delegate. " { $snippet "draw*" } " will be invoked on the draw delegate in a tight loop, updating as frequently as possible."
$nl
"It is possible to change the " { $snippet "tick-delegate" } " and " { $snippet "draw-delegate" } " slots of a game loop while it is running, for example, to use different delegates to control a game while it's in the menu, paused, or running the main game." ;

ARTICLE: "game.loop" "Game loops"
"The " { $vocab-link "game.loop" } " vocabulary contains the implementation of a game loop. The game loop supports decoupled rendering and game logic timers; given a \"tick delegate\" object with a method on the " { $link tick* } " generic and a \"draw delegate\" with a " { $link draw* } " method, the game loop will invoke the " { $snippet "tick*" } " method on the former at regular intervals while invoking the " { $snippet "draw*" } " method on the latter as frequently as possible. Game loop objects must first be constructed:"
{ $subsections
    "game.loop-delegates"
    <game-loop>
    <game-loop*>
}
"Once constructed, the game loop can be started and stopped:"
{ $subsections
    start-loop
    stop-loop
}
"The game loop catches errors that occur in the delegate's methods during the course of the game loop:"
{ $subsections
    game-loop-error
}
"The " { $vocab-link "game.worlds" } " vocabulary provides a convenient " { $link world } " subclass that integrates the game loop implementation with UI applications, managing the starting and stopping of the loop for you." ;

ABOUT: "game.loop"
