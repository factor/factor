USING: calendar help.markup help.syntax kernel strings ;
IN: calendar.parser

HELP: cookie-string>timestamp
{ $values { "str" string } { "timestamp" { $maybe timestamp } } }
{ $description "Parses a cookie expiration date. Legacy hyphenated and asctime-style dates without a timezone are interpreted as GMT. An explicit timezone is preserved. Returns " { $link f } " if the date cannot be parsed." } ;
