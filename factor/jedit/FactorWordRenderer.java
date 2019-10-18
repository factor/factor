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

package factor.jedit;

import factor.*;
import java.awt.Component;
import javax.swing.*;
import org.gjt.sp.jedit.*;

public class FactorWordRenderer extends DefaultListCellRenderer
{
	//{{{ getWordHTMLString() method
	public static String getWordHTMLString(FactorWord word, boolean showIn)
	{
		String defStr = jEdit.getProperty(
			"factor.completion.def",
			new String[] {
				MiscUtilities.charsToEntities(word.getDefiner().name),
				MiscUtilities.charsToEntities(word.name)
			});

		String in;
		if(showIn)
		{
			in = jEdit.getProperty("factor.completion.in",
				new Object[] {
					MiscUtilities.charsToEntities(word.vocabulary)
				});
		}
		else
			in = "";

		String html = "<html>" + in + defStr;

		if(word.stackEffect != null)
		{
			html = jEdit.getProperty("factor.completion.stack",
				new String[] { html, word.stackEffect });
		}

		return html;
	} //}}}

	private FactorSideKickParser parser;
	private boolean showIn;

	//{{{ FactorWordRenderer constructor
	public FactorWordRenderer(FactorSideKickParser parser, boolean showIn)
	{
		this.parser = parser;
		this.showIn = showIn;
	} //}}}

	//{{{ getListCellRendererComponent() method
	public Component getListCellRendererComponent(
		JList list,
		Object value,
		int index,
		boolean isSelected,
		boolean cellHasFocus)
	{
		super.getListCellRendererComponent(list,value,index,
			isSelected,cellHasFocus);

		if(!(value instanceof FactorWord))
			return this;

		FactorWord word = (FactorWord)value;
		setText(getWordHTMLString(word,showIn));

		return this;
	} //}}}
}
