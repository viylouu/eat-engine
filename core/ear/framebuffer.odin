package ear

import "core:fmt"

import "../eaw"

import gl "vendor:OpenGL"

Framebuffer :: struct{
    id: u32,

    desc: FramebufferDesc,
}

FramebufferDesc :: struct{
    out_colors: []^Texture,
    out_depth: ^Texture,
}

create_framebuffer :: proc(desc: FramebufferDesc) -> Framebuffer {
    fb := Framebuffer{ desc = desc }

    gl.GenFramebuffers(1, &fb.id)
    gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)

    assert(len(desc.out_colors) > 0)

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

    gl.DrawBuffers(i32(len(dbufs)), raw_data(dbufs))

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

    return fb
}

delete_framebuffer :: proc(fb: Framebuffer) {
    gl.DeleteFramebuffers(1, raw_data([]u32 { fb.id }))
}

// can provide nil to unbind
bind_framebuffer :: proc(fb: ^Framebuffer) {
    if fb != nil {
        gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)
        gl.Viewport(0,0, i32(fb.desc.out_colors[0].width), i32(fb.desc.out_colors[0].height))
    } else {
        gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
        gl.Viewport(0,0, i32(eaw.width), i32(eaw.height))
    }
}
