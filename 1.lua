local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    TopBar = Color3.fromRGB(139, 0, 0),
    TopBarGradient1 = Color3.fromRGB(180, 0, 0),
    TopBarGradient2 = Color3.fromRGB(100, 0, 0),
    Tab = Color3.fromRGB(28, 28, 28),
    TabActive = Color3.fromRGB(139, 0, 0),
    TabHover = Color3.fromRGB(45, 45, 45),
    Section = Color3.fromRGB(24, 24, 24),
    SectionBorder = Color3.fromRGB(139, 0, 0),
    Element = Color3.fromRGB(32, 32, 32),
    ElementHover = Color3.fromRGB(40, 40, 40),
    ElementBorder = Color3.fromRGB(55, 55, 55),
    Toggle = Color3.fromRGB(139, 0, 0),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    ToggleDot = Color3.fromRGB(255, 255, 255),
    Slider = Color3.fromRGB(139, 0, 0),
    SliderBg = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    TextAccent = Color3.fromRGB(255, 80, 80),
    Dropdown = Color3.fromRGB(28, 28, 28),
    DropdownItem = Color3.fromRGB(35, 35, 35),
    DropdownHover = Color3.fromRGB(50, 20, 20),
    Input = Color3.fromRGB(28, 28, 28),
    InputBorder = Color3.fromRGB(80, 80, 80),
    InputBorderActive = Color3.fromRGB(139, 0, 0),
    Keybind = Color3.fromRGB(139, 0, 0),
    Notification = Color3.fromRGB(22, 22, 22),
    NotificationBorder = Color3.fromRGB(139, 0, 0),
    Shadow = Color3.fromRGB(0, 0, 0),
    Scrollbar = Color3.fromRGB(139, 0, 0),
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

local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos

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
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function AddStroke(parent, color, thickness)
    local stroke = Create("UIStroke", {
        Color = color or Theme.SectionBorder,
        Thickness = thickness or 1,
        Parent = parent,
    })
    return stroke
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent,
    })
end

local function AddShadow(parent)
    local shadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Theme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent,
    })
    return shadow
end

local ScreenGui = Create("ScreenGui", {
    Name = "MCCheatUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = game:GetService("CoreGui"),
})

local NotifHolder = Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 280, 1, 0),
    Parent = ScreenGui,
})

Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 8),
    Parent = NotifHolder,
})

function Library:Notify(title, message, duration, ntype)
    local colors = {
        success = Color3.fromRGB(0, 160, 80),
        error = Color3.fromRGB(180, 0, 0),
        info = Color3.fromRGB(139, 0, 0),
        warning = Color3.fromRGB(200, 120, 0),
    }
    local accent = colors[ntype] or colors.info

    local notif = Create("Frame", {
        BackgroundColor3 = Theme.Notification,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = NotifHolder,
    })
    AddCorner(notif, 6)
    AddStroke(notif, accent, 1)
    AddShadow(notif)

    local accent_bar = Create("Frame", {
        BackgroundColor3 = accent,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = notif,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = accent_bar })

    local inner = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -12, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = notif,
    })

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = inner,
    })

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = inner,
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Font,
        Text = title,
        TextColor3 = accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = inner,
    })

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Font,
        Text = message,
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = inner,
    })

    local bar_bg = Create("Frame", {
        BackgroundColor3 = Theme.SliderBg,
        Size = UDim2.new(1, 0, 0, 2),
        LayoutOrder = 3,
        Parent = inner,
    })
    AddCorner(bar_bg, 2)
    local bar_fill = Create("Frame", {
        BackgroundColor3 = accent,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = bar_bg,
    })
    AddCorner(bar_fill, 2)

    notif.BackgroundTransparency = 1
    Tween(notif, { BackgroundTransparency = 0 }, 0.3)

    Tween(bar_fill, { Size = UDim2.new(0, 0, 1, 0) }, duration or 4, Enum.EasingStyle.Linear)

    task.delay(duration or 4, function()
        Tween(notif, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
end

function Library:CreateWindow(config)
    local cfg = config or {}
    local title = cfg.Title or "MC Cheat"
    local subtitle = cfg.Subtitle or "v1.0"
    local size = cfg.Size or UDim2.new(0, 580, 0, 420)
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

    local Window = {}
    Window._tabs = {}
    Window._activeTab = nil

    local MainFrame = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        Parent = ScreenGui,
    })
    AddCorner(MainFrame, 8)
    AddStroke(MainFrame, Theme.TopBar, 1)

    local MainShadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = 0,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = MainFrame,
    })

    local TopBar = Create("Frame", {
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2,
        Parent = MainFrame,
    })
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = TopBar,
    })

    local TopBarFix = Create("Frame", {
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        ZIndex = 2,
        Parent = TopBar,
    })

    local TopGrad = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.TopBarGradient1),
            ColorSequenceKeypoint.new(1, Theme.TopBarGradient2),
        }),
        Rotation = 90,
        Parent = TopBar,
    })

    local TitleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Font = Font,
        Text = title .. "  ",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })

    local SubLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14 + TitleLabel.TextBounds.X + 4, 0, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Font = Font,
        Text = subtitle,
        TextColor3 = Color3.fromRGB(255, 120, 120),
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = TopBar,
    })

    local CloseBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(180, 30, 30),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        Font = Font,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        ZIndex = 3,
        Parent = TopBar,
    })
    AddCorner(CloseBtn, 4)

    local MinBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
        Position = UDim2.new(1, -36, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        Font = Font,
        Text = "—",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        ZIndex = 3,
        Parent = TopBar,
    })
    AddCorner(MinBtn, 4)

    local minimized = false
    local fullSize = size

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, { Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 40) }, 0.25)
        else
            Tween(MainFrame, { Size = fullSize }, 0.25)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, { Size = UDim2.new(0, size.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        MainFrame.Visible = false
        Tween(MainFrame, { Size = fullSize, BackgroundTransparency = 0 }, 0)
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(220, 50, 50) }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(180, 30, 30) }, 0.15)
    end)

    MakeDraggable(MainFrame, TopBar)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local TabBar = Create("Frame", {
        BackgroundColor3 = Theme.Tab,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 130, 1, -40),
        ZIndex = 2,
        Parent = MainFrame,
    })

    local TabBarBorder = Create("Frame", {
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = 3,
        Parent = TabBar,
    })

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = TabBar,
    })

    local TabList = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TabBar,
    })

    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = TabList,
    })

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = TabList,
    })

    local ContentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 132, 0, 42),
        Size = UDim2.new(1, -134, 1, -44),
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = MainFrame,
    })

    function Window:CreateTab(tabConfig)
        local tabCfg = tabConfig or {}
        local tabName = tabCfg.Name or "Tab"
        local tabIcon = tabCfg.Icon or ""

        local Tab = {}
        Tab._sections = {}

        local tabBtn = Create("TextButton", {
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 34),
            Font = Font,
            Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3,
            Parent = TabList,
        })
        AddCorner(tabBtn, 5)

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = tabBtn,
        })

        local tabIndicator = Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.TopBar,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 0),
            ZIndex = 4,
            Parent = tabBtn,
        })
        AddCorner(tabIndicator, 2)

        local tabContent = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 2,
            Parent = ContentArea,
        })

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 6),
            Parent = tabContent,
        })

        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = tabContent,
        })

        local function SelectTab()
            if Window._activeTab then
                local prev = Window._activeTab
                Tween(prev._btn, { BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDim }, 0.2)
                Tween(prev._indicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.2)
                prev._content.Visible = false
            end

            Tween(tabBtn, { BackgroundColor3 = Theme.TabActive, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.2)
            Tween(tabIndicator, { Size = UDim2.new(0, 3, 0, 20) }, 0.2)
            tabContent.Visible = true

            Tab._btn = tabBtn
            Tab._indicator = tabIndicator
            Tab._content = tabContent
            Window._activeTab = Tab
        end

        Tab._btn = tabBtn
        Tab._indicator = tabIndicator
        Tab._content = tabContent

        tabBtn.MouseButton1Click:Connect(SelectTab)

        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabBtn, { BackgroundColor3 = Theme.TabHover }, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(tabBtn, { BackgroundColor3 = Theme.Element }, 0.15)
            end
        end)

        if #Window._tabs == 0 then
            SelectTab()
        end

        table.insert(Window._tabs, Tab)

        function Tab:CreateSection(sectionConfig)
            local secCfg = sectionConfig or {}
            local secName = secCfg.Name or "Section"

            local Section = {}

            local sectionFrame = Create("Frame", {
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 3,
                Parent = tabContent,
            })
            AddCorner(sectionFrame, 6)
            AddStroke(sectionFrame, Theme.SectionBorder, 1)

            local SecHeader = Create("Frame", {
                BackgroundColor3 = Theme.TopBar,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                ZIndex = 4,
                Parent = sectionFrame,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SecHeader })

            local SecHeaderFix = Create("Frame", {
                BackgroundColor3 = Theme.TopBar,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0.5, 0),
                ZIndex = 4,
                Parent = SecHeader,
            })

            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.TopBarGradient1),
                    ColorSequenceKeypoint.new(1, Theme.TopBarGradient2),
                }),
                Rotation = 90,
                Parent = SecHeader,
            })

            local SecTitle = Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Font,
                Text = "▸  " .. secName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = SecHeader,
            })

            local SecContent = Create("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 26),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 3,
                Parent = sectionFrame,
            })

            Create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = SecContent,
            })

            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = SecContent,
            })

            function Section:AddToggle(toggleConfig)
                local tCfg = toggleConfig or {}
                local tName = tCfg.Name or "Toggle"
                local tDefault = tCfg.Default or false
                local tCallback = tCfg.Callback or function() end

                local toggled = tDefault

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                local elemLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Font,
                    Text = tName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local togBg = Create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = toggled and Theme.Toggle or Theme.ToggleOff,
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 38, 0, 20),
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(togBg, 10)

                local togDot = Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Theme.ToggleDot,
                    Position = toggled and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 6,
                    Parent = togBg,
                })
                AddCorner(togDot, 7)

                local statusLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -54, 0.5, 0),
                    Size = UDim2.new(0, 30, 0, 16),
                    Font = Font,
                    Text = toggled and "ON" or "OFF",
                    TextColor3 = toggled and Theme.TextAccent or Theme.TextDim,
                    TextSize = 10,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local btn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 7,
                    Parent = elemFrame,
                })

                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Tween(togBg, { BackgroundColor3 = toggled and Theme.Toggle or Theme.ToggleOff }, 0.2)
                    Tween(togDot, { Position = toggled and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) }, 0.2)
                    statusLabel.Text = toggled and "ON" or "OFF"
                    statusLabel.TextColor3 = toggled and Theme.TextAccent or Theme.TextDim
                    tCallback(toggled)
                end)

                btn.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local Toggle = {}
                function Toggle:Set(val)
                    toggled = val
                    Tween(togBg, { BackgroundColor3 = toggled and Theme.Toggle or Theme.ToggleOff }, 0.2)
                    Tween(togDot, { Position = toggled and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0) }, 0.2)
                    statusLabel.Text = toggled and "ON" or "OFF"
                    statusLabel.TextColor3 = toggled and Theme.TextAccent or Theme.TextDim
                    tCallback(toggled)
                end
                function Toggle:Get() return toggled end
                return Toggle
            end

            function Section:AddSlider(sliderConfig)
                local sCfg = sliderConfig or {}
                local sName = sCfg.Name or "Slider"
                local sMin = sCfg.Min or 0
                local sMax = sCfg.Max or 100
                local sDefault = sCfg.Default or sMin
                local sSuffix = sCfg.Suffix or ""
                local sCallback = sCfg.Callback or function() end

                local value = math.clamp(sDefault, sMin, sMax)

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 48),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                local nameLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 6),
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Font = Font,
                    Text = sName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local valLabel = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -10, 0, 6),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Font = Font,
                    Text = tostring(value) .. sSuffix,
                    TextColor3 = Theme.TextAccent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local sliderBg = Create("Frame", {
                    BackgroundColor3 = Theme.SliderBg,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 8),
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(sliderBg, 4)

                local sliderFill = Create("Frame", {
                    BackgroundColor3 = Theme.Slider,
                    Size = UDim2.new((value - sMin) / (sMax - sMin), 0, 1, 0),
                    ZIndex = 6,
                    Parent = sliderBg,
                })
                AddCorner(sliderFill, 4)

                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 50)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 0, 0)),
                    }),
                    Parent = sliderFill,
                })

                local sliderDot = Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new((value - sMin) / (sMax - sMin), 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    ZIndex = 7,
                    Parent = sliderBg,
                })
                AddCorner(sliderDot, 7)
                AddStroke(sliderDot, Theme.Slider, 2)

                local dragging = false

                local sliderBtn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 8,
                    Parent = sliderBg,
                })

                local function UpdateSlider(input)
                    local relX = math.clamp(input.Position.X - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
                    local pct = relX / sliderBg.AbsoluteSize.X
                    local val = math.floor(sMin + (sMax - sMin) * pct)
                    value = val
                    valLabel.Text = tostring(val) .. sSuffix
                    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    sliderDot.Position = UDim2.new(pct, 0, 0.5, 0)
                    sCallback(val)
                end

                sliderBtn.InputBegan:Connect(function(input)
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

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local Slider = {}
                function Slider:Set(val)
                    value = math.clamp(val, sMin, sMax)
                    local pct = (value - sMin) / (sMax - sMin)
                    valLabel.Text = tostring(value) .. sSuffix
                    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    sliderDot.Position = UDim2.new(pct, 0, 0.5, 0)
                    sCallback(value)
                end
                function Slider:Get() return value end
                return Slider
            end

            function Section:AddButton(btnConfig)
                local bCfg = btnConfig or {}
                local bName = bCfg.Name or "Button"
                local bDesc = bCfg.Description or ""
                local bCallback = bCfg.Callback or function() end

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, bDesc ~= "" and 44 or 34),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, bDesc ~= "" and 6 or 0),
                    Size = UDim2.new(1, -80, bDesc ~= "" and 0 or 1, bDesc ~= "" and 16 or 0),
                    Font = Font,
                    Text = bName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                if bDesc ~= "" then
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 24),
                        Size = UDim2.new(1, -80, 0, 14),
                        Font = Font,
                        Text = bDesc,
                        TextColor3 = Theme.TextDim,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 5,
                        Parent = elemFrame,
                    })
                end

                local execBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.TopBar,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 60, 0, 24),
                    Font = Font,
                    Text = "RUN",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(execBtn, 4)

                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 30)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0)),
                    }),
                    Rotation = 90,
                    Parent = execBtn,
                })

                execBtn.MouseButton1Click:Connect(function()
                    Tween(execBtn, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }, 0.1)
                    task.wait(0.1)
                    Tween(execBtn, { BackgroundColor3 = Theme.TopBar }, 0.2)
                    bCallback()
                end)

                execBtn.MouseEnter:Connect(function()
                    Tween(execBtn, { BackgroundColor3 = Color3.fromRGB(180, 30, 30) }, 0.15)
                end)
                execBtn.MouseLeave:Connect(function()
                    Tween(execBtn, { BackgroundColor3 = Theme.TopBar }, 0.15)
                end)

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)
            end

            function Section:AddDropdown(dropConfig)
                local dCfg = dropConfig or {}
                local dName = dCfg.Name or "Dropdown"
                local dOptions = dCfg.Options or {}
                local dDefault = dCfg.Default or (dOptions[1] or "None")
                local dCallback = dCfg.Callback or function() end

                local selected = dDefault
                local opened = false

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    ZIndex = 10,
                    ClipsDescendants = false,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Font,
                    Text = dName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                    Parent = elemFrame,
                })

                local dropBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.Dropdown,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 110, 0, 24),
                    Font = Font,
                    Text = selected .. " ▾",
                    TextColor3 = Theme.TextAccent,
                    TextSize = 11,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 11,
                    Parent = elemFrame,
                })
                AddCorner(dropBtn, 4)
                AddStroke(dropBtn, Theme.SectionBorder, 1)

                local dropList = Create("Frame", {
                    BackgroundColor3 = Theme.Dropdown,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -118, 1, 4),
                    Size = UDim2.new(0, 110, 0, 0),
                    ZIndex = 20,
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = elemFrame,
                })
                AddCorner(dropList, 5)
                AddStroke(dropList, Theme.SectionBorder, 1)
                AddShadow(dropList)

                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = dropList,
                })

                local itemHeight = 26
                local maxItems = math.min(#dOptions, 5)

                for i, opt in ipairs(dOptions) do
                    local item = Create("TextButton", {
                        BackgroundColor3 = opt == selected and Theme.DropdownHover or Theme.DropdownItem,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, itemHeight),
                        Font = Font,
                        Text = "  " .. opt,
                        TextColor3 = opt == selected and Theme.TextAccent or Theme.Text,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 21,
                        Parent = dropList,
                    })

                    item.MouseEnter:Connect(function()
                        Tween(item, { BackgroundColor3 = Theme.DropdownHover }, 0.12)
                    end)
                    item.MouseLeave:Connect(function()
                        Tween(item, { BackgroundColor3 = opt == selected and Theme.DropdownHover or Theme.DropdownItem }, 0.12)
                    end)

                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        dropBtn.Text = opt .. " ▾"
                        Tween(dropList, { Size = UDim2.new(0, 110, 0, 0) }, 0.2)
                        task.wait(0.2)
                        dropList.Visible = false
                        opened = false
                        dCallback(opt)
                    end)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        dropList.Visible = true
                        Tween(dropList, { Size = UDim2.new(0, 110, 0, math.min(#dOptions, 5) * itemHeight) }, 0.2)
                    else
                        Tween(dropList, { Size = UDim2.new(0, 110, 0, 0) }, 0.2)
                        task.wait(0.2)
                        dropList.Visible = false
                    end
                end)

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local Dropdown = {}
                function Dropdown:Set(opt)
                    selected = opt
                    dropBtn.Text = opt .. " ▾"
                    dCallback(opt)
                end
                function Dropdown:Get() return selected end
                function Dropdown:Refresh(newOptions)
                    for _, child in pairs(dropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    dOptions = newOptions
                    for i, opt in ipairs(newOptions) do
                        local item = Create("TextButton", {
                            BackgroundColor3 = Theme.DropdownItem,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, itemHeight),
                            Font = Font,
                            Text = "  " .. opt,
                            TextColor3 = Theme.Text,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 21,
                            Parent = dropList,
                        })
                        item.MouseButton1Click:Connect(function()
                            selected = opt
                            dropBtn.Text = opt .. " ▾"
                            Tween(dropList, { Size = UDim2.new(0, 110, 0, 0) }, 0.2)
                            task.wait(0.2)
                            dropList.Visible = false
                            opened = false
                            dCallback(opt)
                        end)
                    end
                end
                return Dropdown
            end

            function Section:AddInput(inputConfig)
                local iCfg = inputConfig or {}
                local iName = iCfg.Name or "Input"
                local iPlaceholder = iCfg.Placeholder or "Type here..."
                local iDefault = iCfg.Default or ""
                local iCallback = iCfg.Callback or function() end

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 48),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 6),
                    Size = UDim2.new(1, -10, 0, 14),
                    Font = Font,
                    Text = iName,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local inputBg = Create("Frame", {
                    BackgroundColor3 = Theme.Input,
                    Position = UDim2.new(0, 8, 0, 24),
                    Size = UDim2.new(1, -16, 0, 18),
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(inputBg, 4)
                local inputStroke = AddStroke(inputBg, Theme.InputBorder, 1)

                local textBox = Create("TextBox", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 6, 0, 0),
                    Size = UDim2.new(1, -12, 1, 0),
                    Font = Font,
                    PlaceholderText = iPlaceholder,
                    PlaceholderColor3 = Theme.TextDim,
                    Text = iDefault,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 6,
                    Parent = inputBg,
                })

                textBox.Focused:Connect(function()
                    Tween(inputStroke, { Color = Theme.InputBorderActive }, 0.2)
                end)
                textBox.FocusLost:Connect(function(enter)
                    Tween(inputStroke, { Color = Theme.InputBorder }, 0.2)
                    if enter then iCallback(textBox.Text) end
                end)

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local Input = {}
                function Input:Get() return textBox.Text end
                function Input:Set(v) textBox.Text = v end
                return Input
            end

            function Section:AddKeybind(kbConfig)
                local kCfg = kbConfig or {}
                local kName = kCfg.Name or "Keybind"
                local kDefault = kCfg.Default or Enum.KeyCode.Unknown
                local kCallback = kCfg.Callback or function() end

                local bound = kDefault
                local listening = false

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Font,
                    Text = kName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local kbBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.Keybind,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 80, 0, 22),
                    Font = Font,
                    Text = bound.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(kbBtn, 4)

                kbBtn.MouseButton1Click:Connect(function()
                    listening = true
                    kbBtn.Text = "..."
                    kbBtn.TextColor3 = Theme.TextDim
                end)

                UserInputService.InputBegan:Connect(function(input, gp)
                    if listening and not gp then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            bound = input.KeyCode
                            kbBtn.Text = input.KeyCode.Name
                            kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            listening = false
                        end
                    elseif not listening and not gp then
                        if input.KeyCode == bound then
                            kCallback()
                        end
                    end
                end)

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local Keybind = {}
                function Keybind:Get() return bound end
                function Keybind:Set(key)
                    bound = key
                    kbBtn.Text = key.Name
                end
                return Keybind
            end

            function Section:AddColorPicker(cpConfig)
                local cpCfg = cpConfig or {}
                local cpName = cpCfg.Name or "Color"
                local cpDefault = cpCfg.Default or Color3.fromRGB(139, 0, 0)
                local cpCallback = cpCfg.Callback or function() end

                local color = cpDefault
                local opened = false

                local elemFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 34),
                    ZIndex = 4,
                    ClipsDescendants = false,
                    Parent = SecContent,
                })
                AddCorner(elemFrame, 5)

                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Font,
                    Text = cpName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = elemFrame,
                })

                local colorDisplay = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = color,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.new(0, 40, 0, 22),
                    Text = "",
                    ZIndex = 5,
                    Parent = elemFrame,
                })
                AddCorner(colorDisplay, 4)
                AddStroke(colorDisplay, Theme.ElementBorder, 1)

                local pickerFrame = Create("Frame", {
                    BackgroundColor3 = Theme.Dropdown,
                    Position = UDim2.new(1, -160, 1, 4),
                    Size = UDim2.new(0, 150, 0, 120),
                    ZIndex = 20,
                    Visible = false,
                    Parent = elemFrame,
                })
                AddCorner(pickerFrame, 6)
                AddStroke(pickerFrame, Theme.SectionBorder, 1)
                AddShadow(pickerFrame)

                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    Parent = pickerFrame,
                })

                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = pickerFrame,
                })

                local h, s, v = Color3.toHSV(color)

                local function MakeSlider(label, defaultVal, callback)
                    local sliderWrap = Create("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        ZIndex = 21,
                        Parent = pickerFrame,
                    })

                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        Font = Font,
                        Text = label,
                        TextColor3 = Theme.TextDim,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22,
                        Parent = sliderWrap,
                    })

                    local bg = Create("Frame", {
                        BackgroundColor3 = Theme.SliderBg,
                        Position = UDim2.new(0, 0, 0, 14),
                        Size = UDim2.new(1, 0, 0, 8),
                        ZIndex = 22,
                        Parent = sliderWrap,
                    })
                    AddCorner(bg, 4)

                    local fill = Create("Frame", {
                        BackgroundColor3 = Theme.Slider,
                        Size = UDim2.new(defaultVal, 0, 1, 0),
                        ZIndex = 23,
                        Parent = bg,
                    })
                    AddCorner(fill, 4)

                    local dot = Create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Position = UDim2.new(defaultVal, 0, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        ZIndex = 24,
                        Parent = bg,
                    })
                    AddCorner(dot, 5)

                    local drag = false
                    local btn = Create("TextButton", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 25,
                        Parent = bg,
                    })

                    btn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            drag = true
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local rel = math.clamp(input.Position.X - bg.AbsolutePosition.X, 0, bg.AbsoluteSize.X)
                            local pct = rel / bg.AbsoluteSize.X
                            fill.Size = UDim2.new(pct, 0, 1, 0)
                            dot.Position = UDim2.new(pct, 0, 0.5, 0)
                            callback(pct)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            drag = false
                        end
                    end)
                end

                MakeSlider("Hue", h, function(val)
                    h = val
                    color = Color3.fromHSV(h, s, v)
                    colorDisplay.BackgroundColor3 = color
                    cpCallback(color)
                end)

                MakeSlider("Sat", s, function(val)
                    s = val
                    color = Color3.fromHSV(h, s, v)
                    colorDisplay.BackgroundColor3 = color
                    cpCallback(color)
                end)

                MakeSlider("Val", v, function(val)
                    v = val
                    color = Color3.fromHSV(h, s, v)
                    colorDisplay.BackgroundColor3 = color
                    cpCallback(color)
                end)

                colorDisplay.MouseButton1Click:Connect(function()
                    opened = not opened
                    pickerFrame.Visible = opened
                end)

                elemFrame.MouseEnter:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
                end)
                elemFrame.MouseLeave:Connect(function()
                    Tween(elemFrame, { BackgroundColor3 = Theme.Element }, 0.15)
                end)

                local CP = {}
                function CP:Get() return color end
                function CP:Set(c)
                    color = c
                    colorDisplay.BackgroundColor3 = c
                    cpCallback(c)
                end
                return CP
            end

            function Section:AddLabel(text)
                local lbl = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Font,
                    Text = text,
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    ZIndex = 4,
                    Parent = SecContent,
                })
                Create("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = lbl })

                local Label = {}
                function Label:Set(t) lbl.Text = t end
                function Label:Get() return lbl.Text end
                return Label
            end

            function Section:AddSeparator()
                local sep = Create("Frame", {
                    BackgroundColor3 = Theme.SectionBorder,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    ZIndex = 4,
                    Parent = SecContent,
                })
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
                    }),
                    Parent = sep,
                })
            end

            return Section
        end

        return Tab
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return Library
