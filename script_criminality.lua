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
-- END Helper funcs

local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/cueshut/saves/main/criminality%20paste%20ui%20library'))()

local window = library.new('leadmarker is so hot', 'leadmarker')

local tab = window.new_tab('rbxassetid://4483345998')
local tab1 = window.new_tab('rbxassetid://4483345998')

local section = tab.new_section('Bruh XD')
local section1 = tab.new_section(':DDD HI')

local sector = section.new_sector('OK', 'Left')
local sector1 = section.new_sector('BRUHHHH', 'Right')

local toggle = sector.element('Toggle', 'Loop Upgraders', false, function(v)
    print(v.Toggle)

    if v.Toggle then
        while v.Toggle do
            if v.toggle == false then
                break
            end

            local upgraders = getUpgraders()
            local dropped = getDropped()
            local teslaResetter = nil

            for _, v in pairs(upgraders) do
                if v.Name == "Tesla Resetter" then
                    teslaResetter = v
                    break
                end
            end

            if #upgraders > 0 and #droppedOres > 0 then
                for i, v2 in pairs(dropped) do
                    local upgraderCount = 0
                    local loopCount = teslaResetter and 2 or 1

                    for passCount = 1, loopCount do
                        for i2, v in pairs(upgraders) do
                            if not teslaResetter or v ~= teslaResetter and v.Model then
                                upgraderCount = upgraderCount + 1
                                if v.Model:FindFirstChild("Upgrade") and v.Model.Upgrade then
                                    firetouchinterest(v2,v.Model.Upgrade,0)
                                    firetouchinterest(v2,v.Model.Upgrade,1)
                                elseif v.Model:FindFirstChild("Upgrader") and v.Model.Upgrader then
                                    firetouchinterest(v2,v.Model.Upgrader,0)
                                    firetouchinterest(v2,v.Model.Upgrader,1)
                                elseif v.Model:FindFirstChild("Cannon") and v.Model.Cannon then
                                    firetouchinterest(v2,v.Model.Cannon,0)
                                    firetouchinterest(v2,v.Model.Cannon,1)
                                end
                            end
                        end

                        if teslaResetter and teslaResetter.Model:FindFirstChild("Upgrade") then
                            firetouchinterest(v2, teslaResetter.Model.Upgrade, 0)
                            firetouchinterest(v2, teslaResetter.Model.Upgrade, 1)
                        end
                    end
                    
                    print("Ore went through " .. upgraderCount .. " upgraders.")

                    if myFactory:FindFirstChild("Frozen Justice") then
                        firetouchinterest(v2, myFactory["Frozen Justice"].Model.Lava, 0)
                        firetouchinterest(v2, myFactory["Frozen Justice"].Model.Lava, 1)
                    elseif myFactory:FindFirstChild("Dreamer's Fright") then
                        firetouchinterest(v2, myFactory["Dreamer's Fright"].Model.Lava, 0)
                        firetouchinterest(v2, myFactory["Dreamer's Fright"].Model.Lava, 1)
                    elseif myFactory:FindFirstChild("Sage Redeemer") then
                        firetouchinterest(v2, myFactory["Sage Redeemer"].Model.Lava, 0)
                        firetouchinterest(v2, myFactory["Sage Redeemer"].Model.Lava, 1)
                    elseif myFactory:FindFirstChild("Basic Furnace") then
                        firetouchinterest(v2, myFactory["Basic Furnace"].Model.Lava, 0)
                        firetouchinterest(v2, myFactory["Basic Furnace"].Model.Lava, 1)
                    else
                        print("No furnace found.")
                    end
                end
            else
                print("No upgraders or dropped ores found.")
            end
        end
    end
end)
 