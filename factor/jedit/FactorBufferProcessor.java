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
import java.io.IOException;
import java.util.*;
import org.gjt.sp.jedit.Buffer;

/**
 * A class used to compile all words in a file, or infer stack effects of all
 * words in a file, etc.
 */
public class FactorBufferProcessor
{
	private String code;
	private LinkedHashMap results;

	//{{{ FactorBufferProcessor constructor
	/**
	 * @param buffer The buffer
	 * @param code The snippet of code to apply to each word. The snippet
	 * should print a string.
	 */
	public FactorBufferProcessor(Buffer buffer, String code, ExternalFactor factor)
		throws IOException
	{
		results = new LinkedHashMap();
		this.code = code;

		Cons words = (Cons)buffer.getProperty(
			FactorSideKickParser.WORDS_PROPERTY);
		Cons wordCodeMap = null;
		while(words != null)
		{
			FactorWord word = (FactorWord)words.car;

			StringBuffer expression = new StringBuffer();
			expression.append(FactorPlugin.factorWord(word));
			expression.append(" ");
			expression.append(code);

			results.put(word,factor.eval(expression.toString()));

			words = words.next();
		}
	} //}}}
	
	//{{{ insertResults() method
	public void insertResults(Buffer buffer, int offset)
	{
		StringBuffer result = new StringBuffer();
		Iterator iter = results.entrySet().iterator();
		while(iter.hasNext())
		{
			Map.Entry entry = (Map.Entry)iter.next();
			result.append("[ ");
			result.append(((String)entry.getValue()).trim());
			result.append(" ] [ \\ ");
			result.append(FactorReader.unparseObject(entry.getKey()));
			result.append(code);
			result.append(" ] unit-test\n");
		}
		buffer.insert(offset,result.toString());
	} //}}}
}
