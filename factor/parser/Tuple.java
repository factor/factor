/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2005 Slava Pestov.
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

public class Tuple extends FactorParsingDefinition
{
	public Tuple(FactorWord word)
	{
		super(word);
	}

	public void eval(FactorReader reader)
		throws Exception
	{
		Object next = reader.nextNonEOL(false,false);
		if(!(next instanceof String))
		{
			reader.getScanner().error("Missing tuple name");
			return;
		}

		String tupleName = (String)next;
		reader.intern(tupleName,true);
		reader.intern("<" + tupleName + ">",true);
		reader.intern(tupleName + "?",true);

		for(;;)
		{
			next = reader.next(false,false);
			if(next == FactorScanner.EOF)
			{
				reader.getScanner().error("Expected ;");
				break;
			}
			else if(next.equals(";"))
				break;
			else if(next instanceof String)
			{
				reader.intern(tupleName + "-" + next,true);
				reader.intern("set-" + tupleName + "-" + next,true);
			}
		}
	}
}
