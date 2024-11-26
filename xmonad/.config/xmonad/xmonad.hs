import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import Graphics.X11.ExtraTypes.XF86
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Actions.SpawnOn
import System.IO


myTerminal = "wezterm"
weztermWithTmux = "wezterm start tmux new -As main"
myBrowser = "firefox"
telegram = "telegram-desktop"
vscode = "code"

myNormalBorderColor = "#CBC3E3" -- light purple
myFocusedBorderColor = "#AA336A" -- dark pink
myWorkspaces = ["1:term", "2:browser", "3:editor", "4:chat"] ++ map show[5..9]

-- Color of current window title in xmobar.
xmobarTitleColor = "#C678DD"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#51AFEF"

myStartupHook = do
    spawnOn "1:term" weztermWithTmux
    spawnOn "2:browser" myBrowser
    spawnOn "3:editor" vscode
    spawnOn "4:chat" telegram


main = do
    xmproc <- spawnPipe "xmobar ~/.config/xmonad/xmobarrc.hs"

    xmonad $ def
        { manageHook = manageDocks <+> manageHook def
        , layoutHook = avoidStruts $ layoutHook def
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
                        , ppTitle = xmobarColor xmobarTitleColor "" . shorten 50
                        }
        , modMask = mod4Mask -- Use Super instead of Alt
        , normalBorderColor = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , terminal = myTerminal
        , workspaces = myWorkspaces
        -- , startupHook = myStartupHook
        -- more changes
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "betterlockscreen -l")
        , ((mod4Mask .|. shiftMask, xK_q), spawn "rofi -show power-menu -modi power-menu:rofi-power-menu")
        , ((mod4Mask, xK_b), spawn myBrowser)
        , ((mod4Mask, xK_p), spawn "rofi -show drun")
        , ((0, xF86XK_PowerDown),         spawn "sudo systemctl suspend")
        , ((0, xF86XK_AudioRaiseVolume),  spawn "amixer -D pulse sset Master 10%+")
        , ((0, xF86XK_AudioLowerVolume),  spawn "amixer -D pulse sset Master 10%-")
        , ((0, xF86XK_AudioMute),         spawn "amixer -D pulse sset Master toggle")
        , ((0, xF86XK_MonBrightnessUp),   spawn "brightnessctl set +10%")
        , ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl set 10%-")
        ]
