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

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ByteVector;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;

import java.util.Map;

/**
 * The AnnotationDefault attribute is a variable length attribute in the
 * attributes table of certain method_info structures, namely those representing
 * members of annotation types. The AnnotationDefault attribute records the
 * default value for the member represented by the method_info structure. Each
 * method_info structures representing a member of an annotation types may contain
 * at most one AnnotationDefault attribute. The JVM must make this default value
 * available so it can be applied by appropriate reflective APIs.
 * <p>
 * The AnnotationDefault attribute has the following format:
 * <pre>
 *    AnnotationDefault_attribute {
 *      u2 attribute_name_index;
 *      u4 attribute_length;
 *      member_value default_value;
 *    }
 * </pre>
 * The items of the AnnotationDefault structure are as follows:
 * <dl>
 * <dt>attribute_name_index</dt>
 * <dd>The value of the attribute_name_index item must be a valid index into the
 *     constant_pool table. The constant_pool entry at that index must be a
 *     CONSTANT_Utf8_info structure representing the string "AnnotationDefault".</dd>
 * <dt>attribute_length</dt>
 * <dd>The value of the attribute_length item indicates the length of the attribute,
 *     excluding the initial six bytes. The value of the attribute_length item is
 *     thus dependent on the default value.</dd>
 * <dt>default_value</dt>
 * <dd>The default_value item represents the default value of the annotation type
 *     {@link org.objectweb.asm.attrs.AnnotationMemberValue member} whose default
 *     value is represented by this AnnotationDefault attribute.</dd>
 * </dl>
 *
 * @see <a href="http://www.jcp.org/en/jsr/detail?id=175">JSR 175 : A Metadata
 * Facility for the Java Programming Language</a>
 *
 * @author Eugene Kuleshov
 */

public class AnnotationDefaultAttribute extends Attribute implements Dumpable {

  public AnnotationMemberValue defaultValue;

  public AnnotationDefaultAttribute () {
    super("AnnotationDefault");
  }

  protected Attribute read (ClassReader cr, int off,
                            int len, char[] buf, int codeOff, Label[] labels) {
    AnnotationDefaultAttribute ann = new AnnotationDefaultAttribute();
    ann.defaultValue = new AnnotationMemberValue();
    ann.defaultValue.read(cr, off, buf);
    return ann;
  }

  protected ByteVector write (ClassWriter cw, byte[] code,
                              int len, int maxStack, int maxLocals) {
    return defaultValue.write(new ByteVector(), cw);
  }

  public void dump (StringBuffer buf, String varName, Map labelNames) {
    buf.append("AnnotationDefaultAttribute ").append(varName)
      .append(" = new AnnotationDefaultAttribute();\n");
    defaultValue.dump(buf, varName + "Val");
    buf.append(varName).append(".defaultValue = ")
      .append(varName).append("Val;\n");
  }

  /**
   * Returns value in the format described in JSR-175 for Java source code.
   */

  public String toString () {
    return "default " + defaultValue;
  }
}
