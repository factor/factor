USING: accessors ldcache system tools.test ;
IN: ldcache.tests

: entries ( -- entries )
    {
        T{ ldcache-entry
           { elf? t }
           { arch x86.64 }
           { osversion 0 }
           { hwcap 0 }
           { key "libwmf-0.2.so.7" }
           { value "/usr/lib/x86_64-linux-gnu/libwmf-0.2.so.7" }
         }
        T{ ldcache-entry
           { elf? t }
           { arch x86.64 }
           { osversion 0 }
           { hwcap 0 }
           { key "libwinpr-utils.so.0.1" }
           { value
             "/usr/lib/x86_64-linux-gnu/libwinpr-utils.so.0.1"
           }
         }
    } ;

{ "libwmf-0.2.so.7" } [
    entries "wmf-0.2" x86.64 search key>>
] unit-test
