#version 430 core

in vec2 fUv;
in vec4 fSample;
flat in vec4 fCol;

layout (location = 2) uniform sampler2D tex;

out vec4 oCol;

void main() {
    vec4 data = texture(tex, fUv * fSample.zw + fSample.xy);
    vec4 col = data * fCol;
    if (col.a == 0)
        discard;

    oCol = col;
}
