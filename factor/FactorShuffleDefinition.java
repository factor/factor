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

import java.util.*;

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

	//{{{ FactorShuffleDefinition constructor
	public FactorShuffleDefinition(FactorWord word, Cons definition)
		throws FactorException
	{
		super(word);
		fromList(definition);
	} //}}}

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

		init();
	} //}}}

	//{{{ init() method
	private void init()
	{
		if(this.shuffleD != null && this.shuffleDlength == 0)
			this.shuffleD = null;
		if(this.shuffleR != null && this.shuffleRlength == 0)
			this.shuffleR = null;
		if(this.shuffleD != null)
		{
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
			for(int i = 0; i < shuffleRlength; i++)
			{
				if(shuffleR[i] == (i | FROM_R_MASK))
					shuffleRstart++;
				else
					break;
			}
		}
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws FactorStackException
	{
		eval(interp,interp.datastack,interp.callstack);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp,
		FactorArray datastack,
		FactorArray callstack)
		throws FactorStackException
	{
		if(datastack.top < consumeD)
			throw new FactorStackException(consumeD);

		if(callstack.top < consumeR)
			throw new FactorStackException(consumeR);

		Object[] temporaryD;
		if(shuffleD != null)
		{
			temporaryD = new Object[shuffleDlength];
			shuffle(datastack,callstack,datastack,consumeD,consumeR,
				shuffleD,temporaryD);
		}
		else
			temporaryD = null;

		Object[] temporaryR;
		if(shuffleR != null)
		{
			temporaryR = new Object[shuffleRlength];
			shuffle(datastack,callstack,callstack,consumeD,consumeR,
				shuffleR,temporaryR);
		}
		else
			temporaryR = null;

		datastack.top -= consumeD;
		if(temporaryD != null)
			datastack.pushAll(temporaryD);

		callstack.top -= consumeR;
		if(temporaryR != null)
			callstack.pushAll(temporaryR);

	} //}}}

	//{{{ shuffle() method
	private void shuffle(
		FactorArray datastack,
		FactorArray callstack,
		FactorArray stack,
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

	//{{{ fromList() method
	public void fromList(Cons definition)
		throws FactorRuntimeException
	{
		String f = "--";

		// 0 in consume map is last consumed, n is first consumed.
		HashMap consumeMap = new HashMap();

		while(definition != null)
		{
			Object next = definition.car;
			if(f.equals(next.toString()))
			{
				definition = definition.next();
				break;
			}
			else if(next instanceof String
				|| next instanceof Character)
			{
				String name = next.toString();
				int counter;
				if(name.startsWith("r:"))
				{
					counter = (FactorShuffleDefinition
						.FROM_R_MASK
						| consumeR++);
					name = name.substring(2);
				}
				else
					counter = consumeD++;

				Object existing = consumeMap.put(name,
					new Integer(counter));
				if(existing != null)
					throw new FactorRuntimeException(
						word + ": appears twice in shuffle LHS: "
						+ next);
			}
			else if(!(next instanceof FactorDocComment))
			{
				throw new FactorRuntimeException(
					word + ": unexpected "
					+ FactorReader.unparseObject(
					next));
			}
			definition = definition.next();
		}

		int consume = consumeMap.size();

		if(definition != null)
		{
			int[] shuffle = new int[definition.length()];

			int i = 0;
			while(definition != null)
			{
				if(definition.car instanceof String
					|| definition.car instanceof Character)
				{
					String name = definition.car.toString();
					boolean r = (name.startsWith("r:"));
					if(r)
						name = name.substring(2);

					Integer _index = (Integer)
						consumeMap.get(name);
					if(_index == null)
					{
						throw new FactorRuntimeException(word +
							": does not appear in shuffle LHS: "
							+ definition.car);
					}

					int index = _index.intValue();

					if(r)
					{
						shuffleRlength++;
						shuffle[i++] = (index
							| FactorShuffleDefinition
							.TO_R_MASK);
					}
					else
					{
						shuffleDlength++;
						shuffle[i++] = index;
					}
				}
				else
				{
					throw new FactorRuntimeException(
						word + ": unexpected "
						+ FactorReader.unparseObject(
						definition.car));
				}
				definition = definition.next();
			}

			shuffleD = new int[shuffleDlength];
			shuffleR = new int[shuffleRlength];

			int j = 0, k = 0;
			for(i = 0; i < shuffle.length; i++)
			{
				int index = shuffle[i];
				if((index & FactorShuffleDefinition.TO_R_MASK)
					== FactorShuffleDefinition.TO_R_MASK)
				{
					index = (index
						& ~FactorShuffleDefinition.TO_R_MASK);
					shuffleR[j++] = index;
				}
				else
					shuffleD[k++] = index;
			}
		}

		init();
	} //}}}

	//{{{ toList() method
	public Cons toList()
	{
		Cons list = null;

		for(int i = 0; i < consumeD; i++)
			list = new Cons(String.valueOf((char)('A' + i)),list);

		for(int i = 0; i < consumeR; i++)
			list = new Cons("r:" + (char)('A' + consumeD + i),list);

		list = new Cons("--",list);

		if(shuffleD != null)
		{
			for(int i = 0; i < shuffleDlength; i++)
			{
				int index = shuffleD[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
				{
					index &= ~FROM_R_MASK;
					index += consumeD;
				}

				list = new Cons(String.valueOf(
					(char)('A' + index)),
					list);
			}
		}

		if(shuffleR != null)
		{
			for(int i = 0; i < shuffleRlength; i++)
			{
				int index = shuffleR[i];
				if((index & FROM_R_MASK) == FROM_R_MASK)
				{
					index &= ~FROM_R_MASK;
					index += consumeD;
				}

				list = new Cons(
					"r:" + (char)('A' + index),
					list);
			}
		}

		return Cons.reverse(list);
	} //}}}
}
