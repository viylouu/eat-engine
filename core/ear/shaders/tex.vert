#version 430 core

struct InstData {
    vec2 pos;
    vec2 size;
    vec4 col;
    vec4 samp;
};

const vec2 verts[6] = vec2[6](
        vec2(0,0), vec2(1,0),
        vec2(1,1), vec2(1,1),
        vec2(0,1), vec2(0,0)
    );

layout(std430, binding = 0) buffer ssbo {
    InstData insts[];
};

layout(std140, binding = 1) uniform uni {
    mat4 proj;
};

out vec2 fUv;
out vec4 fSample;
flat out vec4 fCol;

void main() {
    vec2 vert = verts[gl_VertexID];
    InstData inst = insts[gl_InstanceID];

    gl_Position = proj * vec4(vert * inst.size + inst.pos, 0,1);

    fUv = vert;
    fSample = inst.samp;
    fCol = inst.col;
}
