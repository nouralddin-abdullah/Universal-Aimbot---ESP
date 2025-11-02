--[[
    Universal Project - Main Script
    ESP System using Sense Library
    
    Features:
    - Full ESP integration with custom GUI
    - Player ESP (boxes, tracers, names, health, distance, weapons)
    - Team-based ESP (enemy/friendly)
    - 3D boxes, chams, off-screen arrows
    - Instance ESP support
    - Complete customization
]]

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--=============================================================================--
--                    COMPATIBILITY PATCHES (MUST BE FIRST!)
--=============================================================================--
-- Patch missing Drawing API
if not Drawing then
    Drawing = {
        new = function() 
            return setmetatable({}, {
                __index = function() return function() end end,
                __newindex = function() end
            })
        end
    }
end

-- Load Custom GUI Library with error handling
local CustomGUI
local success, err = pcall(function()
    CustomGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/CustomGui.lua"))()
end)

if not success or not CustomGUI then
    error("❌ Failed to load CustomGUI library: " .. tostring(err))
    return
end

-- Load Sense ESP Library with error handling
local Sense
success, err = pcall(function()
    Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
end)

if not success or not Sense then
    error("❌ Failed to load Sense ESP library: " .. tostring(err))
    return
end

--=============================================================================--
--                       CONFIG MANAGER
--=============================================================================--
local ConfigManager = {
    ConfigFolder = "UniversalProject_Configs",
    CurrentConfigName = ""
}

-- Check if executor supports file functions
function ConfigManager.CheckSupport()
    return writefile and readfile and listfiles and isfolder and makefolder and delfile
end

-- Color3 to table converter
function ConfigManager.Color3ToTable(color)
    return {R = color.R, G = color.G, B = color.B}
end

-- Table to Color3 converter
function ConfigManager.TableToColor3(tbl)
    return Color3.fromRGB(tbl.R * 255, tbl.G * 255, tbl.B * 255)
end

-- Get current configuration
function ConfigManager.GetCurrentConfig()
    local config = {
        ESP = {
            Global = {
                useTeamColor = Sense.sharedSettings.useTeamColor,
                limitDistance = Sense.sharedSettings.limitDistance,
                maxDistance = Sense.sharedSettings.maxDistance,
                textSize = Sense.sharedSettings.textSize,
                textFont = Sense.sharedSettings.textFont
            },
            Enemy = {
                enabled = Sense.teamSettings.enemy.enabled,
                box = Sense.teamSettings.enemy.box,
                boxFill = Sense.teamSettings.enemy.boxFill,
                box3d = Sense.teamSettings.enemy.box3d,
                healthBar = Sense.teamSettings.enemy.healthBar,
                healthText = Sense.teamSettings.enemy.healthText,
                name = Sense.teamSettings.enemy.name,
                distance = Sense.teamSettings.enemy.distance,
                weapon = Sense.teamSettings.enemy.weapon,
                tracer = Sense.teamSettings.enemy.tracer,
                tracerOrigin = Sense.teamSettings.enemy.tracerOrigin,
                offScreenArrow = Sense.teamSettings.enemy.offScreenArrow,
                offScreenArrowSize = Sense.teamSettings.enemy.offScreenArrowSize,
                offScreenArrowRadius = Sense.teamSettings.enemy.offScreenArrowRadius,
                chams = Sense.teamSettings.enemy.chams,
                chamsVisibleOnly = Sense.teamSettings.enemy.chamsVisibleOnly,
                boxColor = {ConfigManager.Color3ToTable(Sense.teamSettings.enemy.boxColor[1]), Sense.teamSettings.enemy.boxColor[2]},
                boxFillColor = {ConfigManager.Color3ToTable(Sense.teamSettings.enemy.boxFillColor[1]), Sense.teamSettings.enemy.boxFillColor[2]},
                tracerColor = {ConfigManager.Color3ToTable(Sense.teamSettings.enemy.tracerColor[1])},
                chamsFillColor = {ConfigManager.Color3ToTable(Sense.teamSettings.enemy.chamsFillColor[1])},
                chamsOutlineColor = {ConfigManager.Color3ToTable(Sense.teamSettings.enemy.chamsOutlineColor[1])}
            },
            Friendly = {
                enabled = Sense.teamSettings.friendly.enabled,
                box = Sense.teamSettings.friendly.box,
                boxFill = Sense.teamSettings.friendly.boxFill,
                box3d = Sense.teamSettings.friendly.box3d,
                healthBar = Sense.teamSettings.friendly.healthBar,
                healthText = Sense.teamSettings.friendly.healthText,
                name = Sense.teamSettings.friendly.name,
                distance = Sense.teamSettings.friendly.distance,
                weapon = Sense.teamSettings.friendly.weapon,
                tracer = Sense.teamSettings.friendly.tracer,
                tracerOrigin = Sense.teamSettings.friendly.tracerOrigin,
                offScreenArrow = Sense.teamSettings.friendly.offScreenArrow,
                chams = Sense.teamSettings.friendly.chams,
                chamsVisibleOnly = Sense.teamSettings.friendly.chamsVisibleOnly,
                boxColor = {ConfigManager.Color3ToTable(Sense.teamSettings.friendly.boxColor[1]), Sense.teamSettings.friendly.boxColor[2]},
                boxFillColor = {ConfigManager.Color3ToTable(Sense.teamSettings.friendly.boxFillColor[1]), Sense.teamSettings.friendly.boxFillColor[2]},
                tracerColor = {ConfigManager.Color3ToTable(Sense.teamSettings.friendly.tracerColor[1])},
                chamsFillColor = {ConfigManager.Color3ToTable(Sense.teamSettings.friendly.chamsFillColor[1])},
                chamsOutlineColor = {ConfigManager.Color3ToTable(Sense.teamSettings.friendly.chamsOutlineColor[1])}
            },
            Whitelist = Sense.whitelist
        },
        Aimbot = nil
    }
    
    -- Only save aimbot config if it's loaded
    if getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot then
        local Aimbot = getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot
        config.Aimbot = {
            Settings = {
                Enabled = Aimbot.Settings.Enabled,
                TeamCheck = Aimbot.Settings.TeamCheck,
                AliveCheck = Aimbot.Settings.AliveCheck,
                WallCheck = Aimbot.Settings.WallCheck,
                Toggle = Aimbot.Settings.Toggle,
                LockPart = Aimbot.Settings.LockPart,
                LockMode = Aimbot.Settings.LockMode,
                Sensitivity = Aimbot.Settings.Sensitivity,
                Sensitivity2 = Aimbot.Settings.Sensitivity2,
                OffsetToMoveDirection = Aimbot.Settings.OffsetToMoveDirection,
                OffsetIncrement = Aimbot.Settings.OffsetIncrement
            },
            FOVSettings = {
                Enabled = Aimbot.FOVSettings.Enabled,
                Visible = Aimbot.FOVSettings.Visible,
                Radius = Aimbot.FOVSettings.Radius,
                NumSides = Aimbot.FOVSettings.NumSides,
                Thickness = Aimbot.FOVSettings.Thickness,
                Transparency = Aimbot.FOVSettings.Transparency,
                Filled = Aimbot.FOVSettings.Filled,
                RainbowColor = Aimbot.FOVSettings.RainbowColor,
                RainbowOutlineColor = Aimbot.FOVSettings.RainbowOutlineColor,
                Color = ConfigManager.Color3ToTable(Aimbot.FOVSettings.Color),
                OutlineColor = ConfigManager.Color3ToTable(Aimbot.FOVSettings.OutlineColor),
                LockedColor = ConfigManager.Color3ToTable(Aimbot.FOVSettings.LockedColor)
            },
            DeveloperSettings = {
                UpdateMode = Aimbot.DeveloperSettings.UpdateMode,
                TeamCheckOption = Aimbot.DeveloperSettings.TeamCheckOption,
                RainbowSpeed = Aimbot.DeveloperSettings.RainbowSpeed
            },
            Blacklisted = Aimbot.Blacklisted
        }
    end
    
    return config
end

-- Apply configuration
function ConfigManager.ApplyConfig(config)
    -- Apply ESP settings
    if config.ESP then
        -- Global settings
        if config.ESP.Global then
            Sense.sharedSettings.useTeamColor = config.ESP.Global.useTeamColor
            Sense.sharedSettings.limitDistance = config.ESP.Global.limitDistance
            Sense.sharedSettings.maxDistance = config.ESP.Global.maxDistance
            Sense.sharedSettings.textSize = config.ESP.Global.textSize
            Sense.sharedSettings.textFont = config.ESP.Global.textFont
        end
        
        -- Enemy settings
        if config.ESP.Enemy then
            local enemy = config.ESP.Enemy
            Sense.teamSettings.enemy.enabled = enemy.enabled
            Sense.teamSettings.enemy.box = enemy.box
            Sense.teamSettings.enemy.boxFill = enemy.boxFill
            Sense.teamSettings.enemy.box3d = enemy.box3d
            Sense.teamSettings.enemy.healthBar = enemy.healthBar
            Sense.teamSettings.enemy.healthText = enemy.healthText
            Sense.teamSettings.enemy.name = enemy.name
            Sense.teamSettings.enemy.distance = enemy.distance
            Sense.teamSettings.enemy.weapon = enemy.weapon
            Sense.teamSettings.enemy.tracer = enemy.tracer
            Sense.teamSettings.enemy.tracerOrigin = enemy.tracerOrigin
            Sense.teamSettings.enemy.offScreenArrow = enemy.offScreenArrow
            Sense.teamSettings.enemy.offScreenArrowSize = enemy.offScreenArrowSize
            Sense.teamSettings.enemy.offScreenArrowRadius = enemy.offScreenArrowRadius
            Sense.teamSettings.enemy.chams = enemy.chams
            Sense.teamSettings.enemy.chamsVisibleOnly = enemy.chamsVisibleOnly
            Sense.teamSettings.enemy.boxColor = {ConfigManager.TableToColor3(enemy.boxColor[1]), enemy.boxColor[2]}
            Sense.teamSettings.enemy.boxFillColor = {ConfigManager.TableToColor3(enemy.boxFillColor[1]), enemy.boxFillColor[2]}
            Sense.teamSettings.enemy.tracerColor = {ConfigManager.TableToColor3(enemy.tracerColor[1])}
            Sense.teamSettings.enemy.chamsFillColor = {ConfigManager.TableToColor3(enemy.chamsFillColor[1])}
            Sense.teamSettings.enemy.chamsOutlineColor = {ConfigManager.TableToColor3(enemy.chamsOutlineColor[1])}
        end
        
        -- Friendly settings
        if config.ESP.Friendly then
            local friendly = config.ESP.Friendly
            Sense.teamSettings.friendly.enabled = friendly.enabled
            Sense.teamSettings.friendly.box = friendly.box
            Sense.teamSettings.friendly.boxFill = friendly.boxFill
            Sense.teamSettings.friendly.box3d = friendly.box3d
            Sense.teamSettings.friendly.healthBar = friendly.healthBar
            Sense.teamSettings.friendly.healthText = friendly.healthText
            Sense.teamSettings.friendly.name = friendly.name
            Sense.teamSettings.friendly.distance = friendly.distance
            Sense.teamSettings.friendly.weapon = friendly.weapon
            Sense.teamSettings.friendly.tracer = friendly.tracer
            Sense.teamSettings.friendly.tracerOrigin = friendly.tracerOrigin
            Sense.teamSettings.friendly.offScreenArrow = friendly.offScreenArrow
            Sense.teamSettings.friendly.chams = friendly.chams
            Sense.teamSettings.friendly.chamsVisibleOnly = friendly.chamsVisibleOnly
            Sense.teamSettings.friendly.boxColor = {ConfigManager.TableToColor3(friendly.boxColor[1]), friendly.boxColor[2]}
            Sense.teamSettings.friendly.boxFillColor = {ConfigManager.TableToColor3(friendly.boxFillColor[1]), friendly.boxFillColor[2]}
            Sense.teamSettings.friendly.tracerColor = {ConfigManager.TableToColor3(friendly.tracerColor[1])}
            Sense.teamSettings.friendly.chamsFillColor = {ConfigManager.TableToColor3(friendly.chamsFillColor[1])}
            Sense.teamSettings.friendly.chamsOutlineColor = {ConfigManager.TableToColor3(friendly.chamsOutlineColor[1])}
        end
        
        -- Whitelist
        if config.ESP.Whitelist then
            Sense.whitelist = config.ESP.Whitelist
        end
    end
    
    -- Apply Aimbot settings
    if config.Aimbot and (getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot) then
        local Aimbot = getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot
        
        if config.Aimbot.Settings then
            Aimbot.Settings.Enabled = config.Aimbot.Settings.Enabled
            Aimbot.Settings.TeamCheck = config.Aimbot.Settings.TeamCheck
            Aimbot.Settings.AliveCheck = config.Aimbot.Settings.AliveCheck
            Aimbot.Settings.WallCheck = config.Aimbot.Settings.WallCheck
            Aimbot.Settings.Toggle = config.Aimbot.Settings.Toggle
            Aimbot.Settings.LockPart = config.Aimbot.Settings.LockPart
            Aimbot.Settings.LockMode = config.Aimbot.Settings.LockMode
            Aimbot.Settings.Sensitivity = config.Aimbot.Settings.Sensitivity
            Aimbot.Settings.Sensitivity2 = config.Aimbot.Settings.Sensitivity2
            Aimbot.Settings.OffsetToMoveDirection = config.Aimbot.Settings.OffsetToMoveDirection
            Aimbot.Settings.OffsetIncrement = config.Aimbot.Settings.OffsetIncrement
        end
        
        if config.Aimbot.FOVSettings then
            Aimbot.FOVSettings.Enabled = config.Aimbot.FOVSettings.Enabled
            Aimbot.FOVSettings.Visible = config.Aimbot.FOVSettings.Visible
            Aimbot.FOVSettings.Radius = config.Aimbot.FOVSettings.Radius
            Aimbot.FOVSettings.NumSides = config.Aimbot.FOVSettings.NumSides
            Aimbot.FOVSettings.Thickness = config.Aimbot.FOVSettings.Thickness
            Aimbot.FOVSettings.Transparency = config.Aimbot.FOVSettings.Transparency
            Aimbot.FOVSettings.Filled = config.Aimbot.FOVSettings.Filled
            Aimbot.FOVSettings.RainbowColor = config.Aimbot.FOVSettings.RainbowColor
            Aimbot.FOVSettings.RainbowOutlineColor = config.Aimbot.FOVSettings.RainbowOutlineColor
            Aimbot.FOVSettings.Color = ConfigManager.TableToColor3(config.Aimbot.FOVSettings.Color)
            Aimbot.FOVSettings.OutlineColor = ConfigManager.TableToColor3(config.Aimbot.FOVSettings.OutlineColor)
            Aimbot.FOVSettings.LockedColor = ConfigManager.TableToColor3(config.Aimbot.FOVSettings.LockedColor)
        end
        
        if config.Aimbot.DeveloperSettings then
            Aimbot.DeveloperSettings.UpdateMode = config.Aimbot.DeveloperSettings.UpdateMode
            Aimbot.DeveloperSettings.TeamCheckOption = config.Aimbot.DeveloperSettings.TeamCheckOption
            Aimbot.DeveloperSettings.RainbowSpeed = config.Aimbot.DeveloperSettings.RainbowSpeed
        end
        
        if config.Aimbot.Blacklisted then
            Aimbot.Blacklisted = config.Aimbot.Blacklisted
        end
    end
end

-- Save configuration
function ConfigManager.SaveConfig(name)
    if not ConfigManager.CheckSupport() then
        return false, "Executor doesn't support file functions"
    end
    
    if name == "" then
        return false, "Config name cannot be empty"
    end
    
    local success, err = pcall(function()
        if not isfolder(ConfigManager.ConfigFolder) then
            makefolder(ConfigManager.ConfigFolder)
        end
        
        local config = ConfigManager.GetCurrentConfig()
        local json = HttpService:JSONEncode(config)
        local filePath = ConfigManager.ConfigFolder .. "/" .. name .. ".json"
        
        writefile(filePath, json)
        ConfigManager.CurrentConfigName = name
    end)
    
    if success then
        return true, "Config saved successfully!"
    else
        return false, "Failed to save config: " .. tostring(err)
    end
end

-- Load configuration
function ConfigManager.LoadConfig(name)
    if not ConfigManager.CheckSupport() then
        return false, "Executor doesn't support file functions"
    end
    
    local success, err = pcall(function()
        local filePath = ConfigManager.ConfigFolder .. "/" .. name .. ".json"
        local json = readfile(filePath)
        local config = HttpService:JSONDecode(json)
        
        ConfigManager.ApplyConfig(config)
        ConfigManager.CurrentConfigName = name
    end)
    
    if success then
        return true, "Config loaded successfully!"
    else
        return false, "Failed to load config: " .. tostring(err)
    end
end

-- Get list of configs
function ConfigManager.GetConfigList()
    if not ConfigManager.CheckSupport() then
        return {}
    end
    
    local configs = {}
    local success, err = pcall(function()
        if not isfolder(ConfigManager.ConfigFolder) then
            makefolder(ConfigManager.ConfigFolder)
        end
        
        local files = listfiles(ConfigManager.ConfigFolder)
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(configs, name)
            end
        end
    end)
    
    return configs
end

-- Delete configuration
function ConfigManager.DeleteConfig(name)
    if not ConfigManager.CheckSupport() then
        return false, "Executor doesn't support file functions"
    end
    
    local success, err = pcall(function()
        local filePath = ConfigManager.ConfigFolder .. "/" .. name .. ".json"
        delfile(filePath)
    end)
    
    if success then
        return true, "Config deleted successfully!"
    else
        return false, "Failed to delete config: " .. tostring(err)
    end
end

-- Update GUI elements to match loaded config (called after ApplyConfig)
function ConfigManager.UpdateGUIFromConfig(config, guiElements)
    if not config or not guiElements then return end
    
    -- Update ESP GUI elements
    if config.ESP and config.ESP.Global then
        pcall(function() if guiElements.ESP_UseTeamColor then guiElements.ESP_UseTeamColor:Set(config.ESP.Global.useTeamColor) end end)
        pcall(function() if guiElements.ESP_LimitDistance then guiElements.ESP_LimitDistance:Set(config.ESP.Global.limitDistance) end end)
        pcall(function() if guiElements.ESP_MaxDistance then guiElements.ESP_MaxDistance:Set(config.ESP.Global.maxDistance) end end)
        pcall(function() if guiElements.ESP_TextSize then guiElements.ESP_TextSize:Set(config.ESP.Global.textSize) end end)
        
        -- Text Font dropdown
        local fontMap = {[0] = "0 - Legacy", [1] = "1 - Arial", [2] = "2 - ArialBold", [3] = "3 - SourceSans", [4] = "4 - SourceSansBold"}
        pcall(function() if guiElements.ESP_TextFont then guiElements.ESP_TextFont:Set(fontMap[config.ESP.Global.textFont] or "2 - ArialBold") end end)
    end
    
    -- Update Enemy ESP GUI elements
    if config.ESP and config.ESP.Enemy then
        local enemy = config.ESP.Enemy
        pcall(function() if guiElements.ESP_Enemy_Enabled then guiElements.ESP_Enemy_Enabled:Set(enemy.enabled) end end)
        pcall(function() if guiElements.ESP_Enemy_Box then guiElements.ESP_Enemy_Box:Set(enemy.box) end end)
        pcall(function() if guiElements.ESP_Enemy_BoxFill then guiElements.ESP_Enemy_BoxFill:Set(enemy.boxFill) end end)
        pcall(function() if guiElements.ESP_Enemy_Box3D then guiElements.ESP_Enemy_Box3D:Set(enemy.box3d) end end)
        pcall(function() if guiElements.ESP_Enemy_HealthBar then guiElements.ESP_Enemy_HealthBar:Set(enemy.healthBar) end end)
        pcall(function() if guiElements.ESP_Enemy_HealthText then guiElements.ESP_Enemy_HealthText:Set(enemy.healthText) end end)
        pcall(function() if guiElements.ESP_Enemy_Name then guiElements.ESP_Enemy_Name:Set(enemy.name) end end)
        pcall(function() if guiElements.ESP_Enemy_Distance then guiElements.ESP_Enemy_Distance:Set(enemy.distance) end end)
        pcall(function() if guiElements.ESP_Enemy_Weapon then guiElements.ESP_Enemy_Weapon:Set(enemy.weapon) end end)
        pcall(function() if guiElements.ESP_Enemy_Tracer then guiElements.ESP_Enemy_Tracer:Set(enemy.tracer) end end)
        pcall(function() if guiElements.ESP_Enemy_TracerOrigin then guiElements.ESP_Enemy_TracerOrigin:Set(enemy.tracerOrigin) end end)
        pcall(function() if guiElements.ESP_Enemy_OffScreenArrow then guiElements.ESP_Enemy_OffScreenArrow:Set(enemy.offScreenArrow) end end)
        pcall(function() if guiElements.ESP_Enemy_ArrowSize then guiElements.ESP_Enemy_ArrowSize:Set(enemy.offScreenArrowSize) end end)
        pcall(function() if guiElements.ESP_Enemy_ArrowRadius then guiElements.ESP_Enemy_ArrowRadius:Set(enemy.offScreenArrowRadius) end end)
        pcall(function() if guiElements.ESP_Enemy_Chams then guiElements.ESP_Enemy_Chams:Set(enemy.chams) end end)
        pcall(function() if guiElements.ESP_Enemy_ChamsVisibleOnly then guiElements.ESP_Enemy_ChamsVisibleOnly:Set(enemy.chamsVisibleOnly) end end)
        
        -- Colors
        pcall(function() if guiElements.ESP_Enemy_BoxColor then guiElements.ESP_Enemy_BoxColor:Set(ConfigManager.TableToColor3(enemy.boxColor[1])) end end)
        pcall(function() if guiElements.ESP_Enemy_BoxOpacity then guiElements.ESP_Enemy_BoxOpacity:Set(enemy.boxColor[2]) end end)
        pcall(function() if guiElements.ESP_Enemy_BoxFillColor then guiElements.ESP_Enemy_BoxFillColor:Set(ConfigManager.TableToColor3(enemy.boxFillColor[1])) end end)
        pcall(function() if guiElements.ESP_Enemy_FillOpacity then guiElements.ESP_Enemy_FillOpacity:Set(enemy.boxFillColor[2]) end end)
        pcall(function() if guiElements.ESP_Enemy_TracerColor then guiElements.ESP_Enemy_TracerColor:Set(ConfigManager.TableToColor3(enemy.tracerColor[1])) end end)
        pcall(function() if guiElements.ESP_Enemy_ChamsFillColor then guiElements.ESP_Enemy_ChamsFillColor:Set(ConfigManager.TableToColor3(enemy.chamsFillColor[1])) end end)
        pcall(function() if guiElements.ESP_Enemy_ChamsOutlineColor then guiElements.ESP_Enemy_ChamsOutlineColor:Set(ConfigManager.TableToColor3(enemy.chamsOutlineColor[1])) end end)
    end
    
    -- Update Friendly ESP GUI elements
    if config.ESP and config.ESP.Friendly then
        local friendly = config.ESP.Friendly
        pcall(function() if guiElements.ESP_Friendly_Enabled then guiElements.ESP_Friendly_Enabled:Set(friendly.enabled) end end)
        pcall(function() if guiElements.ESP_Friendly_Box then guiElements.ESP_Friendly_Box:Set(friendly.box) end end)
        pcall(function() if guiElements.ESP_Friendly_BoxFill then guiElements.ESP_Friendly_BoxFill:Set(friendly.boxFill) end end)
        pcall(function() if guiElements.ESP_Friendly_Box3D then guiElements.ESP_Friendly_Box3D:Set(friendly.box3d) end end)
        pcall(function() if guiElements.ESP_Friendly_HealthBar then guiElements.ESP_Friendly_HealthBar:Set(friendly.healthBar) end end)
        pcall(function() if guiElements.ESP_Friendly_HealthText then guiElements.ESP_Friendly_HealthText:Set(friendly.healthText) end end)
        pcall(function() if guiElements.ESP_Friendly_Name then guiElements.ESP_Friendly_Name:Set(friendly.name) end end)
        pcall(function() if guiElements.ESP_Friendly_Distance then guiElements.ESP_Friendly_Distance:Set(friendly.distance) end end)
        pcall(function() if guiElements.ESP_Friendly_Weapon then guiElements.ESP_Friendly_Weapon:Set(friendly.weapon) end end)
        pcall(function() if guiElements.ESP_Friendly_Tracer then guiElements.ESP_Friendly_Tracer:Set(friendly.tracer) end end)
        pcall(function() if guiElements.ESP_Friendly_TracerOrigin then guiElements.ESP_Friendly_TracerOrigin:Set(friendly.tracerOrigin) end end)
        pcall(function() if guiElements.ESP_Friendly_OffScreenArrow then guiElements.ESP_Friendly_OffScreenArrow:Set(friendly.offScreenArrow) end end)
        pcall(function() if guiElements.ESP_Friendly_Chams then guiElements.ESP_Friendly_Chams:Set(friendly.chams) end end)
        pcall(function() if guiElements.ESP_Friendly_ChamsVisibleOnly then guiElements.ESP_Friendly_ChamsVisibleOnly:Set(friendly.chamsVisibleOnly) end end)
        
        -- Colors
        pcall(function() if guiElements.ESP_Friendly_BoxColor then guiElements.ESP_Friendly_BoxColor:Set(ConfigManager.TableToColor3(friendly.boxColor[1])) end end)
        pcall(function() if guiElements.ESP_Friendly_BoxOpacity then guiElements.ESP_Friendly_BoxOpacity:Set(friendly.boxColor[2]) end end)
        pcall(function() if guiElements.ESP_Friendly_BoxFillColor then guiElements.ESP_Friendly_BoxFillColor:Set(ConfigManager.TableToColor3(friendly.boxFillColor[1])) end end)
        pcall(function() if guiElements.ESP_Friendly_FillOpacity then guiElements.ESP_Friendly_FillOpacity:Set(friendly.boxFillColor[2]) end end)
        pcall(function() if guiElements.ESP_Friendly_TracerColor then guiElements.ESP_Friendly_TracerColor:Set(ConfigManager.TableToColor3(friendly.tracerColor[1])) end end)
        pcall(function() if guiElements.ESP_Friendly_ChamsFillColor then guiElements.ESP_Friendly_ChamsFillColor:Set(ConfigManager.TableToColor3(friendly.chamsFillColor[1])) end end)
        pcall(function() if guiElements.ESP_Friendly_ChamsOutlineColor then guiElements.ESP_Friendly_ChamsOutlineColor:Set(ConfigManager.TableToColor3(friendly.chamsOutlineColor[1])) end end)
    end
    
    -- Update Aimbot GUI elements
    if config.Aimbot and (getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot) then
        if config.Aimbot.Settings then
            pcall(function() if guiElements.Aimbot_Enabled then guiElements.Aimbot_Enabled:Set(config.Aimbot.Settings.Enabled) end end)
            pcall(function() if guiElements.Aimbot_TeamCheck then guiElements.Aimbot_TeamCheck:Set(config.Aimbot.Settings.TeamCheck) end end)
            pcall(function() if guiElements.Aimbot_AliveCheck then guiElements.Aimbot_AliveCheck:Set(config.Aimbot.Settings.AliveCheck) end end)
            pcall(function() if guiElements.Aimbot_WallCheck then guiElements.Aimbot_WallCheck:Set(config.Aimbot.Settings.WallCheck) end end)
            pcall(function() if guiElements.Aimbot_Toggle then guiElements.Aimbot_Toggle:Set(config.Aimbot.Settings.Toggle) end end)
            pcall(function() if guiElements.Aimbot_LockPart then guiElements.Aimbot_LockPart:Set(config.Aimbot.Settings.LockPart) end end)
            
            -- Lock Mode dropdown
            local lockModeMap = {[1] = "1 - CFrame (Smooth)", [2] = "2 - MouseMoveRel (Instant)"}
            pcall(function() if guiElements.Aimbot_LockMode then guiElements.Aimbot_LockMode:Set(lockModeMap[config.Aimbot.Settings.LockMode] or "1 - CFrame (Smooth)") end end)
            
            pcall(function() if guiElements.Aimbot_Sensitivity then guiElements.Aimbot_Sensitivity:Set(config.Aimbot.Settings.Sensitivity) end end)
            pcall(function() if guiElements.Aimbot_Sensitivity2 then guiElements.Aimbot_Sensitivity2:Set(config.Aimbot.Settings.Sensitivity2) end end)
            pcall(function() if guiElements.Aimbot_Prediction then guiElements.Aimbot_Prediction:Set(config.Aimbot.Settings.OffsetToMoveDirection) end end)
            pcall(function() if guiElements.Aimbot_OffsetIncrement then guiElements.Aimbot_OffsetIncrement:Set(config.Aimbot.Settings.OffsetIncrement) end end)
        end
        
        if config.Aimbot.FOVSettings then
            pcall(function() if guiElements.Aimbot_FOV_Enabled then guiElements.Aimbot_FOV_Enabled:Set(config.Aimbot.FOVSettings.Enabled) end end)
            pcall(function() if guiElements.Aimbot_FOV_Visible then guiElements.Aimbot_FOV_Visible:Set(config.Aimbot.FOVSettings.Visible) end end)
            pcall(function() if guiElements.Aimbot_FOV_Radius then guiElements.Aimbot_FOV_Radius:Set(config.Aimbot.FOVSettings.Radius) end end)
            pcall(function() if guiElements.Aimbot_FOV_NumSides then guiElements.Aimbot_FOV_NumSides:Set(config.Aimbot.FOVSettings.NumSides) end end)
            pcall(function() if guiElements.Aimbot_FOV_Thickness then guiElements.Aimbot_FOV_Thickness:Set(config.Aimbot.FOVSettings.Thickness) end end)
            pcall(function() if guiElements.Aimbot_FOV_Transparency then guiElements.Aimbot_FOV_Transparency:Set(config.Aimbot.FOVSettings.Transparency) end end)
            pcall(function() if guiElements.Aimbot_FOV_Filled then guiElements.Aimbot_FOV_Filled:Set(config.Aimbot.FOVSettings.Filled) end end)
            pcall(function() if guiElements.Aimbot_FOV_RainbowColor then guiElements.Aimbot_FOV_RainbowColor:Set(config.Aimbot.FOVSettings.RainbowColor) end end)
            pcall(function() if guiElements.Aimbot_FOV_RainbowOutline then guiElements.Aimbot_FOV_RainbowOutline:Set(config.Aimbot.FOVSettings.RainbowOutlineColor) end end)
            pcall(function() if guiElements.Aimbot_FOV_Color then guiElements.Aimbot_FOV_Color:Set(ConfigManager.TableToColor3(config.Aimbot.FOVSettings.Color)) end end)
            pcall(function() if guiElements.Aimbot_FOV_OutlineColor then guiElements.Aimbot_FOV_OutlineColor:Set(ConfigManager.TableToColor3(config.Aimbot.FOVSettings.OutlineColor)) end end)
            pcall(function() if guiElements.Aimbot_FOV_LockedColor then guiElements.Aimbot_FOV_LockedColor:Set(ConfigManager.TableToColor3(config.Aimbot.FOVSettings.LockedColor)) end end)
        end
        
        if config.Aimbot.DeveloperSettings then
            pcall(function() if guiElements.Aimbot_UpdateMode then guiElements.Aimbot_UpdateMode:Set(config.Aimbot.DeveloperSettings.UpdateMode) end end)
            pcall(function() if guiElements.Aimbot_TeamCheckOption then guiElements.Aimbot_TeamCheckOption:Set(config.Aimbot.DeveloperSettings.TeamCheckOption) end end)
            pcall(function() if guiElements.Aimbot_RainbowSpeed then guiElements.Aimbot_RainbowSpeed:Set(config.Aimbot.DeveloperSettings.RainbowSpeed) end end)
        end
    end
end

-- Create main window
local Window = CustomGUI.new({
    Title = "ToastyHub Universal Script",
    Size = UDim2.new(0, 600, 0, 650),
    Position = UDim2.new(0.5, -300, 0.5, -325),
    Visible = true
})

-- Storage for GUI elements (for updating when loading configs)
-- Flag names match exactly with what's used in GUI creation
local GUIElements = {}

--=============================================================================--
--                              ESP TAB
--=============================================================================--
local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "👁️"
})

--=============================================================================--
--                          ESP ACTIONS
--=============================================================================--
ESPTab:CreateSection("ESP Actions")

ESPTab:CreateButton({
    Name = "Load ESP",
    Callback = function()
        pcall(function()
            Sense.Load()
        end)
    end
})

ESPTab:CreateButton({
    Name = "Unload ESP",
    Callback = function()
        pcall(function()
            Sense.Unload()
        end)
    end
})

--=============================================================================--
--                          GLOBAL ESP SETTINGS
--=============================================================================--
ESPTab:CreateSection("Global Settings")

GUIElements.ESP_UseTeamColor = ESPTab:CreateToggle({
    Name = "Use Team Colors",
    CurrentValue = false,
    Flag = "ESP_UseTeamColor",
    Callback = function(value)
        Sense.sharedSettings.useTeamColor = value
    end
})

GUIElements.ESP_LimitDistance = ESPTab:CreateToggle({
    Name = "Limit Distance",
    CurrentValue = false,
    Flag = "ESP_LimitDistance",
    Callback = function(value)
        Sense.sharedSettings.limitDistance = value
    end
})

GUIElements.ESP_MaxDistance = ESPTab:CreateSlider({
    Name = "Max Distance",
    Min = 50,
    Max = 5000,
    Default = 150,
    Increment = 50,
    Flag = "ESP_MaxDistance",
    Callback = function(value)
        Sense.sharedSettings.maxDistance = value
    end
})

GUIElements.ESP_TextSize = ESPTab:CreateSlider({
    Name = "Text Size",
    Min = 8,
    Max = 20,
    Default = 13,
    Increment = 1,
    Flag = "ESP_TextSize",
    Callback = function(value)
        Sense.sharedSettings.textSize = value
    end
})

GUIElements.ESP_TextFont = ESPTab:CreateDropdown({
    Name = "Text Font",
    Options = {"0 - Legacy", "1 - Arial", "2 - ArialBold", "3 - SourceSans", "4 - SourceSansBold"},
    Default = "2 - ArialBold",
    Multi = false,
    Flag = "ESP_TextFont",
    Callback = function(value)
        local fontMap = {
            ["0 - Legacy"] = 0,
            ["1 - Arial"] = 1,
            ["2 - ArialBold"] = 2,
            ["3 - SourceSans"] = 3,
            ["4 - SourceSansBold"] = 4
        }
        Sense.sharedSettings.textFont = fontMap[value] or 2
    end
})

--=============================================================================--
--                          ENEMY ESP SETTINGS
--=============================================================================--
ESPTab:CreateSection("Enemy ESP")

GUIElements.ESP_Enemy_Enabled = ESPTab:CreateToggle({
    Name = "Enable Enemy ESP",
    CurrentValue = false,
    Flag = "ESP_Enemy_Enabled",
    Callback = function(value)
        Sense.teamSettings.enemy.enabled = value
    end
})

GUIElements.ESP_Enemy_Box = ESPTab:CreateToggle({
    Name = "Box",
    CurrentValue = false,
    Flag = "ESP_Enemy_Box",
    Callback = function(value)
        Sense.teamSettings.enemy.box = value
    end
})

GUIElements.ESP_Enemy_BoxFill = ESPTab:CreateToggle({
    Name = "Box Fill",
    CurrentValue = false,
    Flag = "ESP_Enemy_BoxFill",
    Callback = function(value)
        Sense.teamSettings.enemy.boxFill = value
    end
})

GUIElements.ESP_Enemy_Box3D = ESPTab:CreateToggle({
    Name = "3D Box",
    CurrentValue = false,
    Flag = "ESP_Enemy_Box3D",
    Callback = function(value)
        Sense.teamSettings.enemy.box3d = value
    end
})

GUIElements.ESP_Enemy_HealthBar = ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "ESP_Enemy_HealthBar",
    Callback = function(value)
        Sense.teamSettings.enemy.healthBar = value
    end
})

GUIElements.ESP_Enemy_HealthText = ESPTab:CreateToggle({
    Name = "Health Text",
    CurrentValue = false,
    Flag = "ESP_Enemy_HealthText",
    Callback = function(value)
        Sense.teamSettings.enemy.healthText = value
    end
})

GUIElements.ESP_Enemy_Name = ESPTab:CreateToggle({
    Name = "Name",
    CurrentValue = false,
    Flag = "ESP_Enemy_Name",
    Callback = function(value)
        Sense.teamSettings.enemy.name = value
    end
})

GUIElements.ESP_Enemy_Distance = ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Flag = "ESP_Enemy_Distance",
    Callback = function(value)
        Sense.teamSettings.enemy.distance = value
    end
})

GUIElements.ESP_Enemy_Weapon = ESPTab:CreateToggle({
    Name = "Weapon",
    CurrentValue = false,
    Flag = "ESP_Enemy_Weapon",
    Callback = function(value)
        Sense.teamSettings.enemy.weapon = value
    end
})

GUIElements.ESP_Enemy_Tracer = ESPTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Flag = "ESP_Enemy_Tracer",
    Callback = function(value)
        Sense.teamSettings.enemy.tracer = value
    end
})

GUIElements.ESP_Enemy_TracerOrigin = ESPTab:CreateDropdown({
    Name = "Tracer Origin",
    Options = {"Top", "Middle", "Bottom"},
    Default = "Bottom",
    Multi = false,
    Flag = "ESP_Enemy_TracerOrigin",
    Callback = function(value)
        Sense.teamSettings.enemy.tracerOrigin = value
    end
})

GUIElements.ESP_Enemy_OffScreenArrow = ESPTab:CreateToggle({
    Name = "Off-Screen Arrow",
    CurrentValue = false,
    Flag = "ESP_Enemy_OffScreenArrow",
    Callback = function(value)
        Sense.teamSettings.enemy.offScreenArrow = value
    end
})

GUIElements.ESP_Enemy_ArrowSize = ESPTab:CreateSlider({
    Name = "Arrow Size",
    Min = 10,
    Max = 30,
    Default = 15,
    Increment = 1,
    Flag = "ESP_Enemy_ArrowSize",
    Callback = function(value)
        Sense.teamSettings.enemy.offScreenArrowSize = value
    end
})

GUIElements.ESP_Enemy_ArrowRadius = ESPTab:CreateSlider({
    Name = "Arrow Radius",
    Min = 100,
    Max = 300,
    Default = 150,
    Increment = 10,
    Flag = "ESP_Enemy_ArrowRadius",
    Callback = function(value)
        Sense.teamSettings.enemy.offScreenArrowRadius = value
    end
})

GUIElements.ESP_Enemy_Chams = ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ESP_Enemy_Chams",
    Callback = function(value)
        Sense.teamSettings.enemy.chams = value
    end
})

GUIElements.ESP_Enemy_ChamsVisibleOnly = ESPTab:CreateToggle({
    Name = "Chams Visible Only",
    CurrentValue = false,
    Flag = "ESP_Enemy_ChamsVisibleOnly",
    Callback = function(value)
        Sense.teamSettings.enemy.chamsVisibleOnly = value
    end
})

--=============================================================================--
--                        ENEMY ESP COLORS
--=============================================================================--
ESPTab:CreateSection("Enemy Colors")

GUIElements.ESP_Enemy_BoxColor = ESPTab:CreateColorPicker({
    Name = "Box Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESP_Enemy_BoxColor",
    Callback = function(color)
        Sense.teamSettings.enemy.boxColor[1] = color
    end
})

GUIElements.ESP_Enemy_BoxOpacity = ESPTab:CreateSlider({
    Name = "Box Opacity",
    Min = 0,
    Max = 1,
    Default = 1,
    Increment = 0.1,
    Flag = "ESP_Enemy_BoxOpacity",
    Callback = function(value)
        Sense.teamSettings.enemy.boxColor[2] = value
    end
})

GUIElements.ESP_Enemy_BoxFillColor = ESPTab:CreateColorPicker({
    Name = "Box Fill Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESP_Enemy_BoxFillColor",
    Callback = function(color)
        Sense.teamSettings.enemy.boxFillColor[1] = color
    end
})

GUIElements.ESP_Enemy_FillOpacity = ESPTab:CreateSlider({
    Name = "Fill Opacity",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.1,
    Flag = "ESP_Enemy_FillOpacity",
    Callback = function(value)
        Sense.teamSettings.enemy.boxFillColor[2] = value
    end
})

GUIElements.ESP_Enemy_TracerColor = ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESP_Enemy_TracerColor",
    Callback = function(color)
        Sense.teamSettings.enemy.tracerColor[1] = color
    end
})

GUIElements.ESP_Enemy_ChamsFillColor = ESPTab:CreateColorPicker({
    Name = "Chams Fill Color",
    Default = Color3.fromRGB(51, 51, 51),
    Flag = "ESP_Enemy_ChamsFillColor",
    Callback = function(color)
        Sense.teamSettings.enemy.chamsFillColor[1] = color
    end
})

GUIElements.ESP_Enemy_ChamsOutlineColor = ESPTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESP_Enemy_ChamsOutlineColor",
    Callback = function(color)
        Sense.teamSettings.enemy.chamsOutlineColor[1] = color
    end
})

--=============================================================================--
--                          FRIENDLY ESP SETTINGS
--=============================================================================--
ESPTab:CreateSection("Friendly ESP")

GUIElements.ESP_Friendly_Enabled = ESPTab:CreateToggle({
    Name = "Enable Friendly ESP",
    CurrentValue = false,
    Flag = "ESP_Friendly_Enabled",
    Callback = function(value)
        Sense.teamSettings.friendly.enabled = value
    end
})

GUIElements.ESP_Friendly_Box = ESPTab:CreateToggle({
    Name = "Box",
    CurrentValue = false,
    Flag = "ESP_Friendly_Box",
    Callback = function(value)
        Sense.teamSettings.friendly.box = value
    end
})

GUIElements.ESP_Friendly_BoxFill = ESPTab:CreateToggle({
    Name = "Box Fill",
    CurrentValue = false,
    Flag = "ESP_Friendly_BoxFill",
    Callback = function(value)
        Sense.teamSettings.friendly.boxFill = value
    end
})

GUIElements.ESP_Friendly_Box3D = ESPTab:CreateToggle({
    Name = "3D Box",
    CurrentValue = false,
    Flag = "ESP_Friendly_Box3D",
    Callback = function(value)
        Sense.teamSettings.friendly.box3d = value
    end
})

GUIElements.ESP_Friendly_HealthBar = ESPTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "ESP_Friendly_HealthBar",
    Callback = function(value)
        Sense.teamSettings.friendly.healthBar = value
    end
})

GUIElements.ESP_Friendly_HealthText = ESPTab:CreateToggle({
    Name = "Health Text",
    CurrentValue = false,
    Flag = "ESP_Friendly_HealthText",
    Callback = function(value)
        Sense.teamSettings.friendly.healthText = value
    end
})

GUIElements.ESP_Friendly_Name = ESPTab:CreateToggle({
    Name = "Name",
    CurrentValue = false,
    Flag = "ESP_Friendly_Name",
    Callback = function(value)
        Sense.teamSettings.friendly.name = value
    end
})

GUIElements.ESP_Friendly_Distance = ESPTab:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Flag = "ESP_Friendly_Distance",
    Callback = function(value)
        Sense.teamSettings.friendly.distance = value
    end
})

GUIElements.ESP_Friendly_Weapon = ESPTab:CreateToggle({
    Name = "Weapon",
    CurrentValue = false,
    Flag = "ESP_Friendly_Weapon",
    Callback = function(value)
        Sense.teamSettings.friendly.weapon = value
    end
})

GUIElements.ESP_Friendly_Tracer = ESPTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Flag = "ESP_Friendly_Tracer",
    Callback = function(value)
        Sense.teamSettings.friendly.tracer = value
    end
})

GUIElements.ESP_Friendly_TracerOrigin = ESPTab:CreateDropdown({
    Name = "Tracer Origin",
    Options = {"Top", "Middle", "Bottom"},
    Default = "Bottom",
    Multi = false,
    Flag = "ESP_Friendly_TracerOrigin",
    Callback = function(value)
        Sense.teamSettings.friendly.tracerOrigin = value
    end
})

GUIElements.ESP_Friendly_OffScreenArrow = ESPTab:CreateToggle({
    Name = "Off-Screen Arrow",
    CurrentValue = false,
    Flag = "ESP_Friendly_OffScreenArrow",
    Callback = function(value)
        Sense.teamSettings.friendly.offScreenArrow = value
    end
})

GUIElements.ESP_Friendly_Chams = ESPTab:CreateToggle({
    Name = "Chams",
    CurrentValue = false,
    Flag = "ESP_Friendly_Chams",
    Callback = function(value)
        Sense.teamSettings.friendly.chams = value
    end
})

GUIElements.ESP_Friendly_ChamsVisibleOnly = ESPTab:CreateToggle({
    Name = "Chams Visible Only",
    CurrentValue = false,
    Flag = "ESP_Friendly_ChamsVisibleOnly",
    Callback = function(value)
        Sense.teamSettings.friendly.chamsVisibleOnly = value
    end
})

--=============================================================================--
--                        FRIENDLY ESP COLORS
--=============================================================================--
ESPTab:CreateSection("Friendly Colors")

GUIElements.ESP_Friendly_BoxColor = ESPTab:CreateColorPicker({
    Name = "Box Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "ESP_Friendly_BoxColor",
    Callback = function(color)
        Sense.teamSettings.friendly.boxColor[1] = color
    end
})

GUIElements.ESP_Friendly_BoxOpacity = ESPTab:CreateSlider({
    Name = "Box Opacity",
    Min = 0,
    Max = 1,
    Default = 1,
    Increment = 0.1,
    Flag = "ESP_Friendly_BoxOpacity",
    Callback = function(value)
        Sense.teamSettings.friendly.boxColor[2] = value
    end
})

GUIElements.ESP_Friendly_BoxFillColor = ESPTab:CreateColorPicker({
    Name = "Box Fill Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "ESP_Friendly_BoxFillColor",
    Callback = function(color)
        Sense.teamSettings.friendly.boxFillColor[1] = color
    end
})

GUIElements.ESP_Friendly_FillOpacity = ESPTab:CreateSlider({
    Name = "Fill Opacity",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.1,
    Flag = "ESP_Friendly_FillOpacity",
    Callback = function(value)
        Sense.teamSettings.friendly.boxFillColor[2] = value
    end
})

GUIElements.ESP_Friendly_TracerColor = ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "ESP_Friendly_TracerColor",
    Callback = function(color)
        Sense.teamSettings.friendly.tracerColor[1] = color
    end
})

GUIElements.ESP_Friendly_ChamsFillColor = ESPTab:CreateColorPicker({
    Name = "Chams Fill Color",
    Default = Color3.fromRGB(51, 51, 51),
    Flag = "ESP_Friendly_ChamsFillColor",
    Callback = function(color)
        Sense.teamSettings.friendly.chamsFillColor[1] = color
    end
})

GUIElements.ESP_Friendly_ChamsOutlineColor = ESPTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "ESP_Friendly_ChamsOutlineColor",
    Callback = function(color)
        Sense.teamSettings.friendly.chamsOutlineColor[1] = color
    end
})

--=============================================================================--
--                            AIMBOT TAB
--=============================================================================--
local AimbotTab = Window:CreateTab({
    Name = "Aimbot",
    Icon = "🎯"
})

-- Load Mobile Aimbot Library with error handling
local aimbotLoadSuccess = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nouralddin-abdullah/99-night/refs/heads/main/AimbotV3-mobile.lua"))()
end)

-- Check if aimbot loaded successfully
local Aimbot = getgenv().ExunysDeveloperAimbot or _G.ExunysDeveloperAimbot or ExunysDeveloperAimbot

if not aimbotLoadSuccess or not Aimbot then
    AimbotTab:CreateSection("Aimbot Unavailable")
    AimbotTab:CreateParagraph({
        Title = "⚠️ Aimbot Not Supported",
        Content = "The aimbot library failed to load or is not compatible with this game/executor."
    })
else

--=============================================================================--
--                          AIMBOT ACTIONS
--=============================================================================--
AimbotTab:CreateSection("Aimbot Actions")

AimbotTab:CreateParagraph({
    Title = "📱 Mobile Aimbot",
    Content = "This is the mobile-optimized version! When you load the aimbot, a draggable target button (🎯) will appear on the right side. Tap it to toggle aimbot on/off!"
})

AimbotTab:CreateButton({
    Name = "Load Aimbot",
    Callback = function()
        pcall(function()
            Aimbot.Load()
        end)
    end
})

AimbotTab:CreateButton({
    Name = "Restart Aimbot",
    Callback = function()
        pcall(function()
            ExunysDeveloperAimbot.Restart()
        end)
    end
})

AimbotTab:CreateButton({
    Name = "Unload Aimbot",
    Callback = function()
        pcall(function()
            ExunysDeveloperAimbot:Exit()
        end)
    end
})

--=============================================================================--
--                          MAIN SETTINGS
--=============================================================================--
AimbotTab:CreateSection("Main Settings")

GUIElements.Aimbot_Enabled = AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = true,
    Flag = "Aimbot_Enabled",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.Enabled = value
    end
})

GUIElements.Aimbot_TeamCheck = AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "Aimbot_TeamCheck",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.TeamCheck = value
    end
})

GUIElements.Aimbot_AliveCheck = AimbotTab:CreateToggle({
    Name = "Alive Check",
    CurrentValue = true,
    Flag = "Aimbot_AliveCheck",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.AliveCheck = value
    end
})

GUIElements.Aimbot_WallCheck = AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "Aimbot_WallCheck",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.WallCheck = value
    end
})

GUIElements.Aimbot_Toggle = AimbotTab:CreateToggle({
    Name = "Toggle Mode",
    CurrentValue = false,
    Flag = "Aimbot_Toggle",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.Toggle = value
    end
})

GUIElements.Aimbot_TriggerKey = AimbotTab:CreateDropdown({
    Name = "Trigger Key",
    Options = {"MouseButton1", "MouseButton2", "E", "Q", "C", "V", "X", "Z"},
    Default = "MouseButton2",
    Multi = false,
    Flag = "Aimbot_TriggerKey",
    Callback = function(value)
        local keyMap = {
            ["MouseButton1"] = Enum.UserInputType.MouseButton1,
            ["MouseButton2"] = Enum.UserInputType.MouseButton2,
            ["E"] = Enum.KeyCode.E,
            ["Q"] = Enum.KeyCode.Q,
            ["C"] = Enum.KeyCode.C,
            ["V"] = Enum.KeyCode.V,
            ["X"] = Enum.KeyCode.X,
            ["Z"] = Enum.KeyCode.Z
        }
        ExunysDeveloperAimbot.Settings.TriggerKey = keyMap[value] or Enum.UserInputType.MouseButton2
    end
})

GUIElements.Aimbot_LockPart = AimbotTab:CreateDropdown({
    Name = "Lock Part",
    Options = {"Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"},
    Default = "Head",
    Multi = false,
    Flag = "Aimbot_LockPart",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.LockPart = value
    end
})

--=============================================================================--
--                          LOCK MODE & SENSITIVITY
--=============================================================================--
AimbotTab:CreateSection("Lock Mode & Sensitivity")

GUIElements.Aimbot_LockMode = AimbotTab:CreateDropdown({
    Name = "Lock Mode",
    Options = {"1 - CFrame (Smooth)", "2 - MouseMoveRel (Instant)"},
    Default = "1 - CFrame (Smooth)",
    Multi = false,
    Flag = "Aimbot_LockMode",
    Callback = function(value)
        if value == "1 - CFrame (Smooth)" then
            ExunysDeveloperAimbot.Settings.LockMode = 1
        else
            ExunysDeveloperAimbot.Settings.LockMode = 2
        end
    end
})

GUIElements.Aimbot_Sensitivity = AimbotTab:CreateSlider({
    Name = "CFrame Sensitivity",
    Min = 0,
    Max = 5,
    Default = 0,
    Increment = 0.1,
    Flag = "Aimbot_Sensitivity",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.Sensitivity = value
    end
})

AimbotTab:CreateLabel("(Animation length in seconds before fully locking)")

GUIElements.Aimbot_Sensitivity2 = AimbotTab:CreateSlider({
    Name = "MouseMoveRel Sensitivity",
    Min = 0.5,
    Max = 10,
    Default = 3.5,
    Increment = 0.5,
    Flag = "Aimbot_Sensitivity2",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.Sensitivity2 = value
    end
})

--=============================================================================--
--                          PREDICTION SETTINGS
--=============================================================================--
AimbotTab:CreateSection("Prediction Settings")

GUIElements.Aimbot_Prediction = AimbotTab:CreateToggle({
    Name = "Prediction (Offset to Move Direction)",
    CurrentValue = false,
    Flag = "Aimbot_Prediction",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.OffsetToMoveDirection = value
    end
})

GUIElements.Aimbot_OffsetIncrement = AimbotTab:CreateSlider({
    Name = "Prediction Amplitude",
    Min = 1,
    Max = 30,
    Default = 15,
    Increment = 1,
    Flag = "Aimbot_OffsetIncrement",
    Callback = function(value)
        ExunysDeveloperAimbot.Settings.OffsetIncrement = value
    end
})

AimbotTab:CreateLabel("(Higher = More prediction)")

--=============================================================================--
--                          FOV SETTINGS
--=============================================================================--
AimbotTab:CreateSection("FOV Settings")

GUIElements.Aimbot_FOV_Enabled = AimbotTab:CreateToggle({
    Name = "Enable FOV",
    CurrentValue = true,
    Flag = "Aimbot_FOV_Enabled",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Enabled = value
    end
})

GUIElements.Aimbot_FOV_Visible = AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "Aimbot_FOV_Visible",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Visible = value
    end
})

GUIElements.Aimbot_FOV_Radius = AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Min = 10,
    Max = 500,
    Default = 90,
    Increment = 5,
    Flag = "Aimbot_FOV_Radius",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Radius = value
    end
})

GUIElements.Aimbot_FOV_NumSides = AimbotTab:CreateSlider({
    Name = "FOV Sides",
    Min = 3,
    Max = 100,
    Default = 60,
    Increment = 1,
    Flag = "Aimbot_FOV_NumSides",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.NumSides = value
    end
})

GUIElements.Aimbot_FOV_Thickness = AimbotTab:CreateSlider({
    Name = "FOV Thickness",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 1,
    Flag = "Aimbot_FOV_Thickness",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Thickness = value
    end
})

GUIElements.Aimbot_FOV_Transparency = AimbotTab:CreateSlider({
    Name = "FOV Transparency",
    Min = 0,
    Max = 1,
    Default = 1,
    Increment = 0.1,
    Flag = "Aimbot_FOV_Transparency",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Transparency = value
    end
})

GUIElements.Aimbot_FOV_Filled = AimbotTab:CreateToggle({
    Name = "FOV Filled",
    CurrentValue = false,
    Flag = "Aimbot_FOV_Filled",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.Filled = value
    end
})

--=============================================================================--
--                          FOV COLORS
--=============================================================================--
AimbotTab:CreateSection("FOV Colors")

GUIElements.Aimbot_FOV_RainbowColor = AimbotTab:CreateToggle({
    Name = "Rainbow FOV Color",
    CurrentValue = false,
    Flag = "Aimbot_FOV_RainbowColor",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.RainbowColor = value
    end
})

GUIElements.Aimbot_FOV_RainbowOutline = AimbotTab:CreateToggle({
    Name = "Rainbow Outline Color",
    CurrentValue = false,
    Flag = "Aimbot_FOV_RainbowOutline",
    Callback = function(value)
        ExunysDeveloperAimbot.FOVSettings.RainbowOutlineColor = value
    end
})

GUIElements.Aimbot_FOV_Color = AimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Flag = "Aimbot_FOV_Color",
    Callback = function(color)
        ExunysDeveloperAimbot.FOVSettings.Color = color
    end
})

GUIElements.Aimbot_FOV_OutlineColor = AimbotTab:CreateColorPicker({
    Name = "FOV Outline Color",
    Default = Color3.fromRGB(0, 0, 0),
    Flag = "Aimbot_FOV_OutlineColor",
    Callback = function(color)
        ExunysDeveloperAimbot.FOVSettings.OutlineColor = color
    end
})

GUIElements.Aimbot_FOV_LockedColor = AimbotTab:CreateColorPicker({
    Name = "FOV Locked Color",
    Default = Color3.fromRGB(255, 150, 150),
    Flag = "Aimbot_FOV_LockedColor",
    Callback = function(color)
        ExunysDeveloperAimbot.FOVSettings.LockedColor = color
    end
})

--=============================================================================--
--                          DEVELOPER SETTINGS
--=============================================================================--
AimbotTab:CreateSection("Developer Settings")

GUIElements.Aimbot_UpdateMode = AimbotTab:CreateDropdown({
    Name = "Update Mode",
    Options = {"RenderStepped", "Heartbeat", "Stepped"},
    Default = "RenderStepped",
    Multi = false,
    Flag = "Aimbot_UpdateMode",
    Callback = function(value)
        ExunysDeveloperAimbot.DeveloperSettings.UpdateMode = value
    end
})

GUIElements.Aimbot_TeamCheckOption = AimbotTab:CreateDropdown({
    Name = "Team Check Option",
    Options = {"TeamColor", "Team"},
    Default = "TeamColor",
    Multi = false,
    Flag = "Aimbot_TeamCheckOption",
    Callback = function(value)
        ExunysDeveloperAimbot.DeveloperSettings.TeamCheckOption = value
    end
})

GUIElements.Aimbot_RainbowSpeed = AimbotTab:CreateSlider({
    Name = "Rainbow Speed",
    Min = 1,
    Max = 10,
    Default = 1,
    Increment = 1,
    Flag = "Aimbot_RainbowSpeed",
    Callback = function(value)
        ExunysDeveloperAimbot.DeveloperSettings.RainbowSpeed = value
    end
})

AimbotTab:CreateLabel("(Higher = Slower rainbow)")

--=============================================================================--
--                          BLACKLIST/WHITELIST
--=============================================================================--
AimbotTab:CreateSection("Blacklist Management")

AimbotTab:CreateParagraph({
    Title = "Blacklist System",
    Content = "Add player names to prevent the aimbot from targeting them. Player names can be shortened and are case-insensitive."
})

AimbotTab:CreateTextBox({
    Name = "Blacklist Player",
    Placeholder = "Enter player name...",
    Default = "",
    Flag = "Aimbot_BlacklistName",
    Callback = function(text)
        if text ~= "" then
            pcall(function()
                ExunysDeveloperAimbot:Blacklist(text)
            end)
        end
    end
})

AimbotTab:CreateTextBox({
    Name = "Whitelist Player",
    Placeholder = "Enter player name...",
    Default = "",
    Flag = "Aimbot_WhitelistName",
    Callback = function(text)
        if text ~= "" then
            pcall(function()
                ExunysDeveloperAimbot:Whitelist(text)
            end)
        end
    end
})

AimbotTab:CreateButton({
    Name = "Show Blacklisted Players",
    Callback = function()
        -- Displays blacklisted players in console
    end
})

--=============================================================================--
--                          UTILITY FUNCTIONS
--=============================================================================--
AimbotTab:CreateSection("Utility Functions")

AimbotTab:CreateButton({
    Name = "Get Closest Player",
    Callback = function()
        pcall(function()
            ExunysDeveloperAimbot.GetClosestPlayer()
        end)
    end
})

end -- End of Aimbot loaded successfully check

--=============================================================================--
--                            SETTINGS TAB
--=============================================================================--
local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙️"
})

--=============================================================================--
--                       CONFIGURATION MANAGEMENT
--=============================================================================--
SettingsTab:CreateSection("Configuration Management")

local currentConfigName = ""
local configDropdownOptions = ConfigManager.GetConfigList()
if #configDropdownOptions == 0 then
    configDropdownOptions = {"No configs found"}
end

SettingsTab:CreateTextBox({
    Name = "Config Name",
    Placeholder = "Enter config name...",
    Default = "",
    Flag = "Config_Name",
    Callback = function(text)
        currentConfigName = text
    end
})

SettingsTab:CreateButton({
    Name = "Save Current Configuration",
    Callback = function()
        if currentConfigName == "" then
            return
        end
        
        local success, msg = ConfigManager.SaveConfig(currentConfigName)
        if success then
            -- Refresh dropdown with updated config list
            configDropdownOptions = ConfigManager.GetConfigList()
            if #configDropdownOptions == 0 then
                configDropdownOptions = {"No configs found"}
            end
            configDropdown:UpdateOptions(configDropdownOptions, configDropdownOptions[1])
        end
    end
})

local selectedConfig = ""

local configDropdown = SettingsTab:CreateDropdown({
    Name = "Saved Configurations",
    Options = configDropdownOptions,
    Default = configDropdownOptions[1],
    Multi = false,
    Flag = "Config_Selected",
    Callback = function(value)
        if value ~= "No configs found" then
            selectedConfig = value
        end
    end
})

SettingsTab:CreateButton({
    Name = "Load Selected Configuration",
    Callback = function()
        if selectedConfig == "" or selectedConfig == "No configs found" then
            return
        end
        
        local success, msg = ConfigManager.LoadConfig(selectedConfig)
        if success then
            -- Get the loaded config to update GUI
            local filePath = ConfigManager.ConfigFolder .. "/" .. selectedConfig .. ".json"
            local json = readfile(filePath)
            local config = HttpService:JSONDecode(json)
            
            -- Update GUI elements to match loaded config
            ConfigManager.UpdateGUIFromConfig(config, GUIElements)
        end
    end
})

SettingsTab:CreateButton({
    Name = "Delete Selected Configuration",
    Callback = function()
        if selectedConfig == "" or selectedConfig == "No configs found" then
            return
        end
        
        local success, msg = ConfigManager.DeleteConfig(selectedConfig)
        if success then
            -- Refresh dropdown with updated config list
            configDropdownOptions = ConfigManager.GetConfigList()
            if #configDropdownOptions == 0 then
                configDropdownOptions = {"No configs found"}
            end
            configDropdown:UpdateOptions(configDropdownOptions, configDropdownOptions[1])
            selectedConfig = ""
        end
    end
})

SettingsTab:CreateButton({
    Name = "Refresh Config List",
    Callback = function()
        configDropdownOptions = ConfigManager.GetConfigList()
        if #configDropdownOptions == 0 then
            configDropdownOptions = {"No configs found"}
        end
        
        -- Update the dropdown with new options
        configDropdown:UpdateOptions(configDropdownOptions, configDropdownOptions[1])
    end
})

SettingsTab:CreateButton({
    Name = "Export Config to Clipboard",
    Callback = function()
        if not setclipboard then
            return
        end
        
        local config = ConfigManager.GetCurrentConfig()
        local json = HttpService:JSONEncode(config)
        setclipboard(json)
    end
})

SettingsTab:CreateButton({
    Name = "Import Config from Clipboard",
    Callback = function()
        if not getclipboard then
            return
        end
        
        pcall(function()
            local json = getclipboard()
            local config = HttpService:JSONDecode(json)
            ConfigManager.ApplyConfig(config)
        end)
    end
})

--=============================================================================--
--                            WHITELIST
--=============================================================================--
SettingsTab:CreateSection("Whitelist")

SettingsTab:CreateParagraph({
    Title = "Whitelist System",
    Content = "When the whitelist contains at least 1 user ID, ESP will only show for those specific players. Leave empty to show all players."
})

SettingsTab:CreateTextBox({
    Name = "Add User ID to Whitelist",
    Placeholder = "Enter User ID...",
    Default = "",
    Flag = "Settings_WhitelistID",
    Callback = function(text)
        local userId = tonumber(text)
        if userId then
            table.insert(Sense.whitelist, userId)
        end
    end
})

SettingsTab:CreateButton({
    Name = "Clear Whitelist",
    Callback = function()
        Sense.whitelist = {}
    end
})

SettingsTab:CreateButton({
    Name = "Show Current Whitelist",
    Callback = function()
        -- Displays whitelist in console
    end
})

SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Window:Destroy()
    end
})

--=============================================================================--
--                            INFO TAB
--=============================================================================--
local InfoTab = Window:CreateTab({
    Name = "Info",
    Icon = "ℹ️"
})

InfoTab:CreateParagraph({
    Title = "Universal ESP Project",
    Content = "Full-featured ESP system powered by Sense library. Supports player ESP with boxes, tracers, health bars, names, distances, weapons, 3D boxes, chams, and off-screen arrows."
})

InfoTab:CreateSection("Features")

InfoTab:CreateLabel("✓ 2D & 3D Boxes")
InfoTab:CreateLabel("✓ Health Bars & Text")
InfoTab:CreateLabel("✓ Name & Distance Display")
InfoTab:CreateLabel("✓ Weapon Display")
InfoTab:CreateLabel("✓ Tracers (Top/Middle/Bottom)")
InfoTab:CreateLabel("✓ Off-Screen Arrows")
InfoTab:CreateLabel("✓ Chams (Highlights)")
InfoTab:CreateLabel("✓ Team-Based ESP (Enemy/Friendly)")
InfoTab:CreateLabel("✓ Whitelist System")
InfoTab:CreateLabel("✓ Fully Customizable Colors")
InfoTab:CreateLabel("✓ Distance Limiting")

InfoTab:CreateSection("Usage")

InfoTab:CreateLabel("1. Configure ESP settings in the ESP tab")
InfoTab:CreateLabel("2. Enable Enemy/Friendly ESP as needed")
InfoTab:CreateLabel("3. Go to Settings tab and click 'Load ESP'")
InfoTab:CreateLabel("4. ESP will now be active!")
InfoTab:CreateLabel("5. Click 'Unload ESP' to disable")

InfoTab:CreateSection("Tips")

InfoTab:CreateLabel("• Use 'Limit Distance' to improve performance")
InfoTab:CreateLabel("• Chams highlight players through walls")
InfoTab:CreateLabel("• Off-Screen Arrows show off-screen enemies")
InfoTab:CreateLabel("• Whitelist shows only specific players")
InfoTab:CreateLabel("• Use Team Colors for automatic coloring")

InfoTab:CreateSection("Support")

InfoTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/YOUR_INVITE")
        end
    end
})

InfoTab:CreateParagraph({
    Title = "Credits",
    Content = "GUI: Custom Library\nESP: Sense Library (sirius.menu)\nIntegration: Universal Project Team"
})

-- Script loaded successfully
