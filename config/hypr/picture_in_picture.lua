-- ----------------------------------------------------------------------------
-- [+] INFO
-- ----------------------------------------------------------------------------
-- [/ael-files/config/hypr/picture-in-picture.lua]
-- 
-- Author      : Pascal Malouin (https://github.com/fantomH)
-- Created     : 2026-08-28 18:00:45 UTC
-- Updated     : 2026-08-28 18:00:45 UTC
-- Description : description
-- +--------------------------------------------------------------------------+

-- AEL picture-in-picture rules for Hyprland 0.56+
-- Import from ~/.config/hypr/hyprland.lua with: require("pip")

local function add_pip_rule(name, match)
    hl.window_rule({
        name = name,
        match = match,

        -- All application-specific PiP windows become one logical AEL target.
        tag = "+ael-pip",

        float = true,
        pin = true,
        size = { 576, 324 },
        move = {
            "monitor_w-window_w-20",
            "monitor_h-window_h-60"
        },

        no_initial_focus = true,
        focus_on_activate = false,
        keep_aspect_ratio = true,
        content = "video",
        render_unfocused = true,
        no_dim = true,
        border_size = 2,
        rounding = 8
    })
end

-- Firefox
add_pip_rule("ael-pip-firefox", {
    class = "^firefox$",
    initial_title = "^Picture-in-Picture$"
})

-- Chromium's native Wayland PiP surface currently reports an empty class.
add_pip_rule("ael-pip-chromium", {
    initial_title = "^Picture in picture$"
})

