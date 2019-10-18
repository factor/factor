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

import factor.parser.*;
import factor.primitives.*;
import java.io.*;

public class FactorInterpreter implements FactorObject
{
	// command line arguments are stored here.
	public Cons args;

	// boot.factor sets these.
	public boolean interactive = true;
	public boolean trace = false;
	public boolean errorFlag = false;
	public Throwable error;
	public boolean dump = false;
	public boolean verboseCompile = true;
	public boolean fasl = true;

	public FactorCallFrame callframe;
	public FactorCallStack callstack = new FactorCallStack();
	public FactorDataStack datastack = new FactorDataStack();
	public FactorNamespace dict;
	public FactorWord last;
	public FactorNamespace global;
	private FactorNamespace interpNamespace;
	private Cons compiledExceptions;

	//{{{ main() method
	public static void main(String[] args) throws Exception
	{
		FactorInterpreter interp = new FactorInterpreter();
		interp.init(args,null);
	} //}}}

	//{{{ init() method
	public void init(String[] args, Object root) throws Exception
	{
		// this must be set before boot.factor is finished loading.
		if(args.length > 0 && args[0].equals("-no-fasl"))
			fasl = false;

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
		dict = FactorNamespace.createConstrainedNamespace(
			FactorWord.class);

		// parsing words
		FactorWord lineComment = intern("!");
		lineComment.parsing = new LineComment(lineComment,false);
		FactorWord stackComment = intern("(");
		stackComment.parsing = new StackComment(stackComment);
		FactorWord str = intern("\"");
		str.parsing = new StringLiteral(str);
		FactorWord t = intern("t");
		t.parsing = new T(t);
		FactorWord f = intern("f");
		f.parsing = new F(f);
		FactorWord bra = intern("[");
		bra.parsing = new Bra(bra);
		FactorWord ket = intern("]");
		ket.parsing = new Ket(bra,ket);
		FactorWord comma = intern(",");
		comma.parsing = new Comma(comma);
		FactorWord def = intern(":");
		def.parsing = new Def(def);
		def.getNamespace(this).setVariable("doc-comments",Boolean.TRUE);
		FactorWord ine = intern(";");
		ine.parsing = new Ine(def,ine);
		FactorWord shu = intern("~<<");
		shu.getNamespace(this).setVariable("doc-comments",Boolean.TRUE);
		shu.parsing = new Shu(shu);
		FactorWord fle = intern(">>~");
		fle.parsing = new Fle(shu,fle);
		FactorWord get = intern("$");
		get.parsing = new Prefix(get,get);
		FactorWord set = intern("@");
		set.parsing = new Prefix(set,set);

		// #X
		FactorWord dispatch = intern("#");
		dispatch.parsing = new Dispatch(dispatch);
		FactorWord chr = intern("#\\");
		chr.parsing = new CharLiteral(chr);
		FactorWord intern = intern("#=");
		intern.parsing = new Prefix(intern,intern("intern"));
		FactorWord docComment = intern("#!");
		docComment.parsing = new LineComment(docComment,true);
		FactorWord unreadable = intern("#<");
		unreadable.parsing = new Unreadable(unreadable);

		FactorWord interpreterGet = intern("interpreter");
		interpreterGet.def = new InterpreterGet(interpreterGet);

		// data stack primitives
		FactorWord datastackGet = intern("datastack$");
		datastackGet.def = new DatastackGet(datastackGet);
		FactorWord datastackSet = intern("datastack@");
		datastackSet.def = new DatastackSet(datastackSet);
		FactorWord clear = intern("clear");
		clear.def = new Clear(clear);

		// call stack primitives
		FactorWord callstackGet = intern("callstack$");
		callstackGet.def = new CallstackGet(callstackGet);
		FactorWord callstackSet = intern("callstack@");
		callstackSet.def = new CallstackSet(callstackSet);
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
		jinvokeStatic.def = new JInvokeStatic(jinvokeStatic);
		FactorWord jnew = intern("jnew");
		jnew.def = new JNew(jnew);
		FactorWord jvarGet = intern("jvar$");
		jvarGet.def = new JVarGet(jvarGet);
		FactorWord jvarGetStatic = intern("jvar-static$");
		jvarGetStatic.def = new JVarGetStatic(jvarGetStatic);
		FactorWord jvarSet = intern("jvar@");
		jvarSet.def = new JVarSet(jvarSet);
		FactorWord jvarSetStatic = intern("jvar-static@");
		jvarSetStatic.def = new JVarSetStatic(jvarSetStatic);

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

		global.setVariable("verbose-compile",
			new FactorNamespace.VarBinding(
				getClass().getField("verboseCompile"),
				this));

		String[] boundFields = { "dump",
			"interactive", "trace",
			"dict", "args", "global", "last", "fasl" };
		for(int i = 0; i < boundFields.length; i++)
		{
			global.setVariable(boundFields[i],
				new FactorNamespace.VarBinding(
					getClass().getField(boundFields[i]),
					this));
		}
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace(FactorInterpreter interp)
		throws Exception
	{
		if(interpNamespace == null)
			interpNamespace = new FactorNamespace(
				interp.global,this);

		return interpNamespace;
	} //}}}

	//{{{ runBootstrap() method
	private void runBootstrap() throws Exception
	{
		final String initFile = "boot.factor";
		FactorReader parser = new FactorReader(
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
			System.err.println("Original exception:");
			error.printStackTrace();
			System.err.println("Factor datastack:");
			System.err.println(datastack.toList());
			System.err.println("Factor callstack:");
			System.err.println(callstack.toList());

			topLevel();

			return true;
		}
		else
		{
			errorFlag = true;
			error = FactorJava.unwrapException(e);
			datastack.push(error);
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

	//{{{ compiledException() method
	/**
	 * Called by compiled words to give the user a meaningful call stack
	 * trace in the case of an exception.
	 */
	public void compiledException(FactorWord word, Throwable t)
	{
		// XXX: change callframe.namespace to something more meaningful
		FactorCallFrame compiledCallframe = new FactorCallFrame(
			word,callframe.namespace,
			new Cons(new FactorWord("#<compiled>"),null));
		compiledExceptions = new Cons(compiledCallframe,
			this.compiledExceptions);
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
			newcf = new FactorCallFrame();
			newcf.collapsed = true;
		}
		else
		{
			newcf = new FactorCallFrame();
			newcf.collapsed = false;
			if(callframe != null)
				callstack.push(callframe);
		}

		newcf.word = word;
		newcf.namespace = namespace;
		newcf.ip = code;

		callframe = newcf;
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
			buf.append(FactorReader.unparseObject(obj));
			System.err.println(buf);
		}

		if(obj instanceof FactorWord)
		{
			try
			{
				FactorWordDefinition d = ((FactorWord)obj).def;
				if(d == null)
				{
					throw new FactorUndefinedWordException(
						(FactorWord)obj);
				}
				else
					d.eval(this);
			}
			catch(Exception e)
			{
				callstack.push(callframe);
				callframe = new FactorCallFrame(
					(FactorWord)obj,
					callframe.namespace,
					null);
				while(compiledExceptions != null)
				{
					callstack.push(compiledExceptions.car);
					compiledExceptions = compiledExceptions
						.next();
				}
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
			System.err.println("Cannot internalize: " + name);
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
