/* Fault handler information.  MacOSX version.
Copyright (C) 1993-1999, 2002-2003  Bruno Haible <clisp.org at bruno>
Copyright (C) 2003  Paolo Bonzini <gnu.org at bonzini>

Used under BSD license with permission from Paolo Bonzini and Bruno Haible,
2005-03-10:

http://sourceforge.net/mailarchive/message.php?msg_name=200503102200.32002.bruno%40clisp.org

Modified for Factor by Slava Pestov */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>

#include <mach/mach.h>
#include <mach/mach_error.h>
#include <mach/thread_status.h>
#include <mach/exception.h>
#include <mach/task.h>
#include <pthread.h>

/* This is not defined in any header, although documented.  */

/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/exc_server.html says:
   The exc_server function is the MIG generated server handling function
   to handle messages from the kernel relating to the occurrence of an
   exception in a thread. Such messages are delivered to the exception port
   set via thread_set_exception_ports or task_set_exception_ports. When an
   exception occurs in a thread, the thread sends an exception message to its
   exception port, blocking in the kernel waiting for the receipt of a reply.
   The exc_server function performs all necessary argument handling for this
   kernel message and calls catch_exception_raise, catch_exception_raise_state
   or catch_exception_raise_state_identity, which should handle the exception.
   If the called routine returns KERN_SUCCESS, a reply message will be sent,
   allowing the thread to continue from the point of the exception; otherwise,
   no reply message is sent and the called routine must have dealt with the
   exception thread directly.  */
extern "C" boolean_t exc_server (mach_msg_header_t *request_msg, mach_msg_header_t *reply_msg);


/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/catch_exception_raise.html
   These functions are defined in this file, and called by exc_server.
   FIXME: What needs to be done when this code is put into a shared library? */
extern "C"
kern_return_t
catch_exception_raise (mach_port_t exception_port,
                       mach_port_t thread,
                       mach_port_t task,
                       exception_type_t exception,
                       exception_data_t code,
                       mach_msg_type_number_t code_count);
extern "C"
kern_return_t
catch_exception_raise_state (mach_port_t exception_port,
                             exception_type_t exception,
                             exception_data_t code,
                             mach_msg_type_number_t code_count,
                             thread_state_flavor_t *flavor,
                             thread_state_t in_state,
                             mach_msg_type_number_t in_state_count,
                             thread_state_t out_state,
                             mach_msg_type_number_t *out_state_count);

extern "C"
kern_return_t
catch_exception_raise_state_identity (mach_port_t exception_port,
                                      mach_port_t thread,
                                      mach_port_t task,
                                      exception_type_t exception,
                                      exception_data_t code,
                                      mach_msg_type_number_t codeCnt,
                                      thread_state_flavor_t *flavor,
                                      thread_state_t in_state,
                                      mach_msg_type_number_t in_state_count,
                                      thread_state_t out_state,
                                      mach_msg_type_number_t *out_state_count);

namespace factor
{

void mach_initialize ();

}
