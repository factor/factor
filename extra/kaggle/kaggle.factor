! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax assocs discord formatting
hashtables http http.client http.download io.directories
io.pathnames json kernel math sequences urls ;
IN: kaggle

! Generate kaggle.json at: https://www.kaggle.com/settings
: load-kaggle-api-json ( -- json )
    home ".kaggle/kaggle.json" append-path path>json ;

CONSTANT: kaggle-api-v1 "https://www.kaggle.com/api/v1"
CONSTANT: kaggle-api-internal "https://www.kaggle.com/api/i"

: kaggle-basic-auth ( request -- request )
    load-kaggle-api-json
    [ "username" of ] [ "key" of ] bi set-basic-auth ;

: kaggle-bearer-auth ( request -- request )
    load-kaggle-api-json
    "key" of set-bearer-auth ;

: ensure-kaggle-data-path ( -- path )
    home ".kaggle/data" append-path [ make-directories ] keep ;

: >kaggle-url ( path -- url )
    kaggle-api-v1 prepend >url ;

: >kaggle-internal-url ( path -- url )
    kaggle-api-internal prepend >url ;

: kaggle-get-json ( path -- json )
    >kaggle-url <get-request> kaggle-basic-auth json-request ;

: kaggle-post-json ( post-data path -- json )
    >kaggle-url <post-request> kaggle-basic-auth json-request ;

: kaggle-post-json-internal ( post-data path -- json )
    >kaggle-internal-url <post-request> json-request ;

: kaggle-download ( path -- path )
    >kaggle-url <get-request> kaggle-basic-auth download-to-temporary-file ;

: map-kaggle-pages ( base-url params param-string -- seq )
    [ 0 [ dup ] ] 3dip '[
        1 + _ _ pick suffix _ vsprintf append kaggle-get-json
        dup length 0 = [ 2drop f f ] when
    ] produce nip concat ; inline

: map-kaggle-pages-100 ( base-url -- seq )
    { 100 } "?pageSize=%d&page=%d" map-kaggle-pages ;

: download-jeopardy-csv ( -- path )
    "/datasets/download/tunguz/200000-jeopardy-questions?datasetVersionNumber=1"
    kaggle-download ;

: download-competitions ( -- json )
    "/competitions/list" kaggle-get-json ;

: download-competition-data ( competition -- json )
    "/competitions/data/list/%s" sprintf kaggle-get-json ;

: list-competition-submissions ( competition -- json )
    "/competitions/submissions/%s" sprintf kaggle-get-json ;

! { "fileName": "submission.csv", "message": "First submission" }
: submit-competition-entry ( json competition -- json )
    "/competitions/submissions/%s" sprintf kaggle-post-json ;

: get-submission ( submission-id -- json )
    "/competitions/submissions/%s" sprintf kaggle-get-json ;

: list-datasets ( -- json )
    "/datasets/list" kaggle-get-json ;

: view-dataset ( dataset-id -- json )
    "/datasets/view/" append kaggle-get-json ;

: download-dataset ( dataset-id -- path )
    "/datasets/download/" append kaggle-download ;

! {
!     "title": "New Dataset",
!     "slug": "new-dataset",
!     "ownerSlug": "your-username",
!     "description": "This is a new dataset.",
!     "licenseName": "CC0-1.0",
!     "files": [
!         {
!             "path": "data.csv",
!             "description": "Data file"
!         }
!     ],
!     "convertToCsv": true,
!     "enableQuoting": true
! }
: create-dataset ( json -- json' )
    "/datasets/create" kaggle-post-json ;

! {
!     "versionNotes": "Updated with new data",
!     "files": [
!         {
!             "path": "new-data.csv",
!             "description": "Updated data file"
!         }
!     ],
!     "convertToCsv": true,
!     "enableQuoting": true
! }
: new-dataset-version ( json -- json' )
    "/datasets/version/new" kaggle-post-json ;

: list-kernels ( -- json )
    "/kernels/list" kaggle-get-json ;

: get-kernel-status ( kernel-id -- json )
    "/kernels/status/" append kaggle-get-json ;

: get-kernel-output ( kernel-id -- json )
    "/kernels/%s/output" sprintf kaggle-get-json ;

! {
!     "title": "New Kernel",
!     "slug": "new-kernel",
!     "language": "python",
!     "kernelType": "script",
!     "isPrivate": true,
!     "enableGpu": false,
!     "enableInternet": false,
!     "datasetDataSources": ["username/dataset-slug"],
!     "competitionDataSources": ["competition-name"],
!     "kernelDataSources": ["username/kernel-slug"],
!     "code": "# Your code here"
! }
: push-kernel ( json -- json' )
    "/kernels/push" kaggle-post-json ;

: start-kernel ( json kernel-id -- json' )
    "/kernels/status/%s/start" sprintf kaggle-post-json ;

: cancel-kernel ( json kernel-id -- json' )
    "/kernels/status/%s/cancel" sprintf kaggle-post-json ;

: get-competition-leaderboard ( competition -- json )
    "/competitions/leaderboard/%s" sprintf kaggle-get-json ;

: list-models ( -- json )
    "/models/list" kaggle-get-json ;

! Internal Kaggle API
ENUM: kaggle-categories
    { EDUCATION 11105 }
    { SPORTS-AND-RECREATION 14615 }
    { BUSINESS 14916 }
    { SCIENCE-AND-TECHNOLOGY 12201 }
    { HEALTH 12198 }
    { ART-AND-DESIGN 13418 }
    { CULTURE-AND-HUMANITIES 14601 }
    { GOVERNMENT 12547 }
    { LAW 11081 }
    { ENVIRONMENT 13101 }
    { NEWS-AND-MAGAZINE 14917 }
    { TRAVEL-AND-EVENTS 12008 }
    { FASHION-AND-STYLE 14603 }
    { FOOD-AND-COOKING 13102 }
    { GAMES-AND-TRIVIA 12926 }
    { HUMANITIES 11104 }
    { MUSIC 14918 }
    { PARENTING-AND-FAMILIES 14606 }
    { PROGRAMMING-AND-DATA-SCIENCE 14489 }
    { REAL-ESTATE 12761 }
    { RELIGION-AND-SPIRITUALITY 14919 }
    { SHOPPING 13104 }
    { SOCIAL-MEDIA 14611 }
    { TRANSPORT 14490 }
    { WILDLIFE-AND-NATURE 12009 }
    { WRITING-AND-LITERATURE 14921 }
    { ECONOMICS-AND-FINANCE 12680 }
    { EDUCATION-AND-LEARNING 13106 }
    { HISTORY-AND-SOCIETY 14182 }
    { HOME-AND-GARDEN 13419 }
    { LIFESTYLE 14613 }
    { MISCELLANEOUS 14922 }
    { MOVIES-AND-TELEVISION 14492 }
    { NATURE-AND-ENVIRONMENT 14923 }
    { PEOPLE-AND-SOCIETY 14617 }
    { PETS-AND-ANIMALS 14494 }
    { POLITICS 14619 }
    { SCIENCE-FICTION-AND-FANTASY 14495 }
    { SPORTS 14924 }
    { TECHNOLOGY 14925 }
    { VEHICLES-AND-TRANSPORTATION 14497 } ;

! kaggle-feedback-ids
! FEEDBACK_ID_ALL
! FEEDBACK_ID_UPVOTES
! FEEDBACK_ID_DOWNVOTES
! FEEDBACK_ID_COMMENTS
! FEEDBACK_ID_REPORTS
! FEEDBACK_ID_SUGGESTIONS
! FEEDBACK_ID_THANKS

! kaggle-file-type
! DATASET_FILE_TYPE_GROUP_ALL
! DATASET_FILE_TYPE_GROUP_CSV
! DATASET_FILE_TYPE_GROUP_IMAGE
! DATASET_FILE_TYPE_GROUP_TEXT
! DATASET_FILE_TYPE_GROUP_VIDEO

! kaggle-group
! DATASET_SELECTION_GROUP_PUBLIC
! DATASET_SELECTION_GROUP_PRIVATE
! DATASET_SELECTION_GROUP_ALL

! kaggle-license
! DATASET_LICENSE_GROUP_ALL
! DATASET_LICENSE_GROUP_CC0_1_0
! DATASET_LICENSE_GROUP_CC_BY_4_0
! DATASET_LICENSE_GROUP_CC_BY_SA_4_0
! DATASET_LICENSE_GROUP_GPL_2_0
! DATASET_LICENSE_GROUP_GPL_3_0
! DATASET_LICENSE_GROUP_OTHER

! kaggle-size
! DATASET_SIZE_GROUP_ALL
! DATASET_SIZE_GROUP_SMALL
! DATASET_SIZE_GROUP_MEDIUM
! DATASET_SIZE_GROUP_LARGE

! kaggle-sort-by
! DATASET_SORT_BY_HOTTEST
! DATASET_SORT_BY_VOTES
! DATASET_SORT_BY_VIEWS
! DATASET_SORT_BY_DATASET_UPDATED
! DATASET_SORT_BY_LATEST

! kaggle-viewed
! DATASET_VIEWED_GROUP_UNSPECIFIED
! DATASET_VIEWED_GROUP_VIEWED
! DATASET_VIEWED_GROUP_UNVIEWED

! {
!     "page": 1,
!     "group": "DATASET_SELECTION_GROUP_PUBLIC",
!     "size": "DATASET_SIZE_GROUP_ALL",
!     "fileType": "DATASET_FILE_TYPE_GROUP_ALL",
!     "license": "DATASET_LICENSE_GROUP_ALL",
!     "viewed": "DATASET_VIEWED_GROUP_UNSPECIFIED",
!     "categoryIds": [],
!     "search": "",
!     "sortBy": "DATASET_SORT_BY_HOTTEST",
!     "includeTopicalDatasets": false,
!     "minUsabilityRating": 0.8,
!     "feedbackIds": []
! }
: kaggle-search ( hash -- json )
    "/datasets.DatasetService/SearchDatasets" kaggle-post-json-internal ;

: kaggle-sign-out ( -- json )
    { } "/users.AccountService/SignOut" kaggle-post-json-internal ;

! { "email": "foo@gmail.com", "returnUrl": "/work" }
: kaggle-start-reset-password ( json -- json' )
    "/users.AccountService/StartResetPassword" kaggle-post-json-internal ;

! { "resetPasswordCode": "gcjVHH", "email": "foo@gmail.com",
! "resendIfExpired": false, "returnUrl": "/work" }
! on success:
! { "outcome": "VALIDATE_RESET_PASSWORD_CODE_OUTCOME_SUCCESS_USER_HAS_GOOGLE_LOGIN",
! "userId": 536 }
: kaggle-validate-reset-password-code ( json -- json' )
    "/users.AccountService/ValidateResetPasswordCode" kaggle-post-json-internal ;

: find-cookie-by-name ( seq name -- cookie/f ) '[ name>> _ = ] find nip ;

! { "email": "foo@gmail.com", "password": "pass", "returnUrl": "/work" }
: kaggle-email-sign-in ( json -- json' )
    [
        "https://www.kaggle.com/account/login" http-get drop
        cookies>> [
            "XSRF-TOKEN" find-cookie-by-name
            [ value>> "X-XSRF-TOKEN" associate ] [ H{ } clone ] if*
        ] [ ] bi
    ] dip

    "/users.LegacyUsersService/EmailSignIn"
    >kaggle-internal-url <post-request>
    "https://www.kaggle.com/account/login?phase=emailSignIn&returnUrl=%2Fwork" "referer" set-header
    swap >>cookies
    swap [ swap set-header ] assoc-each
    "1a567385c6b3c7697e12a04f7f0dcbaeccab6013" "x-kaggle-build-version" set-header
    json-request ;
