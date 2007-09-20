! Tested with Apache JAMES version 2.3.1 on localhost
! cram-md5 authentication tested against Exim 4
! Replace "localhost" with your smtp server
! e.g. "your.smtp.server" initialize

USING: smtp tools.test ;

"localhost" initialize ! replace localhost with your smtp server

! 8889 set-port ! default port = 25, change for testing purposes

! 30000 set-read-timeout ! default = 60000
! f set-esmtp ! when esmtp (extended smtp) is not supported

start

! "md5 password here" "login" cram-md5-auth

"root@localhost" mailfrom ! your@mail.address

"root@localhost" rcptto ! someone@example.com

! { "From: Your Name <your@mail.address>" 
!   "To: Destination Address <someone@example.com>"
!   "Subject: test message"
!   "Date: Thu, 17 May 2007 18:46:45 +0200"
!   "Message-Id: <unique.message.id.string@example.com>"
!   " "
!   "This is a test message."
! } send-message

{ "From: Your Name <root@localhost>" 
  "To: Destination Address <root@localhost>"
  "Subject: test message"
  "Date: Thu, 17 May 2007 18:46:45 +0200"
  "Message-Id: <unique.message.id.string@example.com>"
  " "
  "This is a test message."
} send-message

quit