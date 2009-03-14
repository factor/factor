! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel urls alarms calendar ;
IN: site-watcher

HELP: run-site-watcher
{ $description "Starts the site-watcher on the assoc stored in " { $link sites } "." } ;

HELP: running-site-watcher
{ $var-description "A symbol storing the alarm of a running site-watcher if started with the " { $link run-site-watcher } " word. To prevent multiple site-watchers from running, this variable is checked before allowing another site-watcher to start." } ;

HELP: site-watcher-from
{ $var-description "The email address from which site-watcher sends emails." } ;

HELP: sites
{ $var-description "A symbol storing an assoc of URLs, data about a site, and who to notify if a site goes down." } ;

HELP: watch-site
{ $values
    { "emails" "a string containing an email address, or an array of such" }
    { "url" url }
}
{ $description "Adds a new site to the watch assoc stored in " { $link sites } ", or adds email addresses to an already watched site." } ;

HELP: watch-sites
{ $values
    { "assoc" assoc }
    { "alarm" alarm }
}
{ $description "Runs the site-watcher on the input assoc and returns the alarm that times the site check loop. This alarm may be turned off with " { $link cancel-alarm } ", thus stopping the site-watcher." } ;

HELP: site-watcher-frequency
{ $var-description "A " { $link duration } " specifying how long to wait between checking sites." } ;

HELP: unwatch-site
{ $values
    { "emails" "a string containing an email, or an array of such" }
    { "url" url }
}
{ $description "Removes an email address from being notified when a site's goes down. If this email was the last one watching the site, removes the site as well." } ;

HELP: delete-site
{ $values
    { "url" url }
}
{ $description "Removes a watched site from the " { $link sites } " assoc." } ;

ARTICLE: "site-watcher" "Site watcher"
"The " { $vocab-link "site-watcher" } " vocabulary monitors websites and sends email when a site goes down or comes up." $nl
"To monitor a site:"
{ $subsection watch-site }
"To stop email addresses from being notified if a site's status changes:"
{ $subsection unwatch-site }
"To stop monitoring a site for all email addresses:"
{ $subsection delete-site }
"To run site-watcher using the sites variable:"
{ $subsection run-site-watcher }
;

ABOUT: "site-watcher"
