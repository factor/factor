IN: tools.threads
USING: help.markup help.syntax threads ;

HELP: threads.
{ $description "Prints a list of running threads and their state. The \"Waiting on\" column displays one of the following:"
    { $list
        "\"running\" if the thread is the current thread"
        "\"yield\" if the thread is waiting to run"
        { "the string given to " { $link suspend } " if the thread is suspended" }
    }
} ;

ARTICLE: "tools.threads" "Listing threads"
"Printing a list of running threads:"
{ $subsections threads. } ;

ABOUT: "tools.threads"
