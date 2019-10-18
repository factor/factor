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

package factor.compiler;

import factor.*;
import java.util.*;

public class StackEffect
{
	public final int inD;
	public final int outD;
	public final int inR;
	public final int outR;

	//{{{ StackEffect constructor
	public StackEffect(int inD, int outD, int inR, int outR)
	{
		this.inD = inD;
		this.outD = outD;
		this.inR = inR;
		this.outR = outR;
	} //}}}

	//{{{ getStackEffect() method
	public static StackEffect getStackEffect(Cons definition)
		throws Exception
	{
		return getStackEffect(definition,new HashSet(),
			new LocalAllocator());
	} //}}}

	//{{{ getStackEffect() method
	public static StackEffect getStackEffect(Cons definition,
		Set recursiveCheck, LocalAllocator state)
		throws Exception
	{
		int inD = 0;
		int outD = 0;
		int inR = 0;
		int outR = 0;

		Cons iter = definition;
		while(iter != null)
		{
			Object obj = iter.car;
			if(obj instanceof FactorWord)
			{
				StackEffect se = ((FactorWord)obj).def
					.getStackEffect(
					recursiveCheck,
					state);

				if(se == null)
					return null;

				if(se.inD <= outD)
					outD -= se.inD;
				else
				{
					inD += (se.inD - outD);
					outD = 0;
				}

				if(se.inR <= outR)
					outR -= se.inR;
				else
				{
					inR += (se.inR - outR);
					outR = 0;
				}

				outD += se.outD;
				outR += se.outR;
			}
			else
			{
				outD++;
				state.pushLiteral(obj);
			}

			iter = iter.next();
		}

		return new StackEffect(inD,outD,inR,outR);
	} //}}}

	//{{{ getCorePrototype() method
	public String getCorePrototype()
	{
		StringBuffer signatureBuf = new StringBuffer(
			"(Lfactor/FactorInterpreter;");

		for(int i = 0; i < inD; i++)
		{
			signatureBuf.append("Ljava/lang/Object;");
		}

		if(outD == 0)
			signatureBuf.append(")V");
		else
			signatureBuf.append(")Ljava/lang/Object;");

		return signatureBuf.toString();
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(!(o instanceof StackEffect))
			return false;
		StackEffect effect = (StackEffect)o;
		return effect.inD == inD
			&& effect.outD == outD
			&& effect.inR == inR
			&& effect.outR == outR;
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < inD; i++)
		{
			buf.append("I ");
		}
		for(int i = 0; i < inR; i++)
		{
			buf.append("r:I ");
		}
		buf.append("--");
		for(int i = 0; i < outD; i++)
		{
			buf.append(" O");
		}
		for(int i = 0; i < outR; i++)
		{
			buf.append(" r:O");
		}
		return buf.toString();
	} //}}}
}
