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

package factor.jedit;

import factor.*;
import org.gjt.sp.jedit.Buffer;
import org.gjt.sp.jedit.View;

/**
 * A class used to compile all words in a file, or infer stack effects of all
 * words in a file, etc.
 */
public abstract class FactorBufferProcessor
{
	private String results;

	//{{{ FactorBufferProcessor constructor
	public FactorBufferProcessor(View view, Buffer buffer,
		boolean evalInListener) throws Exception
	{
		StringBuffer buf = new StringBuffer();

		Cons words = (Cons)buffer.getProperty(
			FactorSideKickParser.WORDS_PROPERTY);
		Cons wordCodeMap = null;
		while(words != null)
		{
			FactorWord word = (FactorWord)words.car;
			String expr = processWord(word);
			buf.append("! ");
			buf.append(expr);
			buf.append('\n');
			if(evalInListener)
				FactorPlugin.evalInListener(view,expr);
			else
				buf.append(FactorPlugin.evalInWire(expr));
			words = words.next();
		}
		
		results = buf.toString();
	} //}}}
	
	/**
	 * @return Code to process the word.
	 */
	public abstract String processWord(FactorWord word);

	//{{{ getResults() method
	public String getResults()
	{
		return results;
	} //}}}
}
