! Copyright (C) 2009-2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: assocs help.markup help.syntax ;
IN: cgi

HELP: <cgi-form>
{ $values { "assoc" assoc } }
{ $description "Parse a CGI request into an " { $link assoc } ". Multiple parameters are passed as a list for each key." } ;

HELP: <cgi-simple-form>
{ $values { "assoc" assoc } }
{ $description "Parse a CGI request into an " { $link assoc } ". Only the first parameter is kept, if multiple parameters are passed." } ;
