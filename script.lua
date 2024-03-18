local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
print(("\n"):rep(20))
OrionLib:MakeNotification({
    Name = "Loaded",
    Content = "Script loaded!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

local Window = OrionLib:MakeWindow({
    Name = "Miners Haven",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "OrionTest"
})

-- Locals
local username = game.Players.LocalPlayer.Name
local myFactory = game:GetService("Players").LocalPlayer.PlayerTycoon.Value
local moneyLibrary = require(game:GetService("ReplicatedStorage").MoneyLib)
-- END Locals

-- Utility Tab

local UtilityTab = Window:MakeTab({
    Name = "Utility",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ConveyorSection = UtilityTab:AddSection({
    Name = "Conveyor Speed"
})

ConveyorSection:AddSlider({
    Name = "Conveyor Speed",
    Min = 1,
    Max = 100,
    Default = 1,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        myFactory.AdjustSpeed.Value = Value
        print("Conveyor Speed set to " .. Value)
    end
})

ConveyorSection:AddBind({
    Name = "Close GUI",
    Default = Enum.KeyCode.K,
    Hold = false,
    Callback = function()
        OrionLib:Destroy()
    end    
})

-- Utility Tab END

-- Auto Rebirth Tab
local AutoRebirthTab = Window:MakeTab({
    Name = "Auto Rebirth",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AutoRebirthSection = AutoRebirthTab:AddSection({
    Name = "Auto Rebirth"
})

AutoRebirthSection:AddToggle({
    Name = "Auto Rebirth",
    Default = false,
    Callback = function(Value)
        if game:GetService("Players").LocalPlayer.PlayerGui.GUI.Money.Value >= moneyLibrary.RebornPrice(game:GetService("Players").LocalPlayer) and (game:GetService("Players").LocalPlayer.PlayerTycoon.Value:GetPivot().p - game.Players.LocalPlayer.Character:GetPivot().p).Magnitude <= 150 then
            print("we have enough money")
        end
    end
})

OrionLib:Init()