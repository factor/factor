! See http://factorcode.org/license.txt for BSD license.
USING: io.directories help.markup help.syntax multiline strings exercism.testing.private tools.test ;
IN: exercism.testing

HELP: verify-config
    { $description
      "Verifies a configuration. Called on running " { $link choose-suite } "."

      $nl "When " { $link project-env } " is " { $link dev-env } ", then " { $snippet "config.json" } " is checked for internal consistency and consistency with the filesystem, and that all of the " { $snippet "exercises" } " directory's " { $link child-directories } " contain at least " { $snippet "exercise-tests.factor" } " and " { $snippet "exercise-example.factor" } ". If an error is found, the operation is aborted."

      $nl "When " { $link project-env } " is " { $link user-env } ", then the exercises folders in the current directory are checked to have both an implementation and unit tests; if not all do, then the operation is aborted."
    }
    { $notes
      { $snippet "config.json" } "'s " { $snippet "problems" } " and " { $snippet "deprecated" } " keys should not share any values. " { $snippet "problems" } " should match the " { $snippet "exercises" } " directory's " { $link child-directories } " exactly, and " { $snippet "deprecated" } " should not share any entries with " { $snippet "exercises" } "."
    } ;

HELP: run-exercism-test
    { $values { "exercise" string } }
    { $description
      "Runs the Exercism test with slug " { $snippet "exercise"} " from the current directory."

      $nl "To test user solutions to Exercism exercises, start Factor in the " { $snippet "exercism/factor" } " directory, or " { $link set-current-directory } " there from the Listener."

      $nl "To test server-side example solutions to Exercism exercises, start Factor in the " { $snippet "exercism/xfactor" } " git repository, or " { $link set-current-directory } " there from the Listener."
    }

    { $examples
      { $example
        "USING: io.directories exercism.testing ;"
        "\"/home/you/exercism/factor\" set-current-directory"
        "\"hello-world\" run-exercism-test"

        "testing exercise: hello-world
Unit Test: { { \"Hello, World!\" } [ \"\" hello-name ] }
Unit Test: { { \"Hello, Alice!\" } [ \"Alice\" hello-name ] }
Unit Test: { { \"Hello, Bob!\" } [ \"Bob\" hello-name ] }
"
      }

      { $example
        "USING: io.directories exercism.testing ;"
        "\"/home/you/git/exercism/xfactor\" set-current-directory"
        "\"hello-world\" run-exercism-test with-directory"

        "testing exercise: hello-world
Unit Test: { { \"Hello, World!\" } [ \"\" hello-name ] }
Unit Test: { { \"Hello, Alice!\" } [ \"Alice\" hello-name ] }
Unit Test: { { \"Hello, Bob!\" } [ \"Bob\" hello-name ] }
"
      }
    } ;

HELP: run-all-exercism-tests
    { $description
      "Runs all Exercism exercise tests found in the " { $link exercises-folder } " in the current directory." } ;

HELP: choose-suite
    { $values { "arg" string } }
    { $description
      "Runs tests for problem named " { $snippet "arg" } ", or runs all tests if " { $snippet "arg" } " is "
      { $snippet "\"run-all\"" } ". If " { $snippet "arg" } " is "{ $snippet "\"VERIFY\"" } ", then just " { $link verify-config } " is called on the current directory."
    } ;

HELP: guess-project-env
    { $description
      "Guesses (fairly accurately) whether the current directory is " { $link dev-env } " (exercism/xfactor git repository) or " { $link user-env } " (the " { $snippet "exercism/factor" } " Exercism folder)."
    } ;


ARTICLE: "exercism.testing" "Running unit tests on Exercism.io exercises"
    "Both Factor and " { $url "http://exercism.io" } "'s backends have fairly strict naming conventions, which makes unit testing Factor code for Exercism on the client and server side simultaneously a little bit tricky."

    $nl "This vocabulary aims to make testing Exercism exercise code as easy as " { $link POSTPONE: unit-test } " on both the client and server, while still allowing users and Exercism collaborators to use the tried and true " { $link POSTPONE: unit-test } "."

    $nl "Whether server-side or user-facing tests are run is controlled by a variable upon which words dispatch: " { $link project-env } ". It is given its value by " { $vocab-link "exercism.testing" } "'s " { $link POSTPONE: MAIN: } ", or by calling " { $link guess-project-env } " directly."

    $nl "This vocabulary may be most fit for packaging into a binary or running from a terminal:\n\n"
    { $snippet "factor -run=exercism.testing run-all" }

    $nl "Detecting environment type:"
    { $subsections
      guess-project-env
    }

    "Verifying environment configuration:"
    { $subsections
      verify-config
    }

    "Testing exercises:"
    { $subsections
      run-exercism-test
      run-all-exercism-tests
    }

    "Errors:"
    { $subsections
      not-an-exercism-folder
      wrong-project-env
      not-user-env
      not-dev-env
    }

    ;

ABOUT: "exercism.testing"
