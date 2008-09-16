IN: mason.release.upload.tests
USING: mason.release.upload mason.common mason.config
mason.common namespaces calendar tools.test ;

[
    {
        "scp"
        "factor-linux-ppc-2008-09-11-23-12.tar.gz"
        "slava@www.apple.com:/uploads/linux-ppc/factor-linux-ppc-2008-09-11-23-12.tar.gz.incomplete"
    }
    {
        "ssh"
        "www.apple.com"
        "-l" "slava"
        "mv"
        "/uploads/linux-ppc/factor-linux-ppc-2008-09-11-23-12.tar.gz.incomplete"
        "/uploads/linux-ppc/factor-linux-ppc-2008-09-11-23-12.tar.gz"
    }
] [
    [
        "slava" upload-username set
        "www.apple.com" upload-host set
        "/uploads" upload-directory set
        "linux" target-os set
        "ppc" target-cpu set
        T{ timestamp
            { year 2008 }
            { month 09 }
            { day 11 }
            { hour 23 }
            { minute 12 }
        } datestamp stamp set
        upload-command
        rename-command
    ] with-scope
] unit-test

\ upload must-infer
