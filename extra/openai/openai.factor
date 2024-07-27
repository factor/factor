! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs assocs.extras calendar calendar.format
hashtables http http.client io.encodings.string
io.encodings.utf8 json json.http kernel mirrors namespaces
sequences sorting urls ;

IN: openai

SYMBOL: openai-api-base
"https://api.openai.com/v1" openai-api-base set-global

SYMBOL: openai-api-key

SYMBOL: openai-organization

CONSTANT: cheapest-model "gpt-4o-mini"

<PRIVATE

: openai-url ( path -- url )
    [ openai-api-base get ] dip "/" glue >url ;

: openai-request ( request -- data )
    openai-api-key get "Bearer " prepend "Authorization" set-header
    openai-organization get [ "OpenAI-Organization" set-header ] when*
    http-request nip utf8 decode json> ;

: openai-get ( path -- data )
    openai-url "GET" <json-request> openai-request ;

: openai-delete ( path -- data )
    openai-url "DELETE" <json-request> openai-request ;

: openai-post ( post-data path -- data )
    [ <json-post-data> ] [ openai-url ] bi*
    "POST" <json-request> swap >>post-data openai-request ;

: openai-input ( obj -- assoc )
    ! assume all false values are default values and reject
    dup assoc? [ <mirror> >hashtable sift-values ] unless ;

PRIVATE>

: add-human-readable-timestamps ( models -- models )
    [
        dup "created" of unix-time>timestamp timestamp>rfc3339
        "created-string" pick set-at
    ] map ;

: list-models ( -- models )
    "models" openai-get "data" of
    [ "created" of ] sort-by
    add-human-readable-timestamps ;

: list-model-names ( -- names )
    list-models [ "id" of ] map ;

: retrieve-model ( model-id -- data )
    "models/" prepend openai-get ;

: delete-model ( model-id -- data )
    "models/" prepend openai-delete ;

TUPLE: completion model prompt suffix max_tokens temperature
    top_p n stream logprobs echo stop presence_penalty
    frequency_penalty best_of logit_bias user ;

: <completion> ( prompt model -- completion )
    completion new swap >>model swap >>prompt ;

: create-completion ( completion -- data )
    openai-input "completions" openai-post ;

TUPLE: chat-message role content ;

C: <chat-message> chat-message

TUPLE: chat-completion model messages temperature top_p n stream
    stop max_tokens presence_penalty frequency_penalty
    logit_bias user ;

: <chat-completion> ( messages model -- chat-completion )
    chat-completion new swap >>model swap >>messages ;

: <cheapest-chat-completion> ( messages -- chat-completion )
    cheapest-model <chat-completion> ;

: chat-completions ( chat-completion -- data )
    openai-input "chat/completions" openai-post ;

TUPLE: edit model input instruction n temperature top_p ;

: <edit> ( instruction model -- edit )
    edit new swap >>model swap >>instruction ;

: create-edit ( edit -- data )
    openai-input "edits" openai-post ;

TUPLE: image-generation prompt n size response_format user ;

: <image-generation> ( prompt -- image-generation )
    image-generation new swap >>prompt ;

: create-image ( image-generation -- data )
    openai-input "images/generations" openai-post ;

TUPLE: image-edit image mask prompt n size response_format user ;

: <image-edit ( image prompt -- image-edit )
    image-edit new swap >>prompt swap >>image ;

: create-image-edit ( image-edit -- data  )
    openai-input "images/edits" openai-post ;

TUPLE: image-variation image n size response_format user ;

: <image-variation> ( image -- image-variation )
    image-variation new swap >>image ;

: create-image-variation ( image-variation -- data )
    openai-input "images/variations" openai-post ;

TUPLE: embeddings model input user ;

: <embeddings> ( input model -- embeddings )
    embeddings new swap >>model swap >>input ;

: create-embeddings ( embeddings -- data )
    openai-input "embeddings" openai-post ;

TUPLE: transcription file model prompt response_format
    temperature language ;

: <transcription> ( file model -- transcription )
    transcription new swap >>model swap >>file ;

: create-transcription ( transcription -- data )
    openai-input "audio/transcriptions" openai-post ;

TUPLE: translation file model prompt response_format temperature ;

: <translation> ( file model -- translation )
    translation new swap >>model swap >>file ;

: create-translation ( translation -- data )
    openai-input "audio/translations" openai-post ;

: list-files ( -- files )
    "files" openai-get ;

TUPLE: file-upload file purpose ;

C: <file-upload> file-upload

: upload-file ( file-upload -- data )
    openai-input "files" openai-post ;

: delete-file ( file-id -- data )
    "files/" prepend openai-delete ;

: retrieve-file ( file-id -- data )
    "files/" prepend openai-get ;

: retrieve-file-content ( file-id -- content )
    "files/" "/content" surround openai-get ;

TUPLE: fine-tune training_file validation_file model n_epochs
    batch_size learning_rate_multiplier prompt_loss_weight
    compute_classification_metrics classification_n_classes
    classification_positive_class classification_betas suffix ;

: <fine-tune> ( training_file -- fine-tune )
    fine-tune new swap >>training_file ;

: create-fine-tune ( fine-tune -- data )
    openai-input "fine-tunes" openai-post ;

: list-fine-tunes ( -- data )
    "fine-tunes" openai-get ;

: retrieve-fine-tune ( fine-tune-id -- data )
    "fine-tunes/" prepend openai-get ;

: cancel-fine-tune ( fine-tune-id -- data )
    H{ } swap "fine-tunes/" "/cancel" surround openai-post ;

! XXX: query parameter ?stream=true/false
: list-fine-tune-events ( fine-tune-id -- data )
    "fine-tunes/" "/events" surround openai-get ;

TUPLE: moderation input model ;

: <moderation> ( input -- moderation )
    moderation new swap >>input ;

: create-moderation ( moderation -- data )
    openai-input "moderation" openai-post ;
