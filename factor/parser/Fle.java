/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
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

package factor.parser;

import factor.*;
import java.util.*;

public class Fle extends FactorParsingDefinition
{
	private FactorWord start;

	public Fle(FactorWord start, FactorWord end)
	{
		super(end);
		this.start = start;
	}

	public void eval(FactorInterpreter interp, FactorReader reader)
		throws FactorParseException
	{
		Cons definition = reader.popState(start,word);
		if(definition == null)
			reader.error("Missing word name");
		if(!(definition.car instanceof FactorWord))
		{
			reader.error("Not a word name: "
				+ definition.car);
		}

		FactorWord w = (FactorWord)definition.car;
		reader.append(w.name);
		reader.append(createShuffle(
			interp,reader,w,definition.next()));
		reader.append(interp.intern("define"));
	}

	private FactorShuffleDefinition createShuffle(
		FactorInterpreter interp, FactorReader reader,
		FactorWord word, Cons definition)
		throws FactorParseException
	{
		FactorWord f = interp.intern("--");

		// 0 in consume map is last consumed, n is first consumed.
		HashMap consumeMap = new HashMap();
		int consumeD = 0;
		int consumeR = 0;

		while(definition != null)
		{
			Object next = definition.car;
			if(next == f)
			{
				definition = definition.next();
				break;
			}
			else if(next instanceof FactorWord)
			{
				String name = ((FactorWord)next).name;
				int counter;
				if(name.startsWith("r:"))
				{
					next = interp.intern(name.substring(2));
					counter = (FactorShuffleDefinition
						.FROM_R_MASK
						| consumeR++);
				}
				else
					counter = consumeD++;

				Object existing = consumeMap.put(next,
					new Integer(counter));
				if(existing != null)
					reader.error(
						word + ": appears twice in shuffle LHS: "
						+ next);
			}
			else if(!(next instanceof FactorDocComment))
			{
				reader.error(word + ": unexpected "
					+ FactorReader.unparseObject(
					next));
			}
			definition = definition.next();
		}

		int consume = consumeMap.size();

		if(definition == null)
		{
			return new FactorShuffleDefinition(word,
				consumeD,consumeR,
				null,0,null,0);
		}

		int[] shuffle = new int[definition.length()];

		int shuffleDlength = 0;
		int shuffleRlength = 0;

		int i = 0;
		while(definition != null)
		{
			if(definition.car instanceof FactorWord)
			{
				FactorWord w = ((FactorWord)definition.car);
				String name = w.name;
				if(name.startsWith("r:"))
					w = interp.intern(name.substring(2));

				Integer _index = (Integer)consumeMap.get(w);
				if(_index == null)
				{
					reader.error(word +
						": does not appear in shuffle LHS: "
						+ definition.car);
				}

				int index = _index.intValue();

				if(name.startsWith("r:"))
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
			else if(!(definition.car instanceof FactorDocComment))
			{
				reader.error(word + ": unexpected "
					+ FactorReader.unparseObject(
					definition.car));
			}
			definition = definition.next();
		}

		int[] shuffleD = new int[shuffleDlength];
		int[] shuffleR = new int[shuffleRlength];
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

		return new FactorShuffleDefinition(word,consumeD,consumeR,
			shuffleD,shuffleDlength,shuffleR,shuffleRlength);
	}
}
