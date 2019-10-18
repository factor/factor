! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax kernel math ui.gadgets.worlds ;
IN: game.loop

HELP: fps
{ $values { "fps" real } { "micros" integer } }
{ $description "Converts a frames per second value into an interval length in microseconds." } ;

HELP: <game-loop>
{ $values
    { "tick-interval-micros" integer } { "delegate" "a " { $link "game.loop-delegates" } }
    { "loop" game-loop }
}
{ $description "Constructs a new stopped " { $link game-loop } " object. When started, the game loop will call the " { $link tick* } " method on the " { $snippet "delegate" } " every " { $snippet "tick-interval-micros" } " microseconds, and " { $link draw* } " on the delegate as frequently as possible. The " { $link start-loop } " and " { $link stop-loop } " words start and stop the game loop." } ;

HELP: benchmark-frames-per-second
{ $values
    { "loop" game-loop }
    { "n" float }
}
{ $description "Returns the average number of times per second the game loop has called " { $link draw* } " on its delegate since the game loop was started with " { $link start-loop } " or since the benchmark counters have been reset with " { $link reset-loop-benchmark } "." } ;

HELP: benchmark-ticks-per-second
{ $values
    { "loop" game-loop }
    { "n" float }
}
{ $description "Returns the average number of times per second the game loop has called " { $link tick* } " on its delegate since the game loop was started with " { $link start-loop } " or since the benchmark counters have been reset with " { $link reset-loop-benchmark } "." } ;

{ reset-loop-benchmark benchmark-frames-per-second benchmark-ticks-per-second } related-words

HELP: draw*
{ $values
    { "tick-slice" float } { "delegate" "a " { $link "game.loop-delegates" } }
}
{ $description "This generic word is called by a " { $link game-loop } " on its " { $snippet "delegate" } " object in a tight loop while the game loop is running. The " { $snippet "tick-slice" } " value represents what fraction of the game loop's " { $snippet "tick-interval-micros" } " time period has passed since " { $link tick* } " was most recently called on the delegate." } ;

HELP: game-loop
{ $class-description "Objects of the " { $snippet "game-loop" } " class manage game loops. See " { $link "game.loop" } " for an overview of the game loop library. To construct a game loop, use " { $link <game-loop> } ". To start and stop a game loop, use the " { $link start-loop } " and " { $link stop-loop } " words." } ;

HELP: game-loop-error
{ $values
    { "game-loop" game-loop } { "error" "an error object" }
}
{ $description "If an uncaught error is thrown from inside a game loop delegate's " { $link tick* } " or " { $link draw* } ", the game loop will catch the error, stop the game loop, and rethrow an error of this class." } ;

HELP: reset-loop-benchmark
{ $values
    { "loop" game-loop }
}
{ $description "Resets the benchmark counters on a " { $link game-loop } ". Subsequent calls to " { $link benchmark-frames-per-second } " and " { $link benchmark-ticks-per-second } " will measure their values from the point " { $snippet "reset-loop-benchmark" } " was called." } ;

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
{ $description "This generic word is called by a " { $link game-loop } " on its " { $snippet "delegate" } " object at regular intervals while the game loop is running. The game loop's " { $snippet "tick-interval-micros" } " attribute determines the number of microseconds between invocations of " { $snippet "tick*" } "." } ;

{ draw* tick* } related-words

ARTICLE: "game.loop-delegates" "Game loop delegate"
"A " { $link game-loop } " object requires a " { $snippet "delegate" } " that implements the logic that controls the game. A game loop delegate can be any object that provides two methods for the following generic words:"
{ $subsections
    tick*
    draw*
}
{ $snippet "tick*" } " will be called at a regular interval determined by the game loop's " { $snippet "tick-interval-micros" } " attribute. " { $snippet "draw*" } " will be invoked in a tight loop, updating as frequently as possible." ;

ARTICLE: "game.loop" "Game loops"
"The " { $vocab-link "game.loop" } " vocabulary contains the implementation of a game loop. The game loop supports decoupled rendering and game logic timers; given a delegate object with methods on the " { $link tick* } " and " { $link draw* } " methods, the game loop will invoke the " { $snippet "tick*" } " method at regular intervals while invoking the " { $snippet "draw*" } " method as frequently as possible. Game loop objects must first be constructed:"
{ $subsections
    "game.loop-delegates"
    <game-loop>
}
"Once constructed, the game loop can be started and stopped:"
{ $subsections
    start-loop
    stop-loop
}
"The game loop maintains performance counters for measuring drawing frames and ticks per second:"
{ $subsections
    reset-loop-benchmark
    benchmark-frames-per-second
    benchmark-ticks-per-second
}
"The game loop manages errors that occur in the delegate's methods during the course of the game loop:"
{ $subsections
    game-loop-error
}
"The " { $vocab-link "game.worlds" } " vocabulary provides a convenient " { $link world } " subclass that integrates the game loop implementation with UI applications, managing the starting and stopping of the loop for you." ;

ABOUT: "game.loop"
