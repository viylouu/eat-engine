package ear

import "core:fmt"

import gl "vendor:OpenGL"
import "vendor:stb/image"

Texture :: struct{
    id: u32,

    width: u32,
    height: u32,

    desc: TextureDesc,
}

TextureDesc :: struct{
    filter: TextureFilter,
    type: TextureType
}

TextureFilter :: enum{
    Nearest,
    Linear,
}

TextureType :: enum{
    Color,
    Depth,
}

create_texture :: proc(desc: TextureDesc, pixels: [^]u8, width, height: u32) -> Texture {
    tex := Texture{ desc = desc, width = width, height = height }

    gl.GenTextures(1, &tex.id)
    assert(tex.id != 0)

    gl.BindTexture(gl.TEXTURE_2D, tex.id)

    sampling := TYPECONV_texture_filter(tex.desc.filter)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

    gl.TexImage2D(
        gl.TEXTURE_2D,
        0,
        desc.type == .Color? gl.RGBA : gl.DEPTH_COMPONENT24,
        i32(width), i32(height),
        0,
        desc.type == .Color? gl.RGBA : gl.DEPTH_COMPONENT,
        gl.UNSIGNED_BYTE,
        pixels
        )

    gl.BindTexture(gl.TEXTURE_2D, 0)

    return tex
}

load_texture :: proc(desc: TextureDesc, data: []u8) -> Texture {
    width,height, chans: i32
    pixels := image.load_from_memory(raw_data(data), i32(len(data)), &width, &height, &chans, 4)
    assert(pixels != nil)

    defer image.image_free(pixels)

    tex := create_texture(desc, pixels, u32(width), u32(height))
    return tex
}

delete_texture :: proc(tex: Texture) {
    gl.DeleteTextures(1, raw_data( []u32{ tex.id } ))
}

// this sets the uniform aswell!
bind_texture :: proc(tex: Texture, slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, tex.id)
    gl.Uniform1i(i32(slot), i32(slot))
}



@private
TYPECONV_texture_filter :: proc(filter: TextureFilter) -> i32 {
    switch filter {
    case .Nearest:
        return gl.NEAREST
    case .Linear:
        return gl.LINEAR
    }

    assert(false)
    return 0
}


