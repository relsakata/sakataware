local dev = true
local beta = false
local Version = "0.0.1a"

if game.PlaceId == 9872472334 then
    GameName = "Evade"
end

if not isfolder("SakataWare") then
    makefolder("SakataWare")
end

if library and getgenv().SakataWareLoaded then
    library:Unload()
    getgenv().SakataWareLoaded = nil
end

local library = loadstring(game:HttpGet("https://github.com/relsakata/evade/raw/main/library.lua"))()

if GameName == "Evade" then
    do
        local CurrentTick = tick()

        getgenv().SakataWareLoaded = CurrentTick
        getgenv().SakataWare = {
            AutoFarm = {
                toggle = false,
                autohide = false,
                autoclover = false,
                autorevive = false,
                autorespawn = false,
            },
            Speed = false,
            SpeedValue = 1500,
            HideUser = false,
            Threads = {}
        }

        local script_flag = {
            Hiding = false,
            Reviving = false,
            Clover = false,
        }

        local Players = game.Players
        local LocalPlayer = Players.LocalPlayer
        local char = LocalPlayer.Character
        local Action = "Hide"
        
        LocalPlayer.CharacterAdded:Connect(function(new)
            char = new
        end)
        
        local GetDownedPlr = function()
            for i,v in pairs(workspace.Game.Players:GetChildren()) do
                if v:GetAttribute("Downed") then
                    return v
                end
            end
        end

        getgenv().SakataWare.Threads[#SakataWare.Threads+1] = task.spawn(function()
            local old
            old = hookmetamethod(game,"__namecall", newcclosure(function(self,...)
                local Args = {...}
                local method = getnamecallmethod()
                if tostring(self) == 'Communicator' and Args[1] == "update" and getgenv().SakataWare.Speed and getgenv().SakataWareLoaded==CurrentTick then
                    return getgenv().SakataWare.SpeedValue, 50
                end
                return old(self,...)
            end))

            local Action = "None"
            local lastClover = tick()
            while task.wait() do
                LocalPlayer.Character:WaitForChild"HumanoidRootPart"
                if getgenv().SakataWare.AutoFarm.toggle then
                    if getgenv().SakataWare.AutoFarm.autorespawn and (char and char:GetAttribute("Downed") == true or not char) then
                        game:GetService("ReplicatedStorage").Events.Respawn:FireServer()
                    end
                    if Action == "None" and not script_flag.Hiding and getgenv().SakataWare.AutoFarm.autohide then
                        char:PivotTo(CFrame.new(char.HumanoidRootPart.Position+Vector3.new(0,200,0))) -- Hide
                        script_flag.Hiding=true
                    end
                    -- local DownedPlr = GetDownedPlr()
                    -- if DownedPlr and getgenv().SakataWare.AutoFarm.autorevive and Action == "None" then
                    --     -- script_flag.Hiding = false
                    --     -- Action = "Reviving"
                    --     -- task.spawn(function()
                    --     --     repeat task.wait() char.HumanoidRootPart:PivotTo(CFrame.new(DownedPlr.HumanoidRootPart.Position - Vector3.new(0, 8, 0))) until Action == "None" or char == nil
                    --     -- end)
                    --     -- game:GetService("ReplicatedStorage").Events.Revive.RevivePlayer:FireServer(DownedPlr.Name, true)
                    --     -- task.wait(3.5)
                    --     -- game:GetService("ReplicatedStorage").Events.Revive.RevivePlayer:FireServer(DownedPlr.Name, false)
                    --     -- task.wait(.2)
                    --     -- Action = "None"
                    -- end
                    if getgenv().SakataWare.AutoFarm.autoclover and Action == "None" and tick() - lastClover >= 10 then
                        -- collect clovers
                        for i,v in pairs(game:GetService("Workspace").Game.Effects.Tickets:GetChildren()) do
                            if v:FindFirstChild("HumanoidRootPart") then
                                script_flag.Hiding = false
                                Action = "Clover"
                                char:PivotTo(CFrame.new(v.HumanoidRootPart.Position))
                                task.wait(.2)
                            end
                        end
                        lastClover = tick()
                        Action = "None"
                    end
                end
            end
        end)


        if getgenv().SakataWareLoaded~=CurrentTick then
            for i,v in getgenv().SakataWare.Threads do
                v:Cancel()
            end
        end

        local HomeTab = library:AddTab("Home")
        local HomeColumn = HomeTab:AddColumn();
        local MainSection = HomeColumn:AddSection("Home")
        MainSection:AddDivider("Main")
        if not isfile("SakataWare/HideUser") then
            writefile("SakataWare/HideUser", "return false")
        end
        local HideUser = loadstring(readfile("SakataWare/HideUser"))()

        local Name

        if HideUser then
            Name = "Anonymous"
        else
            Name = game.Players.LocalPlayer.DisplayName
        end

        local HelloLabel = MainSection:AddLabel(`Hello, {Name}!`)
        local VersionLabel = MainSection:AddLabel(`Version, {dev and "DEV" or beta and "BETA "..Version or Version}!`)

        local MainTab = library:AddTab("Main")
        local MainColumn1 = MainTab:AddColumn();
        local AutoFarmSection = MainColumn1:AddSection("Main")


        local UiTable = {
            AutoFarm = {},
        };


        UiTable.AutoFarm.toggle = AutoFarmSection:AddToggle({
            default = false,
            text = "Toggle",
            flag = "AutoFarmEnabled",
            callback = function(bool)
                getgenv().SakataWare.AutoFarm.toggle = bool
            end
        })

        AutoFarmSection:AddDivider("Settings");

        UiTable.AutoFarm.autohide = AutoFarmSection:AddToggle({
            default = false,
            text = "Auto Hide",
            flag = "Hiding",
            callback = function(bool)
                getgenv().SakataWare.AutoFarm.autohide = bool
            end
        })

        -- UiTable.AutoFarm.autorevive = AutoFarmSection:AddToggle({
        --     default = false,
        --     text = "Auto Revive",
        --     flag = "Revive",
        --     callback = function(bool)
        --         getgenv().SakataWare.AutoFarm.autorevive = bool
        --     end
        -- })

        UiTable.AutoFarm.autoclover = AutoFarmSection:AddToggle({
            default = false,
            text = "Auto Clover",
            flag = "Clover",
            callback = function(bool)
                getgenv().SakataWare.AutoFarm.autoclover = bool
            end
        })

        UiTable.AutoFarm.autorespawn = AutoFarmSection:AddToggle({
            default = false,
            text = "Auto Respawn",
            flag = "Respawn",
            callback = function(bool)
                getgenv().SakataWare.AutoFarm.autorespawn = bool
            end
        })

        local MiscSection = MainColumn1:AddSection("Misc")
        UiTable.Speed = MiscSection:AddToggle({
            default = false,
            text = "Speed",
            flag = "Speed",
            callback = function(bool)
                getgenv().SakataWare.Speed = bool
            end
        })

        MiscSection:AddBox({text = "1500", callback = function(value) getgenv().SakataWare.SpeedValue = value end});

        local SettingsTab = library:AddTab("Settings"); 
        local SettingsColumn = SettingsTab:AddColumn(); 
        local SettingsColumn2 = SettingsTab:AddColumn(); 
        local SettingSection = SettingsColumn:AddSection("Menu"); 
        local ConfigSection = SettingsColumn2:AddSection("Configs");
        local Warning = library:AddWarning({type = "confirm"});

        SettingSection:AddBind({text = "Open / Close", flag = "UI Toggle", nomouse = true, key = "End", callback = function()
            library:Close();
        end});

        SettingSection:AddButton({text = "Unload UI", callback = function()
            local r, g, b = library.round(library.flags["Menu Accent Color"]);
            Warning.text = "<font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. 'Are you sure you wana unload the UI?' .. "</font>";
            if Warning:Show() then
            library:Unload()
            end
        end});

        SettingSection:AddColor({text = "Accent Color", flag = "Menu Accent Color", color = Color3.fromRGB(88,133,198), callback = function(color)
            if library.currentTab then
                library.currentTab.button.TextColor3 = color;
            end
            for i,v in pairs(library.theme) do
                v[(v.ClassName == "TextLabel" and "TextColor3") or (v.ClassName == "ImageLabel" and "ImageColor3") or "BackgroundColor3"] = color;
            end
        end});

        -- [Background List]
        local backgroundlist = {
            Floral = "rbxassetid://5553946656",
            Flowers = "rbxassetid://6071575925",
            Circles = "rbxassetid://6071579801",
            Hearts = "rbxassetid://6073763717"
        };

        -- [Background List]
        local back = SettingSection:AddList({text = "Background", max = 4, flag = "background", values = {"Floral", "Flowers", "Circles", "Hearts"}, value = "Floral", callback = function(v)
            if library.main then
                library.main.Image = backgroundlist[v];
            end
        end});

        -- [Background Color Picker]
        back:AddColor({flag = "backgroundcolor", color = Color3.new(), callback = function(color)
            if library.main then
                library.main.ImageColor3 = Color or Color3.fromRGB(37,38,38)
            end
        end, trans = 1, calltrans = function(trans)
            if library.main then
                library.main.ImageTransparency = 1 - trans;
            end
        end});

        -- [Tile Size Slider]
        SettingSection:AddSlider({text = "Tile Size", min = 50, max = 500, value = 50, callback = function(size)
            if library.main then
                library.main.TileSize = UDim2.new(0, size, 0, size);
            end
        end});

        -- [Discord Button]
        SettingSection:AddButton({text = "Discord", callback = function()
            local r, g, b = library.round(library.flags["Menu Accent Color"]);
            Warning.text = "<font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. 'Discord invite copied to clip board!' .. "</font>";
            if Warning:Show() then
            setclipboard('discord.gg/awakenkn-gg')
            end
        end});

        -- [Config Box]
        ConfigSection:AddBox({text = "Config Name", skipflag = true});

        -- [Config List]
        ConfigSection:AddList({text = "Configs", skipflag = true, value = "", flag = "Config List", values = library:GetConfigs()});

        -- [Create Button]
        ConfigSection:AddButton({text = "Create", callback = function()
            library:GetConfigs();
            writefile(library.foldername .. "/" .. library.flags["Config Name"] .. library.fileext, "{}");
            library.options["Config List"]:AddValue(library.flags["Config Name"]);
        end});

        -- [Save Button]
        ConfigSection:AddButton({text = "Save", callback = function()
            local r, g, b = library.round(library.flags["Menu Accent Color"]);
            Warning.text = "Are you sure you want to save the current settings to config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?";
            if Warning:Show() then
                library:SaveConfig(library.flags["Config List"]);
            end
        end});

        -- [Load Button]
        ConfigSection:AddButton({text = "Load", callback = function()
            local r, g, b = library.round(library.flags["Menu Accent Color"]);
            Warning.text = "Are you sure you want to load config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?";
            if Warning:Show() then
                library:LoadConfig(library.flags["Config List"]);
            end
        end});

        -- [Delete Button]
        ConfigSection:AddButton({text = "Delete", callback = function()
            local r, g, b = library.round(library.flags["Menu Accent Color"]);
            Warning.text = "Are you sure you want to delete then config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. library.flags["Config List"] .. "</font>?";
            if Warning:Show() then
                local config = library.flags["Config List"];
                if table.find(library:GetConfigs(), config) and isfile(library.foldername .. "/" .. config .. library.fileext) then
                    library.options["Config List"]:RemoveValue(config);
                    delfile(library.foldername .. "/" .. config .. library.fileext);
                end
            end
        end});

        library:Init();
        library:selectTab(library.tabs[1]);
    end
end
