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

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

/**
 * The RuntimeInvisibleAnnotations attribute is similar to the
 * RuntimeVisibleAnnotations attribute, except that the annotations represented by
 * a RuntimeInvisibleAnnotations attribute must not be made available for return
 * by reflective APIs, unless the JVM has been instructed to retain these
 * annotations via some implementation-specific mechanism such as a command line
 * flag. In the absence of such instructions, the JVM ignores this attribute.
 * <p>
 * The RuntimeInvisibleAnnotations attribute is a variable length attribute in the
 * attributes table of the ClassFile, field_info, and method_info structures. The
 * RuntimeInvisibleAnnotations attribute records runtime-invisible Java
 * programming language annotations on the corresponding class, method, or field.
 * Each ClassFile, field_info, and method_info structure may contain at most one
 * RuntimeInvisibleAnnotations attribute, which records all the runtime-invisible
 * Java programming language annotations on the corresponding program element.
 * <p>
 * The RuntimeInvisibleAnnotations attribute has the following format:
 * <pre>
 *   RuntimeInvisibleAnnotations_attribute {
 *     u2 attribute_name_index;
 *     u4 attribute_length;
 *     u2 num_annotations;
 *     annotation annotations[num_annotations];
 *   }
 * </pre>
 * The items of the RuntimeInvisibleAnnotations structure are as follows:
 * <dl>
 * <dt>attribute_name_index</dt>
 * <dd>The value of the attribute_name_index item must be a valid index into the
 *     constant_pool table. The constant_pool entry at that index must be a
 *     CONSTANT_Utf8_info structure representing the string
 *     "RuntimeInvisibleAnnotations".</dd>
 * <dt>attribute_length</dt>
 * <dd>The value of the attribute_length item indicates the length of the
 *     attribute, excluding the initial six bytes. The value of the
 *     attribute_length item is thus dependent on the number of runtime-invisible
 *     annotations represented by the structure, and their values.</dd>
 * <dt>num_annotations</dt>
 * <dd>The value of the num_annotations item gives the number of runtime-invisible
 *     annotations represented by the structure. Note that a maximum of 65535
 *     runtime-invisible Java programming language annotations may be directly
 *     attached to a program element.</dd>
 * <dt>annotations</dt>
 * <dd>Each value of the annotations table represents a single runtime-invisible
 *     {@link org.objectweb.asm.attrs.Annotation annotation} on a program element.</dd>
 * </dl>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=175">JSR 175 : A Metadata
 * Facility for the Java Programming Language</a>
 *
 * @author Eugene Kuleshov
 */

public class RuntimeInvisibleAnnotations extends Attribute implements Dumpable {

  public List annotations = new LinkedList();

  public RuntimeInvisibleAnnotations () {
    super("RuntimeInvisibleAnnotations");
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    RuntimeInvisibleAnnotations atr = new RuntimeInvisibleAnnotations();
    Annotation.readAnnotations(atr.annotations, cr, off, buf);
    return atr;
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    return Annotation.writeAnnotations(new ByteVector(), annotations, cw);
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("RuntimeInvisibleAnnotations ").append(varName)
      .append(" = new RuntimeInvisibleAnnotations();\n");
    Annotation.dumpAnnotations(buf, varName, annotations);
  }

  /**
   * Returns value in the format described in JSR-175 for Java source code.
   */

  public String toString () {
    return Annotation.stringAnnotations(annotations);
  }
}
