USING: calendar help.markup help.syntax ;
IN: logging.parser

HELP: parse-log
{ $values { "lines" "a sequence of strings" } { "entries" "a sequence of log entries" } }
{ $description "Parses a sequence of log entries. Malformed entries are printed out and ignore. The result is a sequence of arrays of the shape " { $snippet "{ timestamp level name>> message }" } ", where"
    { $list
        { { $snippet "timestamp" } " is a " { $link timestamp } }
        { { $snippet "level" } " is a log level; see " { $link "logging.levels" } }
        { { $snippet "word-name" } " is a string" }
        { { $snippet "message" } " is a string" }
    }
} ;

ARTICLE: "logging.parser" "Log file parser"
"The " { $vocab-link "logging.parser" } " vocabulary parses log files output by the " { $vocab-link "logging" } " vocabulary. It is used by " { $link "logging.analysis" } " and " { $vocab-link "logging.insomniac" } " to analyze logs."
$nl
"There is only one primary entry point:"
{ $subsections parse-log } ;

ABOUT: "logging.parser"
