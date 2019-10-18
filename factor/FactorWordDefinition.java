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
	protected FactorWord word;

	public boolean compileFailed;

	public FactorWordDefinition(FactorWord word)
	{
		this.word = word;
	}

	public abstract void eval(FactorInterpreter interp)
		throws Exception;

	//{{{ toList() method
	public Cons toList()
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
		recursiveCheck.add(word,new StackEffect());
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
		mw.visitVarInsn(ALOAD,0);

		String defclass;
		StackEffect effect;

		RecursiveForm rec = recursiveCheck.get(word);
		if(rec != null && rec.active && compiler.word == word)
		{
			// recursive call!
			defclass = compiler.className;
			effect = compiler.word.def.getStackEffect();
		}
		else if(this instanceof FactorCompoundDefinition)
		{
			throw new FactorCompilerException("You are an idiot!");
		}
		else
		{
			defclass = getClass().getName()
				.replace('.','/');
			effect = getStackEffect();
		}

		compiler.generateArgs(mw,effect.inD,null);

		String signature = effect.getCorePrototype();

		mw.visitMethodInsn(INVOKESTATIC,defclass,"core",signature);

		if(effect.outD == 0)
		{
			// do nothing
		}
		else if(effect.outD == 1)
		{
			compiler.push(mw);
		}
		else
		{
			// transfer from data stack to JVM locals
			FactorDataStack datastack = compiler.datastack;

			// allocate the appropriate number of locals
			compiler.produce(compiler.datastack,effect.outD);

			// store the datastack instance somewhere
			mw.visitVarInsn(ALOAD,0);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter",
				"datastack",
				"Lfactor/FactorDataStack;");
			int datastackLocal = compiler.allocate();
			mw.visitVarInsn(ASTORE,datastackLocal);

			// put all elements from the real datastack
			// into locals
			for(int i = 0; i < effect.outD; i++)
			{
				mw.visitVarInsn(ALOAD,datastackLocal);
				mw.visitMethodInsn(INVOKEVIRTUAL,
					"factor/FactorDataStack",
					"pop",
					"()Ljava/lang/Object;");

				Result destination = (Result)
					datastack.stack[
					datastack.top - i - 1];

				mw.visitVarInsn(ASTORE,destination.getLocal());
			}

		}

		return effect.inD + 1;
	} //}}}

	//{{{ compileImmediate() method
	/**
	 * Compile a call to this word. Returns maximum JVM stack use.
	 */
	public int compileImmediate(CodeVisitor mw, FactorCompiler compiler,
		RecursiveState recursiveCheck) throws Exception
	{
		throw new FactorCompilerException("Cannot compile " + word + " in immediate mode");
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return getClass().getName() + ": " + word;
	} //}}}
}
