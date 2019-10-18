/**
 * ASM: a very small and fast Java bytecode manipulation framework
 * Copyright (c) 2000,2002,2003 INRIA, France Telecom
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Contact: Eric.Bruneton@rd.francetelecom.com
 *
 * Author: Eric Bruneton
 */

package org.objectweb.asm.attrs;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

/**
 * StackMapAttribute is used by CDLC preverifier and also by javac compiller
 * starting from J2SE 1.5. Definition is given in appendix "CLDC Byte Code
 * Typechecker Specification" from CDLC 1.1 specification.
 * <p>
 * <i>Note that this implementation does not calculate StackMapFrame structures
 * from the method bytecode. If method code is changed or generated from scratch,
 * then developer is responsible to prepare a correct StackMapFrame structures.</i>
 * <p>
 * The format of the stack map in the class file is given below. In the following,
 * <ul>
 * <li>if the length of the method's byte code1 is 65535 or less, then <tt>uoffset</tt>
 *     represents the type u2; otherwise <tt>uoffset</tt> represents the type u4.</li>
 * <li>If the maximum number of local variables for the method is 65535 or less,
 *     then <tt>ulocalvar</tt> represents the type u2; otherwise <tt>ulocalvar</tt>
 *     represents the type u4.</li>
 * <li>If the maximum size of the operand stack is 65535 or less, then <tt>ustack</tt>
 *     represents the type u2; otherwise ustack represents the type u4.</li>
 * </ul>
 *
 * <pre>
 *   stack_map { // attribute StackMap
 *     u2 attribute_name_index;
 *     u4 attribute_length
 *     uoffset number_of_entries;
 *     stack_map_frame entries[number_of_entries];
 *   }
 * </pre>
 * Each stack map frame has the following format:
 * <pre>
 *   stack_map_frame {
 *     uoffset offset;
 *     ulocalvar number_of_locals;
 *     verification_type_info locals[number_of_locals];
 *     ustack number_of_stack_items;
 *     verification_type_info stack[number_of_stack_items];
 *   }
 * </pre>
 * The <tt>verification_type_info</tt> structure consists of a one-byte tag
 * followed by zero or more bytes, giving more information about the tag.
 * Each <tt>verification_type_info</tt> structure specifies the verification
 * type of one or two locations.
 * <pre>
 *   union verification_type_info {
 *     Top_variable_info;
 *     Integer_variable_info;
 *     Float_variable_info;
 *     Long_variable_info;
 *     Double_variable_info;
 *     Null_variable_info;
 *     UninitializedThis_variable_info;
 *     Object_variable_info;
 *     Uninitialized_variable_info;
 *   }
 *
 *   Top_variable_info {
 *     u1 tag = ITEM_Top; // 0
 *   }
 *
 *   Integer_variable_info {
 *     u1 tag = ITEM_Integer; // 1
 *   }
 *
 *   Float_variable_info {
 *     u1 tag = ITEM_Float; // 2
 *   }
 *
 *   Long_variable_info {
 *     u1 tag = ITEM_Long; // 4
 *   }
 *
 *   Double_variable_info {
 *     u1 tag = ITEM_Double; // 3
 *   }
 *
 *   Null_variable_info {
 *     u1 tag = ITEM_Null; // 5
 *   }
 *
 *   UninitializedThis_variable_info {
 *     u1 tag = ITEM_UninitializedThis; // 6
 *   }
 *
 *   Object_variable_info {
 *     u1 tag = ITEM_Object; // 7
 *     u2 cpool_index;
 *   }
 *
 *   Uninitialized_variable_info {
 *     u1 tag = ITEM_Uninitialized // 8
 *     uoffset offset;
 *   }
 * </pre>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=139">JSR 139 : Connected
 * Limited Device Configuration 1.1</a>
 *
 * @author Eugene Kuleshov
 */

public class StackMapAttribute extends Attribute implements Dumpable {

  static final int MAX_SIZE = 65535;

  public LinkedList frames = new LinkedList();

  public StackMapAttribute () {
    super("StackMap");
  }

  public StackMapFrame getFrame (Label label) {
    for (int i = 0; i < frames.size(); i++) {
      StackMapFrame frame = (StackMapFrame)frames.get(i);
      if (frame.label == label) {
        return frame;
      }
    }
    return null;
  }

  protected Attribute read (ClassReader cr, int off, int len,
                            char[] buf, int codeOff, Label[] labels) {
    StackMapAttribute attr = new StackMapAttribute();
    // note that this is not the size of Code attribute
    int codeSize = cr.readInt(codeOff + 4);
    int size = 0;
    if (codeSize > MAX_SIZE) {
      size = cr.readInt(off);
      off += 4;
    } else {
      size = cr.readShort(off);
      off += 2;
    }
    for (int i = 0; i < size; i++) {
      StackMapFrame frame = new StackMapFrame();
      off = frame.read(cr, off, buf, codeOff, labels);
      attr.frames.add(frame);
    }
    return attr;
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    ByteVector bv = new ByteVector();
    if (code.length > MAX_SIZE) {
      bv.putInt(frames.size());
    } else {
      bv.putShort(frames.size());
    }
    for (int i = 0; i < frames.size(); i++) {
      ((StackMapFrame)frames.get(i)).write(cw, maxStack, maxLocals, bv);
    }
    return bv;
  }

  protected Label[] getLabels () {
    HashSet labels = new HashSet();
    for (int i = 0; i < frames.size(); i++) {
      ((StackMapFrame)frames.get(i)).getLabels(labels);
    }
    return (Label[])labels.toArray(new Label[labels.size()]);
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("{\n");
    buf.append("StackMapAttribute ").append(varName).append("Attr");
    buf.append(" = new StackMapAttribute();\n");
    if (frames.size() > 0) {
      for (int i = 0; i < frames.size(); i++) {
        ((StackMapFrame)frames.get(i))
          .dump(buf, varName + "frame" + i, labelNames);
      }
    }
    buf.append(varName).append(".visitAttribute(").append(varName);
    buf.append("Attr);\n}\n");
  }

  public String toString () {
    StringBuffer sb = new StringBuffer("StackMap[");
    for (int i = 0; i < frames.size(); i++) {
      sb.append('\n').append('[').append(frames.get(i)).append(']');
    }
    sb.append("\n]");
    return sb.toString();
  }
}
