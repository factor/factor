/* Fault handler information.  MacOSX version.
Copyright (C) 1993-1999, 2002-2003  Bruno Haible <clisp.org at bruno>
Copyright (C) 2003  Paolo Bonzini <gnu.org at bonzini>

Used under BSD license with permission from Paolo Bonzini and Bruno Haible,
2005-03-10

see http://www.caddr.com/macho/archives/sbcl-devel/2005-3/4764.html */

#include "factor.h"

/* The following sources were used as a *reference* for this exception handling
   code:
      1. Apple's mach/xnu documentation
      2. Timothy J. Wood's "Mach Exception Handlers 101" post to the
         omnigroup's macosx-dev list.
         www.omnigroup.com/mailman/archive/macosx-dev/2000-June/002030.html */

/* The exception port on which our thread listens.  */
static mach_port_t our_exception_port;

/* A handler that is called in the faulting thread. */
static void
terminating_handler (void *fault_addr)
{
  memory_protection_error(fault_addr,SIGSEGV);
  abort ();
}


/* Handle an exception by invoking the user's fault handler and/or forwarding
   the duty to the previously installed handlers.  */
kern_return_t
catch_exception_raise (mach_port_t exception_port,
                       mach_port_t thread,
                       mach_port_t task,
                       exception_type_t exception,
                       exception_data_t code,
                       mach_msg_type_number_t code_count)
{
  SIGSEGV_EXC_STATE_TYPE exc_state;
  SIGSEGV_THREAD_STATE_TYPE thread_state;
  mach_msg_type_number_t state_count;
  unsigned long sp;

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_get_state.html.  */
  state_count = SIGSEGV_EXC_STATE_COUNT;
  if (thread_get_state (thread, SIGSEGV_EXC_STATE_FLAVOR,
                        (void *) &exc_state, &state_count)
      != KERN_SUCCESS)
    {
      /* The thread is supposed to be suspended while the exception handler
         is called. This shouldn't fail. */
      return KERN_FAILURE;
    }

  state_count = SIGSEGV_THREAD_STATE_COUNT;
  if (thread_get_state (thread, SIGSEGV_THREAD_STATE_FLAVOR,
                        (void *) &thread_state, &state_count)
      != KERN_SUCCESS)
    {
      /* The thread is supposed to be suspended while the exception handler
         is called. This shouldn't fail. */
      return KERN_FAILURE;
    }

  sp = (unsigned long) (SIGSEGV_STACK_POINTER (thread_state));

  SIGSEGV_PROGRAM_COUNTER (thread_state) = (unsigned long) terminating_handler;
  SIGSEGV_STACK_POINTER (thread_state) = fix_stack_ptr(sp);
  pass_arg0(&thread_state,SIGSEGV_EXC_STATE_FAULT(exc_state));

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_set_state.html.  */
  if (thread_set_state (thread, SIGSEGV_THREAD_STATE_FLAVOR,
                        (void *) &thread_state, state_count)
      != KERN_SUCCESS)
    {
      return KERN_FAILURE;
    }
  return KERN_SUCCESS;
}


/* The main function of the thread listening for exceptions.  */
static void *
mach_exception_thread (void *arg)
{
  for (;;)
    {
      /* These two structures contain some private kernel data. We don't need
         to access any of it so we don't bother defining a proper struct. The
         correct definitions are in the xnu source code. */
      /* Buffer for a message to be received.  */
      struct
        {
          mach_msg_header_t head;
          mach_msg_body_t msgh_body;
          char data[1024];
        }
        msg;
      /* Buffer for a reply message.  */
      struct
        {
          mach_msg_header_t head;
          char data[1024];
        }
        reply;

      mach_msg_return_t retval;

      /* Wait for a message on the exception port.  */
      retval = mach_msg (&msg.head, MACH_RCV_MSG | MACH_RCV_LARGE, 0,
                         sizeof (msg), our_exception_port,
                         MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
      if (retval != MACH_MSG_SUCCESS)
        {
          abort ();
        }

      /* Handle the message: Call exc_server, which will call
         catch_exception_raise and produce a reply message.  */
      exc_server (&msg.head, &reply.head);

      /* Send the reply.  */
      if (mach_msg (&reply.head, MACH_SEND_MSG, reply.head.msgh_size,
                    0, MACH_PORT_NULL,
                    MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL)
          != MACH_MSG_SUCCESS)
        {
          abort ();
        }
    }
}


/* Initialize the Mach exception handler thread.
   Return 0 if OK, -1 on error.  */
int mach_initialize ()
{
  mach_port_t self;
  exception_mask_t mask;
  pthread_attr_t attr;
  pthread_t thread;

  self = mach_task_self ();

  /* Allocate a port on which the thread shall listen for exceptions.  */
  if (mach_port_allocate (self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port)
      != KERN_SUCCESS)
    return -1;

  /* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_right.html.  */
  if (mach_port_insert_right (self, our_exception_port, our_exception_port,
                              MACH_MSG_TYPE_MAKE_SEND)
      != KERN_SUCCESS)
    return -1;

  /* The exceptions we want to catch.  Only EXC_BAD_ACCESS is interesting
     for us (see above in function catch_exception_raise).  */
  mask = EXC_MASK_BAD_ACCESS;

  /* Create the thread listening on the exception port.  */
  if (pthread_attr_init (&attr) != 0)
    return -1;
  if (pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED) != 0)
    return -1;
  if (pthread_create (&thread, &attr, mach_exception_thread, NULL) != 0)
    return -1;
  pthread_attr_destroy (&attr);

  /* Replace the exception port info for these exceptions with our own.
     Note that we replace the exception port for the entire task, not only
     for a particular thread.  This has the effect that when our exception
     port gets the message, the thread specific exception port has already
     been asked, and we don't need to bother about it.
     See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_set_exception_ports.html.  */
  if (task_set_exception_ports (self, mask, our_exception_port,
                                EXCEPTION_DEFAULT, MACHINE_THREAD_STATE)
      != KERN_SUCCESS)
    return -1;

  return 0;
}
