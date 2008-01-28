USING: help.markup help.syntax ui.commands ui.operations
ui.tools.search ui.tools.workspace editors vocabs.loader
kernel sequences prettyprint tools.test strings ;
IN: help.tutorial

ARTICLE: "first-program-start" "Creating a vocabulary for your first program"
"Factor source code is organized into " { $link "vocabularies" } ". Before we can write our first program, we must create a vocabulary for it."
$nl
"Start by asking Factor for the path to your ``work'' directory, where you will place your own code:"
{ $code "\"work\" resource-path ." }
"Open the work directory in your file manager, and create a subdirectory named " { $snippet "palindrome" } ". Inside this directory, create a file named " { $snippet "palindrome.factor" } " using your favorite text editor. Leave the file empty for now."
$nl
"Inside the Factor listener, type"
{ $code "USE: palindrome" }
"The source file should now load. Since it is empty, it does nothing. If you get an error message, make sure you created the directory and the file in the right place and gave them the right names."
$nl
"Now, we will start filling out this source file. Go back to your editor, and type:"
{ $code
    "! Copyright (C) 2008 <your name here>"
    "! See http://factorcode.org/license.txt for BSD license."
}
"This is the standard header for Factor source files; it consists of two " { $link "syntax-comments" } "."
$nl
"Now, we tell Factor that all definitions in this source file should go into the " { $snippet "palindrome" } " vocabulary using the " { $link POSTPONE: IN: } " word:"
{ $code "IN: palindrome" }
"You are now ready to go onto the nex section." ;

ARTICLE: "first-program-logic" "Writing some logic in your first program"
"Your " { $snippet "palindrome.factor" } " file should look like the following after the previous section:"
{ $code
    "! Copyright (C) 2008 <your name here>"
    "! See http://factorcode.org/license.txt for BSD license."
    "IN: palindrome"
}
"We will now write our first word using " { $link POSTPONE: : } ". This word will test if a string is a palindrome; it will take a string as input, and give back a  boolean as output. We will call this word " { $snippet "palindrome?" } ", following a naming convention that words returning booleans have names ending with " { $snippet "?" } "."
$nl
"Recall that a string is a palindrome if it is spelled the same forwards or backwards; that is, if the string is equal to its reverse. We can express this in Factor as follows:"
{ $code ": palindrome? ( string -- ? ) dup reverse = ;" }
"Place this definition at the end of your source file."
$nl
"Now we have changed the source file, we must reload it into Factor so that we can test the new definition. To do this, simply go to the Factor workspace and press " { $command workspace "workflow" refresh-all } ". This will find any previously-loaded source files which have changed on disk, and reload them."
$nl
"When you do this, you will get an error about the " { $link dup } " word not being found. This is because this word is part of the " { $vocab-link "kernel" } " vocabulary, but this vocabulary is not part of the source file's " { $link "vocabulary-search" } ". You must explicitly list dependencies in source files. This allows Factor to automatically load required vocabularies and makes larger programs easier to maintain."
$nl
"To add the word to the search path, first convince yourself that this word is in the " { $vocab-link "kernel" } " vocabulary by entering the following in the listener:"
{ $code "\\ dup see" }
"This shows the definition of " { $link dup } ", along with an " { $link POSTPONE: IN: } " form."
$nl
"Now, add the following at the start of the source file:"
{ $code "USING: kernel ;" }
"Next, find out what vocabulary " { $link reverse } " lives in:"
{ $code "\\ reverse see" }
"It lives in the " { $vocab-link "sequences" } " vocabulary, so we add that to the search path:"
{ $code "USING: kernel sequences ;" }
"Finally, check what vocabulary " { $link = } " lives in:"
{ $code "\\ = see" }
"It's in the " { $vocab-link "kernel" } " vocabulary, which we've already added to the search path."

"Now press " { $command workspace "workflow" refresh-all } " again, and the source file should reload without any errors." ;

ARTICLE: "first-program-test" "Testing your first program"
"Your " { $snippet "palindrome.factor" } " file should look like the following after the previous section:"
{ $code
    "! Copyright (C) 2008 <your name here>"
    "! See http://factorcode.org/license.txt for BSD license."
    "IN: palindrome"
    "USING: kernel sequences ;"
    ""
    ": palindrome? ( str -- ? ) dup reverse = ;"
}
"We will now test our new word in the listener. First, push a string on the stack:"
{ $code "\"hello\"" }
"Note that the stack display at the top of the workspace now shows this string. Having supplied the input, we call our word:"
{ $code "palindrome?" }
"The stack display should now have a boolean false - " { $link f } " - which is the word's output. Since ``hello'' is not a palindrome, this is what we expect. We can get rid of this boolean by calling " { $link drop } ". The stack should be empty after this is done."
$nl
"Now, let's try it with a palindrome; we will push the string and call the word in the same line of code:"
{ $code "\"racecar\" palindrome?" }
"The stack should now contain a boolean true - " { $link t } ". We can print it and drop it using the " { $link . } " word:"
{ $code "." }
"What we just did is called " { $emphasis "interactive testing" } ". A more advanced technique which comes into play with larger programs is " { $link "tools.test" } "."
$nl
"Create a file named " { $snippet "palindrome-tests.factor" } " in the same directory as " { $snippet "palindrome.factor" } ". Now, we can run unit tests from the listener:"
{ $code "\"palindrome\" test" }
"We will add some unit tests corresponding to the interactive tests we did above. Unit tests are defined with the " { $link unit-test } " word, which takes a sequence of expected outputs, and a piece of code. It runs the code, and asserts that it outputs the expected values."
$nl
"Add the following three lines to " { $snippet "palindrome-tests.factor" } ":"
{ $code
    "USING: palindrome tools.test ;"
    "[ f ] [ \"hello\" palindrome? ] unit-test"
    "[ t ] [ \"racecar\" palindrome? ] unit-test"
}
"Now, you can run unit tests:"
{ $code "\"palindrome\" test" }
"It should report that all tests have passed." ;

ARTICLE: "first-program-extend" "Extending your first program"
"Our palindrome program works well, however we'd like to extend it to ignore spaces and non-alphabetical characters in the input."
$nl
"For example, we'd like it to identify the following as a palindrome:"
{ $code "\"A man, a plan, a canal: Panama.\"" }
"However, right now, the simplistic algorithm we use says this is not a palindrome:"
{ $example "\"A man, a plan, a canal: Panama.\" palindrome?" "f" }
"We would like it to output " { $link t } " there. We can encode this requirement with a unit test that we add to " { $snippet "palindrome-tests.factor" } ":"
{ $code "[ t ] [ \"A man, a plan, a canal: Panama.\" palindrome? ] unit-test" }
"If you now run unit tests, you will see a unit test failure:"
{ $code "\"palindrome\" test" }
"The next step is to, of course, fix our code so that the unit test can pass."
$nl
"We begin by writing a word called " { $snippet "normalize" } " which removes blanks and non-alphabetical characters from a string, and then converts the string to lower case. We call this word " { $snippet "normalize" } ". To figure out how to write this word, we begin with some interactive experimentation in the listener."
$nl
"Start by pushing a character on the stack; notice that characters are really just integers:"
{ $code "CHAR: a" }
"Now, use the " { $link Letter? } " word to test if it is an alphabetical character, upper or lower case:"
{ $example "Letter? ." "t" }
"This gives the expected result."
$nl
"Now try with a non-alphabetical character:"
{ $code "CHAR: #" }
{ $example "Letter? ." "f" }
"What we want to do is given a string, remove all characters which do not match the " { $link Letter? } " predicate. Let's push a string on the stack:"
{ $code "\"A man, a plan, a canal: Panama.\"" }
"Now, place a quotation containing " { $link Letter? } " on the stack; quoting code places it on the stack instead of executing it immediately:"
{ $code "[ Letter? ]" }
"Finally, pass the string and the quotation to the " { $link subset } " word:"
{ $code "subset" }
"Now the stack should contain the following string:"
{ "\"AmanaplanacanalPanama\"" }
"This is almost what we want; we just need to convert the string to lower case now. This can be done by calling " { $link >lower } "; the " { $snippet ">" } " prefix is a naming convention for conversion operations, and should be read as ``to'':"
{ $code ">lower" }
"Finally, let's print the top of the stack and discard it:"
{ $code "." }
"This will output " { $snippet "amanaplanacanalpanama" } ". This string is in the form that we want, and we evaluated the following code to get it into this form:"
{ $code "[ Letter? ] subset >lower" }
"This code starts with a string on the stack, removes non-alphabetical characters, and converts the result to lower case, leaving a new string on the stack. We put this code in a new word, and add the new word to " { $snippet "palindrome.factor" } ":"
{ $code ": normalize ( str -- newstr ) [ Letter? ] subset >lower ;" }
"You will need to add " { $vocab-link "strings" } " to the vocabulary search path, so that " { $link Letter? } " can be used in the source file."
$nl
"We modify " { $snippet "palindrome?" } " to first apply " { $snippet "normalize" } " to its input:"
{ $code ": palindrome? ( str -- ? ) normalize dup reverse = ;" }
"Now if you press " { $command workspace "workflow" refresh-all } ", the source file should reload without any errors. You can run unit tests again, and this time, they will all pass:"
{ $code "\"palindrome\" test" } ;

ARTICLE: "first-program" "Your first program"
"In this tutorial, we will write a simple Factor program which prompts the user to enter a word, and tests if it is a palindrome (that is, the word is spelled the same backwards and forwards)."
$nl
"In this tutorial, you will learn about basic Factor development tools, as well as application deployment."
{ $subsection "first-program-start" }
{ $subsection "first-program-logic" }
{ $subsection "first-program-test" }
{ $subsection "first-program-extend" } ;

ABOUT: "first-program"
