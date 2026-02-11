package ear

import "core:fmt"
import "core:math/linalg/glsl"

import "../eaw"
import "../eau"

import gl "vendor:OpenGL"

Framebuffer :: struct{
    id: u32,

    desc: FramebufferDesc,

    delete: proc(fb: ^Framebuffer),
    bind: proc(fb: ^Framebuffer),
}

FramebufferDesc :: struct{
    out_colors: []^Texture,
    out_depth: ^Texture,
    width: u32,
    height: u32,
}

create_framebuffer :: proc(desc: FramebufferDesc, arena: ^eau.Arena = nil) -> ^Framebuffer {
    fb := new_clone(Framebuffer{ 
        desc = desc,

        delete = delete_framebuffer,
        bind = bind_framebuffer,
    })

    gl.GenFramebuffers(1, &fb.id)
    gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)

    dbufs := make([dynamic]u32)
    for col, i in desc.out_colors {
        gl.FramebufferTexture2D(
            gl.FRAMEBUFFER,
            u32(gl.COLOR_ATTACHMENT0 + i),
            gl.TEXTURE_2D,
            col.id,
            0,
            )
        append(&dbufs, u32(gl.COLOR_ATTACHMENT0 + i))
    }

    if len(dbufs) > 0 do gl.DrawBuffers(i32(len(dbufs)), raw_data(dbufs))
    else do gl.DrawBuffer(gl.NONE)

    if desc.out_depth != nil {
        gl.FramebufferTexture2D(
            gl.FRAMEBUFFER,
            gl.DEPTH_ATTACHMENT,
            gl.TEXTURE_2D,
            desc.out_depth.id,
            0,
            )
    }

    if gl.CheckFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE {
        fmt.eprintln("framebuffer incomplete!")
        assert(false)
    }

    delete(dbufs)

    gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)

    if arena != nil do arena->add(fb, rawptr(delete_framebuffer))
    return fb
}

delete_framebuffer :: proc(fb: ^Framebuffer) {
    gl.DeleteFramebuffers(1, raw_data([]u32 { fb.id }))

    free(fb)
}

// can provide nil to unbind
bind_framebuffer :: proc(fb: ^Framebuffer) {
    flush()

    if fb != nil {
        w,h := fb.desc.width, fb.desc.height

        gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)
        gl.Viewport(0,0, i32(w), i32(h))
        proj = glsl.mat4Ortho3d(0, f32(w), 0, f32(h), 0,1)
    } else {
        gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
        gl.Viewport(0,0, i32(eaw.width), i32(eaw.height))
        proj = glsl.mat4Ortho3d(0, f32(eaw.width), f32(eaw.height), 0, 0,1)
    }
}

