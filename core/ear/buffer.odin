package ear

import "core:fmt"

import "../eau"

import gl "vendor:OpenGL"

Buffer :: struct{
    id: u32,

    size: u32,
        prev_size: u32,
    data: rawptr,

    desc: BufferDesc,
    dest: ^^eau.Destructor,

    delete: proc(buffer: ^Buffer),
    bind: proc(buffer: ^Buffer, slot: u32),

    update: proc(buffer: ^Buffer),
}

BufferDesc :: struct{
    type: BufferType,
    usage: BufferUsage,
    stride: u32,
}

BufferType :: enum{
    Uniform,
    Storage,
    Vertex,
    Index,
}

BufferUsage :: enum{
    Dynamic,
    Static
}


create_buffer :: proc(desc: BufferDesc, db: rawptr, size: u32, arena: ^eau.Arena = nil) -> ^Buffer {
    buf := new_clone(Buffer{ 
        desc = desc, 
        data = db, 
        size = size, prev_size = size,

        delete = delete_buffer,
        bind = bind_buffer,

        update = update_buffer,
    })

    gl.GenBuffers(1, &buf.id)

    targ := TYPECONV_buffer_type(desc.type)

    gl.BindBuffer(targ, buf.id)
    gl.BufferData(
        targ,
        int(buf.size),
        buf.data,
        TYPECONV_buffer_usage(desc.usage),
        )
    gl.BindBuffer(targ, 0)

    if arena != nil do buf.dest = arena->add(buf, rawptr(delete_buffer))
    return buf
}

delete_buffer :: proc(buffer: ^Buffer) {
    gl.DeleteBuffers(1, raw_data( []u32{ buffer.id } ))

    if buffer.dest != nil { free(buffer.dest^); buffer.dest^ = nil }
    free(buffer)
}

bind_buffer :: proc(buffer: ^Buffer, slot: u32) {
    targ := TYPECONV_buffer_type(buffer.desc.type)

    gl.BindBuffer(targ, buffer.id)

    if buffer.desc.type == .Uniform || buffer.desc.type == .Storage {
        gl.BindBufferBase(targ, slot, buffer.id) }

    if buffer.desc.type == .Vertex {
        gl.BindVertexBuffer(slot, buffer.id, 0, i32(buffer.desc.stride)) }
}

update_buffer :: proc(buffer: ^Buffer) {
    if buffer.prev_size != 0 do assert(buffer.desc.usage == .Dynamic)

    targ := TYPECONV_buffer_type(buffer.desc.type)

    gl.BindBuffer(targ, buffer.id)

    if buffer.size > buffer.prev_size {
        buffer.prev_size = buffer.size
        gl.BufferData(targ, int(buffer.size), buffer.data, gl.DYNAMIC_DRAW)
    } else do gl.BufferSubData(targ, 0, int(buffer.size), buffer.data)

    gl.BindBuffer(targ, 0)
}



@private
TYPECONV_buffer_type :: proc(type: BufferType) -> u32 {
    switch type {
    case .Uniform: return gl.UNIFORM_BUFFER
    case .Storage: return gl.SHADER_STORAGE_BUFFER
    case .Vertex:  return gl.ARRAY_BUFFER
    case .Index:   return gl.ELEMENT_ARRAY_BUFFER
    }

    assert(false)
    return 0
}

@private
TYPECONV_buffer_usage :: proc(usage: BufferUsage) -> u32 {
    switch usage {
    case .Dynamic: return gl.DYNAMIC_DRAW
    case .Static:  return gl.STATIC_DRAW
    }

    assert(false)
    return 0
}
