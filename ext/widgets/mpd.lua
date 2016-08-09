-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch }
local helpers = require("vicious.helpers")
sock = require("socket.core")
pass = nil
host = nil
port = nil
-- }}}


-- Mpd: provides Music Player Daemon information
-- vicious.widgets.mpd
local mpd = {}


local function play_pause_toggle()
   if host == nil or port == nil then
      return
   end

   local c = assert(sock.connect(host,port))
   local s = c:receive('*l')
   local status = ""

   c:send("status\n")
   while true do
      s = c:receive('*l')
      if s == "OK" then break end
      for k, v in string.gmatch(s, "([%w]+):[%s](.*)$") do
	 if k == "state" then
	    if v == "play" then
	       c:send("pause\n")
	       status = "pause"
	    else
	       c:send("play\n")
	       status = "start"
	    end
	 end
       end
   end
   c:close()
   return status
end

local function play_stop_toggle()
   if host == nil or port == nil then
      return
   end
   
   local c = assert(sock.connect(host,port))
   local s = c:receive('*l')
   local status = ""

   c:send("status\n")
   while true do
      s = c:receive('*l')
      if s == "OK" then break end
      for k, v in string.gmatch(s, "([%w]+):[%s](.*)$") do
	 if k == "state" then
	    if v == "stop" then
	       c:send("play\n")
	       status = "start"
	    else
	       c:send("stop\n")
	       status = "stop"
	    end
	 end
       end
   end
   c:close()
   return status
end

-- {{{ MPD widget type
local function worker(format, warg)
    local mpd_state  = {
        ["{volume}"] = 0,
        ["{state}"]  = "N/A",
        ["{Artist}"] = "N/A",
        ["{Title}"]  = "N/A",
        ["{Album}"]  = "N/A",
        ["{Genre}"]  = "N/A",
        --["{Name}"] = "N/A",
        --["{file}"] = "N/A",
    }

    -- Fallback to MPD defaults
    pass = warg and (warg.password or warg[1]) or "\"\""
    host = warg and (warg.host or warg[2]) or "127.0.0.1"
    port = warg and (warg.port or warg[3]) or "6600"

    -- Construct MPD client options
    local c = assert(sock.connect(host,port))
    
    local s = c:receive('*l')

    c:send("status\n")
    while true do
       s = c:receive('*l')
       if s == "OK" then break end
       for k, v in string.gmatch(s, "([%w]+):[%s](.*)$") do
            if     k == "volume" then mpd_state["{"..k.."}"] = v and tonumber(v)
            elseif k == "state"  then mpd_state["{"..k.."}"] = helpers.capitalize(v)
            end
        end
    end
    
    c:send("currentsong\n")
    while true do
       s = c:receive('*l')
       if s == "OK" then break end
       for k, v in string.gmatch(s, "([%w]+):[%s](.*)$") do
            if     k == "Artist" then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Title"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Album"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            elseif k == "Genre"  then mpd_state["{"..k.."}"] = helpers.escape(v)
            --elseif k == "Name" then mpd_state["{"..k.."}"] = helpers.escape(v)
	    --elseif k == "file" then mpd_state["{"..k.."}"] = helpers.escape(v)
	    end
       end
    end

    c:close()
    
    return mpd_state
end
-- }}}

mpd.play_pause_toggle = play_pause_toggle
mpd.play_stop_toggle = play_stop_toggle
return setmetatable(mpd, { __call = function(_, ...) return worker(...) end })
