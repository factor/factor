USING: debugger editors help help.apropos help.markup
help.syntax help.vocabs memory see stack-checker
tools.destructors tools.time ;
IN: help.tips

TIP: "To look at the most recent error, run " { $link :error } ". To look at the most recent error's callstack, run " { $link :c } "." ;

TIP: "Learn to use " { $link "dataflow-combinators" } "." ;

TIP: "Learn to use " { $link "editor" } " to be able to jump to the source code for word definitions from the listener." ;

TIP: "Check out " { $url "https://concatenative.org/wiki/view/Factor/FAQ" } " to get answers to frequently-asked questions." ;

TIP: "Consider joining the Factor Discord server: " { $url "https://discord.gg/QxJYZx3QDf" } ". The developers are active and happy to help." ;

TIP: "You can write documentation for your own code using the " { $link "help" } "." ;

TIP: "You can write graphical applications using the " { $link "ui" } "." ;

TIP: "Power tools: " { $links see edit help about apropos time infer. } ;

TIP: "Tips of the day implement the " { $link "definition-protocol" } " and new tips of the day can be defined using the " { $link POSTPONE: TIP: } " parsing word." ;

TIP: "Try some simple demo applications:" { $code "\"demos\" run" } "Then look at the source code in " { $snippet "extra/" } "." ;

TIP: "To save time on reloading big libraries such as the " { $vocab-link "furnace" } " web framework, save the image after loading them using the " { $link save } " word." ;

TIP: "Use the " { $link leaks. } " combinator to track down resource leaks." ;

HELP: TIP:
{ $syntax "TIP: content ;" }
{ $values { "content" "a markup element" } }
{ $description "Defines a new tip of the day." }
{ $examples
  { $unchecked-example
    "TIP: \"Factor is a fun programming language.\" ;"
  }
} ;

ARTICLE: "all-tips-of-the-day" "All tips of the day"
{ $tips-of-the-day } ;

ARTICLE: "tips-of-the-day" "Tips of the day"
"The " { $vocab-link "help.tips" } " vocabulary provides a facility for displaying tips of the day in the " { $link "ui-listener" } ". Tips are defined with a parsing word:"
{ $subsections POSTPONE: TIP: }
"All tips defined so far:"
{ $subsections "all-tips-of-the-day" } ;

ABOUT: "tips-of-the-day"
