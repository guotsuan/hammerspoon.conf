--- === BingDaily ===
---
--- Use Bing daily picture as your wallpaper, automatically.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/BingDaily.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/BingDaily.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "BingDaily"
obj.version = "1.1"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- BingDaily.uhd_resolution
--- Variable
--- If `true`, download image in UHD resolution instead of HD. Defaults to `false`.
obj.uhd_resolution = false

local user_agent_str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
local json_req_url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1"
local cache_dir = os.getenv("HOME") .. "/wallpapers"

local function cachePath(file_name)
    hs.fs.mkdir(cache_dir)
    return cache_dir .. "/" .. file_name
end

local function fullImageURL(pic_url)
    if pic_url:match("^https?://") then
        return pic_url
    end
    return "https://www.bing.com" .. pic_url
end

local function curl_callback(exitCode, stdOut, stdErr)
    if exitCode == 0 then
        obj.task = nil
        obj.last_pic = obj.file_name
        local localpath = cachePath(obj.file_name)

        -- set wallpaper for all screens
        local allScreen = hs.screen.allScreens()
        for _,screen in ipairs(allScreen) do
            screen:desktopImageURL("file://" .. localpath)
        end
    else
        obj.task = nil
        print(stdOut, stdErr)
    end
end

local function bingRequest()
    hs.http.asyncGet(json_req_url, {["User-Agent"]=user_agent_str}, function(stat,body,header)
        if stat == 200 then
            local ok, decode_data = pcall(function() return hs.json.decode(body) end)
            if not ok or type(decode_data) ~= "table" or type(decode_data.images) ~= "table" or type(decode_data.images[1]) ~= "table" then
                print("BingDaily: invalid Bing JSON response")
                return
            end

            local pic_url = decode_data.images[1].url
            if type(pic_url) ~= "string" or pic_url == "" then
                print("BingDaily: Bing response did not include an image URL")
                return
            end

            if obj.uhd_resolution then
                pic_url = pic_url:gsub("1920x1080", "UHD")
            end

            local pic_name = "pic-temp-spoon.jpg"
            local url_parts = hs.http.urlParts(pic_url) or {}
            for _, v in pairs(url_parts.queryItems or {}) do
                if v.id then
                    pic_name = v.id
                    break
                end
            end

            if obj.last_pic ~= pic_name then
                obj.file_name = pic_name
                obj.full_url = fullImageURL(pic_url)
                if obj.task then
                    obj.task:terminate()
                    obj.task = nil
                end
                local localpath = cachePath(obj.file_name)
                obj.task = hs.task.new("/usr/bin/curl", curl_callback, {"-fL", "-A", user_agent_str, obj.full_url, "-o", localpath})
                obj.task:start()
            end
        else
            print("Bing URL request failed!")
        end
    end)
end

function obj:init()
    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(3*60*60, function() bingRequest() end)
        obj.timer:setNextTrigger(5)
    else
        obj.timer:start()
    end
end

return obj
