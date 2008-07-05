USING: strings.parser kernel namespaces unicode.data ;

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
