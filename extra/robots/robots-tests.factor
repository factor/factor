! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar io.encodings.utf8 io.files robots tools.test
urls ;

{
    { "http://www.chiplist.com/sitemap.txt" }
    {
        T{ rules
            { user-agents V{ "*" } }
            { allows V{ } }
            { disallows
                V{
                    URL" /cgi-bin/"
                    URL" /scripts/"
                    URL" /ChipList2/scripts/"
                    URL" /ChipList2/styles/"
                    URL" /ads/"
                    URL" /ChipList2/ads/"
                    URL" /advertisements/"
                    URL" /ChipList2/advertisements/"
                    URL" /graphics/"
                    URL" /ChipList2/graphics/"
                }
            }
            { visit-time
                {
                    T{ duration { hour 2 } }
                    T{ duration { hour 5 } }
                }
            }
            { request-rate 1 }
            { crawl-delay 1 }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "UbiCrawler" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "DOC" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Zao" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "sitecheck.internetseer.com" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Zealbot" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "MSIECrawler" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "SiteSnagger" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "WebStripper" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "WebCopier" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Fetch" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Offline Explorer" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Teleport" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "TeleportPro" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "WebZIP" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "linko" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "HTTrack" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Microsoft.URL.Control" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Xenu" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "larbin" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "libwww" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "ZyBORG" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "Download Ninja" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "wget" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "grub-client" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "k2spider" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "NPBot" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents V{ "WebReaper" } }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
        T{ rules
            { user-agents
                V{
                    "abot"
                    "ALeadSoftbot"
                    "BeijingCrawler"
                    "BilgiBot"
                    "bot"
                    "botlist"
                    "BOTW Spider"
                    "bumblebee"
                    "Bumblebee"
                    "BuzzRankingBot"
                    "Charlotte"
                    "Clushbot"
                    "Crawler"
                    "CydralSpider"
                    "DataFountains"
                    "DiamondBot"
                    "Dulance bot"
                    "DYNAMIC"
                    "EARTHCOM.info"
                    "EDI"
                    "envolk"
                    "Exabot"
                    "Exabot-Images"
                    "Exabot-Test"
                    "exactseek-pagereaper"
                    "Exalead NG"
                    "FANGCrawl"
                    "Feed::Find"
                    "flatlandbot"
                    "Gigabot"
                    "GigabotSiteSearch"
                    "GurujiBot"
                    "Hatena Antenna"
                    "Hatena Bookmark"
                    "Hatena RSS"
                    "HatenaScreenshot"
                    "Helix"
                    "HiddenMarket"
                    "HyperEstraier"
                    "iaskspider"
                    "IIITBOT"
                    "InfociousBot"
                    "iVia"
                    "iVia Page Fetcher"
                    "Jetbot"
                    "Kolinka Forum Search"
                    "KRetrieve"
                    "LetsCrawl.com"
                    "Lincoln State Web Browser"
                    "Links4US-Crawler"
                    "LOOQ"
                    "Lsearch/sondeur"
                    "MapoftheInternet.com"
                    "NationalDirectory"
                    "NetCarta_WebMapper"
                    "NewsGator"
                    "NextGenSearchBot"
                    "ng"
                    "nicebot"
                    "NP"
                    "NPBot"
                    "Nudelsalat"
                    "Nutch"
                    "OmniExplorer_Bot"
                    "OpenIntelligenceData"
                    "Oracle Enterprise Search"
                    "Pajaczek"
                    "panscient.com"
                    "PeerFactor 404 crawler"
                    "PeerFactor Crawler"
                    "PlantyNet"
                    "PlantyNet_WebRobot"
                    "plinki"
                    "PMAFind"
                    "Pogodak!"
                    "QuickFinder Crawler"
                    "Radiation Retriever"
                    "Reaper"
                    "RedCarpet"
                    "ScorpionBot"
                    "Scrubby"
                    "Scumbot"
                    "searchbot"
                    "Seeker.lookseek.com"
                    "SeznamBot"
                    "ShowXML"
                    "snap.com"
                    "snap.com beta crawler"
                    "Snapbot"
                    "SnapPreviewBot"
                    "sohu"
                    "SpankBot"
                    "Speedy Spider"
                    "Speedy_Spider"
                    "SpeedySpider"
                    "spider"
                    "SquigglebotBot"
                    "SurveyBot"
                    "SynapticSearch"
                    "T-H-U-N-D-E-R-S-T-O-N-E"
                    "Talkro Web-Shot"
                    "Tarantula"
                    "TerrawizBot"
                    "TheInformant"
                    "TMCrawler"
                    "TridentSpider"
                    "Tutorial Crawler"
                    "Twiceler"
                    "unwrapbot"
                    "URI::Fetch"
                    "VengaBot"
                    "Vonna.com b o t"
                    "Vortex"
                    "Votay bot"
                    "WebAlta Crawler"
                    "Webbot"
                    "Webclipping.com"
                    "WebCorp"
                    "Webinator"
                    "WIRE"
                    "WISEbot"
                    "Xerka WebBot"
                    "XSpider"
                    "YodaoBot"
                    "Yoono"
                    "yoono"
                }
            }
            { allows V{ } }
            { disallows V{ URL" /" } }
            { unknowns H{ } }
        }
    }
} [ "vocab:robots/robots.txt" utf8 file-contents parse-robots.txt ] unit-test
