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

public class FactorInterpreter implements FactorObject, Runnable
{
	public static final String VERSION = "0.60.8";

	// command line arguments are stored here.
	public Cons args;

	// boot.factor sets these.
	public boolean interactive = true;
	public Throwable error;
	public boolean dump = false;
	public boolean verboseCompile = false;
	public boolean mini = false;
	// if this is false and an error occurs, bail out.
	public boolean startupDone = false;

	public Cons callframe;
	public FactorArray callstack = new FactorArray();
	public FactorArray datastack = new FactorArray();
	public FactorArray namestack = new FactorArray();
	public FactorArray catchstack = new FactorArray();

	/**
	 * Maps vocabulary names to vocabularies.
	 */
	public FactorNamespace vocabularies;

	/**
	 * Vocabulary search path for interactive parser.
	 */
	public Cons use;

	/**
	 * Vocabulary to define new words in.
	 */
	public String in;

	/**
	 * Kernel vocabulary. Re-created on each startup, contains
	 * primitives and parsing words.
	 */
	public FactorNamespace builtins;

	/**
	 * Most recently defined word.
	 */
	public FactorWord last;

	public FactorNamespace global;

	private FactorNamespace interpNamespace;

	private Cons compiledExceptions;

	//{{{ main() method
	public static void main(String[] args) throws Exception
	{
		FactorInterpreter interp = new FactorInterpreter();
		interp.init(args,null);
		interp.run();
	} //}}}

	//{{{ init() method
	public void init(FactorInterpreter interp) throws Exception
	{
		this.args = interp.args;
		this.interactive = interp.interactive;
		this.dump = interp.dump;
		this.verboseCompile = interp.verboseCompile;
		this.callframe = interp.callframe;
		this.callstack = (FactorArray)interp.callstack.clone();
		this.datastack = (FactorArray)interp.datastack.clone();
		this.namestack = (FactorArray)interp.namestack.clone();
		this.catchstack = (FactorArray)interp.catchstack.clone();
		this.vocabularies = interp.vocabularies;
		this.use = interp.use;
		this.in = interp.in;
		this.builtins = interp.builtins;
		this.last = interp.last;
		this.global = interp.global;
	} //}}}

	//{{{ init() method
	public void init(String[] args, Object root) throws Exception
	{
		for(int i = 0; i < args.length; i++)
		{
			String arg = args[i];
			// this switch forces minimal libraries to be loaded
			if(arg.equals("-no-mini"))
			{
				mini = false;
				args[i] = null;
			}
			else if(arg.equals("-mini"))
			{
				mini = true;
				args[i] = null;
			}
		}

		this.args = Cons.fromArray(args);

		vocabularies = new FactorNamespace();
		initBuiltinDictionary();
		initNamespace(root);
		topLevel();

		runBootstrap();
	} //}}}

	//{{{ initBuiltinDictionary() method
	private void initBuiltinDictionary() throws Exception
	{
		builtins = new FactorNamespace();
		vocabularies.setVariable("builtins",builtins);

		in = "builtins";
		use = new Cons(in,null);

		// parsing words
		FactorWord lineComment = define("builtins","!");
		lineComment.parsing = new LineComment(lineComment,false);
		FactorWord stackComment = define("builtins","(");
		stackComment.parsing = new StackComment(stackComment);
		FactorWord str = define("builtins","\"");
		str.parsing = new StringLiteral(str,true);
		FactorWord t = define("builtins","t");
		t.parsing = new T(t);
		FactorWord f = define("builtins","f");
		f.parsing = new F(f);
		FactorWord bra = define("builtins","[");
		bra.parsing = new Bra(bra);
		FactorWord ket = define("builtins","]");
		ket.parsing = new Ket(bra,ket);
		FactorWord bar = define("builtins","|");
		bar.parsing = new Bar(bar);
		FactorWord def = define("builtins",":");
		def.parsing = new Def(def);
		def.getNamespace().setVariable("doc-comments",Boolean.TRUE);
		FactorWord ine = define("builtins",";");
		ine.parsing = new Ine(def,ine);
		FactorWord shuffle = define("builtins","~<<");
		shuffle.parsing = new Shuffle(shuffle,">>~");

		FactorWord noParsing = define("builtins","POSTPONE:");
		noParsing.parsing = new NoParsing(noParsing);

		// #X
		FactorWord dispatch = define("builtins","#");
		dispatch.parsing = new Dispatch(dispatch);
		FactorWord ch = define("builtins","#\\");
		ch.parsing = new CharLiteral(ch);
		FactorWord raw = define("builtins","#\"");
		raw.parsing = new StringLiteral(raw,false);
		FactorWord complex = define("builtins","#{");
		complex.parsing = new ComplexLiteral(complex,"}");
		FactorWord docComment = define("builtins","#!");
		docComment.parsing = new LineComment(docComment,true);
		FactorWord unreadable = define("builtins","#<");
		unreadable.parsing = new Unreadable(unreadable);

		// #: is not handled with a special dispatch. instead, when
		// a word starting with #: is passed to intern(), it creates
		// a new symbol
		FactorWord passthru = define("builtins","#:");
		passthru.parsing = new PassThrough(passthru);

		// vocabulary parsing words
		FactorWord defer = define("builtins","DEFER:");
		defer.parsing = new Defer(defer);
		FactorWord in = define("builtins","IN:");
		in.parsing = new In(in);
		FactorWord use = define("builtins","USE:");
		use.parsing = new Use(use);

		FactorWord interpreterGet = define("builtins","interpreter");
		interpreterGet.def = new InterpreterGet(interpreterGet);
		interpreterGet.inline = true;

		// reading numbers with another base
		FactorWord bin = define("builtins","BIN:");
		bin.parsing = new Base(bin,2);
		FactorWord oct = define("builtins","OCT:");
		oct.parsing = new Base(oct,8);
		FactorWord hex = define("builtins","HEX:");
		hex.parsing = new Base(hex,16);

		// primitives used by 'expand' and 'map'
		FactorWord restack = define("builtins","restack");
		restack.def = new Restack(restack);
		FactorWord unstack = define("builtins","unstack");
		unstack.def = new Unstack(unstack);

		// reflection primitives
		FactorWord jinvoke = define("builtins","jinvoke");
		jinvoke.def = new JInvoke(jinvoke,false);
		jinvoke.inline = true;
		FactorWord jinvokeStatic = define("builtins","jinvoke-static");
		jinvokeStatic.def = new JInvoke(jinvokeStatic,true);
		jinvokeStatic.inline = true;
		FactorWord jnew = define("builtins","jnew");
		jnew.def = new JNew(jnew);
		jnew.inline = true;
		FactorWord jvarGet = define("builtins","jvar-get");
		jvarGet.def = new JVarGet(jvarGet);
		jvarGet.inline = true;
		FactorWord jvarGetStatic = define("builtins","jvar-static-get");
		jvarGetStatic.def = new JVarGetStatic(jvarGetStatic);
		jvarGetStatic.inline = true;
		FactorWord jvarSet = define("builtins","jvar-set");
		jvarSet.def = new JVarSet(jvarSet);
		jvarSet.inline = true;
		FactorWord jvarSetStatic = define("builtins","jvar-static-set");
		jvarSetStatic.def = new JVarSetStatic(jvarSetStatic);
		jvarSetStatic.inline = true;
		FactorWord coerce = define("builtins","coerce");
		coerce.def = new Coerce(coerce);
		coerce.inline = true;

		// definition
		FactorWord define = define("builtins","define");
		define.def = new Define(define);

		// combinators
		FactorWord execute = define("builtins","execute");
		execute.def = new Execute(execute);
		FactorWord call = define("builtins","call");
		call.def = new Call(call);
		call.inline = true;
		FactorWord ifte = define("builtins","ifte");
		ifte.def = new Ifte(ifte);
		ifte.inline = true;
	} //}}}

	//{{{ initNamespace() method
	private void initNamespace(Object root) throws Exception
	{
		global = new FactorNamespace(null,root);

		global.setVariable("interpreter",this);

		global.setVariable("verbose-compile",
			new FactorNamespace.VarBinding(
				getClass().getField("verboseCompile"),
				this));

		global.setVariable("startup-done",
			new FactorNamespace.VarBinding(
				getClass().getField("startupDone"),
				this));

		String[] boundFields = {
			"global",
			"vocabularies",
			"args",
			"dump",
			"interactive",
			"builtins",
			"in",
			"last",
			"use"
		};

		for(int i = 0; i < boundFields.length; i++)
		{
			String name = boundFields[i];
			global.setVariable(name,
				new FactorNamespace.VarBinding(
					getClass().getField(name),
					this));
		}
	} //}}}

	//{{{ getNamespace() method
	public FactorNamespace getNamespace()
		throws Exception
	{
		if(interpNamespace == null)
			interpNamespace = new FactorNamespace(this);

		return interpNamespace;
	} //}}}

	//{{{ runBootstrap() method
	private void runBootstrap() throws Exception
	{
		String initFile = "/library/platform/jvm/boot.factor";
		FactorReader parser = new FactorReader(
			initFile,
			new BufferedReader(
			new InputStreamReader(
			getClass().getResourceAsStream(
			initFile))),
			this);
                
		call(parser.parse());

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
				{
					if(callstack.top == 0)
						break;

					callframe = (Cons)callstack.pop();
					continue;
				}

				Object eval = callframe.car;
				callframe = callframe.next();
				eval(eval);
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
		error = FactorJava.unwrapException(e);
		if(!startupDone)
		{
			error.printStackTrace();
			topLevel();
			return true;
		}
		
		datastack.push(error);
		try
		{
			FactorWord throwWord = searchVocabulary(
				"errors","throw");
			if(throwWord == null)
				throw new NullPointerException();
			eval(throwWord);
			return false;
		}
		catch(Throwable e2)
		{
			System.err.println("Exception when calling throw:");
			e.printStackTrace();
			topLevel();

			return true;
		}
	} //}}}

	//{{{ createCompiledCallframe() method
	private Cons createCompiledCallframe(FactorWord word)
	{
		return new Cons(new FactorWord(null,"#<compiled>"),word);
	} //}}}

	//{{{ compiledException() method
	/**
	 * Called by compiled words to give the user a meaningful call stack
	 * trace in the case of an exception.
	 */
	public void compiledException(FactorWord word, Throwable t)
	{
		compiledExceptions = new Cons(createCompiledCallframe(word),
			this.compiledExceptions);
	} //}}}

	//{{{ call() method
	/**
	 * Pushes the given list of code onto the callstack.
	 */
	public void call(Cons code)
	{
		// tail call optimization
		if(callframe != null)
			callstack.push(callframe);

		callframe = code;
	} //}}}

	//{{{ eval() method
	/**
	 * Evaluates a word.
	 */
	public void eval(Object obj) throws Exception
	{
		if(obj instanceof FactorWord)
		{
			try
			{
				FactorWordDefinition d = ((FactorWord)obj).def;
				if(d == null)
				{
					throw new FactorUndefinedWordException(
						((FactorWord)obj).name);
				}
				else
					d.eval(this);
			}
			catch(Exception e)
			{
				callstack.push(callframe);
				/* callframe = createCompiledCallframe(
					(FactorWord)obj); */
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

	//{{{ getVariable() method
	/**
	 * Return the value of a variable, by searching the namestack
	 * in order.
	 */
	public Object getVariable(String name) throws Exception
	{
		for(int i = namestack.top - 1; i >= 0; i--)
		{
			FactorNamespace namespace = FactorJava.toNamespace(
				namestack.stack[i]);
			if(namespace.isDefined(name))
				return namespace.getVariable(name);
		}

		return null;
	} //}}}

	//{{{ isUninterned() method
	/**
	 * Words whose name begin with #: but are not #: themselves are not
	 * in any vocabulary.
	 */
	public static boolean isUninterned(String name)
	{
		return (name.startsWith("#:") && name.length() > 2);
	} //}}}

	//{{{ getVocabulary() method
	public FactorNamespace getVocabulary(String name)
		throws Exception
	{
		Object value = vocabularies.getVariable(name);
		if(value instanceof FactorNamespace)
			return (FactorNamespace)value;
		else
			return null;
	} //}}}

	//{{{ defineVocabulary() method
	public void defineVocabulary(String name)
		throws Exception
	{
		Object value = vocabularies.getVariable(name);
		if(value == null)
		{
			value = new FactorNamespace();
			vocabularies.setVariable(name,value);
		}
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search in the given vocabulary for the given word.
	 */
	public FactorWord searchVocabulary(String vname, String name)
	{
		if(isUninterned(name))
			return new FactorWord(null,name);

		try
		{
			FactorNamespace v = getVocabulary(vname);
			if(v != null)
			{
				Object word = v.getVariable(name);
				if(word instanceof FactorWord)
					return (FactorWord)word;
				else
					return null;
			}
			else
				return null;
		}
		catch(Exception e)
		{
			// should not happen!
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ searchVocabulary() method
	/**
	 * Search through the given vocabulary list for the given word.
	 */
	public FactorWord searchVocabulary(Cons vocabulary, String name)
	{
		if(isUninterned(name))
			return new FactorWord(null,name);

		while(vocabulary != null)
		{
			FactorWord word = searchVocabulary(
				(String)vocabulary.car,name);
			if(word != null)
				return word;

			vocabulary = vocabulary.next();
		}

		return null;
	} //}}}

	//{{{ define() method
	/**
	 * Define a word in the given vocabulary if it doesn't exist already.
	 */
	public FactorWord define(String vocabulary, String name)
	{
		if(isUninterned(name))
			return new FactorWord(null,name);

		try
		{
			FactorNamespace v = getVocabulary(vocabulary);
			if(v == null)
			{
				v = new FactorNamespace();
				vocabularies.setVariable(vocabulary,v);
			}
			Object value = v.getVariable(name);
			if(value instanceof FactorWord)
				return (FactorWord)value;
			else
			{
				// save to same workspace as vocabulary,
				// or no workspace if vocabulary is builtins
				FactorWord word = new FactorWord(
					vocabulary,name,null);
				v.setVariable(name,word);
				return word;
			}
		}
		catch(Exception e)
		{
			// should not happen!
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
		namestack.top = 0;
		namestack.push(global);
		catchstack.top = 0;
		// DEFER: the word
		define("kernel","exit*");
		catchstack.push(new Cons(new Integer(1),
			new Cons(searchVocabulary("kernel","exit*"),null)));
		define("errors","default-error-handler");
		catchstack.push(new Cons(searchVocabulary("errors",
			"default-error-handler"),null));
		callframe = null;
	} //}}}
}
