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

import org.objectweb.asm.*;

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
	public FactorShuffleDefinition(int consumeD, int consumeR,
		int[] shuffleD, int shuffleDlength,
		int[] shuffleR, int shuffleRlength)
	{
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

	//{{{ canCompile() method
	boolean canCompile()
	{
		return true;
	} //}}}

	//{{{ compile() method
	/**
	 * Write the definition of the eval() method in the compiled word.
	 * Local 0 -- this
	 * Local 1 -- word
	 * Local 2 -- interpreter
	 */
	boolean compile(FactorWord word, FactorInterpreter interp,
		ClassWriter cw, CodeVisitor mw)
		throws Exception
	{
		boolean fromD = false;
		boolean fromR = false;
		for(int i = 0; i < shuffleDlength; i++)
		{
			fromD = true;
			if((shuffleD[i] & FROM_R_MASK) == FROM_R_MASK)
			{
				fromR = true;
				break;
			}
		}
		for(int i = 0; i < shuffleRlength; i++)
		{
			fromR = true;
			if((shuffleR[i] & FROM_R_MASK) == FROM_R_MASK)
			{
				fromR = true;
				break;
			}
		}

		// Local 3 -- datastack
		// Local 4 -- datastack top-consumeD
		// Local 5 -- datastack array
		if(consumeD != 0 || fromD)
		{
			// (datastack datastack datastack)
			mw.visitVarInsn(ALOAD,2);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "datastack",
				"Lfactor/FactorDataStack;");
			mw.visitInsn(DUP);
			if(consumeD != 0)
			{
				mw.visitInsn(DUP);
				mw.visitIntInsn(BIPUSH,consumeD);
				mw.visitMethodInsn(INVOKEVIRTUAL,
					"factor/FactorArrayStack", "ensurePop",
					"(I)V");
			}

			mw.visitInsn(DUP);
			// datastack -> 3
			mw.visitVarInsn(ASTORE,3);
			// datastack.top-consumeD -> 4
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "top",
				"I");
			if(consumeD != 0)
			{
				mw.visitIntInsn(BIPUSH,consumeD);
				mw.visitInsn(ISUB);
			}
			mw.visitVarInsn(ISTORE,4);
			// datastack.stack -> 5
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,5);
		}

		// Local 6 -- callstack
		// Local 7 -- callstack top-consumeR
		// Local 8 -- callstack array
		if(consumeR != 0 || fromR)
		{
			// (callstack callstack)
			mw.visitVarInsn(ALOAD,2);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "callstack",
				"Lfactor/FactorCallStack;");
			mw.visitInsn(DUP);
			if(consumeR != 0)
			{
				mw.visitInsn(DUP);
				mw.visitIntInsn(BIPUSH,consumeR);
				mw.visitMethodInsn(INVOKEVIRTUAL,
					"factor/FactorArrayStack", "ensurePop",
					"(I)V");
			}

			mw.visitInsn(DUP);
			// callstack -> 6
			mw.visitVarInsn(ASTORE,6);
			// callstack.top-consumeR -> 7
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "top",
				"I");
			if(consumeR != 0)
			{
				mw.visitIntInsn(BIPUSH,consumeR);
				mw.visitInsn(ISUB);
			}
			mw.visitVarInsn(ISTORE,7);
			// callstack.stack -> 8
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,8);
		}

		int locals = 9;

		if(shuffleD != null)
		{
			for(int i = shuffleDstart; i < shuffleDlength; i++)
			{
				// stack[top-consumeD+shuffleD[i]] -> 9+i
				int index = shuffleD[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
				{
					mw.visitVarInsn(ALOAD,8);
					mw.visitVarInsn(ILOAD,7);
					index &= ~FROM_R_MASK;
				}
				else
				{
					mw.visitVarInsn(ALOAD,5);
					mw.visitVarInsn(ILOAD,4);
				}

				if(index != 0)
				{
					mw.visitIntInsn(BIPUSH,index);
					mw.visitInsn(IADD);
				}

				mw.visitInsn(AALOAD);
				mw.visitVarInsn(ASTORE,9 + i);
			}

			locals += shuffleDlength;
		}

		if(shuffleR != null)
		{
			for(int i = shuffleRstart; i < shuffleRlength; i++)
			{
				// stack[top-consumeR+shuffleR[i]] -> 9+i
				int index = shuffleR[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
				{
					mw.visitVarInsn(ALOAD,8);
					mw.visitVarInsn(ILOAD,7);
					index &= ~FROM_R_MASK;
				}
				else
				{
					mw.visitVarInsn(ALOAD,5);
					mw.visitVarInsn(ILOAD,4);
				}

				if(index != 0)
				{
					mw.visitIntInsn(BIPUSH,index);
					mw.visitInsn(IADD);
				}

				mw.visitInsn(AALOAD);
				mw.visitVarInsn(ASTORE,locals + i);
			}
		}

		if(shuffleD != null)
		{
			// ensure that the stack array has enough space.
			mw.visitVarInsn(ALOAD,3);
			mw.visitInsn(DUP);
			mw.visitIntInsn(BIPUSH,shuffleDlength);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "ensurePush", "(I)V");
			// the datastack.stack array might have changed.
			// reload it.
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,5);

			for(int i = shuffleDstart; i < shuffleDlength; i++)
			{
				// stack[top - consumeD + i] <- 9+i
				mw.visitVarInsn(ALOAD,5);
				mw.visitVarInsn(ILOAD,4);
				if(i != 0)
				{
					mw.visitIntInsn(BIPUSH,i);
					mw.visitInsn(IADD);
				}
				mw.visitVarInsn(ALOAD,9 + i);
				mw.visitInsn(AASTORE);
			}

			// increment the 'top' field.
			mw.visitVarInsn(ALOAD,3);
			mw.visitVarInsn(ILOAD,4);
			mw.visitIntInsn(BIPUSH,shuffleDlength);
			mw.visitInsn(IADD);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");
		}
		else if(consumeD != 0)
		{
			mw.visitVarInsn(ALOAD,3);
			mw.visitVarInsn(ILOAD,4);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");
		}

		if(shuffleR != null)
		{
			// ensure that the stack array has enough space.
			mw.visitVarInsn(ALOAD,6);
			mw.visitInsn(DUP);
			mw.visitIntInsn(BIPUSH,shuffleDlength);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArrayStack", "ensurePush", "(I)V");
			// the callstack.stack array might have changed.
			// reload it.
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArrayStack", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,8);

			for(int i = shuffleRstart; i < shuffleRlength; i++)
			{
				// stack[top - consumeD + i] <- locals+i
				mw.visitVarInsn(ALOAD,8);
				mw.visitVarInsn(ILOAD,7);
				if(i != 0)
				{
					mw.visitIntInsn(BIPUSH,i);
					mw.visitInsn(IADD);
				}
				mw.visitVarInsn(ALOAD,locals + i);
				mw.visitInsn(AASTORE);
			}

			// increment the 'top' field.
			mw.visitVarInsn(ALOAD,6);
			mw.visitVarInsn(ILOAD,7);
			mw.visitIntInsn(BIPUSH,shuffleRlength);
			mw.visitInsn(IADD);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");
		}
		else if(consumeR != 0)
		{
			mw.visitVarInsn(ALOAD,6);
			mw.visitVarInsn(ILOAD,7);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArrayStack", "top",
				"I");
		}

		mw.visitInsn(RETURN);

		// Max stack and locals
		mw.visitMaxs(4,9 + shuffleDlength + shuffleRlength);

		return true;
	} //}}}

	//{{{ eval() method
	public void eval(FactorWord word, FactorInterpreter interp)
		throws FactorStackException
	{
		FactorArrayStack datastack = interp.datastack;
		FactorArrayStack callstack = interp.callstack;

		if(datastack.top < consumeD)
			throw new FactorStackException(consumeD);

		if(callstack.top < consumeR)
			throw new FactorStackException(consumeR);

		if(shuffleD != null)
			shuffle(interp,datastack,consumeD,consumeR,shuffleD,temporaryD);

		if(shuffleR != null)
			shuffle(interp,callstack,consumeD,consumeR,shuffleR,temporaryR);

		datastack.top -= consumeD;
		if(temporaryD != null)
			datastack.pushAll(temporaryD);

		callstack.top -= consumeR;
		if(temporaryR != null)
			callstack.pushAll(temporaryR);

	} //}}}

	//{{{ shuffle() method
	private void shuffle(FactorInterpreter interp, FactorArrayStack stack,
		int consumeD, int consumeR, int[] shuffle, Object[] temporary)
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
				array = interp.callstack.stack;
				top = interp.callstack.top;
				index = (index & ~FROM_R_MASK);
				consume = consumeR;
			}
			else
			{
				array = interp.datastack.stack;
				top = interp.datastack.top;
				consume = consumeD;
			}
			temporary[i] = array[top - consume + index];
		}
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
