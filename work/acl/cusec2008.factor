USING: slides help.markup math arrays hashtables namespaces
 kernel sequences parser io io.styles ;

IN: cusec2008

: big ( str -- ) 54 font-size associate format nl ;

: cusec2008 ( -- x )
{
    { $slide "The ACL Is Dead"
      {
        { $emphasis "A Story For Young(er) Programmers" }
        $nl
        $nl
        { $emphasis "Zed A. Shaw" }
      }
    }

    { $slide "Thanks For Inviting Me"
        "Smoked meat and bagels."
    }
    
    { $slide "Brought To You In Factor"
        "http://factorcode.org/"
            "Too bad slava can't be here.  I'll post the source so you can do:"
            { $code "'cusec2008' run" }
        "... to run it ..."
    }

    { $slide "Why Factor?"
        "It's cool, and totally weird yet fun."
            "Kind of like finding a chocolate tricycle you can ride and eat at the same time but only if you wear a fez."
            "It also lets me do this:"
            { $code ": big ( str -- ) 54 font-size associate format nl ;" }
        { $code "{ $slide \"Heading For Slide\" \"Stuff for slide\" }" }
        "Which is valid Factor to create..."
    }

    { $slide "Heading For Slide" "Stuff for slide" }
    { $slide "Neat?" { $emphasis "Oh Very" } }

    { $slide "The Story"
        "Industrial Autism"
            "Corporate Greed"
            "Bad Java APIs"
            "Stupidity"
            "Turing Completeness"
    }

    { $slide "A Common Problem"
        "All Organizations have:"
            "People doing things,"
            "to stuff,"
            "in 'containers'."
    }

    { $slide "Called Document Management"
        "Law Firms"
            "Banks"
            "Government Offices"
            "Anyone who can get sued"
    }

    { $slide "People Are Evil(ish)"
        "And Stupid"
            "And Refuse To Learn"
    }

    { $slide "Thus Access Control Lists (ACL)"
        "or RBACs"
    }

    { $slide "An ACL Lists"
        "Which People"
            "can do which Things"
            "to what Stuff"
            "in what Containers"
    }

    { $slide "Everything Was Great in DMS Land"
        "Companies Sold Them"
            "Other Companies Bought Them"
            "Programmers and Sysadmins Wrangled Them"
    }

    { $slide "Mediocrity Reigned Supreme!" 
        "Yes Mediocrity"
    }

    { $slide "'Trimmed' Down Sample"
        { $code 
            "Transaction trans = Transaction.createNewTransaction(..);"
                "Entity person = EntityResolvingThing.find(opaqueId);"
                "Container folder = person.find(opaqueId);"
                "Document doc = DocumentCreator.create(settings);"
                "doc.addAttributes(attribs);"
                "doc.setContent(data);"
                "folder.addDocument(doc, person);"
                "doc.save();"
                "trans.commit();"
        }
    }

    { $slide "Yet, It Worked"
        "The ACL Was Fixed"
            "Rarely Changed"
            "And Fit Small Groups"
    }

    { $slide "Enter Dennis Kozlosky"
        "And Enron"
            "And Citibank"
            "And The .com Bust"
            "And Elliot Spitzer"
    }

    { $slide "Corporate Greed Killed The DMS"
        "Actually Laws Did"
            "Sarbanes-Oxley (SOX)"
            "NY State Trade Laws"
            "NSAD"
            "IRS"
            "HIPPA"
            "FTC"
    }

    { $slide "Laws Are Written By Humans"
        "Not computers."
    }

    { $slide "Law Is Actually Turing Complete"
        "Has Repetition"
            "and Conditionals"
            "and even Storage"
    }
    { $slide "Law Is Fuzzy Though" 
        "Just like the people who comply with them."
    }

    { $slide "Business Is Fuzzy Too"
        "Just like the people running them."
    }

    { $slide "Yet An ACL Is.."
        { $emphasis "Not Turing Complete" }
    }

    { $slide "Horrible Example 1"
        "An associate partner cannot speak to an analyst unless there is a compliance officer present except when their senior manager gives a business reason."
    }

    { $slide "Horrible Example 2"
            "An analyst can participate in a project if they are on a project for a client that is later than other projects but not for projects later than their current project."
    }

    { $slide "Horrible Example 3"
            "A manager can review the files in a subordinate's personal container only after they have left the company but can transfer the ownership of said personal container to themselves."
    }


    { $slide "These Are Real"
        "You Can't Invalidate Them"
            "You Must Enforce Them"
            "All The 'Proven' ACL Won't Help..."
    }

    { $slide "Programmers Hate This"
        "Tough, it's what's real."
            "The ACL is not right, these rules are."
    }

    { $slide "The ACL Is Dead Because"
        "It's Not Turing Complete"
            "No Repetition"
            "No Externally Accessible Storage"
            "No Conditionals"
    }

    { $slide "Evidence Against ACL"
        "Simplest compliance rule was 270,000 ACL entries."
            "Would require 5 minute polling updates."
            "Couldn't handle real-time changes."
            "Would require 12 monster machines."
    }

    { $slide "Not Future Proof"
        "Imagine a Law Change."
            "How would you confirm that the changes to"
            "the ACL matched the law?"
    }

    { $slide "Evidence For A Turing Language"
        "ALL rules require 400 lines of Ruby."
            "Business Analysts can read the rules."
            "Changes to rules reflected instantly."
            { $emphasis "Rule engine can tell you why." }
    }

    { $slide "A Language Wins"
        "ACL Cannot Handle modern security rules."
    }

    { $slide "The Suck Begins"
        "This the part of the story where the hero enters the cave."
    }

    { $slide "We Had To Use This Product"
        "It Sucked"
            "2 seconds to store"
            "3-4 seconds to get"
            "The most complex security that did nothing."
    }

    { $slide "Corporate Interests Required It"
        "Not Technical Needs"
        "We Were Screwed"
            "This Is " $emphasis "Real" " Programming"
    }

    { $slide "You Do Not Have The Money"
        "Your Boss Does"
    }

    { $slide "Selling Crap Requires:"
            "Connections!?"
            "Threats!?"
            "Subterfuge!?"
    }

    { $slide "Nope..."
        "Steaks and Strippers."
    }

    { $slide "Your Boss Don't Know Jack"
        "Usually an MBA"
            "Clueless About Technology"
            "Never Believes You"
            "Almost Always Driven Externally"
    }

    { $slide "Millions On The Line"
        "What Do You Do?"
            "How Do Fight The Monster?"
    }

    { $slide "Ultimately Get In Charge"
        "We need more techies making the decisions."
    }

    { $slide "Management Knows Manufacturing"
        "All MBAs Learn About Manufacturing"
            "Utilization"
            "Assembly Processes"
            "ROI"
            "Production Levels"
            "JIT Logistics"
    }

    { $slide "Bullshit!"
        "Programming IS NOT MANUFACTURING"
            "Journalism"
            "Film"
            "Cabinetry"
            "Music"
    }

    { $slide "What To Do?"
        "Here's my strategy..."
    }

    { $slide "0) Understand Your Problem"
        "It's social, nobody trusts you."
        "'I demand all of your creativity, "
            "  yet trust none of your judgment.'"
    }

    { $slide "1) Gather Evidence"
        "Play Ball and Be Objective"
            "Collect Information"
            "Really Try To Use It"
            "Stop If It's Good Enough"
    }

    { $slide "2) Develop Alternatives"
        "Base them on theory and practice"
            "ex: ACL != Turing Complete"
            "Use Statistics"
            "Use Simple Plain Writing"
    }

    { $slide "3) Make Pretty Graphs"
        "Use Evidence to Show Technical Limits"
            "Keep It Simple"
            "Be Prepared To Get Deep Technical"
    }

    { $slide "4) Present Your HONEST Alternative"
        "They Can Smell Bullshit"
            "Be Ruthlessly Honest"
            "They Deal With Sales"
            "Be Non-Sales"
            "Show A Working Alternative Prototype"
    }

    { $slide "5) Go Build It To Sell Them"
        "If they won't listen, and you've got it, then go make it."
    }

    { $slide "Here Was Our Alternative"
        "ACL Is Not Turing Complete"
            "The Five Reviewed Systems Were Slow"
            "We Had Graphs"
    }

    { $slide "We Needed Alternatives"
        "Something Turing Complete"
            "Database Backed"
            "that Integrated Seamlessly"
    }

    { $slide "Three Part Solution"
        "Use a real programming language"
            "Resolve Roles First"
            "Apply A Rules Engine"
    }

    { $slide "A Real Programming Language"
        "Ruby was chosen"
            "Tried Drools, sucked"
    }

    { $slide "Resolve Roles First"
        "All roles for all people on all containers"
            "could be resolved with just 30 lines of Ruby."
    }

    { $slide "This Was 120k ACL Entries"
        { $code "def person_is_supervisor(person, container)"
            "  container.owner.supervisor == person"
            "end"
        }
    }

    { $slide "Apply A Rules Engine"
        "All rules including bizarre corner cases"
            "applied with about 200 lines of Ruby"
    }

    { $slide "This Was 10/Person/Container/Action"
        { $code "def rule_supervisor(person, action, role)"
            "  person.departed && "
            "  allowed_actions.include?(action) &&"
            "  role == :supervisor"
            "end"
        }
    }

    { $slide "Pretty Impressive Case"
        "Still Not Enough"
            "Which is where your lesson comes in"
    }

    { $slide "Management Still Wanted Junk"
        "Technology didn't matter."
            "What mattered was that their proposed product"
            "had the same name."
    }

    { $slide "Yes, Same Name"
        "The people at the top don't get tech."
            "They think you're all liars."
            "They're old and barely get the web."
            { $emphasis "The Same Damn Name Mattered" }
    }

    { $slide "We Won Eventually"
        "But only after *months* of wasted money on crap tech."
    }

    { $slide "This Is Why Corporate Coding Sucks"
        "You are a factory worker."
            "You work on an assembly line."
            "You shut up and do as your told."
            "But, be creative too or die!"
            "You fill out time sheets."
    }

    { $slide "Code Monkey Code"
        "Most business leaders don't like you."
            "They hate depending on you."
            "They wish they didn't need you."
            "And sales people know this."
    }

    { $slide "Don't Be A Corporate Coder"
        "But you need to eat!"
            "'Wait! You're a corporate coder asshole!'"
    }

    { $slide "Not Losing Your Soul"
        "I work for a corporation, but I'm not their coder."
            "My works are my art and expression, they get none of it."
            "If they want my creativity, they have to accept my judgment."
    }

    { $slide "Work Coding At Work"
        "Work should be boring and effortless."
            "Nothing new, nothing special, minimal effort for the best job."
    }

    { $slide "Play Coding At Home"
        "Play should be bizarre, fun, constantly risky."
            "Bleeding destructive horrible edge."
            "Don't believe anything anyone tells you."
            "Dig into your geek soul and create."
    }

    { $slide "CREATE!"
        "Doesn't matter what."
            "Doesn't matter who likes it."
            "Just make something.  Many things."
            "Different things."
    }

    { $slide "You Won't Get Fired"
        "It's just a job, be daring."
            "If you get fired, 10 smarter companies will hire you."
            "You are not a slave."
    }

    { $slide "Use A Fake Name"
        "Hide your cool stuff."
            "Be different, skate on the edge of nerd society."
            "If everyone does Java, you do FORTH."
    }

    { $slide "Then..."
        "Walk into work and laugh while they flounder."
            "Save your creative soul for you."
    }

    { $slide "Share Your Life"
        "With people who don't consider you..."
    }

    { $slide "Another Resource"
        "They have to 'utilize'."
    }

    { $slide "Thank You!"
        "Any questions?"
    }

} ;

: start-presentation ( -- )
    cusec2008 "CUSEC" slides-window ;

MAIN: start-presentation 
 
