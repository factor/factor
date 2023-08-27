USING: help.markup help.syntax ui.commands ui.operations
editors vocabs.loader kernel sequences prettyprint tools.test
vocabs.refresh strings unicode ui.tools.browser ui.tools.common ;
IN: help.tutorial

ARTICLE: "first-program-start" "Creating a vocabulary for your first program"
"Factor source code is organized into " { $link "vocabularies" } ". Before we can write our first program, we must create a vocabulary for it."
$nl
"Start by loading the scaffold tool:"
{ $code "USE: tools.scaffold" }
"Then, ask the scaffold tool to create a new vocabulary named " { $snippet "palindrome" } ":"
{ $code "\"palindrome\" scaffold-work" }
"If you look at the output, you will see that a few files were created in your “work” directory, and that the new source file was loaded."
$nl
"The following phrase will print the full path of your work directory:"
{ $code "\"work\" resource-path ." }
"The work directory is one of several " { $link "vocabs.roots" } " where Factor searches for vocabularies. It is possible to define new vocabulary roots; see " { $link "add-vocab-roots" } ". To keep things simple in this tutorial, we'll just use the work directory, though."
$nl
"Open the work directory in your file manager, and open the subdirectory named " { $snippet "palindrome" } ". Inside this subdirectory you will see a file named " { $snippet "palindrome.factor" } ". Open this file in your text editor."
$nl
"You are now ready to go on to the next section: " { $link "first-program-logic" } "." ;

ARTICLE: "first-program-logic" "Writing some logic in your first program"
"The Factor workflow is to edit source code on disk and then to refresh the live image. Let's examine the file that we just created with the scaffold tool."
$nl
"Your " { $snippet "palindrome.factor" } " file should look like the following after the previous section:"
{ $code
    "! Copyright (C) 2022 Your name."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: ;"
    "IN: palindrome"
}
"Notice that the file ends with an " { $link POSTPONE: IN: } " form telling Factor that all definitions in this source file should go into the " { $snippet "palindrome" } " vocabulary using the " { $link POSTPONE: IN: } " word. We will be adding new definitions after the " { $link POSTPONE: IN: } " form."
$nl
"In order to be able to call the words defined in the " { $snippet "palindrome" } " vocabulary, you need to issue the following command in the listener:"
{ $code "USE: palindrome" }
"Now, we will be making some additions to the file. Since the file was loaded by the scaffold tool in the previous step, you need to tell Factor to reload it if it changes. Factor has a handy feature for this; pressing " { $command tool "common" refresh-all } " in the listener window will reload any changed source files. You can also force a single vocabulary to reload, in case the refresh feature does not pick up changes from disk:"
{ $code "\"palindrome\" reload" }
"We will now write our first word using " { $link POSTPONE: : } ". This word will test if a string is a palindrome; it will take a string as input, and give back a boolean as output. We will call this word " { $snippet "palindrome?" } ", following a naming convention that words returning booleans have names ending with " { $snippet "?" } "."
$nl
"Recall that a string is a palindrome if it is spelled the same forwards or backwards; that is, if the string is equal to its reverse. We can express this in Factor as follows:"
{ $code ": palindrome? ( string -- ? ) dup reverse = ;" }
"Place this definition at the end of your source file."
$nl
"Now we have changed the source file, we must reload it into Factor so that we can test the new definition. To do this, simply go to the Factor listener and press " { $command tool "common" refresh-all } ". This will find any previously-loaded source files which have changed on disk, and reload them."
$nl
"When you do this, you will get an error about the " { $link dup } " word not being found. This is because this word is part of the " { $vocab-link "kernel" } " vocabulary, but this vocabulary is not part of the source file's " { $link "word-search" } ". You must explicitly list dependencies in source files. This allows Factor to automatically load required vocabularies and makes larger programs easier to maintain."
$nl
"To add the word to the search path, first convince yourself that this word is in the " { $vocab-link "kernel" } " vocabulary. Enter " { $snippet "dup" } " in the listener's input area, and press " { $operation com-browse } ". This will open the documentation browser tool, viewing the help for the " { $link dup } " word. One of the subheadings in the help article will mention the word's vocabulary."
$nl
"Go back to the third line in your source file and change it to:"
{ $code "USING: kernel ;" }
"Next, find out what vocabulary " { $link reverse } " lives in; type the word name " { $snippet "reverse" } " in the listener's input area, and press " { $operation com-browse } "."
$nl
"It lives in the " { $vocab-link "sequences" } " vocabulary, so we add that to the search path:"
{ $code "USING: kernel sequences ;" }
"Finally, check what vocabulary " { $link = } " lives in, and confirm that it's in the " { $vocab-link "kernel" } " vocabulary, which we've already added to the search path."
$nl
"Now press " { $command tool "common" refresh-all } " again, and the source file should reload without any errors. You can now go on and learn about " { $link "first-program-test" } "." ;

ARTICLE: "first-program-test" "Testing your first program"
"Your " { $snippet "palindrome.factor" } " file should look like the following after the previous section:"
{ $code
    "! Copyright (C) 2012 Your name."
    "! See https://factorcode.org/license.txt for BSD license."
    "USING: kernel sequences ;"
    "IN: palindrome"
    ""
    ": palindrome? ( string -- ? ) dup reverse = ;"
}
"We will now test our new word in the listener. If you haven't done so already, add the palindrome vocabulary to the listener's vocabulary search path:"
{ $code "USE: palindrome" }
"Next, push a string on the stack (by surrounding text with quotes in the listener and then hitting " { $snippet "ENTER" } "):"
{ $code "\"hello\"" }
"Note that the stack display in the listener now shows this string. Having supplied the input, we call our word:"
{ $code "palindrome?" }
"The stack display should now have a boolean false - " { $link f } " - which is the word's output. Since “hello” is not a palindrome, this is what we expect. We can get rid of this boolean by calling " { $link drop } ". The stack should be empty after this is done."
$nl
"Now, let's try it with a palindrome; we will push the string and call the word in the same line of code:"
{ $code "\"racecar\" palindrome?" }
"The stack should now contain a boolean true - " { $link t } ". We can print it and drop it using the " { $link . } " word:"
{ $code "." }
"What we just did is called " { $emphasis "interactive testing" } ". A more advanced technique which comes into play with larger programs is " { $link "tools.test" } "."
$nl
"Create a test harness file using the scaffold tool:"
{ $code "\"palindrome\" scaffold-tests" }
"Now, open the file named " { $snippet "palindrome-tests.factor" } "; it is located in the same directory as " { $snippet "palindrome.factor" } ", and it was created by the scaffold tool."
$nl
"We will add some unit tests, which are similar to the interactive tests we did above. Unit tests are defined with the " { $link POSTPONE: unit-test } " word, which takes a sequence of expected outputs, and a piece of code. It runs the code, and asserts that it outputs the expected values."
$nl
"Add the following two lines to " { $snippet "palindrome-tests.factor" } ":"
{ $code
    "{ f } [ \"hello\" palindrome? ] unit-test"
    "{ t } [ \"racecar\" palindrome? ] unit-test"
}
"Now, you can run unit tests:"
{ $code "\"palindrome\" test" }
"It should report that all your tests have been run and there were no test failures, displaying the following output:"
$nl
{ $snippet "\
Unit Test: { { f } [ \"hello\" palindrome? ] }

Unit Test: { { t } [ \"racecar\" palindrome? ] }" }
$nl
"Now you can read about " { $link "first-program-extend" } "." ;

ARTICLE: "first-program-extend" "Extending your first program"
"Our palindrome program works well, however we'd like to extend it to ignore spaces and non-alphabetical characters in the input."
$nl
"For example, we'd like it to identify the following as a palindrome:"
{ $code "\"A man, a plan, a canal: Panama.\"" }
"However, right now, the simplistic algorithm we use says this is not a palindrome:"
{ $unchecked-example "\"A man, a plan, a canal: Panama.\" palindrome? ." "f" }
$nl
"We would like it to output " { $link t } " there. We can encode this requirement with a unit test that we add to " { $snippet "palindrome-tests.factor" } ":"
{ $code "{ t } [ \"A man, a plan, a canal: Panama.\" palindrome? ] unit-test" }
"If you now run unit tests, you will see a unit test failure:"
{ $code "\"palindrome\" test" }
"The next step is to, of course, fix our code so that the unit test can pass."
$nl
"We begin by writing a word which removes blanks and non-alphabetical characters from a string, and then converts the string to lower case. We call this word " { $snippet "normalize" } ". To figure out how to write this word, we begin with some interactive experimentation in the listener."
$nl
"Start by pushing a character on the stack; notice that characters are really just integers:"
{ $code "CHAR: a" }
"Now, use the " { $link Letter? } " word to test if it is an alphabetical character, upper or lower case:"
{ $unchecked-example "Letter? ." "t" }
"Note: you might receive an error message that asks if you want to use the " { $link "ascii" } " or " { $link "unicode" } " versions of the " { $link Letter? } " word. Choosing the Unicode version will allow Factor to continue running your code."
$nl
"This gives the expected result."
$nl
"Now try with a non-alphabetical character:"
{ $code "CHAR: #" }
{ $unchecked-example "Letter? ." "f" }
"What we want to do is given a string, remove all characters which do not match the " { $link Letter? } " predicate. Let's push a string on the stack:"
{ $code "\"A man, a plan, a canal: Panama.\"" }
"Now, place a quotation containing " { $link Letter? } " on the stack; quoting code places it on the stack instead of executing it immediately:"
{ $code "[ Letter? ]" }
"Note: " { $link "quotations" } " are similar to anonymous functions or blocks of code that have not been executed yet."
$nl
"Finally, we pass the string and the quotation to the " { $link filter } " word, which will run your quotation and return a new string that contains only characters for which " { $link Letter? } " returns \"true\":"
{ $code "filter" }
"The stack should now contain the following string: "
{ $snippet "AmanaplanacanalPanama" } ". "
"This is almost what we want; we just need to convert the string to lower case now. This can be done by calling " { $link >lower } "; the " { $snippet ">" } " prefix is a naming convention for conversion operations, and should be read as “to”:"
{ $code ">lower" }
"Finally, let's print the top of the stack and discard it:"
{ $code "." }
"This will output " { $snippet "amanaplanacanalpanama" } ". This string is in the form that we want, and we evaluated the following code to get it into this form:"
{ $code "[ Letter? ] filter >lower" }
"This code starts with a string on the stack, removes non-alphabetical characters, and converts the result to lower case, leaving a new string on the stack. We put this code in a new word, and add the new word to " { $snippet "palindrome.factor" } ":"
{ $code ": normalize ( string -- string' ) [ Letter? ] filter >lower ;" }
"You will need to add " { $vocab-link "unicode" } " to the vocabulary search path, so that " { $link >lower } " and " { $link Letter? } " can be used in the source file."
$nl
"We modify " { $snippet "palindrome?" } " to first apply " { $snippet "normalize" } " to its input:"
{ $code ": palindrome? ( string -- ? ) normalize dup reverse = ;" }
"Factor compiles the file from the top down. So, be sure to place the definition for " { $snippet "normalize" } " above the definition for " { $snippet "palindrome?" } "."
$nl
"Now if you press " { $command tool "common" refresh-all } ", the source file should reload without any errors. You can run unit tests again, and this time, they will all pass:"
{ $code "\"palindrome\" test" }
"Congratulations, you have now completed " { $link "first-program" } "!" ;

ARTICLE: "first-program" "Your first program"
"In this tutorial, we will write a simple Factor program which prompts the user to enter a word, and tests if it is a palindrome (that is, the word is spelled the same backwards and forwards)."
$nl
"In this tutorial, you will learn about basic Factor development tools."
$nl
"Note: when you come across boxes with Factor code examples, you can click on them to copy and paste the code into your listener, to be run by then hitting " { $snippet "ENTER" } "."
$nl
{ $subsections
    "first-program-start"
    "first-program-logic"
    "first-program-test"
    "first-program-extend"
} ;

ABOUT: "first-program"
