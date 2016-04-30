
--[[
                                             
     Powerarrow Darker Awesome WM config 2.0 
     github.com/copycat-killer               
                                             
--]]

theme                               = {}

theme_dir                           = os.getenv("HOME") .. "/.config/awesome/themes/patacca"
theme.icons                         = theme_dir .. "/icons/"
theme.wallpaper                     = theme_dir .. "/wall.png"

theme.font                          = "Dejavu Sans Mono 9"
theme.fg_normal                     = "#DDDDFF"
theme.fg_focus                      = "#F0DFAF"
theme.fg_urgent                     = "#CC9393"
theme.bg_normal                     = "#1A1A1A"
theme.bg_focus                      = "#313131"
theme.bg_urgent                     = "#1A1A1A"
theme.border_width                  = "1"
theme.border_normal                 = "#3F3F3F"
theme.border_focus                  = "#7F7F7F"
theme.border_marked                 = "#CC9393"
theme.titlebar_bg_focus             = "#FFFFFF"
theme.titlebar_bg_normal            = "#FFFFFF"
theme.tasklist_bg_focus             = "#1A1A1A"
theme.tasklist_fg_focus             = "#D8D782"
theme.textbox_widget_margin_top     = 1
theme.notify_fg                     = theme.fg_normal
theme.notify_bg                     = theme.bg_normal
theme.notify_border                 = theme.border_focus
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2
theme.mouse_finder_color            = "#CC9393"
theme.menu_height                   = "16"
theme.menu_width                    = "140"

-- Taglist
theme.taglist_fg_focus              = "#D8D782"
theme.taglist_squares_sel           = theme.icons .. "panel/taglist/square_sel.png"
theme.taglist_squares_unsel         = theme.icons .. "panel/taglist/square_unsel.png"
theme.taglist_font                  = "Cantarell Bold 12"

-- Widget
theme.widget_uptime                 = theme.icons .. "panel/widget/uptime.png"
theme.widget_ac                     = theme.icons .. "panel/widget/ac.png"
theme.widget_battery                = theme.icons .. "panel/widget/battery.png"
theme.widget_battery_low            = theme.icons .. "panel/widget/battery_low.png"
theme.widget_battery_empty          = theme.icons .. "panel/widget/battery_empty.png"
theme.widget_mem                    = theme.icons .. "panel/widget/mem.png"
theme.widget_cpu                    = theme.icons .. "panel/widget/cpu.png"
theme.widget_temp                   = theme.icons .. "panel/widget/temp.png"
theme.widget_netdown                = theme.icons .. "panel/widget/net_down.png"
theme.widget_netup                  = theme.icons .. "panel/widget/net_up.png"
theme.widget_net                    = theme.icons .. "panel/widget/net.png"
theme.widget_hdd                    = theme.icons .. "panel/widget/hdd.png"
theme.widget_music                  = theme.icons .. "panel/widget/note.png"
theme.widget_music_on               = theme.icons .. "panel/widget/note_on.png"
theme.widget_vol                    = theme.icons .. "panel/widget/vol.png"
theme.widget_vol_low                = theme.icons .. "panel/widget/vol_low.png"
theme.widget_vol_no                 = theme.icons .. "panel/widget/vol_no.png"
theme.widget_vol_mute               = theme.icons .. "panel/widget/vol_mute.png"
theme.widget_mail                   = theme.icons .. "panel/widget/mail.png"
theme.widget_mail_on                = theme.icons .. "panel/widget/mail_on.png"
theme.widget_wifi_high              = theme.icons .. "panel/widget/wifi_high.png"
theme.widget_wifi_medhigh           = theme.icons .. "panel/widget/wifi_medhigh.png"
theme.widget_wifi_med               = theme.icons .. "panel/widget/wifi_med.png"
theme.widget_wifi_medlow            = theme.icons .. "panel/widget/wifi_medlow.png"
theme.widget_wifi_low               = theme.icons .. "panel/widget/wifi_low.png"
theme.widget_wifi_no                = theme.icons .. "panel/widget/wifi_no.png"

-- Notification
theme.notify_font_color_1           = "#7fb219"
theme.notify_font_color_2           = "#ff6363"
theme.notify_font_color_3           = "#dbdb1e"

theme.submenu_icon                  = theme.icons .. "submenu.png"

theme.layout_tile                   = theme.icons .. "tile.png"
theme.layout_tilegaps               = theme.icons .. "tilegaps.png"
theme.layout_tileleft               = theme.icons .. "tileleft.png"
theme.layout_tilebottom             = theme.icons .. "tilebottom.png"
theme.layout_tiletop                = theme.icons .. "tiletop.png"
theme.layout_fairv                  = theme.icons .. "fairv.png"
theme.layout_fairh                  = theme.icons .. "fairh.png"
theme.layout_spiral                 = theme.icons .. "spiral.png"
theme.layout_dwindle                = theme.icons .. "dwindle.png"
theme.layout_max                    = theme.icons .. "max.png"
theme.layout_fullscreen             = theme.icons .. "fullscreen.png"
theme.layout_magnifier              = theme.icons .. "magnifier.png"
theme.layout_floating               = theme.icons .. "floating.png"

theme.arrl                          = theme.icons .. "arrl.png"
theme.arrl_dl                       = theme.icons .. "arrl_dl.png"
theme.arrl_ld                       = theme.icons .. "arrl_ld.png"

theme.tasklist_disable_icon         = true
theme.tasklist_floating             = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

return theme
