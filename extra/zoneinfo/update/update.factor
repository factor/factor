! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: build-from-source cli.git io.launcher kernel sequences
sorting ;
IN: zoneinfo.update

: update-zoneinfo ( -- )
    "eggert" "tz" [
        git-tag* sort last git-reset-hard drop
        { "make" "leapseconds" } run-process drop
        { "make" "version" } run-process drop
        "vocab:zoneinfo" [
            {
                "africa"
                "antarctica"
                "asia"
                "australasia"
                "backward"
                "backzone"
                "calendars"
                "etcetera"
                "europe"
                "factory"
                "iso3166.tab"
                "leapseconds"
                "northamerica"
                "southamerica"
                "version"
                "zone1970.tab"
            } copy-output-files
        ] with-out-directory
    ] with-updated-github-repo ;
