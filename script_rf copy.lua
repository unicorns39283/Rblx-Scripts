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
_G.justRebirthed = false
_G.remoteDropEnabled = false
_G.autoLoopUpgraders = false
_G.autoBoxTP = false
_G.autoPulse = false
_G.autoRPFarm = false
_G.Excavating = false
_G.autoOpenBoxes = false
_G.cloverCollecting = false
_G.cloverCollectThread = nil
_G.boostOres = true
_G.loopTimes = 1
_G.sendToWebhook = false
_G.webhookURL = ""
_G.loopNTimesWithTeslaResetter = false
_G.teleportCoroutine = nil
-- END Global variables

-- ArrayList variables
local ConveyorSpeedState = 1
local ConveyorSpeedChangeState = false 
local autoRemoteDropState = false
local alwaysAtBaseState = false
local autoRebirthState = false
local layoutState = false
local autoLoopUpgradersState = false
local autoLoopUpgradersLoopTimes = 1
local teleportToBoxesState = false
local autoOpenBoxesState = false
local autoExcavateState = false
local walkSpeedState = 16
local jumpPowerState = 50
local autoCloverCollectState = false
-- END ArrayList variables

-- Helper funcs
function getDropped()
    local tbl = {}
    for _, v in pairs(game:GetService("Workspace").DroppedParts[myFactory.Name]:GetChildren()) do
        if v:IsA("BasePart") then
            table.insert(tbl, v)
        end
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
function getFurnaces()
    tbl = {}
    for i,v in pairs(myFactory:GetChildren()) do
        if v:FindFirstChild("Model") then
            local model = v.Model
            if model and model:FindFirstChild("Lava") then
                table.insert(tbl,v)
            end
        end
    end
    return tbl
end
-- Utility Tab
local utilitytab = window:CreateTab("Utility", 4483362458)
local conveyorsection = utilitytab:CreateSection("Conveyor Speed")
local autoremotedrop = utilitytab:CreateToggle({
    Name = "Auto Remote Drop",
    CurrentValue = false,
    Flag = "AutoRemoteDrop",
    Callback = function(Value)
        autoRemoteDropState = Value
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
local autoexcavate = utilitytab:CreateToggle({
    Name = "Auto Excavate",
    CurrentValue = false,
    Flag = "AutoExcavate",
    Callback = function(Value)
        autoExcavateState = Value
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
local autopulse = utilitytab:CreateToggle({
    Name = "Auto Pulse",
    CurrentValue = false,
    Flag = "AutoPulse",
    Callback = function(Value)
        _G.autoPulse = Value
        if Value then
            task.spawn(function()
                while _G.autoPulse do
                    local success, message = pcall(function()
                        task.wait()
                        game:GetService("ReplicatedStorage").Pulse:FireServer()
                    end)
                    if not success then
                        print("An error occurred during auto pulse: " .. tostring(message))
                        _G.autoPulse = false
                    end
                end
            end)
        end
    end
})
local speedSlider = utilitytab:CreateSlider({
	Name = "Conveyor Speed",
	Range = {1, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 1,
	Flag = "ConveyorSpeed",
    Callback = function(Value)
        if myFactory:FindFirstChild("AdjustSpeed") then
            myFactory.AdjustSpeed.Value = Value
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
            _G.autoRPFarm = false
            _G.autoPulse = false
            _G.autoBoxTP = false
            _G.autoOpenBoxes = false
            if _G.teleportCoroutine then
                coroutine.close(_G.teleportCoroutine)
                _G.teleportCoroutine = nil
            end
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
local autosellores = utilitytab:CreateButton({
    Name = "Auto Sell Ores",
    Callback = function()
        for i,v in pairs(getDropped()) do
            local furnacezz = getFurnaces()
            if furnacezz and #furnacezz > 0 then
                local firstFurnace = furnacezz[1]
                if firstFurnace.Model:FindFirstChild("Lava") then
                    firetouchinterest(v, firstFurnace.Model.Lava, 0)
                    task.wait()
                    firetouchinterest(v, firstFurnace.Model.Lava, 1)
                end
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
local tporestoplayer = utilitytab:CreateButton({
    Name = "TP Ores to Player",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")      
        if humanoidRootPart then
            for i, v in pairs(getDropped()) do
                local cframe = humanoidRootPart.CFrame
                local inFrontOfPlayer = cframe + (cframe.lookVector * 5)
                local targetPos = Vector3.new(inFrontOfPlayer.X, humanoidRootPart.Position.Y, inFrontOfPlayer.Z)
                v.CFrame = CFrame.new(targetPos)
            end
        else
            warn("HumanoidRootPart not found")
        end
    end,
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
        autoRebirthState = Value
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
                            _G.justRebirthed = true
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
                                    print("    Loading layout "..layoutNumber .. ". selectedLayout: " .. selectedLayout)
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                elseif selectedLayout == "Layout 1" then
                                    print("    Loading layout "..layoutNumber .. ". selectedLayout: " .. selectedLayout)
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                elseif selectedLayout == "Layout 3" then
                                    print("    Loading layout "..layoutNumber .. ". selectedLayout: " .. selectedLayout)
                                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load", "Layout"..layoutNumber)
                                end
                                task.wait(1)
                                _G.justRebirthed = false
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
    Options = {"Layout 1", "Layout 2", "Layout 3"},
    CurrentOption = "Layout 3",
    Flag = "SelectedLayout",
    Callback = function(Option)
        layoutState = Option
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
-- local autoloopupgraders = oreboostingtab:CreateToggle({
--     Name = "Auto Loop Upgraders",
--     CurrentValue = true,
--     Flag = "AutoLoopUpgraders",
--     Callback = function(Value)
--         autoLoopUpgradersState = Value
--         _G.autoLoopUpgraders = Value
--         if Value then
--             task.spawn(function()
--                 while _G.autoLoopUpgraders do
--                     local success, message = pcall(function()
--                         local upgraders = getUpgraders()
--                         local droppedOres = getDropped()
--                         local furnacezz = getFurnaces()
--                         local teslaResetter = nil

--                         for _, v in pairs(upgraders) do
--                             if v.Name == "Tesla Resetter" then
--                                 teslaResetter = v
--                                 break
--                             end
--                         end

--                         if #upgraders > 0 and #droppedOres > 0 then
--                             for i, v2 in pairs(getDropped()) do
--                                 print("Dropped ore: " .. v2.Name)
--                                 print("Anchored: " .. tostring(v2.Anchored))
--                                 local upgraderCount = 0
--                                 local loopCount = _G.loopNTimesWithTeslaResetter and _G.loopTimes or (teslaResetter and 2 or _G.loopTimes)
--                                 -- local loopCount = teslaResetter and 2 or _G.loopTimes
--                                 for passCount = 1, loopCount do
--                                     for i2, v in pairs(upgraders) do
--                                         if not teslaResetter or v ~= teslaResetter and v.Model then
--                                             upgraderCount = upgraderCount + 1
--                                             if v.Model:FindFirstChild("Upgrade") and v.Model.Upgrade then
--                                                 firetouchinterest(v2,v.Model.Upgrade,0)
--                                                 task.wait()
--                                                 firetouchinterest(v2,v.Model.Upgrade,1)
--                                             elseif v.Model:FindFirstChild("Upgrader") and v.Model.Upgrader then
--                                                 firetouchinterest(v2,v.Model.Upgrader,0)
--                                                 task.wait()
--                                                 firetouchinterest(v2,v.Model.Upgrader,1)
--                                             elseif v.Model:FindFirstChild("Cannon") and v.Model.Cannon then
--                                                 firetouchinterest(v2,v.Model.Cannon,0)
--                                                 task.wait()
--                                                 firetouchinterest(v2,v.Model.Cannon,1)
--                                             end
--                                         end
--                                     end
--                                     if teslaResetter and teslaResetter.Model:FindFirstChild("Upgrade") then
--                                         firetouchinterest(v2, teslaResetter.Model.Upgrade, 0)
--                                         task.wait()
--                                         firetouchinterest(v2, teslaResetter.Model.Upgrade, 1)
--                                     end
--                                 end
--                                 print("Ore went through " .. upgraderCount .. " upgraders.")
--                                 if furnacezz and #furnacezz > 0 then
--                                     local firstFurnace = furnacezz[1]
--                                     if firstFurnace.Model:FindFirstChild("Lava") then
--                                         -- TODO: Switch between ghetto and non-ghetto method of selling ores
--                                         -- local furnaceCFrame = firstFurnace.Model.Lava.CFrame
--                                         -- local aboveFurnace = CFrame.new(furnaceCFrame.Position + Vector3.new(0, 5, 0))
--                                         -- v2.CFrame = aboveFurnace
--                                         firetouchinterest(v2, firstFurnace.Model.Lava, 0)
--                                         firetouchinterest(v2, firstFurnace.Model.Lava, 1)
--                                         task.wait()
--                                     end
--                                 end
--                             end
--                         else
--                             task.wait()
--                         end
--                     end)
--                     if not success then
--                         print("An error occurred during auto loop upgraders: " .. tostring(message))
--                     end
--                 end
--             end)
--         end
--     end
-- })
local autoloopupgraders = oreboostingtab:CreateToggle({
    Name = "Auto Loop Upgraders",
    CurrentValue = false,
    Flag = "AutoLoopUpgraders",
    Callback = function(Value)
        _G.autoLoopUpgraders = Value
        if Value then
            task.spawn(function()
                while _G.autoLoopUpgraders do
                    local success, message = pcall(function()
                        if _G.justRebirthed then
                            task.wait(5)
                            _G.justRebirthed = false
                        end

                        local upgraders = getUpgraders()
                        local droppedOres = getDropped()
                        local furnacezz = getFurnaces()
                        local teslaResetter

                        if not upgraders or #upgraders == 0 then
                            task.wait()
                            return
                        end

                        for _, v in pairs(upgraders) do
                            if v.Name == "Tesla Resetter" then
                                teslaResetter = v
                                break
                            end
                        end

                        local function processOre(v2)
                            print("Dropped ore: " .. v2.Name)
                            print("Anchored: " .. tostring(v2.Anchored))
                            local upgraderCount = 0
                            local loopCount = teslaResetter and (_G.loopNTimesWithTeslaResetter and _G.loopTimes or 2) or _G.loopTimes
                            
                            for passCount = 1, loopCount do
                                for _, v in pairs(upgraders) do
                                    if not teslaResetter or v ~= teslaResetter then
                                        upgraderCount = upgraderCount + 1
                                        if v.Model then
                                            local interactionPart = v.Model:FindFirstChild("Upgrade") or v.Model:FindFirstChild("Upgrader") or v.Model:FindFirstChild("Cannon")
                                            if interactionPart then
                                                firetouchinterest(v2, interactionPart, 0)
                                                task.wait()
                                                firetouchinterest(v2, interactionPart, 1)
                                            end
                                        end
                                    end
                                end
                                if teslaResetter and teslaResetter.Model and teslaResetter.Model:FindFirstChild("Upgrade") then
                                    firetouchinterest(v2, teslaResetter.Model.Upgrade, 0)
                                    task.wait()
                                    firetouchinterest(v2, teslaResetter.Model.Upgrade, 1)
                                end
                            end
                            print("Ore went through " .. upgraderCount .. " upgraders.")
                            if furnacezz and #furnacezz > 0 then
                                local firstFurnace = furnacezz[1]
                                if firstFurnace.Model:FindFirstChild("Lava") then
                                    firetouchinterest(v2, firstFurnace.Model.Lava, 0)
                                    firetouchinterest(v2, firstFurnace.Model.Lava, 1)
                                    task.wait()
                                end
                            end
                        end
                        if #upgraders > 0 and #droppedOres > 0 then
                            for _, ore in pairs(droppedOres) do
                                coroutine.wrap(processOre)(ore)
                            end
                        else
                            task.wait()
                        end
                    end)
                    if not success then
                        print("An error occurred during auto loop upgraders: " .. tostring(message))
                    end
                    task.wait()
                end
            end)
        end
    end
})
local loopNTimesToggle = oreboostingtab:CreateToggle({
    Name = "Loop N Times with Tesla Resetter",
    CurrentValue = false,
    Flag = "LoopNTimesWithTeslaResetter",
    Callback = function(Value)
        _G.loopNTimesWithTeslaResetter = Value
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
        autoLoopUpgradersLoopTimes = Value
        _G.loopTimes = Value
    end,
})
local autorpfarming = oreboostingtab:CreateToggle({
    Name = "Auto RP Farming",
    CurrentValue = false,
    Flag = "AutoRPFarming",
    Callback = function(Value)
        _G.autoRPFarm = Value
        local furnaceCache = nil
        local oreQueue = {}
        local function processOre(ore, furnace)
            firetouchinterest(ore, furnace, 0)
            coroutine.yield()
            firetouchinterest(ore, furnace, 1)
        end
        if Value then
            task.spawn(function()
                while _G.autoRPFarm do
                    local success, message = pcall(function()
                        if not furnaceCache then
                            local furnacezz = getFurnaces()
                            if furnacezz and #furnacezz > 0 then
                                furnaceCache = furnacezz[1]
                            end
                        end

                        local droppedOres = getDropped()
                        if #droppedOres > 0 and furnaceCache and furnaceCache.Model:FindFirstChild("Lava") then
                            for i, ore in ipairs(droppedOres) do
                                oreQueue[i] = coroutine.create(processOre)
                                coroutine.resume(oreQueue[i], ore, furnaceCache.Model.Lava)
                            end
                            for i = 1, #oreQueue do
                                if coroutine.status(oreQueue[i]) == "suspended" then
                                    coroutine.resume(oreQueue[i])
                                end
                                oreQueue[i] = nil
                            end
                        end
                    end)

                    if not success then
                        print("An error occurred during auto RP farming: " .. tostring(message))
                        _G.autoRPFarm = false
                    end

                    if not furnaceCache then
                        task.wait(0.1)
                    else
                        task.wait()
                    end
                end
                furnaceCache = nil
            end)
        else
            furnaceCache = nil
        end
    end
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
local teleporttoboxes = cratestab:CreateToggle({
    Name = "Teleport to Boxes",
    CurrentValue = false,
    Flag = "TeleportToBoxes",
    Callback = function(Value)
        _G.autoBoxTP = Value
        if Value then
            if not _G.teleportCoroutine then
                originalCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                _G.teleportCoroutine = coroutine.create(function()
                    while _G.autoBoxTP do
                        local success, message = pcall(function()
                            wait(1)
                            local boxesFolder = workspace:FindFirstChild("Boxes")
                            if boxesFolder then
                                for _, v in pairs(boxesFolder:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        local targetPos = Vector3.new(v.Position.X, v.Position.Y - 25, v.Position.Z)
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                                        wait(0.5)
                                    end
                                end
                            end
                        end)

                        if not success then
                            print("An error occurred while teleporting: " .. tostring(message))
                        end
                    end
                end)
                coroutine.resume(_G.teleportCoroutine)
            end
        else
            if _G.teleportCoroutine then
                coroutine.close(_G.teleportCoroutine)
                _G.teleportCoroutine = nil
            end
            if originalCFrame then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
            end
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
        selectedCrate = Option[1] or "Regular"
    end
})
local opencrate = cratestab:CreateToggle({
    Name = "Auto Open Boxes",
    CurrentValue = false,
    Flag = "AutoOpenBoxes",
    Callback = function(Value)
        _G.autoOpenBoxes = Value
        if Value then
            task.spawn(function()
                while _G.autoOpenBoxes do
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
local walkspeedslider = playertab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " (16-500)",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        walkSpeedState = Value
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
        jumpPowerState = Value
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
        autoCloverCollectState = Value
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

-- Visual
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

local testURL = "https://discord.com/api/webhooks/1221621067517399161/WvFhySwRiBPE7Z423dEcDPDnIQXKLGl-LxD3W-fKOWrl8rhEeWkNdmNNzXXT-ivFYexP?wait=true"
game:GetService("Players").LocalPlayer.PlayerGui.GUI.Notifications.ChildAdded:Connect(function(v)
    print("here")
    local function processNotification(item)
        if item.Tier.Text ~= "Reborn" and item.Tier.Text ~= "Slipstream" and item.Tier.Text ~= "Adv. Reborn" and item.Tier.Text ~= "Shiny Reborn" then
            print("Item is not reborn or slipstream. (DEBUG: " .. item.Tier.Text .. ")")
            return
        end

        local lifeValue = game:GetService("Players").LocalPlayer.leaderstats.Life.Value
        local imageid = item.Icon.Image

        if string.find(imageid, "rbxasset") then
            imageid = string.split(tostring(item.Icon.Image), "//")[2]
        end

        local imagedata = game:GetService("HttpService"):JSONDecode(request({
            Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. tonumber(imageid) .. "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false"
        }).Body)
        local imagelink = imagedata.data[1]["imageUrl"]

        local data = {
            ["embeds"] = {
                {
                    ["title"] = "Test Webhook",
                    ["fields"] = {
                        {
                            ["name"] = "Rebirth",
                            ["value"] = tostring("```\n" .. lifeValue .. "```"),
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Item",
                            ["value"] = tostring("```\n" .. item.Title.Text .. "```"),
                            ["inline"] = true
                        },
                        {
                            ["name"] = "Tier",
                            ["value"] = tostring("```\n" .. item.Tier.Text .. "```"),
                            ["inline"] = true
                        },
                    },
                    ["color"] = tonumber("0x" .. tostring(string.split(string.format("#%02X%02X%02X", 255, 0, 0), "#")[2])),
                    ["footer"] = {
                        ["text"] = "Testing | " .. os.date()
                    },
                    ["thumbnail"] = {
                        ["url"] = tostring(imagelink)
                    }
                }
            }
        }
        request({
            Url = testURL,
            Body = game:GetService("HttpService"):JSONEncode(data),
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"}
        })
    end
    if (v.Name == "ItemTemplate" or v.Name == "ItemTemplateMini") and v:FindFirstChild("Title") and v:FindFirstChild("Tier") and v:FindFirstChild("Icon") then
        processNotification(v)
    end
end)