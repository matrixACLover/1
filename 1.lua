local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Panel = Color3.fromRGB(25, 25, 25),
    PanelHeader = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(100, 120, 255),
    AccentDark = Color3.fromRGB(70, 90, 200),
    Module = Color3.fromRGB(28, 28, 28),
    ModuleHover = Color3.fromRGB(35, 35, 35),
    ModuleActive = Color3.fromRGB(40, 40, 60),
    Border = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(220, 220, 220),
    TextDim = Color3.fromRGB(140, 140, 140),
    SettingBg = Color3.fromRGB(22, 22, 22),
    SliderBg = Color3.fromRGB(35, 35, 35),
    ToggleOn = Color3.fromRGB(100, 120, 255),
    ToggleOff = Color3.fromRGB(50, 50, 50),
}

local Font = Enum.Font.Code

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local ScreenGui = Create("ScreenGui", {
    Name = "NovolineUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = game:GetService("CoreGui"),
})

local PanelHolder = Create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Parent = ScreenGui,
})

function Library:CreateWindow(config)
    local cfg = config or {}
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

    local Window = {}
    Window._panels = {}

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == toggleKey then
            for _, panel in pairs(Window._panels) do
                panel._frame.Visible = not panel._frame.Visible
            end
        end
    end)

    function Window:CreatePanel(panelConfig)
        local pCfg = panelConfig or {}
        local pName = pCfg.Name or "Panel"
        local pPosition = pCfg.Position or UDim2.new(0, 20 + (#Window._panels * 160), 0, 50)

        local Panel = {}
        Panel._modules = {}
        Panel._collapsed = false

        local panelFrame = Create("Frame", {
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Position = pPosition,
            Size = UDim2.new(0, 150, 0, 25),
            ZIndex = 100,
            Parent = PanelHolder,
        })
        AddCorner(panelFrame, 6)
        AddStroke(panelFrame, Theme.Border, 1)

        local header = Create("Frame", {
            BackgroundColor3 = Theme.PanelHeader,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 25),
            ZIndex = 101,
            Parent = panelFrame,
        })
        AddCorner(header, 6)

        local headerFix = Create("Frame", {
            BackgroundColor3 = Theme.PanelHeader,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -6),
            Size = UDim2.new(1, 0, 0, 6),
            ZIndex = 101,
            Parent = header,
        })

        local accent = Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 102,
            Parent = header,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = accent })

        local accentFix = Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 102,
            Parent = accent,
        })

        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.AccentDark),
            }),
            Parent = accent,
        })

        local title = Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -8, 1, 0),
            Font = Font,
            Text = pName,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 103,
            Parent = header,
        })

        local moduleList = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(1, 0, 1, -25),
            ClipsDescendants = true,
            ZIndex = 100,
            Parent = panelFrame,
        })

        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = moduleList,
        })

        MakeDraggable(panelFrame, header)

        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Panel._collapsed = not Panel._collapsed
                if Panel._collapsed then
                    Tween(panelFrame, { Size = UDim2.new(0, 150, 0, 25) }, 0.2)
                else
                    local totalHeight = 25
                    for _, mod in pairs(Panel._modules) do
                        totalHeight = totalHeight + 20
                        if mod._expanded then
                            totalHeight = totalHeight + (#mod._settings * 22)
                        end
                    end
                    Tween(panelFrame, { Size = UDim2.new(0, 150, 0, totalHeight) }, 0.2)
                end
            end
        end)

        Panel._frame = panelFrame
        Panel._moduleList = moduleList

        function Panel:UpdateSize()
            if Panel._collapsed then return end
            local totalHeight = 25
            for _, mod in pairs(Panel._modules) do
                totalHeight = totalHeight + 20
                if mod._expanded then
                    totalHeight = totalHeight + (#mod._settings * 22)
                end
            end
            panelFrame.Size = UDim2.new(0, 150, 0, totalHeight)
        end

        function Panel:AddModule(moduleConfig)
            local mCfg = moduleConfig or {}
            local mName = mCfg.Name or "Module"
            local mBind = mCfg.Bind or Enum.KeyCode.Unknown
            local mCallback = mCfg.Callback or function() end

            local Module = {}
            Module._enabled = false
            Module._expanded = false
            Module._settings = {}
            Module._bind = mBind

            local modFrame = Create("Frame", {
                BackgroundColor3 = Theme.Module,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 104,
                Parent = moduleList,
            })

            local modBtn = Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Font = Font,
                Text = " " .. mName,
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105,
                Parent = modFrame,
            })

            local expandBtn = Create("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 20, 0, 20),
                Font = Font,
                Text = "⚙",
                TextColor3 = Theme.TextDim,
                TextSize = 10,
                ZIndex = 105,
                Parent = modFrame,
            })

            local settingsList = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 104,
                Parent = modFrame,
            })

            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = settingsList,
            })

            modBtn.MouseButton1Click:Connect(function()
                Module._enabled = not Module._enabled
                if Module._enabled then
                    Tween(modBtn, { TextColor3 = Theme.Accent }, 0.15)
                    Tween(modFrame, { BackgroundColor3 = Theme.ModuleActive }, 0.15)
                else
                    Tween(modBtn, { TextColor3 = Theme.TextDim }, 0.15)
                    Tween(modFrame, { BackgroundColor3 = Theme.Module }, 0.15)
                end
                mCallback(Module._enabled)
            end)

            modBtn.MouseEnter:Connect(function()
                if not Module._enabled then
                    Tween(modFrame, { BackgroundColor3 = Theme.ModuleHover }, 0.1)
                end
            end)

            modBtn.MouseLeave:Connect(function()
                if not Module._enabled then
                    Tween(modFrame, { BackgroundColor3 = Theme.Module }, 0.1)
                end
            end)

            expandBtn.MouseButton1Click:Connect(function()
                Module._expanded = not Module._expanded
                if Module._expanded then
                    expandBtn.Text = "▼"
                    settingsList.Size = UDim2.new(1, 0, 0, #Module._settings * 22)
                else
                    expandBtn.Text = "⚙"
                    settingsList.Size = UDim2.new(1, 0, 0, 0)
                end
                Panel:UpdateSize()
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if not gp and input.KeyCode == Module._bind and Module._bind ~= Enum.KeyCode.Unknown then
                    Module._enabled = not Module._enabled
                    if Module._enabled then
                        Tween(modBtn, { TextColor3 = Theme.Accent }, 0.15)
                        Tween(modFrame, { BackgroundColor3 = Theme.ModuleActive }, 0.15)
                    else
                        Tween(modBtn, { TextColor3 = Theme.TextDim }, 0.15)
                        Tween(modFrame, { BackgroundColor3 = Theme.Module }, 0.15)
                    end
                    mCallback(Module._enabled)
                end
            end)

            Module._frame = modFrame
            Module._settingsList = settingsList

            function Module:AddToggle(tConfig)
                local tCfg = tConfig or {}
                local tName = tCfg.Name or "Toggle"
                local tDefault = tCfg.Default or false
                local tCallback = tCfg.Callback or function() end

                local toggled = tDefault

                local setFrame = Create("Frame", {
                    BackgroundColor3 = Theme.SettingBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 22),
                    ZIndex = 104,
                    Parent = settingsList,
                })

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Font,
                    Text = tName,
                    TextColor3 = Theme.TextDim,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 105,
                    Parent = setFrame,
                })

                local togBg = Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff,
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 30, 0, 12),
                    ZIndex = 105,
                    Parent = setFrame,
                })
                AddCorner(togBg, 6)

                local togDot = Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = toggled and UDim2.new(1, -6, 0.5, 0) or UDim2.new(0, 6, 0.5, 0),
                    Size = UDim2.new(0, 8, 0, 8),
                    ZIndex = 106,
                    Parent = togBg,
                })
                AddCorner(togDot, 4)

                local btn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 107,
                    Parent = setFrame,
                })

                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(togBg, { BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff }, 0.15)
                    Tween(togDot, { Position = toggled and UDim2.new(1, -6, 0.5, 0) or UDim2.new(0, 6, 0.5, 0) }, 0.15)
                    tCallback(toggled)
                end)

                table.insert(Module._settings, setFrame)
                Panel:UpdateSize()
            end

            function Module:AddSlider(sConfig)
                local sCfg = sConfig or {}
                local sName = sCfg.Name or "Slider"
                local sMin = sCfg.Min or 0
                local sMax = sCfg.Max or 100
                local sDefault = sCfg.Default or sMin
                local sCallback = sCfg.Callback or function() end

                local value = sDefault

                local setFrame = Create("Frame", {
                    BackgroundColor3 = Theme.SettingBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 22),
                    ZIndex = 104,
                    Parent = settingsList,
                })

                local nameLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.6, 0, 0, 10),
                    Font = Font,
                    Text = sName,
                    TextColor3 = Theme.TextDim,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 105,
                    Parent = setFrame,
                })

                local valLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -6, 0, 0),
                    Size = UDim2.new(0.4, 0, 0, 10),
                    Font = Font,
                    Text = tostring(value),
                    TextColor3 = Theme.Accent,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 105,
                    Parent = setFrame,
                })

                local sliderBg = Create("Frame", {
                    BackgroundColor3 = Theme.SliderBg,
                    Position = UDim2.new(0, 6, 0, 14),
                    Size = UDim2.new(1, -12, 0, 4),
                    ZIndex = 105,
                    Parent = setFrame,
                })
                AddCorner(sliderBg, 2)

                local sliderFill = Create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0),
                    ZIndex = 106,
                    Parent = sliderBg,
                })
                AddCorner(sliderFill, 2)

                local dragging = false

                local function UpdateSlider(input)
                    local relX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                    local pct = relX / sliderBg.AbsoluteSize.X
                    local val = math.floor(sMin + (sMax - sMin) * pct)
                    value = val
                    valLabel.Text = tostring(val)
                    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    sCallback(val)
                end

                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                table.insert(Module._settings, setFrame)
                Panel:UpdateSize()
            end

            function Module:AddDropdown(dConfig)
                local dCfg = dConfig or {}
                local dName = dCfg.Name or "Dropdown"
                local dOptions = dCfg.Options or {"Option1"}
                local dDefault = dCfg.Default or dOptions[1]
                local dCallback = dCfg.Callback or function() end

                local selected = dDefault
                local opened = false

                local setFrame = Create("Frame", {
                    BackgroundColor3 = Theme.SettingBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 22),
                    ZIndex = 104,
                    ClipsDescendants = false,
                    Parent = settingsList,
                })

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Font,
                    Text = dName,
                    TextColor3 = Theme.TextDim,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 105,
                    Parent = setFrame,
                })

                local dropBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.Module,
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.new(0, 60, 0, 14),
                    Font = Font,
                    Text = selected,
                    TextColor3 = Theme.Text,
                    TextSize = 8,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 105,
                    Parent = setFrame,
                })
                AddCorner(dropBtn, 3)

                local dropList = Create("Frame", {
                    BackgroundColor3 = Theme.Module,
                    Position = UDim2.new(1, -66, 1, 2),
                    Size = UDim2.new(0, 60, 0, 0),
                    ZIndex = 200,
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = setFrame,
                })
                AddCorner(dropList, 3)
                AddStroke(dropList, Theme.Border, 1)

                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropList,
                })

                for _, opt in ipairs(dOptions) do
                    local item = Create("TextButton", {
                        BackgroundColor3 = opt == selected and Theme.ModuleHover or Theme.Module,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 16),
                        Font = Font,
                        Text = opt,
                        TextColor3 = opt == selected and Theme.Accent or Theme.Text,
                        TextSize = 8,
                        ZIndex = 201,
                        Parent = dropList,
                    })

                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        dropBtn.Text = opt
                        Tween(dropList, { Size = UDim2.new(0, 60, 0, 0) }, 0.15)
                        task.wait(0.15)
                        dropList.Visible = false
                        opened = false
                        dCallback(opt)
                    end)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        dropList.Visible = true
                        Tween(dropList, { Size = UDim2.new(0, 60, 0, math.min(#dOptions, 4) * 16) }, 0.15)
                    else
                        Tween(dropList, { Size = UDim2.new(0, 60, 0, 0) }, 0.15)
                        task.wait(0.15)
                        dropList.Visible = false
                    end
                end)

                table.insert(Module._settings, setFrame)
                Panel:UpdateSize()
            end

            table.insert(Panel._modules, Module)
            Panel:UpdateSize()

            return Module
        end

        table.insert(Window._panels, Panel)
        return Panel
    end

    return Window
end

return Library
