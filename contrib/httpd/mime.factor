! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: io hashtables kernel lists namespaces ;

: file-extension ( filename -- extension )
    "." split dup length 1 <= [ drop f ] [ peek ] if ;

: mime-type ( filename -- mime-type )
    file-extension "mime-types" get
    hash [ "text/plain" ] unless* ;

H{
    { "html"   "text/html"                        }
    { "txt"    "text/plain"                       }
    { "xml"    "text/xml"                         }
    { "css"    "text/css"                         }
                                                    
    { "gif"    "image/gif"                        }
    { "png"    "image/png"                        }
    { "jpg"    "image/jpeg"                       }
    { "jpeg"   "image/jpeg"                       }
                                                    
    { "jar"    "application/octet-stream"         }
    { "zip"    "application/octet-stream"         }
    { "tgz"    "application/octet-stream"         }
    { "tar.gz" "application/octet-stream"         }
    { "gz"     "application/octet-stream"         }
                                                    
    { "factor" "application/x-factor"             }
    { "factsp" "application/x-factor-server-page" }
} "mime-types" global set-hash
