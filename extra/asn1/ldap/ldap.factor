! Copyright (C) 2007 Elie CHAFTARI
! See https://factorcode.org/license.txt for BSD license.

IN: asn1.ldap

CONSTANT: SearchScope_BaseObject      0
CONSTANT: SearchScope_SingleLevel     1
CONSTANT: SearchScope_WholeSubtree    2

: asn-syntax ( -- hashtable )
    H{
        { "application"
            H{
                { "primitive"
                    H{
                        { 2 "null" }    ! UnbindRequest body
                     }
                }
                { "constructed"
                    H{
                        { 0 "array" }   ! BindRequest
                        { 1 "array" }   ! BindResponse
                        { 2 "array" }   ! UnbindRequest
                        { 3 "array" }   ! SearchRequest
                        { 4 "array" }   ! SearchData
                        { 5 "array" }   ! SearchResult
                        { 6 "array" }   ! ModifyRequest
                        { 7 "array" }   ! ModifyResponse
                        { 8 "array" }   ! AddRequest
                        { 9 "array" }   ! AddResponse
                        { 10 "array" }  ! DelRequest
                        { 11 "array" }  ! DelResponse
                        { 12 "array" }  ! ModifyRdnRequest
                        { 13 "array" }  ! ModifyRdnResponse
                        { 14 "array" }  ! CompareRequest
                        { 15 "array" }  ! CompareResponse
                        { 16 "array" }  ! AbandonRequest
                        { 19 "array" }  ! SearchResultReferral
                        { 24 "array" }  ! Unsolicited Notification
                     }
                }
            }
        }
        { "context_specific"
             H{
                 { "primitive"
                     H{
                         { 0 "string" }  ! password
                         { 1 "string" }  ! Kerberos v4
                         { 2 "string" }  ! Kerberos v5
                         { 7 "string" }  ! serverSaslCreds
                     }
                 }
                 { "constructed"
                     H{
                         { 0 "array" }    ! RFC-2251 Control and Filter-AND
                         { 1 "array" }    ! SearchFilter-OR
                         { 2 "array" }    ! SearchFilter-NOT
                         { 3 "array" }    ! Seach referral
                         { 4 "array" }    ! unknown use in Microsoft Outlook
                         { 5 "array" }    ! SearchFilter-GE
                         { 6 "array" }    ! SearchFilter-LE
                         { 7 "array" }    ! serverSaslCreds
                     }
                 }
             }
        }
    } ;
