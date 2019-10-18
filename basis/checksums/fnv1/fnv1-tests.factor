USING: checksums checksums.fnv1 tools.test ;

! A few test vectors taken from http://www.isthe.com/chongo/src/fnv/test_fnv.c

{ 0x811c9dc5 } [ "" fnv1-32 checksum-bytes ] unit-test
{ 0x811c9dc5 } [ "" fnv1a-32 checksum-bytes ] unit-test
{ 0xcbf29ce484222325 } [ "" fnv1-64 checksum-bytes ] unit-test
{ 0xcbf29ce484222325 } [ "" fnv1a-64 checksum-bytes ] unit-test

{ 0x050c5d7e } [ "a" fnv1-32 checksum-bytes ] unit-test
{ 0xe40c292c } [ "a" fnv1a-32 checksum-bytes ] unit-test
{ 0xaf63bd4c8601b7be } [ "a" fnv1-64 checksum-bytes ] unit-test
{ 0xaf63dc4c8601ec8c } [ "a" fnv1a-64 checksum-bytes ] unit-test

{ 0x050c5d7d } [ "b" fnv1-32 checksum-bytes ] unit-test
{ 0xe70c2de5 } [ "b" fnv1a-32 checksum-bytes ] unit-test
{ 0xaf63bd4c8601b7bd } [ "b" fnv1-64 checksum-bytes ] unit-test
{ 0xaf63df4c8601f1a5 } [ "b" fnv1a-64 checksum-bytes ] unit-test

{ 0x31f0b262 } [ "foobar" fnv1-32 checksum-bytes ] unit-test
{ 0xbf9cf968 } [ "foobar" fnv1a-32 checksum-bytes ] unit-test
{ 0x340d8765a4dda9c2 } [ "foobar" fnv1-64 checksum-bytes ] unit-test
{ 0x85944171f73967e8 } [ "foobar" fnv1a-64 checksum-bytes ] unit-test

! I couldn't find any test vectors for 128, 256, 512, or 1024 versions of FNV1 hashes.
! So, just to check that your maths works the same as my maths, here's a few samples computed on my laptop.
! So they may be right or wrong, but either way, them failing is cause for concern somewhere...

{ 3897470310 } [ "Hello, world!" fnv1-32 checksum-bytes ] unit-test
{ 3985698964 } [ "Hello, world!" fnv1a-32 checksum-bytes ] unit-test
{ 7285062107457560934 } [ "Hello, world!" fnv1-64 checksum-bytes ] unit-test
{ 4094109891673226228 } [ "Hello, world!" fnv1a-64 checksum-bytes ] unit-test
{ 281580511747867177735318995358496831158 } [ "Hello, world!" fnv1-128 checksum-bytes ] unit-test
{ 303126633380056630368940439484674414572 } [ "Hello, world!" fnv1a-128 checksum-bytes ] unit-test
{ 104295939182568077644846978685759236849634734810631820736486253421270219742822 } [ "Hello, world!" fnv1-256 checksum-bytes ] unit-test
{ 9495445728692795332446740615588417456874414534608540692485745371050033741380 } [ "Hello, world!" fnv1a-256 checksum-bytes ] unit-test
{ 3577308325596719252093726711895047340166329831006673109476042102918876665433235513101496175651226507162015890004121912850661561110326527625579463564626958 } [ "Hello, world!" fnv1-512 checksum-bytes ] unit-test
{ 3577308325596719162840652138474318309664256091923081930027929425092517582111473988451078821416039944023089883981242376700859598441397004715365740906054208 } [ "Hello, world!" fnv1a-512 checksum-bytes ] unit-test
{ 52692754922840008511959888105094366091401994235075816792707658326855733053286986999719949898492311786648795846192078757217437117165934438286601534984230194601365788544275827382423366672856972872132009691615382991251544423521887009322211754219117294019951276080952271766377222613325328591830596794468813260226 } [ "Hello, world!" fnv1-1024 checksum-bytes ] unit-test
{ 52692754922840008511959888105094366091401994235075816792707658326855804920671100511873485674717442819607149127986090276849364757610838433887624184145636764448608707614141109841761957788887305179569455221243999538336208648824673027111352338809582124430199044921035232455717748500524777795242051756321605065326 } [ "Hello, world!" fnv1a-1024 checksum-bytes ] unit-test
