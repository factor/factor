! Copyright (C) 2008 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax sequences kernel accessors ;
IN: id3

HELP: file-id3-tags
{ $values 
    { "path" "a path string" } 
    { "id3v2-info/f" "a tuple storing ID3v2 metadata or f" } }
    { $description "Return a tuple containing the ID3 information parsed out of the MP3 file, or " { $link f } " if no metadata is present.  Currently, the parser supports the following tags: "
      $nl { $link title>> }
      $nl { $link artist>> }
      $nl { $link album>> }
      $nl { $link year>> }
      $nl { $link genre>> }
      $nl { $link comment>> } } ;

ARTICLE: "id3" "ID3 tags"
"The " { $vocab-link "id3" } " vocabulary contains words for parsing " { $emphasis "ID3" } " tags, which are textual fields storing an MP3's title, artist, and other metadata." $nl
"Parsing ID3 tags from an MP3 file:"
{ $subsection file-id3-tags } ;

ABOUT: "id3"
