hs.loadSpoon("ReloadConfiguration")
hs.loadSpoon("BingDaily")
spoon.ReloadConfiguration:start()
hs.alert.show("Config loaded")

hs.window.animationDuration = 0

local window = require("hs.window")
local spaces = require("hs.spaces")
local allScreens = hs.screen.allScreens()

--function focusOnScreen(num)
    --local allScreens = hs.screen.allScreens()
    --allspaces = nil
    
    --for i=0,#allScreens do
        --allspaces[i-1] = spaces.activeSpaceOnScreen(allScreens[i-1])
    --end
    --spaces.gotoSpace(allspaces[num-1])
--end

function isInScreen(screen, win)
  return win:screen() == screen
end

function focusOnScreen(screen, num)
  --Get windows within screen, ordered from front to back.
  --If no windows exist, bring focus to desktop. Otherwise, set focus on
  --front-most application window.
  if screen then
      local windows = hs.fnutils.filter(
          hs.window.orderedWindows(),
          hs.fnutils.partial(isInScreen, screen))
      local windowToFocus = #windows > 0 and windows[1] or hs.window.desktop()
      if windowToFocus then
          windowToFocus:focus()
      else
          hs.alert.show("bad windows")
      end

      -- Move mouse to center of screen
      local pt = hs.geometry.rectMidPoint(screen:fullFrame())
      hs.mouse.absolutePosition(pt)

      hs.alert.show("Swith to Screen "..tostring(num), nil, screen)
  else
      hs.alert.show("Screen is not avilable...")
  end
end

function getGoodFocusedWindow(nofull)
   local win = window.focusedWindow()
   if not win or not win:isStandard() then return end
   if nofull and win:isFullScreen() then return end
   return win
end

function flashScreen(screen)
   local flash=hs.canvas.new(screen:fullFrame()):appendElements({
	 action = "fill",
	 fillColor = { alpha = 0.25, red=1},
	 type = "rectangle"})
   flash:show()
   hs.timer.doAfter(.15,function () flash:delete() end)
end

function switchSpace(skip,dir)
   for i=1,skip do
      hs.eventtap.keyStroke({"ctrl","fn"},dir,0) -- "fn" is a bugfix!
   end
end

function moveWindowOneSpace(dir,switch)
   local win = getGoodFocusedWindow(true)
   if not win then return end
   local screen=win:screen()
   local uuid=screen:getUUID()
   local userSpaces=nil
   for k,v in pairs(spaces.allSpaces()) do
      userSpaces=v
      if k==uuid then break end
   end
   if not userSpaces then return end
   local thisSpace=spaces.windowSpaces(win) -- first space win appears on
   if not thisSpace then return else thisSpace=thisSpace[1] end
   local last=nil
   local skipSpaces=0
   for _, spc in ipairs(userSpaces) do
      if spaces.spaceType(spc)~="user" then -- skippable space
	 skipSpaces=skipSpaces+1
      else
	 if last and
	    ((dir=="left" and spc==thisSpace) or
	     (dir=="right" and last==thisSpace)) then
	       local newSpace=(dir=="left" and last or spc)
	       if switch then
		  -- spaces.gotoSpace(newSpace)  -- also possible, invokes MC
		  switchSpace(skipSpaces+1,dir)
	       end
	       spaces.moveWindowToSpace(win,newSpace)
	       return
	 end
	 last=spc	 -- Haven't found it yet...
	 skipSpaces=0
      end
   end
   flashScreen(screen)   -- Shouldn't get here, so no space found
end

mash =      {"cmd", "ctrl"}
mashshift = {"cmd", "ctrl","shift"}

hs.hotkey.bind(mash, "s",nil,
	    function() moveWindowOneSpace("right",true) end)
hs.hotkey.bind(mash, "a",nil,
	    function() moveWindowOneSpace("left",true) end)
hs.hotkey.bind(mashshift, "s",nil,
	    function() moveWindowOneSpace("right",false) end)
hs.hotkey.bind(mashshift, "a",nil,
	    function() moveWindowOneSpace("left",false) end)

hs.hotkey.bind({"alt", "cmd"}, "Left", function() 
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen=win:screen()
    local max = screen:frame()
    
    f.x = max.x
    f.y = max.y
    f.w = max.w / 2.0
    f.h = max.h
    win:setFrame(f)
end)

hs.hotkey.bind({"alt", "cmd"}, "Right", function() 
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen=win:screen()
        local max = screen:frame()
        
        f.y = max.y
        f.w = max.w / 2.0
        f.x = max.x + max.w - f.w
        f.h = max.h
        win:setFrame(f)
    end
end)


--hs.hotkey.bind({"alt", "cmd"}, "Left", function() 
    --local win = hs.window.focusedWindow()
    --local f = win:frame()
    --local screen=win:screen()
    --local max = screen:frame()
    
    --win:moveToUnit({0, 0, 0.5, 1})
--end)

--hs.hotkey.bind({"alt", "cmd"}, "Right", function() 
    --local win = hs.window.focusedWindow()
    --local f = win:frame()
    --local screen=win:screen()
    --local max = screen:frame()
    
    --win:moveToUnit({0.5, 0, 0.5, 1})
--end)

hs.hotkey.bind({"alt", "cmd"}, "f", function() 
    local win = hs.window.focusedWindow()
    win:toggleZoom()
end)

hs.hotkey.bind({"cmd", "shift"}, "f", function() 
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen=win:screen()
    local max = screen:frame()

    win:setFrame(max)
end)

hs.hotkey.bind({"cmd", "shift"}, "f", function() 

    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen=win:screen()
    local max = screen:frame()

    win:setFrame(max)
end)

-- change focus
hs.hotkey.bind({"cmd", "alt"}, "l", function() hs.window.filter.focusEast() end)
hs.hotkey.bind({"cmd", "alt"}, "h", function() hs.window.filter.focusWest() end)
hs.hotkey.bind({"cmd", "alt"}, "j", function() hs.window.filter.focusSouth() end)
hs.hotkey.bind({"cmd", "alt"}, "k", function() hs.window.filter.focusNorth() end)


--hs.hotkey.bind({"alt", "cmd"}, "Right", function() 

-- set up your instance(s)
--expose = hs.expose.new(nil,{showThumbnails=false}) -- default windowfilter, no thumbnails
--expose_min = hs.expose.new{'Google Chrome', 'iTerm2'} -- default windowfilter, no thumbnails
expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application
expose_all = hs.expose.new(nil,{includeOtherSpaces=true, showThumbnails=false}) -- only windows in the current Mission Control Space
expose_cur_space = hs.expose.new(nil,{includeOtherSpaces=false, showThumbnails=false}) -- only windows in the current Mission Control Space
--expose_browsers = hs.expose.new{'Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- for your dozens of browser windows :)

-- then bind to a hotkey
hs.hotkey.bind('alt-cmd','a','Expose All',function()expose_all:toggleShow()end)
hs.hotkey.bind('alt-cmd','e','Expose',function()expose_cur_space:toggleShow()end)
hs.hotkey.bind('alt-cmd','p','App Expose',function()expose_app:toggleShow()end)
--hs.hotkey.bind('alt-cmd','m','Expose Min',function()expose_browsers:toggleShow()end)

function movetospace(num)
    --local spaces = require("hs.spaces")
    local win = hs.window.focusedWindow()
    local screen=win:screen()
    local spaceID_cur = spaces.activeSpaceOnScreen(screen)
    local spaceIDs = spaces.spacesForScreen(screen)
    --print(spaces.spaceName(spaceID_cur))
    print(spaceID_cur)
    spaces.moveWindowToSpace(win,spaceIDs[num])
    spaces.gotoSpace(spaceIDs[num]) 
end 

hs.hotkey.bind({"ctrl", "alt"}, "1", function() focusOnScreen(allScreens[3], 1)  end)
hs.hotkey.bind({"ctrl", "alt"}, "2", function() focusOnScreen(allScreens[1], 2)  end)
hs.hotkey.bind({"ctrl", "alt"}, "3", function() focusOnScreen(allScreens[2], 3) end)

hs.hotkey.bind({"cmd", "alt"}, "1", function() movetospace(1) end)
hs.hotkey.bind({"cmd", "alt"}, "2", function() movetospace(2) end)
hs.hotkey.bind({"cmd", "alt"}, "3", function() movetospace(3) end)
hs.hotkey.bind({"cmd", "alt"}, "4", function() movetospace(4) end)
hs.hotkey.bind({"cmd", "alt"}, "6", function() movetospace(6) end)

-- proxy profile select

function change_profile( pname )
    -- if hs.application.launchOrFocus("Proxifier") then
    --     hs.alter.show("yes")
    -- else
    --     hs.alter.show("no")
    -- end
    hs.application.launchOrFocus("Proxifier")
    local proxifer=hs.appfinder.appFromName("Proxifier")
    local str_local_menu = {"File", "Load Profile", "localproxy"}
    local str_router_menu = {"File", "Load Profile", "routerproxy"}
    local local_menu = proxifer:findMenuItem(str_local_menu)
    local router_menu = proxifer:findMenuItem(str_router_menu)
    if pname == 'local' then
        if (router_menu['ticked'] and local_menu) then
            proxifer:selectMenuItem(str_local_menu)
            hs.alert.show("Local proxy enabled")
        end
    else 
        if (local_menu['ticked'] and router_menu) then
            proxifer:selectMenuItem(str_router_menu)
            hs.alert.show("Router proxy enabled")
        end
    end
    proxifer:hide()

end

function focus_or_new_tab_iterm()
    hs.application.enableSpotlightForNameSearches(true)
    local appname="com.googlecode.iterm2"

    if hs.application.launchOrFocusByBundleID(appname) ~= nil then
        hs.alert.show(appname.." started")
    else
        hs.alert.show(appname.." failed to open")
    end
end


function manage_ss(signal)
    --local appname="ShadowsocksX-NG"
    local appname="com.qiuyuzhou.ShadowsocksX-NG"
    local short_name="ShadowsocksX-NG-R8"
    local ss=hs.application.find(appname)

    if signal == 'close' then
        if ss ~= nil then
            ss:kill()
            hs.alert.show(short_name.." closed")
        end
    elseif signal == 'open' then
        if hs.application.launchOrFocusByBundleID(appname) ~= nil then
            hs.alert.show(short_name.." started")
        else
            hs.alert.show(short_name.." failed to open")
        end
    end

end



wifiWatcher = nil
--homeSSID = "SHAO"
homeSSID = {"VolcanNet", "Mandalorian5", "Mandalorian"}
lastSSID = hs.wifi.currentNetwork()
homebin_pro = os.getenv("HOME") .. "/bin/pro"

function ssidChangedCallback()
    local hostname = hs.execute("hostname")
    if  string.match(hostname,'iMac') == nil then
    
        newSSID = hs.wifi.currentNetwork()

        local function contains(table, val)
           for i=1,#table do
              if table[i] == val then
                 return true
              end
           end
           return false
        end

        if contains(homeSSID, newSSID) then
            -- We just joined our home WiFi network
            if newSSID == "VolcanNet" then 
                cmd = "ALL_PROXY=socks5://192.168.1.1:1081  '\"$@\"'"
                change_profile("officerouter")
            else
                cmd = "ALL_PROXY=socks5://192.168.1.1:1082  '\"$@\"'"
                change_profile("router")
            end
            hs.execute("echo "..cmd.." >| "..homebin_pro)
            --hs.execute("launchctl unload ~/Library/LaunchAgents/com.ss_plugins.kcptun.plist")
            --hs.execute("launchctl unload ~/Library/LaunchAgents/com.ss_plugins.obfs.plist")
            manage_ss('close')
        else
            -- We just departed our home WiFi network
            change_profile("local")
            cmd = "ALL_PROXY=socks5://127.0.0.1:1086 https_proxy=127.0.0.1:1087 '\"$@\"'"
            hs.execute("echo "..cmd.." >| "..homebin_pro)
            --hs.execute("launchctl load ~/Library/LaunchAgents/com.ss_plugins.kcptun.plist")
            --hs.execute("launchctl load ~/Library/LaunchAgents/com.ss_plugins.obfs.plist")
            manage_ss('open')
        end

        lastSSID = newSSID
    end
end

--wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
--wifiWatcher:start()

function switch_ss(signal)
    if signal == 'local' then
        change_profile("local")
        cmd = "ALL_PROXY=socks5://127.0.0.1:1086 https_proxy=127.0.0.1:1087 '\"$@\"'"
        hs.execute("echo "..cmd.." >| "..homebin_pro)
        manage_ss('open')
    else
        change_profile("router")
        cmd = "ALL_PROXY=socks5://192.168.1.6:5321 '\"$@\"'"
        hs.execute("echo "..cmd.." >| "..homebin_pro)
        manage_ss('close')
    end
end

function download_youtube()
    local url = hs.pasteboard.getContents()
    if url ~= nil then
        started = hs.execute("~/bin/ydown '"..hs.pasteboard.getContents().."'", true)

        if started ~=nil then 
            if started then
                hs.alert.show("Downlowding started")
            end
        else
            hs.alert.show("Error! Please try again")
        end
    end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "y", download_youtube)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "s", function() switch_ss('local')end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "w", function() switch_ss('router')end)

hs.hotkey.bind({"cmd", "alt"}, "return", function()
    local iterm = hs.application.find("iTerm") 
	if iterm then
            hs.applescript.applescript([[
                    tell application "iTerm"
                            create window with default profile
                    end tell
            ]])
	else
		hs.application.open("iTerm")
	end
end)

