! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs biassocs combinators formatting
http.client http.json json kernel literals sequences ;
IN: itunes

ERROR: http-get-error url res json ;

: ?key ( key assoc -- key ? ) dupd key? ; inline

: find-first-value ( assoc keys -- value key )
    [ of ] with map-find ; inline

CONSTANT: apple-languages $[
    H{
        { "af" "Afrikaans" }
        { "sq" "Albanian" }
        { "sq" "Albanian" }
        { "eu" "Basque" }
        { "be" "Belarusian" }
        { "bg" "Bulgarian" }
        { "ca" "Catalan" }
        { "Chinese (Simplified)" "zh-cn" }
        { "Chinese (Traditional)" "zh-tw" }
        { "hr" "Croatian" }
        { "cs" "Czech" }
        { "da" "Danish" }
        { "nl" "Dutch" }
        { "nl-be" "Dutch (Belgium)" }
        { "nl-nl" "Dutch (Netherlands)" }
        { "en" "English" }
        { "en-au" "English (Australia)" }
        { "en-bz" "English (Belize)" }
        { "en-ca" "English (Canada)" }
        { "en-ie" "English (Ireland)" }
        { "en-jm" "English (Jamaica)" }
        { "en-nz" "English (New Zealand)" }
        { "en-ph" "English (Phillipines)" }
        { "en-za" "English (South Africa)" }
        { "en-tt" "English (Trinidad)" }
        { "en-gb" "English (United Kingdom)" }
        { "en-us" "English (United States)" }
        { "en-zw" "English (Zimbabwe)" }
        { "et" "Estonian" }
        { "fo" "Faeroese" }
        { "fi" "Finnish" }
        { "fr" "French" }
        { "fr-be" "French (Belgium)" }
        { "fr-ca" "French (Canada)" }
        { "fr-fr" "French (France)" }
        { "fr-lu" "French (Luxembourg)" }
        { "fr-mc" "French (Monaco)" }
        { "fr-ch" "French (Switzerland)" }
        { "gl" "Galician" }
        { "gd" "Gaelic" }
        { "de" "German" }
        { "de-at" "German (Austria)" }
        { "de-de" "German (Germany)" }
        { "de-li" "German (Liechtenstein)" }
        { "de-lu" "German (Luxembourg)" }
        { "de-ch" "German (Switzerland)" }
        { "el" "Greek" }
        { "haw" "Hawaiian" }
        { "hu" "Hungarian" }
        { "is" "Icelandic" }
        { "in" "Indonesian" }
        { "ga" "Irish" }
        { "it" "Italian" }
        { "it-it" "Italian (Italy)" }
        { "it-ch" "Italian (Switzerland)" }
        { "ja" "Japanese" }
        { "ko" "Korean" }
        { "mk" "Macedonian" }
        { "no" "Norwegian" }
        { "pl" "Polish" }
        { "pt" "Portugese" }
        { "pt-br" "Portugese (Brazil)" }
        { "pt-pt" "Portugese (Portugal" }
        { "ro" "Romanian" }
        { "ro-mo" "Romanian (Moldova)" }
        { "ro-ro" "Romanian (Romania" }
        { "ru" "Russian" }
        { "ru-mo" "Russian (Moldova)" }
        { "ru-ru" "Russian (Russia)" }
        { "sr" "Serbian" }
        { "sk" "Slovak" }
        { "sl" "Slovenian" }
        { "es" "Spanish" }
        { "es-ar" "Spanish (Argentinia)" }
        { "es=bo" "Spanish (Bolivia)" }
        { "es-cl" "Spanish (Chile)" }
        { "es-co" "Spanish (Colombia)" }
        { "es-cr" "Spanish (Costa Rica)" }
        { "es-do" "Spanish (Dominican Republic)" }
        { "es-ec" "Spanish (Ecuador)" }
        { "es-sv" "Spanish (El Salvador)" }
        { "es-gt" "Spanish (Guatemala)" }
        { "es-hn" "Spanish (Honduras)" }
        { "es-mx" "Spanish (Mexico)" }
        { "es-ni" "Spanish (Nicaragua)" }
        { "es-pa" "Spanish (Panama)" }
        { "es-py" "Spanish (Paraguay)" }
        { "es-pe" "Spanish (Peru)" }
        { "es-pr" "Spanish (Puerto Rico)" }
        { "es-es" "Spanish (Spain)" }
        { "es-uy" "Spanish (Uruguay)" }
        { "es-ve" "Spanish (Venezuela)" }
        { "sv" "Swedish" }
        { "sv-fi" "Swedish (Finland)" }
        { "sv-se" "Swedish (Sweden)" }
        { "tr" "Turkish" }
        { "uk" "Ukranian" }
    } >biassoc
]

: >language-code ( name/code -- abbrev )
    apple-languages from>> ?key [ ] [ apple-languages to>> ?at drop ] if ;

: search-apple-podcasts ( terms -- json )
    "https://itunes.apple.com/search?media=podcast&term=%s" sprintf http-get-json nip ;

! https://podcasts.apple.com/de/genre/podcasts/id26

: >top-apple-podcasts ( hash -- json )
    {
        [ { "language" "code" } find-first-value drop >language-code "US" or ]
        [ { "genre" } find-first-value drop "26" or ] ! Genre "26" is "top"
        [ { "limit" } find-first-value drop "10" or ]
        [ { "explicit" } find-first-value drop "true" or ]
    } cleave
    "https://itunes.apple.com/%s/rss/toppodcasts/genre=%s/limit=%s/explicit=%s/json"
    sprintf http-get-json nip  ;

: top-100-apple-podcasts ( code/f -- json )
    "US" or
    'H{
        { "limit" "100" }
        { "code" _ }
        { "explicit" "true" }
        { "genre" "26" }
    } >top-apple-podcasts ;

: id>podcast ( id -- podcast )
    "https://itunes.apple.com/lookup?id=%s" sprintf http-get-json nip ;


! TODO
! https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/10/explicit.json
! https://rss.itunes.apple.com/api/v1/us/podcasts/top-podcasts/all/10/explicit.json
! https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop?genreId=26&popId=28
! https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
