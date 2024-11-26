Config { font = "JetBrainsMono Nerd Font Normal 10"
        , borderColor = "black"
        , border = TopB
        , bgColor = "black"
        , fgColor = "grey"
        , position = TopW L 100
        , commands = [ Run Cpu ["-L","3","-H","50","--normal","green","--high","red"] 10
                        , Run Memory ["-t","Mem: <usedratio>%"] 10
                        -- , Run Swap [] 10
                        -- , Run Com "uname" ["-s","-r"] "" 36000
                        -- , Run Com "stalonetray" [] "" 0
                        -- , Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
                        , Run Date "<fc=#ECBE7B><fn=1></fn></fc> %a %b %_d %I:%M" "date" 300
                        , Run Battery ["-t", "Battery: <left>% (<timeleft>)", "-L", "20", "-H", "80", "-l", "#ff5555", "-n", "#ffff55", "-h", "#55ff55"] 10
                        , Run Com "./.config/xmonad/volume.sh" [] "volume" 10
                        , Run Com "xkb-switch" [] "" 10
                        , Run Com "hostname" [] "" 0
                        , Run Com "whoami" [] "" 0
                        , Run StdinReader
                    ]
        , sepChar = "%"
        , alignSep = "}{"
        , template = "%StdinReader% }{ %cpu% | %memory% | %date% | %battery% | %volume% | %xkb-switch% | %whoami%@%hostname%"
        }
