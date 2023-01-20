! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations threads ;
IN: progress-bars.models

HELP: set-progress-bar
{ $values
    { "ratio/float" "a real number between 0 and 1" }
}
{ $description "Sets the progress-bar model in the current scope to the percent that the task has been completed." } ;

HELP: with-file-reader-progress
{ $values
    { "path" "a pathname string" } { "encoding" "an encoding" } { "quot" quotation }
}
{ $description "Opens a file for reading, displays a progress bar, and calls the quotation for processing the file. The progress bar will automatically update every 100 milliseconds, but only if the quotation yields (by calling " { $link yield } ") so that the UI has a chance to redraw." }
{ $examples
    "Loop through the Factor image file, discarding each character as it's read and updating a progress bar:"
    { $unchecked-example "USING: system progress-bars.models prettyprint io.encodings.binary threads ;
image-path binary [
    [ 4096 read yield ] loop
] with-file-reader-progress"
""
    }
} ;

HELP: with-progress-bar
{ $values
    { "quot" quotation }
}
{ $description "Makes a new model for a progress bar for a task that is 0% complete, sets this model in a dynamic variable in a new scope, and calls a quotation that has access to this model. Progress can be updated with " { $link set-progress-bar } "." } ;

ARTICLE: "progress-bars.models" "Progress bar models"
"The " { $vocab-link "progress-bars.models" } " vocabulary makes a progress bar model and various utility words that make progress bars for common tasks." $nl
"Making a generic progress bar:"
{ $subsections with-progress-bar }
"Updating a progress-bar:"
{ $subsections set-progress-bar }
"A progress bar for reading files:"
{ $subsections with-file-reader-progress } ;

ABOUT: "progress-bars.models"
