! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences tools.test ;
IN: discord.chatgpt-bot

! "What's the best mix of dogs that is not recognized by the AKC?"
! '{ { "role" "user" } { "content" _ } } >hashtable <chat-completion> chat-completions
CONSTANT: chatgpt-response H{
    { "id" "chatcmpl-75jBVGPgxxmuTOLvGVprcuSW3Vol6" }
    {
        "usage"
        H{
            { "prompt_tokens" 24 }
            { "total_tokens" 217 }
            { "completion_tokens" 193 }
        }
    }
    { "created" 1681599685 }
    { "model" "gpt-3.5-turbo-0301" }
    { "object" "chat.completion" }
    {
        "choices"
        {
            H{
                {
                    "message"
                    H{
                        { "role" "assistant" }
                        {
                            "content"
                            "As an AI language model, I do not have personal preferences. However, some breeds that are not currently recognized by the AKC but are popular among many people include:\n\n1. Dorgi - Dachshund and Corgi mix\n2. Pomsky - Pomeranian and Husky mix \n3. Labradoodle - Labrador Retriever and Poodle mix \n4. Cavachon - Cavalier King Charles Spaniel and Bichon Frise mix \n5. Goldendoodle - Golden Retriever and Poodle mix \n6. Cockapoo - Cocker Spaniel and Poodle mix \n7. Bernedoodle - Bernese Mountain Dog and Poodle mix \n8. Maltipoo - Maltese and Poodle mix \n9. Shichon - Shih Tzu and Bichon Frise mix \n10. Chiweenie - Chihuahua and Dachshund mix."
                        }
                    }
                }
                { "finish_reason" "stop" }
                { "index" 0 }
            }
        }
    }
}

{ t } [
    chatgpt-response first-chat-completion "As an AI language model," head?
] unit-test
