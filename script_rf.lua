local rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
print(("\n"):rep(20))

local window = rayfield:CreateWindow({
	Name = "Miners Haven",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "Please wait while the script is loading...",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "RayfieldTest",
		FileName = "MinersHaven"
	},
	KeySystem = false,
    KeySettings = {
		Title = "Sirius Hub",
		Subtitle = "Key System",
		Note = "Join the discord (discord.gg/sirius)",
		SaveKey = true,
		Key = "ABCDEF"
	}
})

rayfield:Notify("Loaded", "Script loaded!", 4483362458)

-- Locals
local username = game.Players.LocalPlayer.Name
local myFactory = game:GetService("Players").LocalPlayer.PlayerTycoon.Value
local moneyLibrary = require(game:GetService("ReplicatedStorage").MoneyLib)
-- END Locals

-- Global variables
local selectedLayout = "Layout 2"

local loadLayoutDelay = 5
local originalCFrame = nil

local isTeleporting = false
local autoRebirthRunning = false
local remoteDropEnabled = false

_G.loadLayoutAfterRebirth = false
_G.remoteDropEnabled = false
_G.autoLoopUpgraders = false
_G.Excavating = false
_G.cloverCollecting = false
_G.cloverCollectThread = nil
_G.boostOres = true
_G.loopTimes = 1
-- END Global variables

-- Helper funcs
function getDropped()
    local tbl = {}
    for _, v in pairs(game:GetService("Workspace").DroppedParts[myFactory.Name]:GetChildren()) do
        if v:IsA("BasePart") then
            table.insert(tbl, v)
        end
        -- table.insert(tbl, v)
    end
    return tbl
end 
function getUpgraders()
    tbl = {}
    for i,v in pairs(myFactory:GetChildren()) do
        if v:FindFirstChild("Model") then
            local model = v.Model
            if model and model:FindFirstChild("Upgrade") then
                table.insert(tbl,v)
            elseif model and model:FindFirstChild("Upgrader") then
                table.insert(tbl,v)
            elseif model and model:FindFirstChild("Cannon") then
                table.insert(tbl,v)
            end
        end
    end
    return tbl
end
-- Utility Tab
local utilitytab = window:CreateTab("Utility", 4483362458)
local conveyorsection = utilitytab:CreateSection("Conveyor Speed")

local speedSlider = utilitytab:CreateSlider({
	Name = "Conveyor Speed",
	Range = {0, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 1,
	Flag = "ConveyorSpeed",
    Callback = function(Value)
        if _G.speedEnabled == true then
            myFactory.AdjustSpeed.Value = Value
            print("Conveyor Speed set to " .. Value)
        end
    end,
})

local destroy = utilitytab:CreateKeybind({
    Name = "Close GUI",
    CurrentKeybind = "K",
    HoldToInteract = false,
    Flag = "CloseGUI",
    Callback = function()
        local success, message = pcall(function()
            autoRebirthRunning = false
            _G.remoteDropEnabled = false
            _G.autoLoopUpgraders = false
            _G.Excavating = false
            _G.cloverCollecting = false
            if _G.cloverCollectThread then
                task.cancel(_G.cloverCollectThread)
                _G.cloverCollectThread = nil
            end
            _G.boostOres = true
            rayfield:Destroy()
        end)

        if not success then
            print("An error occurred while closing the GUI: " .. tostring(message))
        end
    end
})

local autoremotedrop = utilitytab:CreateToggle({
    Name = "Auto Remote Drop",
    CurrentValue = false,
    Flag = "AutoRemoteDrop",
    Callback = function(Value)
        _G.remoteDropEnabled = Value
        if Value then
            task.spawn(function()
                while _G.remoteDropEnabled do
                    local success, message = pcall(function()
                        task.wait()
                        game:GetService("ReplicatedStorage").RemoteDrop:FireServer()
                    end)
                    if not success then
                        print("An error occurred during auto remote drop: " .. tostring(message))
                        _G.remoteDropEnabled = false
                    end
                end
            end)
        end
    end
})

local autosellores = utilitytab:CreateButton({
    Name = "Auto Sell Ores",
    Callback = function()
        for i,v in pairs(getDropped()) do
            -- TODO: Find smarter way of finding furnace
            if myFactory:FindFirstChild("Invasive Cyberlord") then
                firetouchinterest(v, myFactory["Invasive Cyberlord"].Model.Lava, 0)
                firetouchinterest(v, myFactory["Invasive Cyberlord"].Model.Lava, 1)
            end
        end
    end
})

local withdrawall = utilitytab:CreateButton({
    Name = "Withdraw All",
    Callback = function()
        game:GetService("ReplicatedStorage"):WaitForChild("DestroyAll"):InvokeServer()
    end,
})

local alwaysatbase = utilitytab:CreateToggle({
    Name = "Always at Base",
    CurrentValue = false,
    Flag = "AlwaysAtBase",
    Callback = function(Value)
        if Value then
            wait(0.1)
            game.Players.LocalPlayer.NearTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
            game.Players.LocalPlayer.ActiveTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
        
            if game.Players.LocalPlayer.NearTycoon.Value == nil then
                if Value then
                    wait(0.1)
                    game.Players.LocalPlayer.NearTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
                end
            end

            if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
                if Value then
                    wait(0.1)
                    game.Players.LocalPlayer.ActiveTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
                end
            end
        else
            wait(0.1)
            game.Players.LocalPlayer.NearTycoon.Value = nil
            game.Players.LocalPlayer.ActiveTycoon.Value = nil
            if game.Players.LocalPlayer.NearTycoon.Value == nil then
                if Value then
                    wait(0.1)
                    game.Players.LocalPlayer.NearTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
                end
            end
            if game.Players.LocalPlayer.ActiveTycoon.Value == nil then
                if Value then
                    wait(0.1)
                    game.Players.LocalPlayer.ActiveTycoon.Value = game.Players.LocalPlayer.PlayerTycoon.Value
                end
            end
        end
    end
})

-- Utility Tab END

-- Auto Rebirth Tab

local autorebirthtab = window:CreateTab("Auto Rebirth", 4483362458)

local autorebirthsection = autorebirthtab:CreateSection("Auto Rebirth")

local autorebirthtoggle = autorebirthtab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        autoRebirthRunning = Value
        if Value then
            task.spawn(function()
                while autoRebirthRunning do
                    local success, message = pcall(function()
                        task.wait()
                        if game:GetService("Players").LocalPlayer.PlayerGui.GUI.Money.Value >= moneyLibrary.RebornPrice(game:GetService("Players").LocalPlayer) and (game:GetService("Players").LocalPlayer.PlayerTycoon.Value:GetPivot().p - game.Players.LocalPlayer.Character:GetPivot().p).Magnitude <= 150 then
                            -- _G.boostOres = false
                            print("We have enough money for rebirth.")
                            game:GetService("ReplicatedStorage").Rebirth:InvokeServer(26)
                            print("loadLayoutAfterRebirth = " .. tostring(_G.loadLayoutAfterRebirth))
                            task.wait(0.25)
                            print("loadLayoutAfterRebirth = " .. tostring(_G.loadLayoutAfterRebirth))
                            if _G.loadLayoutAfterRebirth then
                                local layoutNumber = string.match(selectedLayout, "%d")
                                print("    Loading layout "..layoutNumber .. ". selectedLayout: " .. selectedLayout)
                                -- game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout" .. 3)
                                print("   layoutNumber: " .. layoutNumber .. " selectedLayout: " .. selectedLayout)
                                task.wait(loadLayoutDelay)
                                if selectedLayout == "Layout 2" then
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                elseif selectedLayout == "Layout 1" then
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                elseif selectedLayout == "Layout 3" then
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                end
                            end
                        end
                    end)

                    if not success then
                        print("An error occurred during auto rebirth: " .. tostring(message))
                    end

                    if not autoRebirthRunning then
                        break
                    end
                end
            end)
        end
    end
})

local autoloadsetupafterrebirth = autorebirthtab:CreateToggle({
    Name = "Auto Load Setup After Rebirth",
    CurrentValue = false,
    Flag = "AutoLoadSetupAfterRebirth",
    Callback = function(Value)
        _G.loadLayoutAfterRebirth = Value
    end
})

local layoutDropdown = autorebirthtab:CreateDropdown({
    Name = "Layout",
    Options = {"Layout 2", "Layout 1", "Layout 3"},
    CurrentOption = "Layout 3",
    Flag = "SelectedLayout",
    Callback = function(Option)
        print(Option)
        selectedLayout = Option[1] or "Layout 3"
    end
})

local delaySlider = autorebirthtab:CreateSlider({
    Name = "Load Layout Delay",
    Range = {0, 60},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 5,
    Flag = "LoadLayoutDelay",
    Callback = function(Value)
        loadLayoutDelay = Value
    end
})

-- Auto Rebirth Tab END

-- Ore boosting
local oreboostingtab = window:CreateTab("Ore Boosting", 4483362458)

local oreboostingsection = oreboostingtab:CreateSection("Ore Boosting")

local autoloopupgraderslabel1 = oreboostingtab:CreateLabel("Auto Loop Upgraders will loop all upgraders and then sell the ores.")
local autoloopupgraderslabel2 = oreboostingtab:CreateLabel("NOTE: Works best with a Tesla Resetter.")
local autoloopupgraderslabel3 = oreboostingtab:CreateLabel("NOTE: Do NOT use in public servers. You may get reported.")

local autoloopupgraders = oreboostingtab:CreateToggle({
    Name = "Auto Loop Upgraders",
    CurrentValue = true,
    Flag = "AutoLoopUpgraders",
    Callback = function(Value)
        _G.autoLoopUpgraders = Value
        if Value then
            task.spawn(function()
                while _G.autoLoopUpgraders do
                    local success, message = pcall(function()
                        local upgraders = getUpgraders()
                        local droppedOres = getDropped()
                        local teslaResetter = nil

                        for _, v in pairs(upgraders) do
                            if v.Name == "Tesla Resetter" then
                                -- print("Found Tesla Resetter")
                                teslaResetter = v
                                break
                            end
                            -- print("No Tesla Resetter found.")
                        end
                        -- print("teslaResetter: " .. tostring(teslaResetter))

                        -- local loopCount = teslaResetter and 2 or _G.loopTimes
                        -- print("    loopCount: " .. loopCount)

                        if #upgraders > 0 and #droppedOres > 0 then
                            for i, v2 in pairs(getDropped()) do
                                local upgraderCount = 0
                                local loopCount = teslaResetter and 2 or _G.loopTimes
                                for passCount = 1, loopCount do
                                    for i2, v in pairs(upgraders) do
                                        if not teslaResetter or v ~= teslaResetter and v.Model then
                                            upgraderCount = upgraderCount + 1
                                            if v.Model:FindFirstChild("Upgrade") and v.Model.Upgrade then
                                                firetouchinterest(v2,v.Model.Upgrade,0)
                                                task.wait()
                                                firetouchinterest(v2,v.Model.Upgrade,1)
                                            elseif v.Model:FindFirstChild("Upgrader") and v.Model.Upgrader then
                                                firetouchinterest(v2,v.Model.Upgrader,0)
                                                task.wait()
                                                firetouchinterest(v2,v.Model.Upgrader,1)
                                            elseif v.Model:FindFirstChild("Cannon") and v.Model.Cannon then
                                                firetouchinterest(v2,v.Model.Cannon,0)
                                                task.wait()
                                                firetouchinterest(v2,v.Model.Cannon,1)
                                            end
                                        end
                                    end

                                    if teslaResetter and teslaResetter.Model:FindFirstChild("Upgrade") then
                                        firetouchinterest(v2, teslaResetter.Model.Upgrade, 0)
                                        task.wait()
                                        firetouchinterest(v2, teslaResetter.Model.Upgrade, 1)
                                    end
                                end

                                print("Ore went through " .. upgraderCount .. " upgraders.")

                                if myFactory:FindFirstChild("Sacrificial Altar") then
                                    firetouchinterest(v2, myFactory["Sacrificial Altar"].Model.Lava, 0)
                                    firetouchinterest(v2, myFactory["Sacrificial Altar"].Model.Lava, 1)
                                end
                            end
                        else
                            print("No upgraders or dropped ores found")
                            task.wait(1)
                        end
                    end)

                    if not success then
                        print("An error occurred during auto loop upgraders: " .. tostring(message))
                    end
                end
            end)
        end
    end
})

local loopTimes = oreboostingtab:CreateSlider({
    Name = "Loop Times",
    Range = {1, 100},
    Increment = 1,
    Suffix = " (1-100)",
    CurrentValue = 1,
    Flag = "LoopTimes",
    Callback = function(Value)
        _G.loopTimes = Value
    end,
})

-- END Ore boosting

-- AntiAfk
if game.Players.LocalPlayer then
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end
-- END Antiafk

-- Crates
local cratestab = window:CreateTab("Crates", 4483362458)

local cratessection = cratestab:CreateSection("Crates")

local walktoboxes = cratestab:CreateToggle({
    Name = "Walk to Boxes",
    CurrentValue = false,
    Flag = "WalkToBoxes",
    Callback = function(Value)
        if Value then
            repeat
                wait(0.5)
                local boxesFolder = workspace:FindFirstChild("Boxes")
                if boxesFolder then
                    local currentBox = nil

                    for _, v in pairs(boxesFolder:GetChildren()) do
                        if v:IsA("BasePart") then
                            currentBox = v
                            break
                        end
                    end

                    if currentBox then
                        local humanoid = game.Players.LocalPlayer.Character.Humanoid
                        humanoid:MoveTo(currentBox.Position)
                        while humanoid:GetState() ~= Enum.HumanoidStateType.Jumping do
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            wait()
                        end
                    end
                end
            until not Value or not currentBox
        end
    end,
})

local teleporttoboxes = cratestab:CreateToggle({
    Name = "Teleport to Boxes",
    CurrentValue = false,
    Flag = "TeleportToBoxes",
    Callback = function(Value)
        if Value then
            originalCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            isTeleporting = true

            while isTeleporting do
                local success, message = pcall(function()
                    wait(1)
                    local boxesFolder = workspace:FindFirstChild("Boxes")
                    if boxesFolder then
                        for _, v in pairs(boxesFolder:GetChildren()) do
                            if v:IsA("BasePart") then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                            end
                        end
                    end
                end)

                if not success then
                    print("An error occurred while teleporting: " .. tostring(message))
                    isTeleporting = false
                end
            end
        else
            if originalCFrame then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
            end
            isTeleporting = false
        end
    end
})

local selectedCrate = "Regular"
local crateDropdown = cratestab:CreateDropdown({
    Name = "What box to open?",
    Options = {'Regular', 'Unreal', 'Inferno', 'Luxury', 'Red-Banded', 'Spectral', 'Heavenly', 'Magnificent', 'Festive', 'Easter', 'Birthday', 'Twitch'},
    CurrentOption = "Regular",
    Flag = "SelectedCrate",
    Callback = function(Option)
        print(Option)
        selectedCrate = Option[1] or "Regular"
    end
})

local opencrate = cratestab:CreateToggle({
    Name = "Auto Open Boxes",
    CurrentValue = false,
    Flag = "AutoOpenBoxes",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Value do
                    local success, message = pcall(function()
                        task.wait(0.5)
                        game:GetService("ReplicatedStorage").MysteryBox:InvokeServer(selectedCrate)
                    end)

                    if not success then
                        print("An error occurred while trying to open a crate: " .. tostring(message))
                        Value = false
                    end
                end
            end)
        end
    end,
})
-- END Crates

-- Player
local playertab = window:CreateTab("Player", 4483362458)

local playersection = playertab:CreateSection("Player")

-- proximity prompt
local autoexcavate = playertab:CreateToggle({
    Name = "Auto Excavate",
    CurrentValue = false,
    Flag = "AutoExcavate",
    Callback = function(Value)
        if Value then
            _G.Excavating = true
            task.spawn(function()
                while _G.Excavating do
                    task.wait()
                    for i, v in pairs(myFactory:GetChildren()) do
                        if string.find(v.name, "Excavator") then
                            fireproximityprompt(v.Model.Internal.ProximityPrompt)
                        end
                    end
                end
            end)
        else
            _G.Excavating = false
        end
    end,
})

local walkspeedslider = playertab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " (16-500)",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})

local jumppowerslider = playertab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = " (50-200)",
    CurrentValue = 10,
    Flag = "JumpPower",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end,
})
-- END Player

-- Events (Yearly ones like clovers)

local eventstab = window:CreateTab("Events", 4483362458)

local eventssection = eventstab:CreateSection("Events")

local autoclovercollect = eventstab:CreateToggle({
    Name = "Auto Clover Collect",
    CurrentValue = false,
    Flag = "AutoCloverCollect",
    Callback = function(Value)
        _G.cloverCollecting = Value
        if Value then
            _G.cloverCollectThread = task.spawn(function()
                while Value do
                    local success, message = pcall(function()
                        for i, v in pairs(workspace.Clovers:GetChildren()) do
                            if string.find(v.Name, 'Rainbow') or string.find(v.Name, 'Diamond') or string.find(v.Name, 'Gold') or string.find(v.Name, 'Regular') then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                                task.wait(0.33)
                                fireproximityprompt(v.ProximityPrompt, 0)
                                task.wait(0.16)
                            end
                        end
                    end)
                    if not success then
                        print("An error occurred while collecting clovers: " .. tostring(message))
                    end
                    task.wait()
                end
            end)
        else
            if _G.cloverCollectThread then
                task.cancel(_G.cloverCollectThread)
                _G.cloverCollectThread = nil
            end
        end
    end,
})

-- END Events

-- END Misc Tab

-- World
local worldtab = window:CreateTab("World", 4483362458)

local worldsection = worldtab:CreateSection("World")

local night = worldtab:CreateButton({
    Name = "Night",
    Callback = function()
        game.Lighting.TimeOfDay = 0
    end,
})

local day = worldtab:CreateButton({
    Name = "Day",
    Callback = function()
        game.Lighting.TimeOfDay = 14
    end,
})

-- END World

-- Vendors
local vendorstab = window:CreateTab("Vendors", 4483362458)

local vendorssection = vendorstab:CreateSection("Vendors")

local stpatricksday = vendorstab:CreateButton({
    Name = "St. Patrick's Day",
    Callback = function()
        game.Players.LocalPlayer.PlayerGui.GUI.Patrick.Visible = true
    end,
})

local getdailybox = vendorstab:CreateButton({
    Name = "Get Daily Box",
    Callback = function()
        firesignal(game:GetService("Players").LocalPlayer.PlayerGui.GUI.SpookMcDookShop.RedeemFrame.MouseButton1Click)
    end,
})

-- END Vendors