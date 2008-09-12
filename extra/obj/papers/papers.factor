
USING: sets obj obj.util obj.view ;

IN: obj.papers

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: title        properties adjoin
SYM: abstract     properties adjoin
SYM: authors      properties adjoin
SYM: file         properties adjoin
SYM: date         properties adjoin
SYM: participants properties adjoin
SYM: description  properties adjoin

SYM: chapter      properties adjoin
SYM: section      properties adjoin
SYM: paragraph    properties adjoin
SYM: content      properties adjoin

SYM: subjects     properties adjoin
SYM: source       properties adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: paper  types adjoin
SYM: person types adjoin
SYM: event  types adjoin

SYM: excerpt types adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: bay-wei-chang       { type person } define-object
SYM: chuck-moore         { type person } define-object
SYM: craig-chambers      { type person } define-object
SYM: david-ungar         { type person } define-object
SYM: frank-g-halasz      { type person } define-object
SYM: gerald-jay-sussman  { type person } define-object
SYM: guy-lewis-steele-jr { type person } define-object
SYM: randall-b-smith     { type person } define-object
SYM: randall-h-trigg     { type person } define-object
SYM: robert-adams        { type person } define-object
SYM: russell-noftsker    { type person } define-object
SYM: thomas-p-moran      { type person } define-object
SYM: urs-holzle          { type person } define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: programming-as-an-experience
  {
    type     paper
    title    "Programming as an Experience: The Inspiration for Self"
    abstract "The Self system attempts to integrate intellectual and non-intellectual aspects of programming to create an overall experience. The language semantics, user interface, and implementation each help create this integrated experience. The language semantics embed the programmer in a uniform world of simple ob jects that can be modified without appealing to definitions of abstractions. In a similar way, the graphical interface puts the user into a uniform world of tangible objects that can be directly manipulated and changed without switching modes. The implementation strives to support the world-of-objects illusion by minimiz ing perceptible pauses and by providing true source-level semantics without sac rificing performance. As a side benefit, it encourages factoring. Although we see areas that fall short of the vision, on the whole, the language, interface, and im plementation conspire so that the Self programmer lives and acts in a consistent and malleable world of objects."
    authors  { randall-b-smith david-ungar }
    date     1995
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: self-the-power-of-simplicity
  {
    type paper
    title "Self: The Power of Simplicity"
    abstract "Self is an object-oriented language for exploratory programming based on a small number of simple and concrete ideas: prototypes, slots, and behavior. Prototypes combine inheritance and instantiation to provide a framework that is simpler and more flexible than most object-oriented languages. Slots unite variables and procedures into a single construct. This permits the inheritance hierarchy to take over the function of lexical scoping in conventional languages. Finally, because Self does not distinguish state from behavior, it narrows the gaps between ordinary objects, procedures, and closures. Self's simplicity and expressiveness offer new insights into object-oriented computation."
    authors { randall-b-smith david-ungar }
    date 1987
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: parents-are-shared-parts
  {
    type paper
    title "Parents are Shared Parts: Inheritance and Encapsulation in Self"
    abstract "The design of inheritance and encapsulation in Self, an object-oriented language based on prototypes, results from understanding that inheritance allows parents to be shared parts of their children. The programmer resolves ambiguities arising from multiple inheritance by prioritizing an object's parents. Unifying unordered and ordered multiple inheritance supports differential programming of abstractions and methods, combination of unrelated abstractions, unequal combination of abstractions, and mixins. In Self, a private slot may be accessed if the sending method is a shared part of the receiver, allowing privileged communication between related objects. Thus, classless Self enjoys the benefits of class-based encapsulation."
    authors { craig-chambers david-ungar bay-wei-chang urs-holzle }
    date 1991
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: organizing-programs-without-classes
  {
    type paper
    title "Organizing Programs Without Classes"
    abstract "All organizational functions carried out by classes can be accomplished in a simple and natural way by object inheritance in classless languages, with no need for special mechanisms. A single model--dividing types into prototypes and traits--supports sharing of behavior and extending or replacing representations. A natural extension, dynamic object inheritance, can model behavioral modes. Object inheritance can also be used to provide structured name spaces for well-known objects. Classless languages can even express 'class-based' encapsulation. These stylized uses of object inheritance become instantly recognizable idioms, and extend the repertory of organizing principles to cover a wider range of programs."
    authors { david-ungar craig-chambers bay-wei-chang urs-holzle }
    date 1991
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: scheme-an-interpreter-for-extended-lambda-calculus
  {
    type paper
    title "Scheme: An Interpreter for Extended Lambda Calculus"
    abstract "Inspired by ACTORS [Greif and Hewitt] [Smith and Hewitt], we have implemented an interpreter for a LISP-like language, SCHEME, based on the lambda calculus [Church], but extended for side effects, multiprocessing, and process synchronization. The purpose of this implementation is tutorial. We wish to: (1) alleviate the confusion caused by Micro-PLANNER, CONNIVER, etc. by clarifying the embedding of non-recursive control structures in a recursive host language like LISP. (2) explain how to use these control structures, independent of such issues as pattern matching and data base manipulation. (3) have a simple concrete experimental domain for certain issues of programming semantics and style."
    authors { gerald-jay-sussman guy-lewis-steele-jr }
    date 1975
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: symbolics-is-founded
  {
    type         event
    participants { russell-noftsker robert-adams }
    date         1980
  }
define-object

SYM: symbolics-funding-from-gi
  {
    type        event
    description "Symbolics receives $500,000 from General Instruments"
    date        1982
  }
define-object

SYM: symbolics-files-for-bankruptcy
  {
    type event
    date "1993-01-28"
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: the-evolution-of-forth
  {
    type paper
    title "The Evolution of Forth"
    authors { chuck-moore "elizabeth-d-rather" "donald-r-colburn" }
    abstract
    "Forth is unique among programming languages in that its development and proliferation has been a grass-roots effort unsupported by any major corporate or academic sponsors. Originally conceived and developed by a single individual, its later development has progressed under two significant influences: professional programmers who developed tools to solve application problems and then commercialized them, and the interests of hobbyists concerned with free distribution of Forth. These influences have produced a language markedly different from traditional programming languages."
    date 1993
  }
define-object

SYM: first-complete-stand-alone-forth
  {
    type event
    participants { chuck-moore }
    date 1971
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: notecards-in-a-nutshell
  {
    type paper
    authors { frank-g-halasz thomas-p-moran randall-h-trigg }
    date 1987
  }
define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: the-evolution-of-forth-excerpt-2-1-1
  {
    type excerpt
    source the-evolution-of-forth
    chapter 2
    section 1
    paragraph 1
    content
    "Moore developed the first complete, stand-alone implementation of Forth in 1971 for the 11-meter radio telescope operated by the National Radio Astronomy Observatory (NRAO) at Kitt Peak, Arizona. This system ran on two early minicomputers (a 16 KB DDP-116 and a 32 KB H316) joined by a serial link. Both a multiprogrammed system and a multiprocessor system (in that both computers shared responsibility for controlling the telescope and its scientific instruments), it was responsible for pointing and tracking the telescope, collecting data and recording it on magnetic tape, and supporting an interactive graphics terminal on which an astronomer could analyze previously recorded data. The multiprogrammed nature of the system allowed all these functions to be performed concurrently, without timing conflicts or other interference."
    subjects { chuck-moore first-complete-stand-alone-forth }
  }
define-object

