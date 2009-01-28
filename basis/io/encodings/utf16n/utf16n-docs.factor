USING: help.markup help.syntax ;
IN: io.encodings.utf16n

HELP: utf16n
{ $class-description "The encoding descriptor for UTF-16 without a byte order mark in native endian order. This is useful mostly for FFI calls which take input of strings of the type wchar_t*" }
{ $see-also "encodings-introduction" } ;
