USING: help.markup help.syntax ;
IN: arrays.nested-syntax

HELP: {{
{ $syntax "{{ zim zang ;; zoop ;; zidilly zam ;; ... }}" }
{ $description "Shorthand for a literal array of arrays. Subarrays are separated by the " { $link POSTPONE: ;; } " token." }
{ $examples "The following blocks of code push an equivalent array onto the stack:" { $example "{{ 1 ;; 2 3 ;; 4 5 6 }}" } { $example "{ { 1 } { 2 3 } { 4 5 6 } }" } } ;

HELP: H{{
{ $syntax "H{{ zim zang ;; zoop zidilly ;; zam zung ;; ... }}" }
{ $description "Shorthand for a literal hashtable. Key-value pairs are separated by the " { $link POSTPONE: ;; } " token." }
{ $examples "The following blocks of code push an equivalent hash table onto the stack:" { $example "H{{ \"Monday\" 1 ;; \"Tuesday\" 2 ;; \"Wednesday\" 3 ;; \"Thursday\" 4 }}" } { $example "H{ { \"Monday\" 1 } { \"Tuesday\" 2 } { \"Wednesday\" 3 } { \"Thursday\" 4 } }" } } ;

HELP: [[
{ $syntax "[[ foo ;; bar bas ;; qux quux quuuux ;; ... ]]" }
{ $description "Shorthand for a literal array of quotations. Each quotation is separated by the " { $link POSTPONE: ;; } " token." }
{ $examples "The following blocks of code are equivalent:" { $example "[[ 1+ ;; 2 + ]] cleave" } { $example "{ [ 1+ ] [ 2 + ] } cleave" } } ;

{ POSTPONE: {{ POSTPONE: H{{ POSTPONE: [[ } related-words

HELP: ;;
{ $description "Separator token used in the " { $link POSTPONE: {{ } ", " { $link POSTPONE: H{{ } ", and " { $link POSTPONE: [[ } " literal syntaxes." } ;

HELP: }}
{ $description "Delimiter token used to close the " { $link POSTPONE: {{ } " and " { $link POSTPONE: H{{ } " literal syntaxes." } ;

HELP: ]]
{ $description "Delimiter token used to close the " { $link POSTPONE: [[ } " literal syntax." } ;

