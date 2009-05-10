/* Fault handler information.  MacOSX version.
Copyright (C) 1993-1999, 2002-2003  Bruno Haible <clisp.org at bruno>

Copyright (C) 2003  Paolo Bonzini <gnu.org at bonzini>

Used under BSD license with permission from Paolo Bonzini and Bruno Haible,
2005-03-10:

http://sourceforge.net/mailarchive/message.php?msg_name=200503102200.32002.bruno%40clisp.org

Modified for Factor by Slava Pestov */

#include "master.hpp"

namespace factor
{

/* The exception port on which our thread listens. */
mach_port_t our_exception_port;

/* The following sources were used as a *reference* for this exception handling
code:
1. Apple's mach/xnu documentation
2. Timothy J. Wood's "Mach Exception Handlers 101" post to the
omnigroup's macosx-dev list.
http://www.wodeveloper.com/omniLists/macosx-dev/2000/June/msg00137.html */

/* Modify a suspended thread's thread_state so that when the thread resumes
executing, the call frame of the current C primitive (if any) is rewound, and
the appropriate Factor error is thrown from the top-most Factor frame. */
static void call_fault_handler(exception_type_t exception,
	MACH_EXC_STATE_TYPE *exc_state,
	MACH_THREAD_STATE_TYPE *thread_state)
{
	/* There is a race condition here, but in practice an exception
	delivered during stack frame setup/teardown or while transitioning
	from Factor to C is a sign of things seriously gone wrong, not just
	a divide by zero or stack underflow in the listener */

	/* Are we in compiled Factor code? Then use the current stack pointer */
	if(in_code_heap_p(MACH_PROGRAM_COUNTER(thread_state)))
		signal_callstack_top = (stack_frame *)MACH_STACK_POINTER(thread_state);
	/* Are we in C? Then use the saved callstack top */
	else
		signal_callstack_top = NULL;

	MACH_STACK_POINTER(thread_state) = fix_stack_pointer(MACH_STACK_POINTER(thread_state));

	/* Now we point the program counter at the right handler function. */
	if(exception == EXC_BAD_ACCESS)
	{
		signal_fault_addr = MACH_EXC_STATE_FAULT(exc_state);
		MACH_PROGRAM_COUNTER(thread_state) = (cell)memory_signal_handler_impl;
	}
	else
	{
		if(exception == EXC_ARITHMETIC)
			signal_number = SIGFPE;
		else
			signal_number = SIGABRT;
		MACH_PROGRAM_COUNTER(thread_state) = (cell)misc_signal_handler_impl;
	}
}

/* Handle an exception by invoking the user's fault handler and/or forwarding
the duty to the previously installed handlers.  */
extern "C"
kern_return_t
catch_exception_raise (mach_port_t exception_port,
	mach_port_t thread,
	mach_port_t task,
	exception_type_t exception,
	exception_data_t code,
	mach_msg_type_number_t code_count)
{
	MACH_EXC_STATE_TYPE exc_state;
	MACH_THREAD_STATE_TYPE thread_state;
	mach_msg_type_number_t state_count;

	/* Get fault information and the faulting thread's register contents..
	
	See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_get_state.html.  */
	state_count = MACH_EXC_STATE_COUNT;
	if (thread_get_state (thread, MACH_EXC_STATE_FLAVOR,
			      (natural_t *)&exc_state, &state_count)
		!= KERN_SUCCESS)
	{
		/* The thread is supposed to be suspended while the exception
		handler is called. This shouldn't fail. */
		return KERN_FAILURE;
	}

	state_count = MACH_THREAD_STATE_COUNT;
	if (thread_get_state (thread, MACH_THREAD_STATE_FLAVOR,
			      (natural_t *)&thread_state, &state_count)
		!= KERN_SUCCESS)
	{
		/* The thread is supposed to be suspended while the exception
		handler is called. This shouldn't fail. */
		return KERN_FAILURE;
	}

	/* Modify registers so to have the thread resume executing the
	fault handler */
	call_fault_handler(exception,&exc_state,&thread_state);

	/* Set the faulting thread's register contents..
	
	See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/thread_set_state.html.  */
	if (thread_set_state (thread, MACH_THREAD_STATE_FLAVOR,
			      (natural_t *)&thread_state, state_count)
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
			0, MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL)
			!= MACH_MSG_SUCCESS)
		{
			abort ();
		}
	}
}

/* Initialize the Mach exception handler thread. */
void mach_initialize ()
{
	mach_port_t self;
	exception_mask_t mask;

	self = mach_task_self ();

	/* Allocate a port on which the thread shall listen for exceptions.  */
	if (mach_port_allocate (self, MACH_PORT_RIGHT_RECEIVE, &our_exception_port)
		!= KERN_SUCCESS)
		fatal_error("mach_port_allocate() failed",0);

	/* See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_port_insert_right.html.  */
	if (mach_port_insert_right (self, our_exception_port, our_exception_port,
		MACH_MSG_TYPE_MAKE_SEND)
		!= KERN_SUCCESS)
		fatal_error("mach_port_insert_right() failed",0);

	/* The exceptions we want to catch. */
	mask = EXC_MASK_BAD_ACCESS | EXC_MASK_ARITHMETIC;

	/* Create the thread listening on the exception port.  */
	start_thread(mach_exception_thread);

	/* Replace the exception port info for these exceptions with our own.
	Note that we replace the exception port for the entire task, not only
	for a particular thread.  This has the effect that when our exception
	port gets the message, the thread specific exception port has already
	been asked, and we don't need to bother about it.
	See http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/task_set_exception_ports.html.  */
	if (task_set_exception_ports (self, mask, our_exception_port,
		EXCEPTION_DEFAULT, MACHINE_THREAD_STATE)
		!= KERN_SUCCESS)
		fatal_error("task_set_exception_ports() failed",0);
}

}
