/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor;

import java.io.*;

public class FactorInterpreter
{
	/**
	 * boot.factor checks this, if its true, an interpreter is run on
	 * standard input.
	 */
	public boolean interactive = false;

	public boolean trace = false;
	public boolean errorFlag = false;
	public boolean compile = true;

	public FactorCallFrame callframe;
	public FactorCallStack callstack = new FactorCallStack();
	public FactorDataStack datastack = new FactorDataStack();
	public final FactorDictionary dict = new FactorDictionary();
	public FactorNamespace global;

	//{{{ main() method
	/**
	 * Need to refactor this into Factor.
	 */
	public static void main(String[] args) throws Exception
	{
		FactorInterpreter interp = new FactorInterpreter();

		boolean virgin = false;

		for(int i = 0; i < args.length; i++)
		{
			if(args[i].equals("-trace"))
				interp.trace = true;
			else if(args[i].equals("-virgin"))
				virgin = true;
			else if(args[i].equals("-interp"))
				interp.compile = false;
		}

		interp.interactive = true;
		interp.init(null,!virgin);
		if(virgin)
		{
			System.out.println("Mini-interpreter");
			BufferedReader in = new BufferedReader(
				new InputStreamReader(
				System.in));
			String line;
			for(;;)
			{
				System.out.print("] ");
				System.out.flush();
				line = in.readLine();
				if(line == null)
					break;

				FactorParser parser = new FactorParser(
					"<mini>",new StringReader(line),
					interp.dict);
				FactorList parsed = parser.parse();
				interp.call(parsed);
				interp.run();
				System.out.println(interp.datastack);
			}
		}
		else
		{
			interp.run();
		}

		System.exit(0);
	} //}}}

	//{{{ init() method
	public void init(Object root, boolean bootstrap) throws Exception
	{
		callstack.top = 0;
		datastack.top = 0;
		dict.init();
		initNamespace(root);
		topLevel();
		if(bootstrap)
			runBootstrap();
	} //}}}

	//{{{ initNamespace() method
	private void initNamespace(Object root) throws Exception
	{
		global = new FactorNamespace(null,root);

		global.setVariable("interpreter",this);

		String[] boundFields = { "compile", "interactive", "trace",
			"dict", "errorFlag" };
		for(int i = 0; i < boundFields.length; i++)
		{
			global.setVariable(boundFields[i],
				new FactorNamespace.VarBinding(
					getClass().getField(boundFields[i]),
					this));
		}
	} //}}}

	//{{{ runBootstrap() method
	private void runBootstrap() throws Exception
	{
		final String initFile = "boot.factor";
		FactorParser parser = new FactorParser(
			initFile,
			new InputStreamReader(
			getClass().getResourceAsStream(
			initFile)),
			dict);
		call(dict.intern("[init]"),parser.parse());
		run();
	} //}}}

	//{{{ run() method
	/**
	 * Runs the top-level loop until there is no more code to execute.
	 */
	public void run()
	{
		for(;;)
		{
			try
			{
				if(callframe == null)
					break;

				FactorList ip = callframe.ip;

				if(ip == null)
				{
					if(callstack.top == 0)
						break;

					try
					{
						callframe = (FactorCallFrame)
							callstack.pop();
						continue;
					}
					catch(ClassCastException e)
					{
						throw new FactorRuntimeException(
							"Unbalanced >r/r> or "
							+ "restack/unstack");
					}
				}

				callframe.ip = ip.next();

				eval(ip.car);
			}
			catch(Exception e)
			{
				if(handleError(e))
					return;
			}
		}

		callframe = null;
	} //}}}

	//{{{ handleError() method
	private boolean handleError(Exception e)
	{
		/* if(throwErrors)
		{
			throw e;
		}
		else */ if(errorFlag)
		{
			System.err.println("Exception inside"
				+ " error handler:");
			e.printStackTrace();
			System.err.println(
				"Original exception:");
			e.printStackTrace();
			System.err.println("Factor callstack:");
			System.err.println(callstack);

			return true;
		}
		else
		{
			errorFlag = true;
			datastack.push(FactorJava.unwrapException(e));
			try
			{
				eval(dict.intern("break"));
				return false;
			}
			catch(Exception e2)
			{
				System.err.println("Exception when calling break:");
				e.printStackTrace();
				System.err.println("Factor callstack:");
				System.err.println(callstack);

				return true;
			}
		}
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public final void call(FactorList code)
	{
		call(dict.intern("call"),code);
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public final void call(FactorWord word, FactorList code)
	{
		if(callframe == null)
			call(word,global,code);
		else
			call(word,callframe.namespace,code);
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public final void call(FactorWord word, FactorNamespace namespace, FactorList code)
	{
		FactorCallFrame newcf;

		// tail call optimization
		if(callframe != null && callframe.ip == null)
		{
			if(trace)
				System.err.println("-- TAIL CALL --");
			newcf = getRecycledCallFrame(callstack.top);
			newcf.collapsed = true;
		}
		// try to get a recycled callframe from the stack
		else
		{
			newcf = getRecycledCallFrame(callstack.top + 1);
			newcf.collapsed = false;
			if(callframe != null)
				callstack.push(callframe);
		}

		newcf.word = word;
		newcf.namespace = namespace;
		newcf.ip = code;

		callframe = newcf;
	} //}}}

	//{{{ getRecycledCallFrame() method
	private FactorCallFrame getRecycledCallFrame(int next)
	{
		/* if(callstack.stack != null && next < callstack.stack.length)
		{
			Object o = callstack.stack[next];
			if(o instanceof FactorCallFrame)
				return (FactorCallFrame)o;
			else
				return new FactorCallFrame();
		}
		else */
			return new FactorCallFrame();
	} //}}}

	//{{{ eval() method
	/**
	 * Evaluates a word.
	 */
	private void eval(Object obj) throws Exception
	{
		if(trace)
		{
			StringBuffer buf = new StringBuffer();
			for(int i = 0; i < callstack.top; i++)
				buf.append(' ');
			buf.append(FactorJava.factorTypeToString(obj));
			System.err.println(buf);
		}

		if(obj instanceof FactorWord)
		{
			FactorWord w = (FactorWord)obj;

			try
			{
				w.def.eval(w,this);
			}
			catch(Exception e)
			{
				callstack.push(callframe);
				callframe = new FactorCallFrame(
					w,
					callframe.namespace,
					null);
				throw e;
			}
		}
		else
			datastack.push(obj);
	} //}}}

	//{{{ topLevel() method
	/**
	 * Returns the parser to the top level context.
	 */
	public void topLevel()
	{
		callstack.top = 0;
		datastack.top = 0;
		callframe = new FactorCallFrame(
			dict.intern("[toplevel]"),
			global,
			null);
	} //}}}
}
