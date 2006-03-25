IN: components
USING: hashtables help inspector kernel namespaces sequences
words ;

SYMBOL: components

H{ } clone components set-global

: get-components ( class -- assoc )
    components get-global hash [ { } ] unless*
    { "Slots" [ describe ] } add ;

{
    { "Definition" [ help ] }
    { "Calls in" [ usage. ] }
    { "Calls out" [ uses. ] }
} \ word components get-global set-hash

{
    { "Documentation" [ help ] }
} \ link components get-global set-hash
