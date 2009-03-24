IN: help.tips
USING: help.markup help.syntax debugger ;

TIP: "To look at the most recent error, run " { $link :error } ". To look at the most recent error's callstack, run " { $link :c } "." ;

TIP: "Learn to use " { $link "dataflow-combinators" } "." ;

TIP: "Learn to use " { $link "editor" } " to be able to jump to the source code for word definitions from the listener." ;

TIP: "Check out " { $url "http://concatenative.org/wiki/view/Factor/FAQ" } " to get answers to frequently-asked questions." ;

TIP: "Drop by the " { $snippet "#concatenative" } " IRC channel on " { $snippet "irc.freenode.net" } " some time." ;

TIP: "You can write documentation for your own code using the " { $link "help" } "." ;

TIP: "You can write graphical applications using the " { $link "ui" } "." ;

ARTICLE: "all-tips-of-the-day" "All tips of the day"
{ $tips-of-the-day } ;

ARTICLE: "tips-of-the-day" "Tips of the day"
"The " { $vocab-link "help.tips" } " vocabulary provides a facility for displaying tips of the day in the " { $link "ui-listener" } ". Tips are defined with a parsing word:"
{ $subsection POSTPONE: TIP: }
"All tips defined so far:"
{ $subsection "all-tips-of-the-day" } ;

ABOUT: "tips-of-the-day"