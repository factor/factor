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
import java.util.*;
import org.objectweb.asm.*;

/**
 * A word definition.
 */
public abstract class FactorWordDefinition implements Constants
{
	public final FactorWord word;

	public boolean compileFailed;

	public FactorWordDefinition(FactorWord word)
	{
		this.word = word;
	}

	public abstract void eval(FactorInterpreter interp)
		throws Exception;

	//{{{ toList() method
	public Cons toList(FactorInterpreter interp)
	{
		return new Cons(new FactorWord(getClass().getName()),null);
	} //}}}

	//{{{ getStackEffect() method
	public final StackEffect getStackEffect() throws Exception
	{
		return getStackEffect(new RecursiveState());
	} //}}}

	//{{{ getStackEffect() method
	public final StackEffect getStackEffect(RecursiveState recursiveCheck)
		throws Exception
	{
		FactorCompiler compiler = new FactorCompiler();
		recursiveCheck.add(word,new StackEffect(),null,null);
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
	public int compileCallTo(CodeVisitor mw, FactorCompiler compiler,
		RecursiveState recursiveCheck) throws Exception
	{
		// normal word
		String defclass;
		String defmethod;
		StackEffect effect;

		RecursiveForm rec = recursiveCheck.get(word);
		if(rec != null && rec.active)
		{
			effect = StackEffect.decompose(rec.effect,rec.baseCase);

			// are we recursing back on a form inside the current
			// method?
			RecursiveForm last = recursiveCheck.last();
			if(rec.tail
				&& last.className.equals(rec.className)
				&& last.method.equals(rec.method))
			{
				// GOTO instad of INVOKEVIRTUAL; ie a loop!
				int max = compiler.normalizeStacks(mw);
				mw.visitJumpInsn(GOTO,rec.label);
				compiler.apply(effect);
				return max;
			}

			/* recursive method call! */
			defclass = rec.className;
			defmethod = rec.method;
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
			return compileImmediate(mw,compiler,recursiveCheck);
		}
		/* ordinary method call! */
		else
		{
			defclass = getClass().getName()
				.replace('.','/');
			defmethod = "core";
			effect = getStackEffect();
		}

		mw.visitVarInsn(ALOAD,0);

		compiler.generateArgs(mw,effect.inD,effect.inR,null);

		String signature = effect.getCorePrototype();

		mw.visitMethodInsn(INVOKESTATIC,defclass,defmethod,signature);

		compiler.generateReturn(mw,effect.outD,effect.outR);

		return effect.inD + effect.inR + 1;
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileImmediate(CodeVisitor mw, FactorCompiler compiler,
		RecursiveState recursiveCheck) throws Exception
	{
		Cons definition = toList(compiler.getInterpreter());

		if(definition == null)
			return 0;

		Cons endOfDocs = definition;
		while(endOfDocs != null
			&& endOfDocs.car instanceof FactorDocComment)
			endOfDocs = endOfDocs.next();

		// determine stack effect of this instantiation, and if its
		// recursive.

		FactorDataStack savedDatastack = (FactorDataStack)
			compiler.datastack.clone();
		FactorCallStack savedCallstack = (FactorCallStack)
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

		FactorDataStack afterDatastack = (FactorDataStack)
			compiler.datastack.clone();
		FactorCallStack afterCallstack = (FactorCallStack)
			compiler.callstack.clone();

		compiler.datastack = (FactorDataStack)savedDatastack.clone();
		compiler.callstack = (FactorCallStack)savedCallstack.clone();
		compiler.effect = savedEffect;

		if(!recursive)
		{
			// not recursive; inline.
			mw.visitLabel(recursiveCheck.last().label);
			return compiler.compile(endOfDocs,mw,recursiveCheck);
		}
		else
		{
			// recursive; must generate auxiliary method.
			String method = compiler.auxiliary(word.name,
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

			mergeStacks(savedDatastack,afterDatastack,compiler.datastack);
			mergeStacks(savedCallstack,afterCallstack,compiler.callstack);

			return immediateEffect.inD + immediateEffect.inR + 1;
		}
	} //}}}

	//{{{ mergeStacks() method
	private void mergeStacks(FactorArrayStack s1, FactorArrayStack s2,
		FactorArrayStack into)
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
