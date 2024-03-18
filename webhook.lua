game:GetService("Players").LocalPlayer.PlayerGui.GUI.Notifications.ChildAdded:Connect(function(v)
    if v.Name == "ItemTemplate" or "ItemTemplateMini" and v:FindFirstChild("Title") and v:FindFirstChild("Tier") and v:FindFirstChild("Icon") and Settings.ItemTracker == true then
        local ImageId = v.Icon.Image
        if string.find(ImageId,"rbxasset") then
           ImageId = string.split(tostring(v.Icon.Image),"//")[2]
        end
        local ImageData = game:GetService("HttpService"):JSONDecode(request({Url="https://thumbnails.roblox.com/v1/assets?assetIds="..tonumber(ImageId).."&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false"}).Body)
        local ImageLink = ImageData.data[1]["imageUrl"]
        local Data = {["embeds"]= {{
                ["title"] = "**New Item**",
                ["fields"] = {
                    {
                        ["name"] = ":page_facing_up: **Item**",
                        ["value"] =  tostring("```\n"..v.Title.Text.."```"),
                        ["inline"] = true
                    },
                    {
                        ["name"] = (":arrow_up: **Tier**"),
                        ["value"] =  tostring("```\n"..v.Tier.Text.."```"),
                        ["inline"] = true
                    },
                },
            ["color"] = tonumber("0x"..tostring(string.split((string.format("#%02X%02X%02X", v.BackgroundColor3.R * 0xFF,v.BackgroundColor3.G * 0xFF, v.BackgroundColor3.B * 0xFF)),"#")[2])),
            ["footer"] = {["text"] = "Project Vertigo | "..os.date()},
            ["thumbnail"] = {["url"]=tostring(ImageLink)}
            }}
        }
        request({Url = "https://discord.com/api/webhooks/1218792685738004531/I6AJSX_OdDtRyd2ru4yAdALkPoRh2tNkSSIxfLm0BTRU_JuvM05si0to8bEbDGOCM_Xo?wait=true", Body =  game:GetService("HttpService"):JSONEncode(Data), Method = "POST", Headers = {["content-type"] = "application/json"}})
    end
end)