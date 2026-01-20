package ear

import "core:fmt"

import gl "vendor:OpenGL"

Pipeline :: struct{
    id: u32,
    vao: u32,

    desc: PipelineDesc,
}

PipelineDesc :: struct{
    vertex: ShaderDesc,
    fragment: ShaderDesc,

    vertex_attribs: []VertexAttribDesc,

    depth: bool,
}

ShaderDesc :: struct{
    source: ^cstring,
}

VertexAttribDesc :: struct{
    buffer: ^Buffer,
    location: u32,
    type: PrimitiveType,
    components: u32, // type Float + this being 3 means vec3
    norm: bool,
    stride: u32,
    offset: uintptr,
}

PrimitiveType :: enum{
    Float
}

create_pipeline :: proc(desc: PipelineDesc) -> Pipeline {
    pln := Pipeline{ desc = desc }

    vsh := gl.CreateShader(gl.VERTEX_SHADER)
        defer gl.DeleteShader(vsh)
    gl.ShaderSource(vsh, 1, pln.desc.vertex.source, nil)
    gl.CompileShader(vsh)

    succ: i32
    gl.GetShaderiv(vsh, gl.COMPILE_STATUS, &succ)
    if !bool(succ) {
        fmt.eprintln("vertex shader compilation failed!")
        log: [1024]u8
        gl.GetShaderInfoLog(vsh, 512, nil, &log[0])
        fmt.eprintln(string(log[:]))

        assert(false)
    }

    fsh := gl.CreateShader(gl.FRAGMENT_SHADER)
        defer gl.DeleteShader(fsh)
    gl.ShaderSource(fsh, 1, pln.desc.fragment.source, nil)
    gl.CompileShader(fsh)

    gl.GetShaderiv(fsh, gl.COMPILE_STATUS, &succ)
    if !bool(succ) {
        fmt.eprintln("fragment shader compilation failed!")
        log: [1024]u8
        gl.GetShaderInfoLog(fsh, 512, nil, &log[0])
        fmt.eprintln(string(log[:]))

        assert(false)
    }

    pln.id = gl.CreateProgram()
    for s in ([]u32{ vsh, fsh }) do gl.AttachShader(pln.id, s)
    gl.LinkProgram(pln.id)

    gl.GetProgramiv(pln.id, gl.LINK_STATUS, &succ)
    if !bool(succ) {
        fmt.eprintln("failed to link shader program!")
        log: [512]u8
        gl.GetProgramInfoLog(pln.id, 512, nil, &log[0])
        fmt.eprintln(string(log[:]))

        assert(false)
    }

    gl.GenVertexArrays(1, &pln.vao)
    gl.BindVertexArray(pln.vao)

    for attrib in desc.vertex_attribs {
        bind_buffer(attrib.buffer^, 0)

        gl.VertexAttribPointer(
            attrib.location, 
            i32(attrib.components),
            TYPECONV_primitive_type(attrib.type), 
            attrib.norm? gl.TRUE : gl.FALSE,
            i32(attrib.stride),
            attrib.offset,
            )
        gl.EnableVertexAttribArray(attrib.location)
    }

    gl.BindVertexArray(0)

    return pln
}

delete_pipeline :: proc(pln: Pipeline) {
    gl.DeleteProgram(pln.id)
}

bind_pipeline :: proc(pln: Pipeline) {
    gl.UseProgram(pln.id)
    gl.BindVertexArray(pln.vao)
    if pln.desc.depth { 
        gl.Enable(gl.DEPTH_TEST)
        gl.DepthFunc(gl.LESS)
    } else do gl.Disable(gl.DEPTH_TEST)
}



@private
TYPECONV_primitive_type :: proc(type: PrimitiveType) -> u32 {
    switch type {
    case .Float:
        return gl.FLOAT
    }

    assert(false)
    return 0
}
