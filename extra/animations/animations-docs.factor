USING: help.markup help.syntax ;
IN: animations

HELP: animate ( quot duration -- )

{ $values
    { "quot" "a quot which uses " { $link progress } }
    { "duration" "a duration of time" }
}
{ $description
    { $link animate } " calls " { $link reset-progress }
    " , then continously calls the given quot until the"
    " duration of time has elapsed. The quot should use "
    { $link progress } " at least once."
}
{ $examples
    { $unchecked-example 
        "USING: animations calendar threads prettyprint ;"
        "[ 1 sleep progress unparse write \" ms elapsed\" print ] "
        "1/20 seconds animate ;"
        "46 ms elapsed\n17 ms elapsed"
    }
    { $notes "The amount of time elapsed between these iterations will very." }
} ;

HELP: reset-progress ( -- )
{ $description
    "Initiates the timer. Call this before using "
    "a loop which makes use of " { $link progress } "."
} ;

HELP: progress
{ $values { "time" "an integer" } }
{ $description
    "Gives the time elapsed since the last time"
    " this word was called, in milliseconds." 
}
{ $examples
    { $unchecked-example
        "USING: animations threads prettyprint ;"
        "reset-progress 3 "
        "[ 1 sleep progress unparse write \"ms elapsed\" print ] "
        "times ;"
        "31 ms elapsed\n18 ms elapsed\n16 ms elapsed"
    }
    { $notes "The amount of time elapsed between these iterations will very." }
} ;

ARTICLE: "animations" "Animations"
"Provides a lightweight framework for properly simulating continuous"
" functions of real time. This framework helps one create animations "
"that use rates which do not change across platforms. The speed of the "
"computer should correlate with the smoothness of the animation, not "
"the speed of the animation!"
{ $subsection animate }
{ $subsection reset-progress }
{ $subsection progress }
! A little talk about when to use progress and when to use animate
    { $link progress } " specifically provides the length of time since "
    { $link reset-progress } " was called, and also calls "
    { $link reset-progress } " as its last action. This can be directly "
    "used when one's quote runs for a specific number of iterations, instead "
    "of a length of time. If the animation is like most, and is expected to "
    "run for a specific length of time, " { $link animate } " should be used." ;
ABOUT: "animations"