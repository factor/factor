! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: build-from-source cli.git github io.launcher kernel
sequences sorting sorting.human ;
IN: zoneinfo.update

: zoneinfo-versions ( -- seq )
    "eggert" "tz" "" list-repository-tags-matching
    tag-refs human-sort ;

: update-zoneinfo ( -- )
    "eggert" "tz" zoneinfo-versions last [
        { "make" "leapseconds" } try-process
        { "make" "version" } try-process
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
    ] with-github-worktree-tag ;
