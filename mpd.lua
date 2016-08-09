local awful = require("awful")
local wibox = require("wibox")
local lgi = require 'lgi'
local Gtk = lgi.Gtk
local GtkIconTheme = Gtk.IconTheme.get_default()
local w = require("ext.widgets.mpd")

-- Initialize widget
-- mpdwidget = wibox.widget.textbox()
mpdwidget = wibox.widget.imagebox()
local buttons = awful.util.table.join(
   awful.button({ }, 1, function()
	 w.play_pause_toggle()
   end),
   awful.button({ }, 3, function()
	 w.play_stop_toggle()
   end)
)
mpdwidget:buttons(buttons)

-- Register widget
vicious.register(mpdwidget, w,
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
		       local GtkIconInfo = GtkIconTheme:lookup_icon("media-playback-" .. state, 10, 0)
		       widget:set_image( GtkIconInfo:get_filename())
		       last = current
		    end
		 end, 10)

return mpdwidget
