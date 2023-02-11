! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: spider

HELP: <spider>
{ $values
    { "base" "a string or url" }
    { "spider" spider } }
{ $description "Creates a new web spider with a given base url." } ;

HELP: run-spider
{ $values
    { "spider" spider } }
{ $description "Runs a spider until completion. See the " { $subsection "spider-tutorial" } " for a complete description of the tuple slots that affect how thet spider works." } ;

ARTICLE: "spider-tutorial" "Spider tutorial"
"To create a new spider, call the " { $link <spider> } " word with a link to the site you wish to spider."
{ $code "\"https://concatenative.org\" <spider>" }
"The max-depth is initialized to 0, which retrieves just the initial page. Let's initialize it to something more fun:"
{ $code "1 >>max-depth" }
"Now the spider will retrieve the first page and all the pages it links to in the same domain." $nl
"But suppose the front page contains thousands of links. To avoid grabbing them all, we can set " { $slot "max-count" } " to a reasonable limit."
{ $code "10 >>max-count" }
"A timeout might keep the spider from hitting the server too hard:"
{ $code "USE: calendar 1.5 seconds >>sleep" }
"Since we happen to know that not all pages of a wiki are suitable for spidering, we will spider only the wiki view pages, not the edit or revisions pages. To do this, we add a filter through which new links are tested; links that pass the filter are added to the todo queue, while links that do not are discarded. You can add several filters to the filter array, but we'll just add a single one for now."
{ $code "{ [ path>> \"/wiki/view\" head? ] } >>filters" }
"Finally, to start the spider, call the " { $link run-spider } " word."
{ $code "run-spider" }
"The full code from the tutorial."
{ $code "USING: spider calendar sequences accessors ;
: spider-concatenative ( -- spider )
    \"https://concatenative.org\" <spider>
    1 >>max-depth
    10 >>max-count
    1.5 seconds >>sleep 
    { [ path>> \"/wiki/view\" head? ] } >>filters
    run-spider ;" } ;

ARTICLE: "spider" "Spider"
"The " { $vocab-link "spider" } " vocabulary implements a simple web spider for retrieving sets of webpages."
{ $subsections "spider-tutorial" }
"Creating a new spider:"
{ $subsections <spider> }
"Running the spider:"
{ $subsections run-spider } ;

ABOUT: "spider"
