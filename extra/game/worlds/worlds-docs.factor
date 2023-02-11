! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: audio.engine game.loop help.markup help.syntax
ui.gadgets.worlds ;
IN: game.worlds

HELP: game-attributes
{ $class-description "Extends the " { $link world-attributes } " tuple class with extra attributes for " { $link game-world } "s:" }
{ $list
{ { $snippet "tick-interval-nanos" } " specifies the number of nanoseconds between consecutive calls to the world's " { $link tick-game-world } " method by the game loop. An integer greater than zero must be provided." }
{ { $snippet "use-game-input?" } " specifies whether the game world should initialize the " { $vocab-link "game.input" } " library for use by the game. False by default." }
{ { $snippet "use-audio-engine?" } " specifies whether the game world should manage an " { $link audio-engine } " instance. False by default." }
{ { $snippet "audio-engine-device" } " specifies the string name of the OpenAL device the audio engine, if any, should try to open. The default value of " { $link POSTPONE: f } " attempts to open the default OpenAL device." }
{ { $snippet "audio-engine-voice-count" } " determines the number of independent voices the audio engine will make available. This determines how many individual audio clips can play simultaneously. This cannot exceed the OpenAL implementation's limit on supported voices." }
} ;

HELP: game-world
{ $class-description "A subclass of " { $link world } " that automatically sets up and manages connections to the " { $vocab-link "game.loop" } ", " { $vocab-link "game.input" } ", and " { $vocab-link "audio.engine" } " libraries. It does this by providing methods on " { $link begin-world } ", " { $link end-world } ", and " { $link draw* } ". Subclasses can provide their own world setup, teardown, and update code by adding methods to the " { $link begin-game-world } " and " { $link end-game-world } " generic words. The standard " { $snippet "world" } " generics " { $link draw-world* } " and " { $link resize-world } " can also be given methods to draw the window contents and handle resize events. The " { $snippet "draw-world*" } " method will be invoked in a tight loop by the game loop."
$nl
"The game-world tuple has the following publicly accessible slots:"
{ $list
{ { $snippet "game-loop" } " contains the " { $link game-loop } " instance managed by the game world. If the world is inactive, this slot will contain " { $link POSTPONE: f } "." }
{ { $snippet "audio-engine" } " contains the " { $link audio-engine } " instance managed by the game world. If the world is inactive, or the " { $snippet "use-audio-engine?" } " slot of the " { $link game-attributes } " object used to initialize the world was false, this slot will contain " { $link POSTPONE: f } "." }
} } ;

HELP: begin-game-world
{ $values { "world" game-world } }
{ $description "This generic word is called by the " { $link begin-world } " method for " { $link game-world } " subclasses immediately before the game world starts the game loop. If the game world has an " { $link audio-engine } ", it will be initialized and started before " { $snippet "begin-game-world" } " is called." } ;

HELP: end-game-world
{ $values { "world" game-world } }
{ $description "This generic word is called by the " { $link end-world } " method for " { $link game-world } " subclasses immediately after the game world stops the game loop." } ;

HELP: tick-game-world
{ $values { "world" game-world } }
{ $description "This generic word is called by the " { $link tick* } " method for " { $link game-world } " subclasses every time the game loop's tick interval occurs." } ;

{ game-world begin-game-world end-game-world tick-game-world } related-words

ARTICLE: "game.worlds" "Game worlds"
"The " { $vocab-link "game.worlds" } " vocabulary provides a " { $link world } " subclass that integrates with " { $vocab-link "game.loop" } " and optionally " { $vocab-link "game.input" } " and " { $vocab-link "audio.engine" } " to quickly provide game infrastructure."
{ $subsections
    game-world
    game-attributes
}
"Subclasses of " { $link game-world } " can provide their own setup, teardown, and update code by providing methods for these generic words:"
{ $subsections
    begin-game-world
    end-game-world
    tick-game-world
}
"The standard " { $snippet "world" } " generics " { $link draw-world* } " and " { $link resize-world } " can also be given methods to draw the window contents and handle resize events. The " { $snippet "draw-world*" } " method will be invoked in a tight loop by the game loop to update the screen." ;

ABOUT: "game.worlds"
