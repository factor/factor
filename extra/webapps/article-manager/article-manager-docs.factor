! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax webapps.article-manager.database ;
IN: webapps.article-manager

ARTICLE: { "article-manager" "loading" } "Loading Article Manager"
"To start an instance of the article-manager furnace application:"
{ $example "\"webapps.article-manager\" run" }
"The article-manager database needs to be opened before it can be accessed."
{ $example "open-db" } ;

ARTICLE: { "article-manager" "security" } "Article Manager Security"
"To setup an article manager site you need to authenticate under the basic-authentication realm called \"article-manager-site\". To add and edit articles you need to authenticate under the realm \"article-manager-article\". The following sets up an 'admin' user under these two realms with a password of 'password'."
{ $example "H{ { \"admin\" \"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8\" } } \"article-manager-site\" add-realm\nH{ { \"admin\" \"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8\" } } \"article-manager-article\" add-realm " } 
"Multiple users can be added with different passwords under these realms." ;

ARTICLE: { "article-manager" "setup" } "Article Manager Setup"
"A site must first be setup before it can be accessed by the user. This can be access via the URL " { $url "http://site-name/responder/article-manager/setup-site/" } "\n\n" 
"The 'hostname' is the hostname portion of the URL used to access the site. The 'title' is what appears in the title bar. 'footer' appears at the bottom of the pages in the site and can be used for a copyright notice, etc. 'Introduction' Should be Wiky code and will appear on the first index page of the site. 'HTML' will be appended to every page just before the closing of the 'body' HTML tag. It can be used to put HTML for counters, user tracking, etc.\n\n" 
"The 'Ad Block' sections are used for entering HTML and Javascript code for ads that will appear in the article pages. 'Ad Block 1' appears in the left hand navigation area underneat the menu and above the 'tags' list. The other two ad blocks appear at the top of articles randomly split between either no ad and one of those two blocks." ;

ARTICLE: { "article-manager" "articles" } "Adding or Editing Articles"
"Articles are added or edited using the URL " { $url "http://site-name/responder/article-manager/edit-article/article-name" } ". This will bring up a form with information about the article.\n\n'Publication Date' is the date you want to appear next to the article. You can click the button next to it to select it using a popup calendar. 'Title' is the title of the article.\n\n'Status' can be 'Draft' or 'Published'. 'Draft' articles do not appear in the main index page or list of tags. They can still be accessed via the direct URL however. Note that editing an existing article will default this to 'Draft' automatically, so you'll need to change it back to 'Published' if you want it to appear.\n\n'Tags' is a space-separated list of tag names that can be used for finding articles.\n\n'Body' is the text of the article. It is in Wiky format and shows a preview below it. For more on the Wiky syntax see " { $url "http://goessner.net/articles/wiky/WikyBox.html" } " or Google for 'Wikybox'." 
;

ARTICLE: { "article-manager" "article-manager" } "Article Manager"
"The article-manager is a Furnace application used to manage and display a tagged set of articles. Each instance of the article-manager responder can run multiple sites containing different articles. Follow these instructions to set up an article manager instance."
{ $subsection { "article-manager" "loading" } } 
{ $subsection { "article-manager" "security" } } 
{ $subsection { "article-manager" "setup" } } 
{ $subsection { "article-manager" "articles" } }  ;

ABOUT: { "article-manager" "article-manager" } 