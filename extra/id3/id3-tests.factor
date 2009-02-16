! Copyright (C) 2009 Tim Wawrzynczak
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test id3 ;
IN: id3.tests

[ T{ mp3v2-file
     { header  T{ header f t 0 502 } }
     { frames
       {
           T{ frame
              { frame-id "COMM" }
              { flags B{ 0 0 } }
              { size 19 }
              { data "eng, AG# 08E1C12E" }
           }
           T{ frame
              { frame-id "TIT2" }
              { flags B{ 0 0 } }
              { size 15 }
              { data "Stormy Weather" }
           }
           T{ frame
              { frame-id "TRCK" }
              { flags B{ 0 0 } }
              { size 3 }
              { data "32" }
           }
           T{ frame
              { frame-id "TCON" }
              { flags B{ 0 0 } }
              { size 5 }
              { data "(96)" }
           }
           T{ frame
              { frame-id "TALB" }
              { flags B{ 0 0 } }
              { size 28 }
              { data "Night and Day Frank Sinatra" }
           }
           T{ frame
              { frame-id "PRIV" }
              { flags B{ 0 0 } }
              { size 39 }
              { data "WM/MediaClassPrimaryID�}`�#��K�H�*(D" }
           }
           T{ frame
              { frame-id "PRIV" }
              { flags B{ 0 0 } }
              { size 41 }
              { data "WM/MediaClassSecondaryID" }
           }
           T{ frame
              { frame-id "TPE1" }
              { flags B{ 0 0 } }
              { size 14 }
              { data "Frank Sinatra" }
           }
       }
     }
}
] [ "resource:extra/id3/tests/blah3.mp3" file-id3-tags ] unit-test

[
    T{ mp3v2-file
    { header
        T{ header { version t } { flags 0 } { size 1405 } }
    }
    { frames
        {
            T{ frame
                { frame-id "TIT2" }
                { flags B{ 0 0 } }
                { size 22 }
                { data "Anthem of the Trinity" }
            }
            T{ frame
                { frame-id "TPE1" }
                { flags B{ 0 0 } }
                { size 12 }
                { data "Terry Riley" }
            }
            T{ frame
                { frame-id "TALB" }
                { flags B{ 0 0 } }
                { size 11 }
                { data "Shri Camel" }
            }
            T{ frame
                { frame-id "TCON" }
                { flags B{ 0 0 } }
                { size 10 }
                { data "Classical" }
            }
            T{ frame
                { frame-id "UFID" }
                { flags B{ 0 0 } }
                { size 23 }
                { data "http://musicbrainz.org" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 23 }
                { data "MusicBrainz Artist Id" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 22 }
                { data "musicbrainz_artistid" }
            }
            T{ frame
                { frame-id "TRCK" }
                { flags B{ 0 0 } }
                { size 2 }
                { data "1" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 22 }
                { data "MusicBrainz Album Id" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 21 }
                { data "musicbrainz_albumid" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 29 }
                { data "MusicBrainz Album Artist Id" }
            }
            T{ frame
                { frame-id "TXXX" }
                { flags B{ 0 0 } }
                { size 27 }
                { data "musicbrainz_albumartistid" }
            }
            T{ frame
                { frame-id "TPOS" }
                { flags B{ 0 0 } }
                { size 2 }
                { data "1" }
            }
            T{ frame
                { frame-id "TSOP" }
                { flags B{ 0 0 } }
                { size 1 }
            }
            T{ frame
                { frame-id "TMED" }
                { flags B{ 0 0 } }
                { size 4 }
                { data "DIG" }
            }
        }
    }
}
] [ "resource:extra/id3/tests/blah2.mp3" file-id3-tags ] unit-test

[    
  T{ mp3v1-file
     { title
       "BLAH"
     }
     { artist
       "ARTIST"
     }
     { album
       "ALBUM"
     }
     { year "2009" }
     { comment
       "COMMENT"
     }
     { genre 89 }
  }
] [ "resource:extra/id3/tests/blah.mp3" file-id3-tags ] unit-test

