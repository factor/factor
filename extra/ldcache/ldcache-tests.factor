USING: accessors ldcache ldcache.private system tools.test ;

{ "libwmf-0.2.so.7" } [
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
    } "wmf-0.2" x86.64 search-ldcache key>>
] unit-test
