USING: arrays help.markup help.syntax kernel sequences strings ;
IN: shlex

HELP: parse-shlex
{ $values { "string" string } { "tokens" array } }
{ $description "Splits a command string using Python shlex.split defaults: POSIX mode with comments disabled. Quotes are removed, adjacent quoted and unquoted pieces form one token, and quoted empty arguments are preserved. Only space, tab, carriage return and newline delimit tokens." } ;

HELP: shlex-split
{ $values { "string" string } { "comments?" boolean } { "posix?" boolean } { "tokens" array } }
{ $description "Splits a string like Python's shlex.split(string, comments, posix). With comments enabled, unquoted # starts a comment through the next newline. POSIX mode recognizes backslash escapes outside single quotes; inside double quotes only a double quote or backslash loses its escape. Non-POSIX mode retains quotes, recognizes them only at the start of a token, ends a token at a closing quote, and treats backslashes literally." }
{ $errors "Throws shlex-unclosed-quote for an unmatched quote and shlex-missing-escape for an unfinished POSIX escape." } ;

HELP: shlex-quote
{ $values { "string" string } { "quoted" string } }
{ $description "Quotes one argument for a POSIX shell, like Python's shlex.quote. Empty strings become two single quotes; shell-safe ASCII arguments are unchanged. Other strings are single-quoted with embedded single quotes escaped." }
{ $notes "This quoting is for POSIX shells, not Windows command interpreters." } ;

HELP: shlex-join
{ $values { "tokens" sequence } { "string" string } }
{ $description "Quotes each string with shlex-quote and joins them with spaces. Parsing the result with parse-shlex recovers the original arguments." } ;

ARTICLE: "shlex" "Shell-like lexical analysis"
"String helpers modeled on Python's shlex module:"
{ $subsections parse-shlex shlex-split shlex-quote shlex-join }
"These words tokenize strings without executing commands or expanding variables, wildcards, or command substitutions. Punctuation stays within words, as with Python's split helper. The configurable shlex class, stream input, token pushback, punctuation_chars, and source-file inclusion are not implemented."
{ $url "https://docs.python.org/3/library/shlex.html" } ;

ABOUT: "shlex"
