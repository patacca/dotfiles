-- Standard awesome library
local gears =		require("gears")
local awful =		require("awful")
awful.rules =		require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox =		require("wibox")
-- Theme handling library
local beautiful =	require("beautiful")
-- Other
local naughty =		require("naughty")
local vicious =		require("vicious")
--local menubar =		require("menubar")
local drop =		require("scratchdrop")
local lain =		require("lain")
local blingbling =	require("blingbling")
local string =		require("string")
local alttab =		require("alttab")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

home		= os.getenv("HOME")
confdir		= home .. "/.config/awesome"
themes		= confdir .. "/themes"
active_theme	= themes .. "/patacca"
musicdir	= home .. "/Musica"
language	= string.gsub(os.getenv("LANG"), ".utf8", "")

beautiful.init(active_theme .. "/theme.lua")

terminal	= "urxvt" -- One day my friend, one day...
--terminal	= "xterm"
editor		= os.getenv("EDITOR") or "vim"
editor_cmd	= terminal .. " -e " .. editor
browser		= "firefox"
--mail		= terminal .. " -e mutt "
musicplr	= terminal .. " -g l30x34-320+16 -e ncmpcpp "

-- Default modkeys.

modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- Tags
tags = {
	names = {"➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒"},
	layout = {layouts[1], layouts[8], layouts[4], layouts[8], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]}
}
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
-- }}}

-- Menubar configuration
--menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Wibox
markup = lain.util.markup
separators = lain.util.separators

-- Popups functions
function hide_popup()
	if popup ~= nil then
		naughty.destroy(popup)
		popup = nil
	end
end
function show_popup(args)
	local args		= args or {}
	local title		= args.title or ""
	local text		= ""
	if type(args.text) == "function" then text = args.text() else text = args.text end
	local icon		= args.icon or ""
	
	hide_popup(popup)
	popup = naughty.notify({
		title = title,
		text = text,
		icon = icon,
		timeout = 0,
		hover_timeout = 0.5
	})
end

--- {{{ TOP BAR }}}

-- Textclock + calendar
mytextclock = lain.widgets.abase({
    timeout  = 1,
    cmd      = "date +'%a %d %b %T'",
    settings = function()
	local t_output = ""
	local o_it = string.gmatch(output, "%S+")

	for i=1,3 do t_output = t_output .. " " .. o_it(i) end
        widget:set_markup(" " .. markup("#7788af", t_output) .. markup("#343639", " > ") .. markup("#de5e1e", o_it(1)))
    end
})
lain.widgets.calendar:attach(mytextclock, { font_size = 12 })

-- Net
netwidget = blingbling.net.new({
	interface = "wlp3s0",
	show_text = true,
	text_color = "#83AC75",
	graph_color = "#12A4E5"
})
blingbling.popups.netstat(netwidget, {
	title_color = beautiful.notify_font_color_1,
	established_color = beautiful.notify_font_color_2,
	listen_color = beautiful.notify_font_color_3
})
netwidget:set_ippopup()

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = wibox.widget.textbox()
vicious.register( batwidget, vicious.widgets.bat, '$1$2% ($3) [$4]', 11, "BAT0" )

stop_warning = false
local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

local function bat_notification()
  local f_capacity = io.open("/sys/class/power_supply/BAT0/capacity", "r")
  local f_status = io.open("/sys/class/power_supply/BAT0/status", "r")
  if f_capacity == nil or f_status == nil then
    return false
  end

  local bat_capacity = tonumber(f_capacity:read("*all"))
  local bat_status = trim(f_status:read("*all"))
  local bat_status_preset = { font = "Insonsolata 15" }
  local threshold = 15

  if (bat_capacity > threshold and stop_warning) then
    stop_warning = false
  end

  if (bat_capacity <= threshold and bat_status == "Discharging" and not stop_warning) then
    naughty.notify({
	title = "Battery Warning",
	text = "Battery low! " .. bat_capacity .."%" .. " left!",
	fg = "#ffffff",
	bg = "#C91C1C",
	timeout = 10,
	position = "top_right"
    })
    stop_warning = true
  end
end

battimer = timer({timeout = 37})
battimer:connect_signal("timeout", bat_notification)
battimer:start()

-- File system usage
fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
fswidget = lain.widgets.fs({
    timeout = 307,
    partition = "/home",
    settings  = function()
        widget:set_text(" " .. fs_now.used .. "% (" .. string.sub(tostring(fs_now.available*fs_now.size_gb/100), 0, 4) .. " GB)")
    end
})

-- WIFI
wifiicon = wibox.widget.imagebox()
trash = lain.widgets.net({
    timeout = 7,
    settings = function ()
        high_signal = tostring(62)
        medhigh_signal = tostring(45)
        med_signal = tostring(32)
        medlow_signal = tostring(19)

        local link = awful.util.pread("iwconfig wlp3s0 | awk -F '=' '/Quality/ {print $2}' | cut -d '/' -f 1")

        if net_now.state == "Off" or link == "" then
            wifiicon:set_image(beautiful.widget_wifi_no)
        elseif link > high_signal then
            wifiicon:set_image(beautiful.widget_wifi_high)
        elseif link > medhigh_signal and link <= high_signal then
            wifiicon:set_image(beautiful.widget_wifi_medhigh)
        elseif link > med_signal and link <= medhigh_signal then
            wifiicon:set_image(beautiful.widget_wifi_med)
        elseif link > medlow_signal and link <= med_signal then
            wifiicon:set_image(beautiful.widget_wifi_medlow)
        else
            wifiicon:set_image(beautiful.widget_wifi_low)
        end
    end
})

wifiwidget = wibox.widget.textbox()
vicious.register(
	wifiwidget,
	vicious.widgets.wifi,
	function(widget, args)
		if args["{ssid}"] == "N/A" then
			return " - "
		else
			return " - " .. markup("#1793D0", args["{ssid}"]) .. " "
		end
	end,
	7,
	"wlp3s0"
)

-- WIFI Popups
local function get_netinfo()
	local str = awful.util.pread("ifconfig")
	str = string.gsub(str, "<", "&lt;")
	str = string.gsub(str, ">", "&gt;")
	str = string.gsub(str, "([a-z0-9]-: )", '<span color="' .. beautiful.notify_font_color_1 .. '">%1</span>')
	str = string.gsub(str, "([0-9]*%.[0-9]*%.[0-9]*%.[0-9]*)", '<span color="' .. beautiful.notify_font_color_2 .. '">%1</span>')
	str = string.gsub(str, "ether ([0-9a-z][0-9a-z]:[0-9a-z:]*:[0-9a-z][0-9a-z])", 'ether <span color="' .. beautiful.notify_font_color_2 .. '">%1</span>')
	return str
end
local function get_wifiinfo()
	local str = awful.util.pread("iwconfig")
	str = string.gsub(str, "<", "&lt;")
	str = string.gsub(str, ">", "&gt;")
	str = string.gsub(str, "^([a-z0-9]- )", '<span color="' .. beautiful.notify_font_color_1 .. '">%1</span>')
	str = string.gsub(str, "Access Point: ([0-9A-Z][0-9A-Z]:[0-9A-Z:]*:[0-9A-Z][0-9A-Z])", 'Access Point: <span color="' .. beautiful.notify_font_color_2 .. '">%1</span>')
	str = string.gsub(str, "Link Quality=([0-9]*/[0-9]*)", 'Link Quality=<span color="' .. beautiful.notify_font_color_3 .. '">%1</span>')
	str = string.gsub(str, "Signal level=(%-[0-9]*)", 'Signal level=<span color="' .. beautiful.notify_font_color_3 .. '">%1</span>')
	return str
end

wifiwidget:connect_signal("mouse::enter", function () show_popup({text = get_netinfo}) end)
wifiwidget:connect_signal("mouse::leave", hide_popup)
wifiicon:connect_signal("mouse::enter", function () show_popup({text = get_wifiinfo}) end)
wifiicon:connect_signal("mouse::leave", hide_popup)

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_markup(markup("#FFCC00", " " .. mem_now.used) .. "MB [" .. markup("#FFCC00", mem_now.swapused) .. "MB] ")
    end
})

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
    timeout = 3,
    settings = function()
        vlevel = " " .. volume_now.level .. "% "
        if volume_now.status == "off" then
            volicon:set_image(beautiful.widget_vol_mute)
            vlevel = " M "
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
        else
            volicon:set_image(beautiful.widget_vol)
        end

        widget:set_text(vlevel)
    end
})

volumewidget:buttons(awful.util.table.join(
    awful.button({}, 1, function ()
        awful.util.spawn("pavucontrol")
        volumewidget.update()
    end)
))

-- MPD
mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
mpd_notification = {
    icon = "/tmp/mpdcover.png"
}

function format_time(s)
   return string.format("%d:%.2d", math.floor(s/60), s%60)
end

mpdwidget = lain.widgets.mpd({
    music_dir = musicdir,
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist
            time = " " .. format_time(mpd_now.elapsed) .. "/" .. format_time(mpd_now.time) .. " "
            mpdicon:set_image(beautiful.widget_music_on)
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            time = "paused "
        else
            artist = ""
            time = " "
            mpdicon:set_image(beautiful.widget_music)
        end

        mpd_notification.title = mpd_notification_preset.title
        mpd_notification.text = mpd_notification_preset.text

        widget:set_markup(markup("#EA6F81", artist) .. time)
    end
})

mpdwidget:connect_signal("mouse::enter", function () show_popup(mpd_notification) end)
mpdwidget:connect_signal("mouse::leave", hide_popup)


--- {{{ BOTTOM BAR }}}

-- Uptime + Keyboard map indicator and changer
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
--mytextclock = awful.widget.textclock(" %a %d %b  %H:%M")
uptimewidget = wibox.widget.textbox()
uptimeicon = wibox.widget.imagebox(beautiful.widget_uptime, true)
uptimeiconbox = wibox.layout.margin()
uptimeiconbox:set_widget(uptimeicon)
uptimeiconbox:set_margins(3)
vicious.register(uptimewidget, vicious.widgets.uptime, markup("#DBDB2E", "$1") .. "d -- " .. markup("#DBDB2E", "$2") .. "h:" .. markup("#DBDB2E", "$3") .. "m (" .. markup("#FF1C4A", "$6") .. ")", 59)

kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "it", "" , "IT" }, { "us", "" , "US" } } 
kbdcfg.current = 1
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[3] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end

kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)

-- Coretemp + HDD temp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidgets = {}

tempwidgets[1] = wibox.widget.textbox()
vicious.register(tempwidgets[1], vicious.widgets.thermal, markup("#f1af5f", "$1") .. "°C | ", 7, {"thermal_zone1", "sys"})

for i = 2,6 do
	tempwidgets[i] = wibox.widget.textbox()
	if i ~= 6 then
		vicious.register(tempwidgets[i], vicious.widgets.thermal, markup("#f1af5f", "$1") .. "°C | ", 7, {"coretemp.0/hwmon/hwmon0", "core", "temp" .. i-1 .. "_input"})
	else
		vicious.register(tempwidgets[i], vicious.widgets.thermal, markup("#f1af5f", "$1") .. "°C || ", 7, {"coretemp.0/hwmon/hwmon0", "core", "temp" .. i-1 .. "_input"})
	end
end

tempwidgets[7] = wibox.widget.textbox()
vicious.register(tempwidgets[7], vicious.widgets.hddtemp, markup("#F1AF5F", "${/dev/sda}") .. "°C ", 7)

-- Cores frequency
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cpufreqwidget = wibox.widget.textbox()
vicious.register(
	cpufreqwidget,
	vicious.widgets.cpuinf,
	function(widget, args)
		format = ""
		for i = 0,6 do
			format = format .. args["{cpu" .. i .. " ghz}"] .. " GHz | "
		end
		format = format .. args["{cpu7 ghz}"] .. " GHz "
		return format
	end,
	7
)

-- Disk I/O
diskread_widget = awful.widget.graph({ width = 75})
diskread_widget:set_scale(true)
diskread_widget:set_color({
	type = "linear",
	from = { 0, 0 },
	to = { 75, 0 },
	stops = { { 0, "#FF5656" }, { 0.5, "#88A175" }, { 1, "#AECF96" }}
})
diskread_widget:set_border_color("#597FAB")
diskread_widget:set_background_color("#494B4F")
diskwrite_widget = awful.widget.graph({ width = 75})
diskwrite_widget:set_scale(true)
diskwrite_widget:set_color({
	type = "linear",
	from = { 0, 0 },
	to = { 75, 0 },
	stops = { { 0, "#FF5656" }, { 0.5, "#88A175" }, { 1, "#AECF96" }}
})
diskwrite_widget:set_border_color("#597FAB")
diskwrite_widget:set_background_color("#494B4F")

trash3 = wibox.widget.textbox()
vicious.register(trash3, vicious.widgets.dio, function (widget, args)
	diskwrite_widget:add_value(tonumber(args["{sda write_mb}"]))
	diskread_widget:add_value(tonumber(args["{sda read_mb}"]))
	return 0
end, 1)

-- MEM graph
memgraph = awful.widget.graph({ width = 75 })
memgraph:set_border_color("#597FAB")
memgraph:set_background_color("#494B4F")
memgraph:set_stack(true)
memgraph:set_stack_colors({
	"#119911",
	"#77ff77",
})

-- Unfortunately with vicious.register we can't pass more than 1 arg to widget:add_value
trash2 = wibox.widget.textbox()
vicious.register(trash, vicious.widgets.mem, function(widget, args)
	memgraph:add_value(args[1]/100, 1)
	memgraph:add_value((args[9]-args[2])/args[3], 2)
	return "-1"
end, 1)

-- CPU Cores Usage
cpuwidgets = {}
vicious.cache(vicious.widgets.cpu)

for i = 1,8 do
	cpuwidgets[i] = blingbling.progress_graph({width = 15, rounded_size = 0.3, graph_color = "#E52222", graph_line_color = "#597FAB80", graph_background_color = "#494B4F"})
	vicious.register(cpuwidgets[i], vicious.widgets.cpu, "$" .. i+1)
end
cpuwidgets[9] = awful.widget.graph()
cpuwidgets[9]:set_width(75)
cpuwidgets[9]:set_border_color("#597FAB")
cpuwidgets[9]:set_background_color("#494B4F")
cpuwidgets[9]:set_color({
	type = "linear",
	from = { 0, 0 },
	to = { 75, 0 },
	--stops = { { 0, "#FF5656" }, { 0.7, "#DDA175" }, { 1, "#88A175" }}
	stops = { { 0, "#FF5656" }, { 0.5, "#88A175" }, { 1, "#AECF96" }}
})
vicious.register(cpuwidgets[9], vicious.widgets.cpu, "$1")


-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)


-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, height = 22 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(spr)

    -- Widgets that are aligned to the upper right
    local right_layout_toggle = true
    local function right_add (layout, ...)
        local arg = {...}
        if right_layout_toggle then
            layout:add(arrl_ld)
            for i, n in pairs(arg) do
                layout:add(wibox.widget.background(n ,beautiful.bg_focus))
            end
        else
            layout:add(arrl_dl)
            for i, n in pairs(arg) do
                layout:add(n)
            end
        end
        right_layout_toggle = not right_layout_toggle
    end

    right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(arrl)
    right_add(right_layout, mpdicon, mpdwidget)
    right_add(right_layout, volicon, volumewidget)
    --right_add(right_layout, mailicon, mailwidget)
    right_add(right_layout, memicon, memwidget)
    --right_add(right_layout, cpuicon, cpuwidget)
    right_add(right_layout, spr, wifiicon, wifiwidget)
    right_add(right_layout, fsicon, fswidget)
    right_add(right_layout, baticon, batwidget)
    --right_add(right_layout, netdownicon, netdowninfo, netupicon, netupinfo)
    right_add(right_layout, netwidget)
    right_add(right_layout, mytextclock, spr)
    right_add(right_layout, mylayoutbox[s])

    bottom_left_layout = wibox.layout.fixed.horizontal()
    for i = 1,8 do
        bottom_left_layout:add(cpuwidgets[i])
    end
    bottom_left_layout:add(spr)
    bottom_left_layout:add(cpuwidgets[9])
    bottom_left_layout:add(spr)
    bottom_left_layout:add(memgraph)
    bottom_left_layout:add(spr)
    bottom_left_layout:add(diskread_widget)
    bottom_left_layout:add(spr)
    bottom_left_layout:add(diskwrite_widget)

    bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(arrl)
    right_layout_toggle = not right_layout_toggle
    right_add(bottom_right_layout, cpuicon, spr, cpufreqwidget)
    right_add(bottom_right_layout, tempicon, spr, unpack(tempwidgets))
    right_add(bottom_right_layout, uptimeiconbox, spr, uptimewidget, kbdcfg.widget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)
    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey, }, "q", function () mymainmenu:show() end),

    -- Custome key bindings
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.util.spawn("xbacklight -inc 2") end),
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.util.spawn("xbacklight -dec 2") end),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("amixer set Master 2%+", false)
        volumewidget.update()
    end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("amixer set Master 2%-", false)
        volumewidget.update()
    end),
    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("amixer set Master toggle", false)
        volumewidget.update()
    end),

    -- MPD control
    awful.key({ modkey, "Control" }, "Up", function () awful.util.spawn("mpc toggle", false) end),
    awful.key({ modkey, "Control" }, "Down", function () awful.util.spawn("mpc stop", false) end),
    awful.key({ modkey, "Control" }, "Right", function () awful.util.spawn("mpc next", false) end),
    awful.key({ modkey, "Control" }, "Left", function () awful.util.spawn("mpc prev", false) end),
    awful.key({ modkey, altkey    }, "Up", function () awful.util.spawn("mpc volume +5", false) end),
    awful.key({ modkey, altkey    }, "Down", function () awful.util.spawn("mpc volume -5", false) end),

    -- Show / Hide wiboxes
    awful.key({ altkey }, "t", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
    end),

    -- Widgets popups
    awful.key({ altkey, }, "q", function () lain.widgets.calendar:show(7) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
   awful.key({ altkey          }, "Tab", function () alttab.switch( 1, "Alt_L", "Tab", "ISO_Left_Tab") end),
   awful.key({ altkey, "Shift" }, "Tab", function () alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab") end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- User program
    awful.key({ altkey }, "m", function () awful.util.spawn_with_shell( "urxvt -e htop") end),
    awful.key({ altkey }, "c", function () awful.util.spawn( "chromium") end),
    awful.key({ altkey }, "f", function () awful.util.spawn( "firefox") end),
    awful.key({ altkey }, "i", function () awful.util.spawn( "firefox --private-window") end),
    awful.key({ altkey }, "p", function () awful.util.spawn( "pavucontrol") end),
    --awful.key({ altkey }, "e", function () awful.util.spawn( "thunar") end),
    awful.key({ altkey }, "e", function () awful.util.spawn( "pcmanfm") end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
    -- Menubar
    --awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- Move Windows with keyboard
    awful.key({ modkey, "Shift" }, "Down",  function () awful.client.moveresize(  0,  20, 0, 0) end),
    awful.key({ modkey, "Shift" }, "Up",    function () awful.client.moveresize(  0, -20, 0, 0) end),
    awful.key({ modkey, "Shift" }, "Left",  function () awful.client.moveresize(-20,   0, 0, 0) end),
    awful.key({ modkey, "Shift" }, "Right", function () awful.client.moveresize( 20,   0, 0, 0) end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
