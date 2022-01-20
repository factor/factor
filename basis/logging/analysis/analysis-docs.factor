USING: help.markup help.syntax assocs logging ;
IN: logging.analysis

HELP: analyze-entries
{ $values { "entries" "a sequence of log entries" } { "word-names" "a sequence of strings" } { "errors" "a sequence of log entries" } { "word-histogram" assoc } { "message-histogram" assoc } }
{ $description "Analyzes log entries:"
    { $list
        { "Errors (entries with level " { $link ERROR } " or " { $link CRITICAL } ") are collected into the " { $snippet "errors" } " sequence." }
        { "All logging words are tallied into " { $snippet "word-histogram" } " - for example, this can tell you about HTTP server hit counts." }
        { "All words listed in " { $snippet "word-names" } " have their messages tallied into " { $snippet "message-histogram" } " - for example, this can tell you about popular URLs on an HTTP server." }
    }
} ;

HELP: analysis.
{ $values { "errors" "a sequence of log entries" } { "word-histogram" assoc } { "message-histogram" assoc } }
{ $description "Prints a logging report output by " { $link analyze-entries } ". Formatted output words are used, so the report looks nice in the UI or if sent to an HTML stream." } ;

HELP: analyze-log
{ $values { "lines" "a parsed log file" } { "word-names" "a sequence of strings" } }
{ $description "Analyzes a log file and prints a formatted report. The " { $snippet "word-names" } " parameter is documented in " { $link analyze-entries } "." } ;

ARTICLE: "logging.analysis" "Log analysis"
"The " { $vocab-link "logging.analysis" } " vocabulary builds on the " { $vocab-link "logging.parser" } " vocabulary. It parses log files and produces formatted summary reports. It is used by the " { $vocab-link "logging.insomniac" } " vocabulary to e-mail daily reports."
$nl
"Print log file summary:"
{ $subsections analyze-log }
"Factors:"
{ $subsections
    analyze-entries
    analysis.
} ;

ABOUT: "logging.analysis"
