/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004, 2005 Slava Pestov.
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
import java.util.*;
import javax.swing.ListCellRenderer;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import sidekick.*;

public class FactorWordCompletion extends SideKickCompletion
{
	protected FactorParsedData data;

	//{{{ FactorWordCompletion constructor
	public FactorWordCompletion(View view, String word, FactorParsedData data)
	{
		super(view,word,FactorPlugin.toWordArray(
			FactorPlugin.getWordCompletions(word,false)));
		this.data = data;
	} //}}}

	/**
	 * @return If this returns false, then we create a new completion
	 * object after user input.
	 */
	public boolean updateInPlace(EditPane editPane, int caret)
	{
		text = FactorSideKickParser.getCompletionWord(editPane,caret);

		List newItems = new ArrayList();
		Iterator iter = items.iterator();
		while(iter.hasNext())
		{
			FactorWord w = (FactorWord)iter.next();
			if(w.name.startsWith(text))
				newItems.add(w);
		}

		items = newItems;

		return true;
	}

	public void insert(int index)
	{
		super.insert(index);
		FactorWord selected = ((FactorWord)get(index));
		if(!FactorPlugin.isUsed(view,selected.vocabulary))
			FactorPlugin.insertUse(view,selected.vocabulary);
	}

	public ListCellRenderer getRenderer()
	{
		return new FactorWordRenderer(data.parser,false);
	}
}
