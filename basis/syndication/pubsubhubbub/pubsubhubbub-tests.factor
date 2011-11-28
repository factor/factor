! Copyright (c) 2010 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: http syndication.pubsubhubbub tools.test urls ;

[
    T{ request
       { method "POST" }
       { url URL" http://rfc1149.superfeedr.com:80/" }
       { version "1.1" }
       { header
         H{
             { "user-agent" "Factor http.client" }
             { "connection" "close" }
         }
       }
       { post-data
         T{ post-data
            { data
              B{
                  104 117 98 46 109 111 100 101 61 112 117 98
                  108 105 115 104 38 104 117 98 46 117 114
                  108 61 104 116 116 112 58 47 47 119 119 119
                  46 114 102 99 49 49 52 57 46 110 101 116 47
                  98 108 111 103 47 102 101 101 100 47 38 104
                  117 98 46 117 114 108 61 104 116 116 112 58
                  47 47 119 119 119 46 114 102 99 49 49 52 57
                  46 110 101 116 47 98 108 111 103 47 101 110
                  47 102 101 101 100 47
              }
            }
            { content-type
              "application/x-www-form-urlencoded"
            }
         }
       }
       { cookies V{ } }
       { redirects 10 }
    }
] [ 
    { "http://www.rfc1149.net/blog/feed/" "http://www.rfc1149.net/blog/en/feed/" } "http://rfc1149.superfeedr.com/" <ping-request>
] unit-test
