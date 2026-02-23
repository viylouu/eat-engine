package ear

import "core:fmt"

import "../eau"
import "../../editor/_hook"

import gl "vendor:OpenGL"
import "vendor:stb/image"

Texture :: struct{
    id: u32,

    pixels: [^]u8,
    stbi_pixels: bool,

    width: u32,
    height: u32,

    desc: TextureDesc,
    dest: ^eau.Destructor,
    idx: int,

    delete: proc(tex: ^Texture),
    bind: proc(tex: ^Texture, slot: u32), // this sets the uniform aswell!

    get_color: proc(tex: ^Texture, #any_int x,y: u32) -> [4]f32,
    set_color: proc(tex: ^Texture, #any_int x,y: u32, col: [4]f32),
    apply_changes: proc(tex: ^Texture),
}

TextureDesc :: struct{
    filter: TextureFilter,
    type: TextureType,
    wrap: TextureWrap,
        wrap_color: [4]f32,
}

TextureFilter :: enum{
    Nearest,
    Linear,
}

TextureType :: enum{
    Color,
    Depth,
    Hdr,
    Hdr32,
}

TextureWrap :: enum{
    Repeat,
    Clamp,
    Color,
}


// in order to get/set color, you need to supply an array for pixels
// you may not supply null
// array size should be at LEAST width * height * 4
create_texture :: proc(desc: TextureDesc, pixels: [^]u8, width, height: u32, arena: ^eau.Arena = nil) -> ^Texture {
    tex := new_clone(Texture{ 
        desc = desc, 
        width = width, height = height,

        delete = delete_texture,
        bind = bind_texture,

        get_color = get_texture_color,
        set_color = set_texture_color,
        apply_changes = apply_texture_changes,

        pixels = pixels,
        stbi_pixels = false,
    })

    gl.GenTextures(1, &tex.id)
    assert(tex.id != 0)

    gl.BindTexture(gl.TEXTURE_2D, tex.id)

    sampling := TYPECONV_texture_filter(desc.filter)
    wrap := TYPECONV_texture_wrap(desc.wrap)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, wrap)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, wrap)
    col := []f32{ desc.wrap_color.r, desc.wrap_color.g, desc.wrap_color.b, desc.wrap_color.a }
    gl.TexParameterfv(gl.TEXTURE_2D, gl.TEXTURE_BORDER_COLOR, raw_data(col))

    gl.TexImage2D(
        gl.TEXTURE_2D,
        0,
        TYPECONV_texture_type_as_intf(desc.type),
        i32(width), i32(height),
        0,
        TYPECONV_texture_type_as_f(desc.type),
        TYPECONV_texture_type_as_type(desc.type),
        pixels
        )

    gl.BindTexture(gl.TEXTURE_2D, 0)

    if arena != nil do tex.dest = arena->add(tex, proc(p: rawptr){ delete_texture((^Texture)(p)) })
    tex.idx = _hook.add_object({ type = .Texture, data = tex, arena = arena, })
    return tex
}

load_texture :: proc(desc: TextureDesc, data: []u8, arena: ^eau.Arena = nil) -> ^Texture {
    width,height, chans: i32
    image.set_flip_vertically_on_load(1)
    pixels := image.load_from_memory(raw_data(data), i32(len(data)), &width, &height, &chans, 4)
    assert(pixels != nil)

    tex := create_texture(desc, pixels, u32(width), u32(height), arena)
    tex.stbi_pixels = true
    return tex
}

delete_texture :: proc(tex: ^Texture) {
    gl.DeleteTextures(1, raw_data( []u32{ tex.id } ))
    if tex.stbi_pixels do image.image_free(tex.pixels)

    if tex.dest != nil do tex.dest.data = nil
    _hook.remove_object(tex.idx)
    free(tex)
}

// this sets the uniform aswell!
bind_texture :: proc(tex: ^Texture, slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, tex.id)
    gl.Uniform1i(i32(slot), i32(slot))
}

get_texture_color :: proc(tex: ^Texture, #any_int x,y: u32) -> [4]f32 {
    i := (x + y * tex.width) * 4
    return { 
        f32(tex.pixels[i + 0]) / 255,
        f32(tex.pixels[i + 1]) / 255,
        f32(tex.pixels[i + 2]) / 255,
        f32(tex.pixels[i + 3]) / 255,
    }
}

set_texture_color :: proc(tex: ^Texture, #any_int x,y: u32, col: [4]f32) {
    i := (x + y * tex.width) * 4
    tex.pixels[i + 0] = u8(col.r * 255)
    tex.pixels[i + 1] = u8(col.g * 255)
    tex.pixels[i + 2] = u8(col.b * 255)
    tex.pixels[i + 3] = u8(col.a * 255)
}

apply_texture_changes :: proc(tex: ^Texture) {
    gl.BindTexture(gl.TEXTURE_2D, tex.id)

    gl.TexSubImage2D(
        gl.TEXTURE_2D,
        0,
        0,0,
        i32(tex.width), i32(tex.height),
        TYPECONV_texture_type_as_f(tex.desc.type),
        TYPECONV_texture_type_as_type(tex.desc.type),
        tex.pixels
        )

    gl.BindTexture(gl.TEXTURE_2D, 0)
}



@private
TYPECONV_texture_filter :: proc(filter: TextureFilter) -> i32 {
    switch filter {
    case .Nearest: return gl.NEAREST
    case .Linear:  return gl.LINEAR
    }

    assert(false)
    return 0
}

@private
TYPECONV_texture_wrap :: proc(wrap: TextureWrap) -> i32 {
    switch wrap {
    case .Repeat: return gl.REPEAT
    case .Clamp:  return gl.CLAMP_TO_EDGE
    case .Color:  return gl.CLAMP_TO_BORDER
    }

    assert(false)
    return 0
}

@private
TYPECONV_texture_type_as_intf :: proc(type: TextureType) -> i32 {
    switch type {
    case .Color: return gl.RGBA8
    case .Depth: return gl.DEPTH_COMPONENT24
    case .Hdr: return gl.RGBA16F
    case .Hdr32: return gl.RGBA32F
    }

    assert(false)
    return 0
}

@private
TYPECONV_texture_type_as_f :: proc(type: TextureType) -> u32 {
    switch type {
    case .Color: return gl.RGBA
    case .Depth: return gl.DEPTH_COMPONENT
    case .Hdr: return gl.RGBA
    case .Hdr32: return gl.RGBA
    }

    assert(false)
    return 0
}

@private
TYPECONV_texture_type_as_type :: proc(type: TextureType) -> u32 {
    switch type {
    case .Color: return gl.UNSIGNED_BYTE
    case .Depth: return gl.UNSIGNED_INT
    case .Hdr: return gl.HALF_FLOAT
    case .Hdr32: return gl.FLOAT
    }

    assert(false)
    return 0
}
