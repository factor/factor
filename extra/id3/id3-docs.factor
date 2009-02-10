! Copyright (C) 2008 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences kernel ;
IN: id3

HELP: id3-parse-mp3-file
{ $values 
    { "path" "a path string" } 
    { "object/f" "either a tuple consisting of the data from an MP3 file, or an f indicating this file has no (supported) ID3 information." } }
{ $description "Return a tuple containing the ID3 information parsed out of the MP3 file" } ;

ARTICLE: "id3" "ID3 tags"
{ $emphasis "ID3" } " tags are textual data that is used to describe the information (title, artist, etc.) in an .MP3 file"
"Parsing an MP3 file: "
{ $subsection id3-parse-mp3-file } ;

ABOUT: "id3"
