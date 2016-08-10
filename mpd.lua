local awful = require("awful")
local wibox = require("wibox")
local lgi = require 'lgi'
local Gtk = lgi.Gtk
local GtkIconTheme = Gtk.IconTheme.get_default()
local extwidgetsmpd = require("ext.widgets.mpd")

-- Initialize widget
-- mpdwidget = wibox.widget.textbox()
mpdwidget = wibox.widget.imagebox()
local buttons = awful.util.table.join(
   awful.button({ }, 1, function()
	 local state = extwidgetsmpd.play_pause_toggle()
	 local GtkIconInfo = GtkIconTheme:lookup_icon("media-playback-" .. state .. "-symbolic", 24, 0)
	 mpdwidget:set_image( GtkIconInfo:get_filename())
   end),
   awful.button({ }, 3, function()
	 local state = extwidgetsmpd.play_stop_toggle()
	 local GtkIconInfo = GtkIconTheme:lookup_icon("media-playback-" .. state .. "-symbolic", 24, 0)
	 mpdwidget:set_image( GtkIconInfo:get_filename())
   end)
)
mpdwidget:buttons(buttons)
local mpdtextbox = wibox.widget.textbox()
local mpdtooltip = awful.tooltip({
      objects = {mpdtextbox},
      timer_function = function()
	 song = extwidgetsmpd("",nil)
	 return song["{Artist}"] .. "\n" .. song["{Title}"] .. "\n" .. song["{Album}"]
      end,
})
mpdtooltip:set_timeout(3)
mpdtooltip:add_to_object(mpdwidget)

-- Register widget
vicious.register(mpdwidget, extwidgetsmpd,
		 function (widget, args)
		    local last = ""
		    local state = stop
		    local current = args["{state}"]
		    if last ~= current then
		       if args["{state}"] == "Stop" then
			  state = "stop"
		       elseif args["{state}"] == "Pause" then
			  state = "pause"
		       elseif args["{state}"] == "Play" then
			  state = "start"
		       end
		       local GtkIconInfo = GtkIconTheme:lookup_icon("media-playback-" .. state .. "-symbolic", 24, 0)
		       widget:set_image( GtkIconInfo:get_filename())
		       last = current
		    end
		 end, 10)

return mpdwidget
