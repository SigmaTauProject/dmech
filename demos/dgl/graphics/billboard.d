/*
Copyright (c) 2015 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dgl.graphics.billboard;

import derelict.opengl.gl;
import dlib.math.vector;
import dlib.math.matrix;
import dlib.math.transformation;

void drawBillboard(Matrix4x4f cameraTransformation, Vector3f position, float scale)
{
    Vector3f up = cameraTransformation.up;
    Vector3f right = cameraTransformation.right;
    Vector3f a = position - ((right + up) * scale);
    Vector3f b = position + ((right - up) * scale);
    Vector3f c = position + ((right + up) * scale);
    Vector3f d = position - ((right - up) * scale);
        
    glBegin(GL_QUADS);
    glTexCoord2i(0, 0); glVertex3fv(a.arrayof.ptr);
    glTexCoord2i(1, 0); glVertex3fv(b.arrayof.ptr);
    glTexCoord2i(1, 1); glVertex3fv(c.arrayof.ptr);
    glTexCoord2i(0, 1); glVertex3fv(d.arrayof.ptr);
    glEnd();
}