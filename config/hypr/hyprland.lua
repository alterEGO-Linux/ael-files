-- ----------------------------------------------------------------------------
-- [+] INFO
-- ----------------------------------------------------------------------------
-- [/ael-files/config/hypr/hyprland.lua]
-- 
-- Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
-- Created     : 2026-05-13 07:45:12 UTC
-- Updated     : 2026-08-28 18:35:52 UTC
-- Description : Hyprland Lua configuration.
-- ----------------------------------------------------------------------------

-- Picture-in-picture module.
require("picture_in_picture")

-- ----------------------------------------------------------------------------
-- [+] DEFAULT APPLICATIONS
-- ----------------------------------------------------------------------------

local TERMINAL = "alacritty"
local FILE_MANAGER = "pcmanfm-qt"
local WEB_BROWSER = "firefox"

-- [+] ------------------------------------------------------------| monitor(s)

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

-- [+] -----------------------------------------------------------| environment

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_SIZE", "24")

-- ----------------------------------------------------------------------------
-- [+] AUTOLAUNCH
-- ----------------------------------------------------------------------------

hl.on("hyprland.start", function()
    -- hyprpm
    -- hl.exec_cmd("hyprpm reload -n")

    -- {polkit}
    -- ref: https://wiki.hyprland.org/Hypr-Ecosystem/hyprpolkitagent/
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- {kb_monitor}
    -- Monitor keyboard layout.
    hl.exec_cmd("~/.config/hypr/scripts/kb_monitor.sh")

    --| bluetooth
    -- hl.exec_cmd("blueman-applet")

    --| network manager
    -- hl.exec_cmd("nm-applet")

    --| waybar
    -- hl.exec_cmd("waybar")

    -- {waypaper}
    hl.exec_cmd("waypaper --restore")

    -- {ael-bar}
    hl.exec_cmd("quickshell -c ael-bar")

end)

-- [+] -----------------------------------------------------------------| input

hl.config({
    input = {
        kb_layout = "us,ca",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",

        follow_mouse = 1,

        touchpad = {
            natural_scroll = false,
        },

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})

-- [+] -----------------------------------------------------------| look & feel

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,

        col = {
            active_border = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",

        -- ref: https://wiki.hyprland.org/Configuring/Tearing/
        allow_tearing = false,
    },

    group = {
        col = {
            border_active = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
        },

        groupbar = {
            font_size = 18,
            scrolling = true,
        },
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },

    animations = {
        enabled = true,
    },
})

-- [+] -------------------------------------------------------------| animation

hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- [+] ---------------------------------------------------------------| layouts

hl.config({

    dwindle = {
        --| ref. https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})

-- [+] ------------------------------------------------------------------| misc

hl.config({
    misc = {
        force_default_wallpaper = 0, -- Set to 0 to disable the anime mascot wallpapers.
    },
})


-- [+] ----------------------------------------------------------------| device

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ----------------------------------------------------------------------------
-- [+] KEYBINDING
-- ----------------------------------------------------------------------------

local mainMod = "SUPER"

-- Small helper for old dispatchers that do not yet have obvious Lua helpers.
local function dispatch(command)
    return hl.dsp.exec_cmd("hyprctl dispatch " .. command)
end

-- [*] Reload Hyprland configuration
hl.bind(
    mainMod .. " + CTRL + R",
    hl.dsp.exec_cmd("hyprctl reload")
)

-- [+] APPLICATION CAROUSEL

local carousel = "qs -c ael-carousel ipc call carousel "

-- Cycle through open applications.
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd(carousel .. "next"))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.exec_cmd(carousel .. "previous"))

-- SUPER+RETURN is already reserved for the terminal, so CTRL is added here.
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd(carousel .. "activate"))

-- Do not bind bare Escape globally; it must remain available to applications.
hl.bind(mainMod .. " + SHIFT + ESCAPE", hl.dsp.exec_cmd(carousel .. "close"))

-- [+] WINDOWS

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })) -- Toggle fullscreen
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close()) -- Kill active window
hl.bind(mainMod .. " + CTRL + X", hl.dsp.exit()) -- Exit Hyprland
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo()) -- Pseudo dwindle
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit")) -- Toggle split dwindle
hl.bind(mainMod .. " + SHIFT + G", dispatch("togglegroup")) -- Toggle group
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.float({ action = "toggle" })) -- Toggle window floating

-- [+] SCRATCHPAD

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic")) -- Toggle scratchpad "magic"
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" })) -- Move window to scratchpad "magic"

-- [+] MOVING AROUND

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0

    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ----------------------------------------------------------------------------
-- [+] KEYBINDING: APPLICATIONS
-- ----------------------------------------------------------------------------

-- {ael-bar} reload -> WIN+CTRL+B
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("quickshell -c ael-bar kill; quickshell -c ael-bar"))

-- [+] ael-menu
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd('alacritty -t "ael-menu" -e "ael-menu"'))

-- [+] file manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(FILE_MANAGER))

-- [+] screenshots
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("grimblast copy area"))

-- [+] terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(TERMINAL))

-- [+] volume
-- Launch pavucontrol
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("pavucontrol"))

-- Audio buttons
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true, repeating = true })

-- {wallpaper} -> WIN+W
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waypaper"))

-- [+] waybar
-- Reload waybar
-- hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("killall waybar && waybar &"))

-- [+] ----------------------------------------------------------| window rules

hl.window_rule({
    name = "float-ael-menu",
    match = { title = ".*ael-menu.*" },
    float = true,
})

hl.window_rule({
    name = "float-pcmanfm",
    match = { class = "pcmanfm" },
    float = true,
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
})

hl.window_rule({
    name = "float-waypaper",
    match = { class = "waypaper" },
    float = true,
})
