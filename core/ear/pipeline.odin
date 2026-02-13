package ear

import "core:fmt"

import "../eau"

import gl "vendor:OpenGL"

Pipeline :: struct{
    id: u32,
    vao: u32,

    desc: PipelineDesc,
    dest: ^^eau.Destructor,

    delete: proc(pln: ^Pipeline),
    bind: proc(pln: ^Pipeline),
}

PipelineDesc :: struct{
    vertex: ShaderDesc,
    fragment: ShaderDesc,

    vertex_attribs: []VertexAttribDesc,

    depth: bool,

    cull_mode: CullMode,
    front: FrontFace,

    blend: Maybe(BlendState)
}

ShaderDesc :: struct{
    source: ^cstring,
}

VertexAttribDesc :: struct{
    location: u32,
    type: PrimitiveType,
    components: u32, // type Float + this being 3 means vec3
    norm: bool,
    offset: u32,
    slot: u32, // slot vertex buffer is bound to
}

PrimitiveType :: enum{
    Float,
    Int,
}

CullMode :: enum{
    None,
    Front,
    Back,
}

FrontFace :: enum{
    CW,
    CCW,
}

BlendState :: struct{
    src_color, dst_color: BlendFactor,
    color_op: BlendOp,
    src_alpha, dst_alpha: BlendFactor,
    alpha_op: BlendOp,
}

BlendFactor :: enum{
    Zero,
    One,
    SrcColor,
    InvSrcColor,
    DstColor,
    InvDstColor,
    SrcAlpha,
    InvSrcAlpha,
    DstAlpha,
    InvDstAlpha,
}

BlendOp :: enum{
    Add,
    Subtract,
    RevSubtract,
    Min,
    Max,
}


create_pipeline :: proc(desc: PipelineDesc, arena: ^eau.Arena = nil) -> ^Pipeline {
    pln := new_clone(Pipeline{ 
        desc = desc,

        delete = delete_pipeline,
        bind = bind_pipeline,
    })

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
        switch attrib.type {
        case .Float:
            gl.VertexAttribFormat(
                attrib.location,
                i32(attrib.components),
                gl.FLOAT,
                attrib.norm? gl.TRUE : gl.FALSE,
                attrib.offset,
                )
        case .Int:
            gl.VertexAttribIFormat(
                attrib.location,
                i32(attrib.components),
                gl.INT,
                attrib.offset,
                )
        }

        gl.VertexAttribBinding(
            attrib.location,
            attrib.slot,
            )
        gl.EnableVertexAttribArray(attrib.location)
    }

    gl.BindVertexArray(0)

    if arena != nil do pln.dest = arena->add(pln, proc(p: rawptr){ delete_pipeline((^Pipeline)(p)) })
    return pln
}

delete_pipeline :: proc(pln: ^Pipeline) {
    gl.DeleteProgram(pln.id)

    if pln.dest != nil { free(pln.dest^); pln.dest^ = nil }
    free(pln)
}

bind_pipeline :: proc(pln: ^Pipeline) {
    gl.UseProgram(pln.id)
    gl.BindVertexArray(pln.vao)

    if pln.desc.depth { 
        gl.Enable(gl.DEPTH_TEST)
        gl.DepthFunc(gl.LESS)
    } else do gl.Disable(gl.DEPTH_TEST)

    if pln.desc.cull_mode != .None {
        gl.Enable(gl.CULL_FACE)
        gl.CullFace(TYPECONV_cull_mode(pln.desc.cull_mode))
        gl.FrontFace(TYPECONV_front_face(pln.desc.front))
    } else do gl.Disable(gl.CULL_FACE)

    if blend, ok := pln.desc.blend.?; ok {
        gl.Enable(gl.BLEND)
        gl.BlendFuncSeparate(
            TYPECONV_blend_factor(blend.src_color),
            TYPECONV_blend_factor(blend.dst_color),
            TYPECONV_blend_factor(blend.src_alpha),
            TYPECONV_blend_factor(blend.dst_alpha),
            )
        gl.BlendEquationSeparate(
            TYPECONV_blend_op(blend.color_op),
            TYPECONV_blend_op(blend.alpha_op),
            )
    } else do gl.Disable(gl.BLEND)
}



/*@private
TYPECONV_primitive_type :: proc(type: PrimitiveType) -> u32 {
    switch type {
    case .Float: return gl.FLOAT
    case .Int: return gl.INT
    }

    assert(false)
    return 0
}*/

@private
TYPECONV_cull_mode :: proc(mode: CullMode) -> u32 {
    switch mode {
    case .None:  return gl.NONE
    case .Front: return gl.FRONT
    case .Back:  return gl.BACK
    }

    assert(false)
    return 0
}

@private
TYPECONV_front_face :: proc(front: FrontFace) -> u32 {
    switch front {
    case .CW:  return gl.CW
    case .CCW: return gl.CCW
    }

    assert(false)
    return 0
}

@private
TYPECONV_blend_factor :: proc(factor: BlendFactor) -> u32 {
    switch factor {
    case .Zero:        return gl.ZERO
    case .One:         return gl.ONE
    case .SrcColor:    return gl.SRC_COLOR
    case .InvSrcColor: return gl.ONE_MINUS_SRC_COLOR
    case .DstColor:    return gl.DST_COLOR
    case .InvDstColor: return gl.ONE_MINUS_DST_COLOR
    case .SrcAlpha:    return gl.SRC_ALPHA
    case .InvSrcAlpha: return gl.ONE_MINUS_SRC_ALPHA
    case .DstAlpha:    return gl.DST_ALPHA
    case .InvDstAlpha: return gl.ONE_MINUS_DST_ALPHA
    }

    assert(false)
    return 0
}

@private
TYPECONV_blend_op :: proc(op: BlendOp) -> u32 {
    switch op {
    case .Add:         return gl.FUNC_ADD
    case .Subtract:    return gl.FUNC_SUBTRACT
    case .RevSubtract: return gl.FUNC_REVERSE_SUBTRACT
    case .Min:         return gl.MIN
    case .Max:         return gl.MAX
    }

    assert(false)
    return 0
}
