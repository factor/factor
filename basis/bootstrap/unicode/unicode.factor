USING: strings.parser kernel namespaces unicode unicode.data ;
IN: bootstrap.unicode

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
