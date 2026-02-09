package ear

import gl "vendor:OpenGL"

TexArray :: struct{
    id: u32,

    // all textures must be same res!
    // format will be obtained from texarray
    texs: []^Texture,

    desc: TexArrayDesc,
    
    delete: proc(texarray: TexArray),
    bind: proc(texarray: TexArray, slot: u32), // this sets the uniform aswell!
    add: proc(texarray: ^TexArray, tex: ^Texture, #any_int layer: u32),
    update: proc(texarray: TexArray),
    update_layer: proc(texarray: TexArray, #any_int layer: u32),
}

TexArrayDesc :: struct{
    filter: TextureFilter,
    //type: TextureType, // assumed color
    wrap: TextureWrap,
        wrap_color: [4]f32,

    width: u32,
    height: u32,
    layers: u32,
}


create_tex_array :: proc(desc: TexArrayDesc) -> TexArray {
    texarray := TexArray{ 
        desc = desc,

        texs = make([]^Texture, desc.layers),

        delete = delete_tex_array,
        add = add_to_tex_array,
        update = update_tex_array,
        update_layer = update_tex_array_layer,
    }

    gl.GenTextures(1, &texarray.id)
    assert(texarray.id != 0)

    gl.BindTexture(gl.TEXTURE_2D_ARRAY, texarray.id)

    sampling := TYPECONV_texture_filter(desc.filter)
    wrap := TYPECONV_texture_wrap(desc.wrap)

    gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, sampling)
    gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, wrap)
    gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, wrap)
    col := []f32{ desc.wrap_color.r, desc.wrap_color.g, desc.wrap_color.b, desc.wrap_color.a }
    gl.TexParameterfv(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_BORDER_COLOR, raw_data(col))

    gl.TexImage3D(
        gl.TEXTURE_2D_ARRAY,
        0,
        gl.RGBA8,
        i32(desc.width),
        i32(desc.height),
        i32(desc.layers),
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        nil,
        )

    gl.BindTexture(gl.TEXTURE_2D_ARRAY, 0)

    return texarray
}

delete_tex_array :: proc(texarray: TexArray) {
    delete(texarray.texs)
}

// this sets the uniform aswell!
bind_tex_array :: proc(texarray: TexArray, slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D_ARRAY, texarray.id)
    gl.Uniform1i(i32(slot), i32(slot))
}

add_to_tex_array :: proc(texarray: ^TexArray, tex: ^Texture, #any_int layer: u32) {
    texarray.texs[layer] = tex

    gl.TexSubImage3D(
        gl.TEXTURE_2D_ARRAY,
        0,
        0, 0, 
        i32(layer),
        i32(texarray.desc.width),
        i32(texarray.desc.height),
        1,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        tex.pixels,
        )
}

update_tex_array :: proc(texarray: TexArray) {
    for tex,i in texarray.texs {
        if tex == nil do continue
        texarray->update_layer(i)
    }
}

update_tex_array_layer :: proc(texarray: TexArray, #any_int layer: u32) {
    gl.TexSubImage3D(
        gl.TEXTURE_2D_ARRAY,
        0,
        0, 0, 
        i32(layer),
        i32(texarray.desc.width),
        i32(texarray.desc.height),
        1,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        texarray.texs[layer].pixels,
        )
}
