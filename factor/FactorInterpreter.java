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

import factor.db.*;
import factor.parser.*;
import factor.primitives.*;
import java.io.*;

public class FactorInterpreter implements FactorObject, Runnable
{
	public static final String VERSION = "0.60.6";

	// we need to call two words (boot and break) from the kernel
	// vocabulary
	private static final String KERNEL_VOCAB = "kernel";

	// command line arguments are stored here.
	public Cons args;

	// boot.factor sets these.
	public boolean interactive = true;
	public boolean errorFlag = false;
	public Throwable error;
	public boolean dump = false;
	public boolean verboseCompile = false;
	public boolean firstTime = false;
	public boolean mini = false;

	public Cons callframe;
	public FactorArray callstack = new FactorArray();
	public FactorArray datastack = new FactorArray();
	public FactorArray namestack = new FactorArray();

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

	/**
	 * Persistent store, maybe null.
	 */
	public Workspace workspace;

	public FactorNamespace global;

	private FactorNamespace interpNamespace;

	private Cons compiledExceptions;

	//{{{ main() method
	public static void main(String[] args) throws Exception
	{
		FactorInterpreter interp = new FactorInterpreter();
		interp.init(args,null);
		interp.run();
		if(interp.workspace != null)
			interp.workspace.close();
	} //}}}

	//{{{ init() method
	public void init(FactorInterpreter interp) throws Exception
	{
		this.args = interp.args;
		this.interactive = interp.interactive;
		this.dump = interp.dump;
		this.verboseCompile = interp.verboseCompile;
		this.firstTime = firstTime;
		this.callframe = interp.callframe;
		this.callstack = (FactorArray)interp.callstack.clone();
		this.datastack = (FactorArray)interp.datastack.clone();
		this.namestack = (FactorArray)interp.namestack.clone();
		this.vocabularies = interp.vocabularies;
		this.use = interp.use;
		this.in = interp.in;
		this.builtins = interp.builtins;
		this.last = interp.last;
		this.workspace = interp.workspace;
		this.global = interp.global;
	} //}}}

	//{{{ init() method
	public void init(String[] args, Object root) throws Exception
	{
		for(int i = 0; i < args.length; i++)
		{
			String arg = args[i];
			if(arg.equals("-no-db"))
			{
				workspace = null;
				args[i] = null;
			}
			else if(arg.equals("-db"))
			{
				if(workspace != null)
					workspace.close();
				workspace = new Workspace(
					new BTreeStore(new File("factor.db"),
					(byte)64,false),false,this);
			}
			else if(arg.startsWith("-db:"))
			{
				if(workspace != null)
					workspace.close();
				workspace = parseDBSpec(arg.substring(4));
				args[i] = null;
			}
			// this switch forces a first time init
			else if(arg.equals("-no-first-time"))
			{
				firstTime = false;
				args[i] = null;
			}
			else if(arg.equals("-first-time"))
			{
				firstTime = true;
				args[i] = null;
			}
			// this switch forces minimal libraries to be loaded
			else if(arg.equals("-no-mini"))
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

		vocabularies = new Table(workspace);
		initBuiltinDictionary();
		initNamespace(root);
		topLevel();

		runBootstrap();
	} //}}}

	//{{{ parseDBSpec() method
	private Workspace parseDBSpec(String db) throws Exception
	{
		int index = db.indexOf(':');
		String className = db.substring(0,index);

		String arg = db.substring(index + 1);

		boolean readOnly;
		if(arg.startsWith("ro:"))
		{
			readOnly = true;
			arg = arg.substring(3);
		}
		else
			readOnly = false;

		Class[] consArgClasses = new Class[] { String.class };
		Object[] consArgs = new Object[] { arg };

		return new Workspace((Store)Class.forName(className)
			.getConstructor(consArgClasses)
			.newInstance(consArgs),readOnly,this);
	} //}}}

	//{{{ initBuiltinDictionary() method
	private void initBuiltinDictionary() throws Exception
	{
		builtins = new Table(null);
		vocabularies.setVariable("builtins",builtins);

		in = "builtins";
		use = new Cons(in,null);

		// parsing words
		FactorWord lineComment = define("builtins","!");
		lineComment.parsing = new LineComment(lineComment,false,null);
		FactorWord stackComment = define("builtins","(");
		stackComment.parsing = new StackComment(stackComment,null);
		FactorWord str = define("builtins","\"");
		str.parsing = new StringLiteral(str,true,null);
		FactorWord t = define("builtins","t");
		t.parsing = new T(t,null);
		FactorWord f = define("builtins","f");
		f.parsing = new F(f,null);
		FactorWord bra = define("builtins","[");
		bra.parsing = new Bra(bra,null);
		FactorWord ket = define("builtins","]");
		ket.parsing = new Ket(bra,ket,null);
		FactorWord bar = define("builtins","|");
		bar.parsing = new Bar(bar,null);
		FactorWord def = define("builtins",":");
		def.parsing = new Def(def,null);
		def.getNamespace().setVariable("doc-comments",Boolean.TRUE);
		FactorWord ine = define("builtins",";");
		ine.parsing = new Ine(def,ine,null);
		FactorWord shuffle = define("builtins","~<<");
		shuffle.parsing = new Shuffle(shuffle,">>~",null);

		FactorWord noParsing = define("builtins","POSTPONE:");
		noParsing.parsing = new NoParsing(noParsing,null);

		// #X
		FactorWord dispatch = define("builtins","#");
		dispatch.parsing = new Dispatch(dispatch,null);
		FactorWord getPersistentObject = define("builtins","#O");
		getPersistentObject.parsing = new GetPersistentObject(
			getPersistentObject,null);
		FactorWord ch = define("builtins","#\\");
		ch.parsing = new CharLiteral(ch,null);
		FactorWord raw = define("builtins","#\"");
		raw.parsing = new StringLiteral(raw,false,null);
		FactorWord complex = define("builtins","#{");
		complex.parsing = new ComplexLiteral(complex,"}",null);
		FactorWord docComment = define("builtins","#!");
		docComment.parsing = new LineComment(docComment,true,null);
		FactorWord unreadable = define("builtins","#<");
		unreadable.parsing = new Unreadable(unreadable,null);

		// #: is not handled with a special dispatch. instead, when
		// a word starting with #: is passed to intern(), it creates
		// a new symbol
		FactorWord passthru = define("builtins","#:");
		passthru.parsing = new PassThrough(passthru,null);

		// vocabulary parsing words
		FactorWord defer = define("builtins","DEFER:");
		defer.parsing = new Defer(defer,null);
		FactorWord in = define("builtins","IN:");
		in.parsing = new In(in,null);
		FactorWord use = define("builtins","USE:");
		use.parsing = new Use(use,null);

		FactorWord interpreterGet = define("builtins","interpreter");
		interpreterGet.def = new InterpreterGet(interpreterGet,null);
		interpreterGet.inline = true;

		// reading numbers with another base
		FactorWord bin = define("builtins","BIN:");
		bin.parsing = new Base(defer,null,2);
		FactorWord oct = define("builtins","OCT:");
		oct.parsing = new Base(defer,null,8);
		FactorWord hex = define("builtins","HEX:");
		hex.parsing = new Base(defer,null,16);

		// primitives used by 'expand' and 'map'
		FactorWord restack = define("builtins","restack");
		restack.def = new Restack(restack,null);
		FactorWord unstack = define("builtins","unstack");
		unstack.def = new Unstack(unstack,null);

		// reflection primitives
		FactorWord jinvoke = define("builtins","jinvoke");
		jinvoke.def = new JInvoke(jinvoke,null,false);
		jinvoke.inline = true;
		FactorWord jinvokeStatic = define("builtins","jinvoke-static");
		jinvokeStatic.def = new JInvoke(jinvokeStatic,null,true);
		jinvokeStatic.inline = true;
		FactorWord jnew = define("builtins","jnew");
		jnew.def = new JNew(jnew,null);
		jnew.inline = true;
		FactorWord jvarGet = define("builtins","jvar-get");
		jvarGet.def = new JVarGet(jvarGet,null);
		jvarGet.inline = true;
		FactorWord jvarGetStatic = define("builtins","jvar-static-get");
		jvarGetStatic.def = new JVarGetStatic(jvarGetStatic,null);
		jvarGetStatic.inline = true;
		FactorWord jvarSet = define("builtins","jvar-set");
		jvarSet.def = new JVarSet(jvarSet,null);
		jvarSet.inline = true;
		FactorWord jvarSetStatic = define("builtins","jvar-static-set");
		jvarSetStatic.def = new JVarSetStatic(jvarSetStatic,null);
		jvarSetStatic.inline = true;
		FactorWord coerce = define("builtins","coerce");
		coerce.def = new Coerce(coerce,null);
		coerce.inline = true;

		// definition
		FactorWord define = define("builtins","define");
		define.def = new Define(define,null);

		// combinators
		FactorWord execute = define("builtins","execute");
		execute.def = new Execute(execute,null);
		FactorWord call = define("builtins","call");
		call.def = new Call(call,null);
		call.inline = true;
		FactorWord ifte = define("builtins","ifte");
		ifte.def = new Ifte(ifte,null);
		ifte.inline = true;
	} //}}}

	//{{{ initNamespace() method
	private void initNamespace(Object root) throws Exception
	{
		if(workspace == null)
			global = new FactorNamespace(null,root);
		else
			global = workspace.getRoot();

		global.setVariable("interpreter",this);

		global.setVariable("error-flag",
			new FactorNamespace.VarBinding(
				getClass().getField("errorFlag"),
				this));

		global.setVariable("verbose-compile",
			new FactorNamespace.VarBinding(
				getClass().getField("verboseCompile"),
				this));

		global.setVariable("global",
			new FactorNamespace.VarBinding(
				getClass().getField("global"),
				this));

		FactorNamespace newVocabs;
		try
		{
			Object obj = global.getVariable("vocabularies");
			if(!(obj instanceof FactorNamespace))
				newVocabs = new Table(workspace);
			else
				newVocabs = (FactorNamespace)obj;
		}
		catch(Exception e)
		{
			System.err.println("Vocabularies table corrupt: " + e);
			newVocabs = new Table(workspace);
		}

		vocabularies = newVocabs;

		global.setVariable("vocabularies",
			new FactorNamespace.VarBinding(
				getClass().getField("vocabularies"),
				this));

		// Shouldn't have to do this twice!
		initBuiltinDictionary();

		String[] boundFields = {
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
		if(workspace == null || workspace.isFirstTime()
			|| firstTime)
		{
			if(workspace != null)
				workspace.setFirstTime(false);
			String initFile = "/library/platform/jvm/boot.factor";
			FactorReader parser = new FactorReader(
				initFile,
				new BufferedReader(
				new InputStreamReader(
				getClass().getResourceAsStream(
				initFile))),
				this);

			call(parser.parse());
		}
		else
			eval(searchVocabulary(KERNEL_VOCAB,"boot"));

		//XXX messy

		run();
		if(errorFlag)
			run();

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
		if(errorFlag)
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
				eval(searchVocabulary(KERNEL_VOCAB,"break"));
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
				callframe = createCompiledCallframe(
					(FactorWord)obj);
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
			value = new Table(workspace);
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
				v = new Table(workspace);
				vocabularies.setVariable(vocabulary,v);
			}
			Object value = v.getVariable(name);
			if(value instanceof FactorWord)
				return (FactorWord)value;
			else
			{
				Workspace workspace;
				if(v instanceof PersistentObject)
				{
					workspace = ((PersistentObject)v)
						.getWorkspace();
				}
				else
					workspace = null;

				// save to same workspace as vocabulary,
				// or no workspace if vocabulary is builtins
				FactorWord word = new FactorWord(workspace,
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
		callframe = null;
	} //}}}
}
