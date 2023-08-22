! Copyright (C) 2013 Charles Alston, John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.pathnames sequences strings ;
IN: spotlight

HELP: mdfind
{ $values { "query" string } { "results" sequence } }
{ $description
    "Finds files matching a given query."
    $nl
    { $snippet "mdfind [-live] [-count] [-onlyin directory] [-name fileName] query" }
    $nl
    "The mdfind command consults the central metadata store and returns a list of files that match the given metadata query. The query can be a string or a query expression."
    $nl
    { $subheading "Spotlight Keywords" }
    "These can be included in the query expression to limit the type of documents returned:"
    { $table
        { "Applications"  "kind:application, kind:applications, kind:app" }
        { "Audio/Music"   "kind:audio, kind:music" }
        { "Bookmarks"     "kind:bookmark, kind:bookmarks" }
        { "Contacts"      "kind:contact, kind:contacts" }
        { "Email"         "kind:email, kind:emails, kind:mail message, kind:mail messages" }
        { "Folders"       "kind:folder, kind:folders" }
        { "Fonts"         "kind:font, kind:fonts" }
        { "iCal Events"   "kind:event, kind:events" }
        { "iCal To Dos"   "kind:todo, kind:todos, kind:to do, kind:to dos" }
        { "Images"        "kind:image, kind:images" }
        { "Movies"        "kind:movie, kind:movies" }
        { "PDF"           "kind:pdf, kind:pdfs" }
        { "Preferences"   "kind:system preferences, kind:preferences" }
        { "Presentations" "kind:presentations, kind:presentation" }
    }
    { $subheading "Date Keywords" }
    "These can be included in the query expression to limit the age of documents returned:"
    { $table
        { "date:today"       "$time.today()" }
        { "date:yesterday"   "$time.yesterday()" }
        { "date:this week"   "$time.this_week()" }
        { "date:this month"  "$time.this_month()" }
        { "date:this year"   "$time.this_year()" }
        { "date:tomorrow"    "$time.tomorrow()" }
        { "date:next month"  "$time.next_month()" }
        { "date:next week"   "$time.next_week()" }
        { "date:next year"   "$time.next_year()" }
    }
    { $subheading "Boolean Operators" }
    "By default mdfind will AND together elements of the query string."
    { $table
        { "| (OR)"    { "to return items that match either word, use the pipe character: " { $snippet "stringA|stringB" } } }
        { "- (NOT)"   { "to exclude documents that match a string: " { $snippet "-string" } } }
        { "=="        "equal" }
        { "!="        "not equal" }
        { "< and >"   "\"less\" or \"more than\"" }
        { "<= and >=" "\"less than or equal\" or \"more than or equal\"" }
    }
}
{ $examples
    "Return all files that have been modified today"
    { $code "\"date:today\" mdfind" }
    "Return all files that have been modified in the last 3 days"
    { $code "\"kMDItemFSContentChangeDate >= $time.today (-3)\" mdfind" }
    "Returns files with particular attributes"
    { $code "\"com.microsoft.word.doc\" \"kMDItemContentType\" attr== mdfind" }
    "Look for files with a particular file name"
    { $code "\"Finding Joy in Combinators.pdf\" \"kMDItemFSName\" attr== mdfind" }
    "Look for terms in documents"
    { $code "\"Document cocoa.messages selector\" mdfind" }
    "Return all files in the users home folder that have been modified in the last 3 days"
    { $code "\"~\" [ \"kMDItemFSContentChangeDate >= $time.today (-3)\" mdfind ] with-directory" }
}
{ $notes "This word uses the " { $link current-directory } " to restrict the search, choosing to search from the root ('" { $snippet "/" } "') if not set." } ;

HELP: mdfind.
{ $values { "query" string } }
{ $description "Similar to " { $link mdfind } ", but prints out the results as a list of " { $link pathname } " objects, allowing you to right-click and \"Open File\" if used with the " { $snippet "webbrowser" } " vocabulary." } ;

HELP: mdls
{ $values { "path" "string or pathname" } }
{ $description
    "Lists the metadata attributes for the specified file."
    $nl
    { $snippet "mdls [-name attributeName] [-raw [-nullMarker markerString]] file ..." }
    $nl
    "The mdls command prints the values of all the metadata attributes associated with the files provided as an argument."
} ;

HELP: mdutil
{ $values { "flags" string } { "on|off" string } { "volume" string } { "seq" sequence } }
{ $description
    "Manage the metadata stores used by Spotlight."
    $nl
    { $snippet "mdutil [-pEsav] [-i on | off] mountPoint ..." }
    $nl
    "The mdutil command is useful for managing the metadata stores for mounted volumes."
} ;

HELP: mdimport
{ $values { "path" string } { "seq" sequence } }
{ $description
    "Import file hierarchies into the metadata datastore."
    $nl
    { $snippet "mdimport [-VXLArgn] [-d level | category] [-w delay] file | directory" }
    $nl
    "mdimport is used to test Spotlight plug-ins, list the installed plug-ins and schema, and re-index files handled by a plug-in when a new plug-in is installed."
} ;

HELP: kMDItems
{ $values { "seq" sequence } }
{ $description "Retrieves all the available kMDItemAttributes." } ;

HELP: kMDItems.
{ $description "Prints a table of all the available kMDItemAttributes." } ;
