#version 330 core

flat in vec4 fCol;

out vec4 oCol;

void main() {
    if (fCol.a == 0)
        discard;

    oCol = fCol;
}
