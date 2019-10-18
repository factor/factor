/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003, 2004 Slava Pestov.
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

import factor.primitives.*;
import java.io.*;

public class FactorInterpreter
{
	// command line arguments are stored here.
	public Cons args;

	// boot.factor sets these.
	public boolean interactive = true;
	public boolean trace = false;
	public boolean errorFlag = false;
	public boolean compile = true;
	public boolean dump = false;

	public FactorCallFrame callframe;
	public FactorCallStack callstack = new FactorCallStack();
	public FactorDataStack datastack = new FactorDataStack();
	public FactorNamespace dict;
	public FactorWord last;
	public FactorNamespace global;

	//{{{ main() method
	public static void main(String[] args) throws Exception
	{
		FactorInterpreter interp = new FactorInterpreter();
		interp.init(args,null);
		System.exit(0);
	} //}}}

	//{{{ init() method
	public void init(String[] args, Object root) throws Exception
	{
		this.args = Cons.fromArray(args);

		callstack.top = 0;
		datastack.top = 0;
		initDictionary();
		initNamespace(root);
		topLevel();
		runBootstrap();
	} //}}}

	//{{{ initDictionary() method
	private void initDictionary() throws Exception
	{
		dict = new FactorNamespace(null,null);

		// data stack primitives
		FactorWord datastackGet = intern("datastack$");
		datastackGet.def = new DatastackGet(
			datastackGet);
		FactorWord datastackSet = intern("datastack@");
		datastackSet.def = new DatastackSet(
			datastackSet);
		FactorWord clear = intern("clear");
		clear.def = new Clear(clear);

		// call stack primitives
		FactorWord callstackGet = intern("callstack$");
		callstackGet.def = new CallstackGet(
			callstackGet);
		FactorWord callstackSet = intern("callstack@");
		callstackSet.def = new CallstackSet(
			callstackSet);
		FactorWord restack = intern("restack");
		restack.def = new Restack(restack);
		FactorWord unstack = intern("unstack");
		unstack.def = new Unstack(unstack);
		FactorWord unwind = intern("unwind");
		unwind.def = new Unwind(unwind);

		// reflection primitives
		FactorWord jinvoke = intern("jinvoke");
		jinvoke.def = new JInvoke(jinvoke);
		FactorWord jinvokeStatic = intern("jinvoke-static");
		jinvokeStatic.def = new JInvokeStatic(
			jinvokeStatic);
		FactorWord jnew = intern("jnew");
		jnew.def = new JNew(jnew);
		FactorWord jvarGet = intern("jvar$");
		jvarGet.def = new JVarGet(jvarGet);
		FactorWord jvarGetStatic = intern("jvar-static$");
		jvarGetStatic.def = new JVarGetStatic(
			jvarGetStatic);
		FactorWord jvarSet = intern("jvar@");
		jvarSet.def = new JVarSet(jvarSet);
		FactorWord jvarSetStatic = intern("jvar-static@");
		jvarSetStatic.def = new JVarSetStatic(
			jvarSetStatic);

		// namespaces
		FactorWord get = intern("$");
		get.def = new Get(get);
		FactorWord set = intern("@");
		set.def = new Set(set);

		// definition
		FactorWord define = intern("define");
		define.def = new Define(define);

		// combinators
		FactorWord execute = intern("execute");
		execute.def = new Execute(execute);
		FactorWord call = intern("call");
		call.def = new Call(call);
		FactorWord bind = intern("bind");
		bind.def = new Bind(bind);
		FactorWord choice = intern("?");
		choice.def = new Choice(choice);
	} //}}}

	//{{{ initNamespace() method
	private void initNamespace(Object root) throws Exception
	{
		global = new FactorNamespace(null,root);

		global.setVariable("interpreter",this);

		global.setVariable("error-flag",
			new FactorNamespace.VarBinding(
				getClass().getField("errorFlag"),
				this));

		String[] boundFields = { "compile", "dump",
			"interactive", "trace",
			"dict", "args", "global", "last" };
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
			this);
		call(intern("[init]"),parser.parse());
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

				Cons ip = callframe.ip;

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
			catch(Throwable e)
			{
				if(handleError(e))
					return;
			}
		}

		callframe = null;
	} //}}}

	//{{{ handleError() method
	private boolean handleError(Throwable e)
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

			topLevel();

			return true;
		}
		else
		{
			errorFlag = true;
			datastack.push(FactorJava.unwrapException(e));
			try
			{
				eval(intern("break"));
				return false;
			}
			catch(Throwable e2)
			{
				System.err.println("Exception when calling break:");
				e.printStackTrace();
				System.err.println("Factor callstack:");
				System.err.println(callstack);

				topLevel();

				return true;
			}
		}
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public final void call(Cons code)
	{
		call(intern("call"),code);
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public final void call(FactorWord word, Cons code)
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
	public final void call(FactorWord word, FactorNamespace namespace, Cons code)
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
	public void eval(Object obj) throws Exception
	{
		if(trace)
		{
			StringBuffer buf = new StringBuffer();
			for(int i = 0; i < callstack.top; i++)
				buf.append(' ');
			buf.append(FactorParser.unparse(obj));
			System.err.println(buf);
		}

		if(obj instanceof FactorWord)
		{
			try
			{
				((FactorWord)obj).def.eval(this);
			}
			catch(Exception e)
			{
				callstack.push(callframe);
				callframe = new FactorCallFrame(
					(FactorWord)obj,
					callframe.namespace,
					null);
				throw e;
			}
		}
		else
			datastack.push(obj);
	} //}}}

	//{{{ intern() method
	public FactorWord intern(String name)
	{
		try
		{
			FactorWord w = (FactorWord)dict.getVariable(name);
			if(w == null)
			{
				w = new FactorWord(name);
				dict.setVariable(name,w);
			}
			return w;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
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
			intern("[toplevel]"),
			global,
			null);
	} //}}}
}
