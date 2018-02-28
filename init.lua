hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
hs.alert.show("Config loaded")


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
    local f = win:frame()
    local screen=win:screen()
    local max = screen:frame()
    
    f.y = max.y
    f.w = max.w / 2.0
    f.x = max.x + max.w - f.w
    f.h = max.h
    win:setFrame(f)
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
expose_all = hs.expose.new(nil,{includeOtherSpaces=true}) -- only windows in the current Mission Control Space
expose_cur_space = hs.expose.new(nil,{includeOtherSpaces=false}) -- only windows in the current Mission Control Space
--expose_browsers = hs.expose.new{'Safari','Google Chrome'} -- specialized expose using a custom windowfilter
-- for your dozens of browser windows :)

-- then bind to a hotkey
hs.hotkey.bind('alt-cmd','a','Expose All',function()expose_all:toggleShow()end)
hs.hotkey.bind('alt-cmd','e','Expose',function()expose_cur_space:toggleShow()end)
hs.hotkey.bind('alt-cmd','p','App Expose',function()expose_app:toggleShow()end)
--hs.hotkey.bind('alt-cmd','m','Expose Min',function()expose_browsers:toggleShow()end)

function movetospace(num)
    local spaces = require("hs._asm.undocumented.spaces")
    local win = hs.window.focusedWindow()
    local screen=win:screen()
    local spaceID_cur = spaces.activeSpace()
    local spaceIDs = screen:spaces()
    --print(spaces.spaceName(spaceID_cur))
    print(spaceID_cur)
    win:spacesMoveTo(spaceIDs[num])
end 

hs.hotkey.bind({"cmd", "alt"}, "1", function() movetospace(1) end)
hs.hotkey.bind({"cmd", "alt"}, "2", function() movetospace(2) end)
hs.hotkey.bind({"cmd", "alt"}, "3", function() movetospace(3) end)
hs.hotkey.bind({"cmd", "alt"}, "4", function() movetospace(4) end)

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

function manage_ss(signal)
    --local appname="ShadowsocksX-NG"
    local appname="com.qiuyuzhou.ShadowsocksX-NG"
    local ss=hs.application.find(appname)

    if signal == 'close' then
        if ss ~= nil then
            ss:kill()
            hs.alert.show(appname.." closed")
        end
    elseif signal == 'open' then
        if hs.application.launchOrFocusByBundleID(appname) ~= nil then
            hs.alert.show(appname.." started")
        else
            hs.alert.show(appname.." failed to open")
        end
    end

end



wifiWatcher = nil
--homeSSID = "SHAO"
homeSSID = "ChinaNet-503"
lastSSID = hs.wifi.currentNetwork()
homebin_pro = os.getenv("HOME") .. "/bin/pro"

function ssidChangedCallback()
    local hostname = hs.execute("hostname")
    if  string.match(hostname,'iMac') == nil then
    
        newSSID = hs.wifi.currentNetwork()

        if newSSID == homeSSID and lastSSID ~= homeSSID then
            -- We just joined our home WiFi network
            change_profile("router")
            cmd = "ALL_PROXY=socks5://192.168.1.254:23456 '\"$@\"'"
            hs.execute("echo "..cmd.." >| "..homebin_pro)
            --hs.execute("launchctl unload ~/Library/LaunchAgents/com.ss_plugins.kcptun.plist")
            --hs.execute("launchctl unload ~/Library/LaunchAgents/com.ss_plugins.obfs.plist")
            manage_ss('close')
        elseif newSSID ~= homeSSID and lastSSID == homeSSID then
            -- We just departed our home WiFi network
            change_profile("local")
            cmd = "ALL_PROXY=socks5://127.0.0.1:1086 '\"$@\"'"
            hs.execute("echo "..cmd.." >| "..homebin_pro)
            --hs.execute("launchctl load ~/Library/LaunchAgents/com.ss_plugins.kcptun.plist")
            --hs.execute("launchctl load ~/Library/LaunchAgents/com.ss_plugins.obfs.plist")
            manage_ss('open')
        end

        lastSSID = newSSID
    end
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

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


