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
import factor.compiler.*;
import java.io.*;
import java.util.*;
import org.objectweb.asm.*;

/**
 * A word definition.
 *
 * The pickled form is an unparsed list. The car of the list is the word,
 * the cdr is toList().
 */
public abstract class FactorWordDefinition
	implements Constants, PersistentObject
{
	public static final String ENCODING = "UTF8";

	private String unparsed;
	private boolean initialized;

	private Workspace workspace;
	private long id;

	protected FactorWord word;

	public boolean compileFailed;

	//{{{ FactorWordDefinition constructor
	/**
	 * A new definition.
	 */
	public FactorWordDefinition(FactorWord word, Workspace workspace)
	{
		this(workspace,workspace == null
			? 0L : workspace.nextID());
		this.word = word;
		initialized = true;
	} //}}}

	//{{{ FactorWordDefinition constructor
	/**
	 * A blank definition, about to be unpickled.
	 */
	public FactorWordDefinition(Workspace workspace, long id)
	{
		this.workspace = workspace;
		this.id = id;
	} //}}}

	//{{{ FactorWordDefinition constructor
	/**
	 * A definition that is not saved in the current workspace.
	 */
	public FactorWordDefinition(FactorWord word)
	{
		this.word = word;
		initialized = true;
	} //}}}

	public abstract void eval(FactorInterpreter interp)
		throws Exception;
	
	//{{{ getWord() method
	public FactorWord getWord(FactorInterpreter interp)
	{
		lazyInit(interp);
		return word;
	} //}}}
	
	//{{{ fromList() method
	public void fromList(Cons cons, FactorInterpreter interp)
		throws FactorRuntimeException, PersistenceException
	{
		throw new PersistenceException("Cannot unpickle " + this);
	} //}}}

	//{{{ toList() method
	public Cons toList(FactorInterpreter interp)
	{
		return new Cons(new FactorWord(null,getClass().getName()),null);
	} //}}}

	//{{{ getStackEffect() method
	public final StackEffect getStackEffect(FactorInterpreter interp)
		throws Exception
	{
		return getStackEffect(new RecursiveState(),interp);
	} //}}}

	//{{{ getStackEffect() method
	public final StackEffect getStackEffect(RecursiveState recursiveCheck,
		FactorInterpreter interp) throws Exception
	{
		FactorCompiler compiler = new FactorCompiler(interp);
		lazyInit(interp);
		recursiveCheck.add(word,new StackEffect(),null,null,null);
		getStackEffect(recursiveCheck,compiler);
		recursiveCheck.remove(word);
		return compiler.getStackEffect();
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler compiler) throws Exception
	{
		lazyInit(compiler.interp);
		throw new FactorCompilerException("Cannot deduce stack effect of " + word);
	} //}}}

	//{{{ compile() method
	FactorWordDefinition compile(FactorInterpreter interp,
		RecursiveState recursiveCheck) throws Exception
	{
		return this;
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public void compileCallTo(CodeVisitor mw, FactorCompiler compiler,
		RecursiveState recursiveCheck) throws Exception
	{
		lazyInit(compiler.interp);
		
		// normal word
		String defclass;
		String defmethod;
		StackEffect effect;

		FactorClassLoader loader;

		RecursiveForm rec = recursiveCheck.get(word);
		if(rec != null && rec.active)
		{
			if(compiler.interp.verboseCompile)
				System.err.println("Recursive call to " + rec);
			effect = StackEffect.decompose(rec.effect,rec.baseCase);

			// are we recursing back on a form inside the current
			// method?
			RecursiveForm last = recursiveCheck.last();
			if(recursiveCheck.allTails(rec)
				&& last.className.equals(rec.className)
				&& last.method.equals(rec.method))
			{
				if(compiler.interp.verboseCompile)
					System.err.println(word + " is tail recursive");
				// GOTO instad of INVOKEVIRTUAL; ie a loop!
				compiler.normalizeStacks(mw);
				mw.visitJumpInsn(GOTO,rec.label);
				compiler.apply(effect);
				return;
			}

			/* recursive method call! */
			defclass = rec.className;
			defmethod = rec.method;
			loader = rec.loader;

			if(!defclass.equals(compiler.className))
				compiler.loader.addDependency(defclass,loader);
		}
		// not a recursive call but we're still not compiled
		// its a bug in the compiler.
		else if(this instanceof FactorCompoundDefinition)
		{
			throw new FactorCompilerException("You are an idiot!");
		}
		// inlining?
		else if(word.inline)
		{
			compileImmediate(mw,compiler,recursiveCheck);
			return;
		}
		/* ordinary method call! */
		else
		{
			defclass = getClass().getName().replace('.','/');
			defmethod = "core";
			effect = getStackEffect(compiler.interp);
			ClassLoader l = getClass().getClassLoader();
			if(l instanceof FactorClassLoader)
			{
				loader = (FactorClassLoader)l;
				compiler.loader.addDependency(getClass().getName(),loader);
			}
			else
				loader = null;
		}

		mw.visitVarInsn(ALOAD,0);

		compiler.generateArgs(mw,effect.inD,effect.inR,null);

		String signature = effect.getCorePrototype();

		mw.visitMethodInsn(INVOKESTATIC,defclass,defmethod,signature);

		compiler.generateReturn(mw,effect.outD,effect.outR);
	} //}}}

	//{{{ compileNonRecursiveImmediate() method
	/**
	 * Non-recursive immediate words are inlined.
	 */
	protected void compileNonRecursiveImmediate(CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck,
		StackEffect immediateEffect) throws Exception
	{
		Cons definition = toList(compiler.getInterpreter());

		Cons endOfDocs = definition;
		while(endOfDocs != null
			&& endOfDocs.car instanceof FactorDocComment)
			endOfDocs = endOfDocs.next();

		compiler.compile(endOfDocs,mw,recursiveCheck);
	} //}}}

	//{{{ compileRecursiveImmediate() method
	/**
	 * Recursive immediate words are compiled to an auxiliary method
	 * inside the compiled class definition.
	 *
	 * This must be done so that recursion has something to jump to.
	 */
	protected void compileRecursiveImmediate(CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck,
		StackEffect immediateEffect) throws Exception
	{
		lazyInit(compiler.interp);
		
		Cons definition = toList(compiler.getInterpreter());

		Cons endOfDocs = definition;
		while(endOfDocs != null
			&& endOfDocs.car instanceof FactorDocComment)
			endOfDocs = endOfDocs.next();

		String method = compiler.auxiliary(word,
			endOfDocs,immediateEffect,recursiveCheck);

		mw.visitVarInsn(ALOAD,0);

		compiler.generateArgs(mw,immediateEffect.inD,
			immediateEffect.inR,null);

		String signature = immediateEffect.getCorePrototype();

		mw.visitMethodInsn(INVOKESTATIC,compiler.className,
			method,signature);

		compiler.generateReturn(mw,
			immediateEffect.outD,
			immediateEffect.outR);
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public void compileImmediate(CodeVisitor mw, FactorCompiler compiler,
		RecursiveState recursiveCheck) throws Exception
	{
		Cons definition = toList(compiler.getInterpreter());

		if(definition == null)
			return;

		Cons endOfDocs = definition;
		while(endOfDocs != null
			&& endOfDocs.car instanceof FactorDocComment)
			endOfDocs = endOfDocs.next();

		// determine stack effect of this instantiation, and if its
		// recursive.

		FactorArray savedDatastack = (FactorArray)
			compiler.datastack.clone();
		FactorArray savedCallstack = (FactorArray)
			compiler.callstack.clone();
		StackEffect savedEffect = compiler.getStackEffect();

		RecursiveState _recursiveCheck = (RecursiveState)
			recursiveCheck.clone();
		_recursiveCheck.last().effect = compiler.getStackEffect();
		getStackEffect(_recursiveCheck,compiler);

		boolean recursive = (_recursiveCheck.last().baseCase != null);

		StackEffect effect = compiler.getStackEffect();

		StackEffect immediateEffect = StackEffect.decompose(
			savedEffect,compiler.getStackEffect());

		// restore previous state.

		FactorArray afterDatastack = (FactorArray)
			compiler.datastack.clone();
		FactorArray afterCallstack = (FactorArray)
			compiler.callstack.clone();

		compiler.datastack = (FactorArray)savedDatastack.clone();
		compiler.callstack = (FactorArray)savedCallstack.clone();
		compiler.effect = savedEffect;

		if(!recursive)
		{
			// not recursive; inline.
			compileNonRecursiveImmediate(mw,compiler,recursiveCheck,
				immediateEffect);
		}
		else
		{
			// recursive; must generate auxiliary method.
			compileRecursiveImmediate(mw,compiler,recursiveCheck,
				immediateEffect);

			mergeStacks(savedDatastack,afterDatastack,compiler.datastack);
			mergeStacks(savedCallstack,afterCallstack,compiler.callstack);
		}
	} //}}}

	//{{{ mergeStacks() method
	private void mergeStacks(FactorArray s1, FactorArray s2,
		FactorArray into)
	{
		for(int i = 0; i < s2.top; i++)
		{
			if(s1.top <= i)
				break;

			if(FactorLib.objectsEqual(s1.stack[i],
				s2.stack[i]))
			{
				into.stack[i] = s1.stack[i];
			}
		}
	} //}}}

	//{{{ getWorkspace() method
	/**
	 * Each persistent object is stored in one workspace only.
	 */
	public Workspace getWorkspace()
	{
		return workspace;
	} //}}}

	//{{{ getID() method
	/**
	 * Each persistent object has an associated ID.
	 */
	public long getID()
	{
		return id;
	} //}}}

	//{{{ lazyInit() method
	public synchronized void lazyInit(FactorInterpreter interp)
	{
		if(initialized)
			return;

		initialized = true;

		try
		{
			Cons pickle = (Cons)FactorReader.parseObject(
				unparsed,interp);
			word = (FactorWord)pickle.car;
			//System.err.println(word + " unpickled");
			fromList(pickle.next(),interp);
		}
		catch(Exception e)
		{
			// should not happen with byte array stream
			throw new RuntimeException("Unexpected error",e);
		}
	} //}}}

	//{{{ pickle() method
	/**
	 * Each persistent object can turn itself into a byte array.
	 */
	public byte[] pickle()
		throws PersistenceException
	{
		try
		{
			ByteArrayOutputStream bytes = new ByteArrayOutputStream();

			Cons pickle = new Cons(word,toList(
				workspace.getInterpreter()));
			bytes.write((FactorReader.getVocabularyDeclaration(pickle)
				+ FactorReader.unparseDBObject(pickle))
				.getBytes(ENCODING));

			return bytes.toByteArray();
		}
		catch(Exception e)
		{
			// should not happen with byte array stream
			throw new PersistenceException("Unexpected error",e);
		}
	} //}}}

	//{{{ unpickle() method
	/**
	 * Each persistent object can set its state to that in a byte array.
	 */
	public void unpickle(byte[] bytes, int offset)
		throws PersistenceException
	{
		try
		{
			unparsed = new String(bytes,offset,
				bytes.length - offset,ENCODING);
		}
		catch(Exception e)
		{
			// should not happen with byte array stream
			throw new PersistenceException("Unexpected error",e);
		}
	} //}}}

	//{{{ getReferences() method
	public Cons getReferences()
	{
		return toList(workspace.getInterpreter());
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return getClass().getName() + ": " + word;
	} //}}}
}
