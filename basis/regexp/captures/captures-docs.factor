USING: assocs help.markup help.syntax kernel math regexp sequences
strings ;
IN: regexp.captures

ABOUT: "regexp.captures"

ARTICLE: "regexp.captures" "Regular expression capture groups"
"The " { $vocab-link "regexp.captures" } " vocabulary extracts capturing groups from regular expression matches."
{ $subsections first-match-with-captures all-matches-with-captures capture regexp-match }
"Ordinary parentheses capture; " { $snippet "(?:...)" } " groups without capturing. Groups are numbered from one in opening-parenthesis order, including groups in alternatives that do not participate and groups repeated zero times. Group zero is the whole match. A named group, written " { $snippet "(?<name>...)" } ", also has a number. Names consist of ASCII letters, digits and underscores, with a letter or underscore first. Names must be unique within the expression."
$nl
"Each group is a slice of the original input, or " { $link f } " if it did not participate. An empty capture is an empty slice. The " { $snippet "groups>>" } " accessor returns the array of groups; " { $link capture } " selects a group by number or name. Slice offsets are character indices in the original input."
{ $example
    "USING: prettyprint regexp regexp.captures strings ;"
    "\"2026-09\" R/ (?<year>\\d{4})-(\\d{2})/ first-match-with-captures"
    "\"year\" swap capture >string ."
    "\"2026\"" }
{ $heading "Match selection" }
"The whole match is exactly the one chosen by " { $link first-match } " or " { $link all-matching-slices } ", including leftmost-longest selection and reversed searches. Within that fixed span, captures prefer earlier alternatives and greedy repetitions. For example, matching " { $snippet "(a|aa)(a?)" } " against " { $snippet "aa" } " captures " { $snippet "a" } " in both groups. This is not POSIX longest-subexpression disambiguation. Reluctant quantifier spellings retain Factor's existing greedy behavior."
$nl
"A repeated group retains its last participating capture. Inner groups that do not participate in a later repetition retain their previous capture. Empty loops are cut off when they revisit the same automaton state at the same input position. Group numbering and capture extraction proceed left to right even for reversed searches."
{ $heading "Lookaround and complement" }
"Positive lookaround can capture outside the whole match. It chooses the longest matching lookahead or lookbehind span, then resolves captures within that span using the same rules. Anchors and boundaries refer to the original input. Groups inside negative lookaround or a complemented expression " { $snippet "(?~...)" } " retain their numbers but do not participate, so their values are " { $link f } "."
{ $heading "Execution" }
"The existing DFA chooses each whole match. A separate ordered NFA pass records captures only when requested, and its compiled program is cached on the regular expression. Capture registers belong to each call. Without lookaround, the pass visits each state at most once per input position, avoiding exponential backtracking. Lookaround adds nested matching work. Backreferences remain unsupported." ;

HELP: regexp-match
{ $class-description "A capture result with a " { $snippet "groups" } " array and a " { $snippet "names" } " association mapping names to group numbers. Group zero is the whole match. Each group is a slice or " { $link f } "." } ;

HELP: first-match-with-captures
{ $values { "string" string } { "regexp" regexp } { "match/f" { $maybe regexp-match } } }
{ $description "Returns captures for the same whole match as " { $link first-match } ", or " { $link f } " if no match exists. Capture selection is described in " { $link "regexp.captures" } "." }
{ $errors "Throws " { $link duplicate-capture-name } " when compiling captures for an expression with duplicate names." } ;

HELP: all-matches-with-captures
{ $values { "string" string } { "regexp" regexp } { "matches" "an array of capture results" } }
{ $description "Returns captures for every match selected by " { $link all-matching-slices } ", in the same order. Empty matches advance in the same way as ordinary matching." }
{ $errors "Throws " { $link duplicate-capture-name } " when compiling captures for an expression with duplicate names." } ;

HELP: capture
{ $values { "group" "a group number or name" } { "match" regexp-match } { "slice/f" { $maybe slice } } }
{ $description "Returns a group by its zero-based number or string name. Group zero is the whole match. Returns " { $link f } " for a group that did not participate." }
{ $errors "Throws " { $link unknown-capture-group } " if the group number or name does not exist." } ;

HELP: duplicate-capture-name
{ $values { "name" string } }
{ $error-description "A capturing group name occurs more than once in the regular expression." } ;

HELP: unknown-capture-group
{ $values { "group" "a group number or name" } }
{ $error-description "A capture was requested with an unknown name, a non-integer index, or an index outside the result's group array." } ;

HELP: inconsistent-capture-match
{ $error-description "The capture automaton could not reproduce the whole match selected by the DFA. This indicates an internal regular expression error." } ;
