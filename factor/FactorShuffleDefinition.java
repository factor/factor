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
import java.util.Map;
import org.objectweb.asm.*;
import org.objectweb.asm.util.*;

/**
 * ~<< name ... -- >>~
 */
public class FactorShuffleDefinition extends FactorWordDefinition
{
	public static final int FROM_R_MASK = (1<<15);
	public static final int TO_R_MASK = (1<<16);
	public static final int SPECIFIER = FROM_R_MASK | TO_R_MASK;

	/**
	 * Elements to consume from stacks.
	 */
	private int consumeD;
	private int consumeR;

	/**
	 * Permutation for elements on stack.
	 */
	private int[] shuffleD;
	private int shuffleDstart;
	private int shuffleDlength;
	private int[] shuffleR;
	private int shuffleRstart;
	private int shuffleRlength;

	/**
	 * This is not thread-safe!
	 */
	private Object[] temporaryD;
	private Object[] temporaryR;

	//{{{ FactorShuffleDefinition constructor
	public FactorShuffleDefinition(FactorWord word,
		int consumeD, int consumeR,
		int[] shuffleD, int shuffleDlength,
		int[] shuffleR, int shuffleRlength)
	{
		super(word);

		this.consumeD = consumeD;
		this.consumeR = consumeR;
		this.shuffleD = shuffleD;
		this.shuffleDlength = shuffleDlength;
		this.shuffleR = shuffleR;
		this.shuffleRlength = shuffleRlength;

		if(this.shuffleD != null && this.shuffleDlength == 0)
			this.shuffleD = null;
		if(this.shuffleR != null && this.shuffleRlength == 0)
			this.shuffleR = null;
		if(this.shuffleD != null)
		{
			temporaryD = new Object[shuffleDlength];
			for(int i = 0; i < shuffleDlength; i++)
			{
				if(shuffleD[i] == i)
					shuffleDstart++;
				else
					break;
			}
		}
		if(this.shuffleR != null)
		{
			temporaryR = new Object[shuffleRlength];
			for(int i = 0; i < shuffleRlength; i++)
			{
				if(shuffleR[i] == (i | FROM_R_MASK))
					shuffleRstart++;
				else
					break;
			}
		}
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler state) throws FactorStackException
	{
		state.ensure(state.datastack,consumeD);
		state.ensure(state.callstack,consumeR);
		eval(state.datastack,state.callstack);
	} //}}}

	//{{{ compile() method
	/**
	 * Compile the given word, returning a new word definition.
	 */
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
		RecursiveState recursiveCheck) throws FactorStackException
	{
		eval(compiler.datastack,compiler.callstack);
		return 0;
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws FactorStackException
	{
		eval(interp.datastack,interp.callstack);
	} //}}}

	//{{{ eval() method
	public void eval(FactorArrayStack datastack, FactorArrayStack callstack)
		throws FactorStackException
	{
		if(datastack.top < consumeD)
			throw new FactorStackException(consumeD);

		if(callstack.top < consumeR)
			throw new FactorStackException(consumeR);

		if(shuffleD != null)
		{
			shuffle(datastack,callstack,datastack,consumeD,consumeR,
				shuffleD,temporaryD);
		}

		if(shuffleR != null)
		{
			shuffle(datastack,callstack,callstack,consumeD,consumeR,
				shuffleR,temporaryR);
		}

		datastack.top -= consumeD;
		if(temporaryD != null)
			datastack.pushAll(temporaryD);

		callstack.top -= consumeR;
		if(temporaryR != null)
			callstack.pushAll(temporaryR);

	} //}}}

	//{{{ shuffle() method
	private void shuffle(
		FactorArrayStack datastack,
		FactorArrayStack callstack,
		FactorArrayStack stack,
		int consumeD,
		int consumeR,
		int[] shuffle,
		Object[] temporary)
		throws FactorStackException
	{
		for(int i = 0; i < temporary.length; i++)
		{
			Object[] array;
			int top;
			int index = shuffle[i];
			int consume;
			if((index & FROM_R_MASK) == FROM_R_MASK)
			{
				array = callstack.stack;
				top = callstack.top;
				index = (index & ~FROM_R_MASK);
				consume = consumeR;
			}
			else
			{
				array = datastack.stack;
				top = datastack.top;
				consume = consumeD;
			}
			temporary[i] = array[top - consume + index];
		}
	} //}}}

	//{{{ toList() method
	public Cons toList()
	{
		return new Cons(word,new Cons(
			new FactorWord(toString()),null));
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		StringBuffer buf = new StringBuffer();

		for(int i = 0; i < consumeD; i++)
		{
			buf.append((char)('A' + i));
			buf.append(' ');
		}

		for(int i = 0; i < consumeR; i++)
		{
			buf.append("r:");
			buf.append((char)('A' + i));
			buf.append(' ');
		}

		buf.append("--");

		if(shuffleD != null)
		{
			for(int i = 0; i < shuffleDlength; i++)
			{
				int index = shuffleD[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
					index &= ~FROM_R_MASK;
				buf.append(' ');
				buf.append((char)('A' + index));
			}
		}

		if(shuffleR != null)
		{
			for(int i = 0; i < shuffleRlength; i++)
			{
				int index = shuffleR[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
					index &= ~FROM_R_MASK;
				buf.append(" r:");
				buf.append((char)('A' + index));
			}
		}

		return buf.toString();
	} //}}}
}
