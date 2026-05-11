local hookfunction   = hookfunction or replaceclosure or detour_function
local hookmetamethod = hookmetamethod
local newcclosure    = newcclosure or function(f) return f end
local getgenv        = getgenv or function() return _G end
if not hookfunction then return end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local myName = Players.LocalPlayer.Name

local RANKS = {
    "AK OWNER", "AK CO OWNER", "AK STAFF", "AK SUPPORT", "AK BOOSTER",
    "AK MOMMY", "AK PERKZ", "CONTENT CREATOR", "AK GHOST", "AK KING",
    "AK SCAR", "AK TWILIGHT", "AK BREEZY", "AK PIPER", "AK SNOWPEEP",
    "STAFF-MANAGER", "AK SUMI...???", "AK ELEVEN", "AK GRIEF",
}

local selected = nil
local done = Instance.new("BindableEvent")

local gui = Instance.new("ScreenGui")
gui.Name = "RankSelector"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 0.4
bg.BorderSizePixel = 0

local panel = Instance.new("Frame", bg)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(360, 440)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
panel.BorderSizePixel = 0
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Pick your rank"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local sub = Instance.new("TextLabel", panel)
sub.Position = UDim2.fromOffset(0, 40)
sub.Size = UDim2.new(1, 0, 0, 20)
sub.BackgroundTransparency = 1
sub.Text = myName
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.TextColor3 = Color3.fromRGB(170, 170, 180)

local scroll = Instance.new("ScrollingFrame", panel)
scroll.Position = UDim2.fromOffset(10, 70)
scroll.Size = UDim2.new(1, -20, 1, -80)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.fromOffset(0, #RANKS * 38)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)

for _, rankName in ipairs(RANKS) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.BorderSizePixel = 0
    btn.Text = rankName
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        selected = rankName
        gui:Destroy()
        done:Fire()
    end)
end

done.Event:Wait()


local fakeWhitelist = '{"users":["' .. myName .. '","SAYROX","LOVESYOU"]}'

local tagsTable = {}
for _, r in ipairs(RANKS) do tagsTable[r] = {} end
tagsTable[selected] = { myName }
tagsTable["BOOSTER_MAPPING"] = {}

local function jsonEncode(t)
    return game:GetService("HttpService"):JSONEncode(t)
end
local fakeTags = jsonEncode(tagsTable)

local function isWL(url)   return type(url) == "string" and url:lower():find("whitelist", 1, true) ~= nil end
local function isTags(url) return type(url) == "string" and url:find("Tags%.json") ~= nil end
local function spoofFor(url)
    if isWL(url)   then return fakeWhitelist end
    if isTags(url) then return fakeTags end
end

pcall(function()
    local orig
    orig = hookfunction(game.HttpGet, newcclosure(function(self, url, ...)
        local s = spoofFor(url); if s then return s end
        return orig(self, url, ...)
    end))
end)

pcall(function()
    local orig
    orig = hookfunction(game.HttpGetAsync, newcclosure(function(self, url, ...)
        local s = spoofFor(url); if s then return s end
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
            local s = spoofFor(args[1]); if s then return s end
        end
        return origNamecall(self, ...)
    end))
end)

local function wrap(orig)
    return newcclosure(function(opts)
        local s = spoofFor(opts.Url or opts.url or "")
        if s then
            return { Body = s, StatusCode = 200, Success = true,
                     Headers = {["Content-Type"] = "application/json"} }
        end
        return orig(opts)
    end)
end
pcall(function() if syn and syn.request then syn.request = wrap(syn.request) end end)
pcall(function() if http and http.request then http.request = wrap(http.request) end end)
pcall(function() if http_request then getgenv().http_request = wrap(http_request) end end)
pcall(function() if request then getgenv().request = wrap(request) end end)

print("Spoofing " .. myName .. " as " .. selected)
print("Sayrox bummed this script")
print("Much luv<3")
loadstring(game:HttpGet("https://absent.wtf/AKADMIN.lua"))()
