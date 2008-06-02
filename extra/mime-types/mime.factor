! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files assocs kernel namespaces ;
IN: http.mime

: mime-type ( filename -- mime-type )
    file-extension "mime-types" get at "application/octet-stream" or ;

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

    { "pdf"    "application/pdf"                  }

    { "factor" "text/plain"                       }
    { "cgi"    "application/x-cgi-script"         }
    { "fhtml"  "application/x-factor-server-page" }
} "mime-types" set-global
