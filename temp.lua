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