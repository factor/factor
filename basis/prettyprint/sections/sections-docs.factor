USING: hashtables help.markup help.syntax io kernel math
prettyprint.config quotations strings ;
IN: prettyprint.sections

HELP: position
{ $var-description "The prettyprinter's current character position." } ;

HELP: recursion-check
{ $var-description "The current nesting of collections being output by the prettyprinter, used to detect circularity and prevent infinite recursion." } ;

HELP: line-limit?
{ $values { "?" boolean } }
{ $description "Tests if the line number limit has been reached, and thus if prettyprinting should stop." } ;

HELP: do-indent
{ $description "Outputs the current indent nesting to " { $link output-stream } "." } ;

HELP: fresh-line
{ $values { "n" "the current column position" } }
{ $description "Advances the prettyprinter by one line unless the current line is empty. If the line limit is exceeded, escapes the prettyprinter by restoring a continuation captured in " { $link do-pprint } "." } ;

HELP: soft
{ $description "Possible input parameter to " { $link line-break } "." } ;

HELP: hard
{ $description "Possible input parameter to " { $link line-break } "." } ;

{ soft hard } related-words

HELP: section-fits?
{ $values { "section" section } { "?" boolean } }
{ $contract "Tests if a section fits in the space that remains on the current line." } ;

HELP: short-section
{ $values { "section" section } }
{ $contract "Prints a section which fits in the current line. This should use a layout strategy maximizing line length and minimizing white space." } ;

HELP: long-section
{ $values { "section" section } }
{ $contract "Prints a section which spans multiple lines. This should use a layout strategy maximizing readability and minimizing line length. Default implementation calls " { $link short-section } "." } ;

HELP: indent-section?
{ $values { "section" section } { "?" boolean } }
{ $contract "Outputs a boolean indicating if the indent level should be increased when printing this section as a " { $link long-section } ". Default implementation outputs " { $link f } "." } ;

HELP: unindent-first-line?
{ $values { "section" section } { "?" boolean } }
{ $contract "Outputs a boolean indicating if the indent level should only be increased for lines after the first line when printing this section as a " { $link long-section } ". Default implementation outputs " { $link f } "." }
{ $notes "This is used to format " { $link colon } " sections because of the colon definition formatting convention." } ;

HELP: newline-after?
{ $values { "section" section } { "?" boolean } }
{ $contract "Outputs a boolean indicating if a newline should be output after printing this section as a " { $link long-section } ". Default implementation outputs " { $link f } "." } ;

HELP: short-section?
{ $values { "section" section } { "?" boolean } }
{ $contract "Tests if a section should be output as a " { $link short-section } ". The default implementation calls " { $link section-fits? } " but this behavior can be customized." } ;

HELP: section
{ $class-description "A piece of prettyprinter output. Instances of this class are not used directly, instead one instantiates various subclasses of this class:"
{ $list
    { $link text }
    { $link line-break }
    { $link block }
    { $link inset }
    { $link flow }
    { $link colon }
}
"Instances of this class have the following slots:"
{ $list
    { { $snippet "start" } " - the start of the section, measured in characters from the beginning of the prettyprinted output" }
    { { $snippet "end" } " - the end of the section, measured in characters from the beginning of the prettyprinted output" }
    { { $snippet "start-group?" } " - see " { $link start-group } }
    { { $snippet "end-group?" } " - see " { $link end-group } }
    { { $snippet "style" } " - character and/or paragraph styles to use when outputting this section. See " { $link "styles" } }
    { { $snippet "overhang" } " - number of columns which must be left blank before the wrap margin for the prettyprinter to consider emitting this section as a " { $link short-section } ". Avoids lone hanging closing brackets" }
} } ;

HELP: new-section
{ $values { "length" integer } { "class" "a subclass of " { $link section } } { "section" section } }
{ $description "Creates a new section with the given length starting from " { $link position } ", advancing " { $link position } "." } ;

HELP: <indent
{ $values { "section" section } }
{ $description "Increases indentation by the " { $link tab-size } " if requested by the section." } ;

HELP: indent>
{ $values { "section" section } }
{ $description "Decreases indentation by the " { $link tab-size } " if requested by the section." } ;

HELP: <fresh-line
{ $values { "section" section } }
{ $description "Prints a line break before the section start." } ;

HELP: fresh-line>
{ $values { "section" section } }
{ $description "Prints a line break after the section end if requested by the section." } ;

HELP: <long-section
{ $values { "section" section } }
{ $description "Begins printing a long section, taking " { $link indent-section? } " and " { $link unindent-first-line? } " into account." } ;

HELP: long-section>
{ $values { "section" section } }
{ $description "Ends printing a long section, taking " { $link indent-section? } " and " { $link newline-after? } " into account." } ;

HELP: pprint-section
{ $values { "section" section } }
{ $contract "Prints a section, performing wrapping and indentation using available formatting information." }
$prettyprinting-note ;

HELP: line-break
{ $values { "type" { $link soft } " or " { $link hard } } }
{ $description "Adds a section introducing a line break to the current block. If the block is output as a " { $link short-section } ", all breaks are ignored. Otherwise, hard breaks introduce unconditional newlines, and soft breaks introduce a newline if the position is more than half of the " { $link margin } "." }
$prettyprinting-note ;

HELP: block
{ $class-description "A block is a section containing child sections. Blocks are introduced by calling " { $link <block } " and " { $link block> } "." } ;

HELP: pprinter-block
{ $values { "block" "a block section" } }
{ $description "Outputs the block currently being constructed." }
$prettyprinting-note ;

HELP: add-section
{ $values { "section" "a section" } }
{ $description "Adds a section to the current block." }
$prettyprinting-note ;

HELP: start-group
{ $description "Marks the start of a group. Sections inside a group are output on one line if possible." } ;

HELP: end-group
{ $description "Marks the end of a group. Sections inside a group are output on one line if possible." } ;

HELP: advance
{ $values { "section" section } }
{ $description "Emits whitespace between sections." }
$prettyprinting-note ;

HELP: save-end-position
{ $values { "block" block } }
{ $description "Save the current position as the end position of the block." } ;

HELP: pprint-sections
{ $values { "block" block } { "advancer" { $quotation ( block -- ) } } }
{ $description "Prints child sections of a block, ignoring any " { $link line-break } " sections. The " { $snippet "advancer" } " quotation is called between every pair of sections." } ;

HELP: do-break
{ $values { "break" line-break } }
{ $description "Prints a break section as per the policy outlined in " { $link line-break } "." } ;

HELP: empty-block?
{ $values { "block" block } { "?" boolean } }
{ $description "Tests if the block has no child sections." } ;

HELP: unless-empty-block
{ $values { "block" block } { "quot" { $quotation ( block -- ) } } }
{ $description "If the block has child sections, calls the quotation, otherwise does nothing." } ;

HELP: (<block)
{ $values { "block" block } }
{ $description "Begins constructing a nested block." } ;

HELP: <block
{ $description "Begins a plain block." } ;

HELP: <text>
{ $values { "string" string } { "style" hashtable } { "text" "a new text section" } }
{ $description "Creates a text section." } ;

HELP: text
{ $values { "string" string } }
{ $description "Adds a string to the current block." }
$prettyprinting-note ;

HELP: styled-text
{ $values { "string" string } { "style" hashtable } }
{ $description "Adds a styled string to the current block." }
$prettyprinting-note ;

HELP: inset
{ $class-description "A " { $link block } " section which indents every line when printed as a " { $link long-section } "." } ;

HELP: <inset
{ $values { "narrow?" boolean } }
{ $description "Begins an " { $link inset } " section. When printed as a " { $link long-section } ", the output format is determined by the " { $snippet "narrow?" } " flag. If it is " { $link f } ", then longer lines are favored, wrapping at the " { $link margin } ". Otherwise, every child section is printed on its own line." }
{ $examples
    "Compare the output of printing a long quotation versus a hashtable. Quotations are printed with " { $snippet "narrow?" } " set to " { $link f } ", and hashtables are printed with " { $snippet "narrow?" } " set to " { $link t } "."
} ;

HELP: flow
{ $class-description "A " { $link block } " section printed on its own line if it can fit entirely on one line." } ;

HELP: <flow
{ $description "Begins a " { $link flow } " section." } ;

HELP: colon
{ $class-description "A " { $link block } " section. When printed as a " { $link long-section } ", indents every line except the first." }
{ $notes "Colon sections are used to enclose word definitions when " { $link "see" } "." } ;

HELP: <colon
{ $description "Begins a " { $link colon } " section." } ;

HELP: block>
{ $description "Adds the current block to its containing block." }
$prettyprinting-note ;

HELP: do-pprint
{ $values { "block" block } }
{ $description "Recursively output all children of the given block. The continuation is restored and output terminates if the line length is exceeded; this test is performed in " { $link fresh-line } "." } ;

HELP: with-pprint
{ $values { "obj" object } { "quot" quotation } }
{ $description "Sets up the prettyprinter and calls the quotation in a new scope. The quotation should add sections to the top-level block. When the quotation returns, the top-level block is printed to " { $link output-stream } "." } ;
