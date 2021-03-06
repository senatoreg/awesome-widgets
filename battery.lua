local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local lgi = require 'lgi'
local Gtk = lgi.Gtk
local GtkIconTheme = Gtk.IconTheme.get_default()

-- battery-full-charging-symbolic
-- battery-full-charged-symbolic
-- battery-full-symbolic
-- battery-good-charging-symbolic
-- battery-good-symbolic
-- battery-low-charging-symbolic
-- battery-low-symbolic
-- battery-caution-charging-symbolic
-- battery-caution-symbolic
-- battery-empty-charging-symbolic
-- battery-empty-symbolic
-- battery-missing-symbolic

local battery = wibox.widget.imagebox()
local batterytextbox = wibox.widget.textbox()
local batterytooltip = awful.tooltip({
      objects = {batterytextbox},
      timer_function = function()
	 local b = vicious.widgets.bat("", "BAT0")
	 return "Level:       " .. b[2] .. "%\nRemaining: " .. b[3]
      end,
})
batterytooltip:set_timeout(3)
batterytooltip:add_to_object(battery)

-- Register widget
vicious.register(battery, vicious.widgets.bat,
  function(widget, args)
    local prefix = "battery-"
    local suffix = "-symbolic"
    local state
    local percentage
    local current
    local last
    if args[1] == '↯' then
      state = ""
    elseif args[1] == '+' then
      state = "-charging"
    elseif args[1] == '-' then
      state = ""
    end
    if args[2] == 100 then
        percentage = "full"
    elseif args[2] < 100 and args[2] >= 90 then
        percentage = "full"
    elseif args[2] < 90 and args[2] >= 80 then
        percentage = "good"
    elseif args[2] < 80 and args[2] >= 70 then
        percentage = "good"
    elseif args[2] < 70 and args[2] >= 60 then
        percentage = "good"
    elseif args[2] < 60 and args[2] >= 50 then
        percentage = "good"
    elseif args[2] < 50 and args[2] >= 40 then
        percentage = "low"
    elseif args[2] < 40 and args[2] >= 30 then
        percentage = "low"
    elseif args[2] < 30 and args[2] >= 20 then
        percentage = "low"
    elseif args[2] < 20 and args[2] >= 10 then
        percentage = "caution"
	-- naughty.notify({ title="Battery Low.", text="Battery level " .. args[2] .. "%", timeout=3 })
    elseif args[2] < 10 then
       percentage = "empty"
       if state ~= "-charging" then naughty.notify({ title="Battery Empty!", text="Battery level " .. args[2] .. "%\nRemaining ".. args[3], timeout=3, bg="#ff0000", fg="#000000" }) end
    end
      current = prefix .. percentage .. state .. suffix
      if last ~= current then
          local GtkIconInfo = GtkIconTheme:lookup_icon(prefix .. percentage .. state .. suffix, 24, 0 )
          widget:set_image( GtkIconInfo:get_filename() )
          last = current
      end
  end,
3, "BAT0")

return battery
