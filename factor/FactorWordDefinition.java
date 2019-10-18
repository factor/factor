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

import factor.compiler.*;
import java.io.*;
import java.util.*;
import org.objectweb.asm.*;

/**
 * A word definition.
 */
public abstract class FactorWordDefinition implements Constants
{
	public FactorWord word;
	public boolean compileFailed;

	//{{{ FactorWordDefinition constructor
	/**
	 * A new definition.
	 */
	public FactorWordDefinition(FactorWord word)
	{
		this.word = word;
	} //}}}

	public abstract void eval(FactorInterpreter interp)
		throws Exception;
	
	//{{{ fromList() method
	public void fromList(Cons cons, FactorInterpreter interp)
		throws FactorRuntimeException
	{
		throw new FactorRuntimeException("Cannot unpickle " + this);
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
		recursiveCheck.add(word,new StackEffect(),null,null,null);
		getStackEffect(recursiveCheck,compiler);
		recursiveCheck.remove(word);
		return compiler.getStackEffect();
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler compiler) throws Exception
	{
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

	//{{{ toString() method
	public String toString()
	{
		return getClass().getName() + ": " + word;
	} //}}}
}
