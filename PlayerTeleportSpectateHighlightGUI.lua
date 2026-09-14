--// Player Teleport + Spectate + Highlight GUI
--// Client-side / LocalScript style

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("PlayerTeleportGUI")
if old then old:Destroy() end

local COLORS = {
    bg = Color3.fromRGB(18, 20, 25),
    surface = Color3.fromRGB(28, 31, 38),
    surface2 = Color3.fromRGB(38, 42, 51),
    primary = Color3.fromRGB(88, 166, 255),
    primaryHover = Color3.fromRGB(110, 180, 255),
    success = Color3.fromRGB(47, 183, 117),
    warning = Color3.fromRGB(230, 180, 70),
    text = Color3.fromRGB(240, 243, 247),
    subtext = Color3.fromRGB(155, 165, 180),
    border = Color3.fromRGB(55, 60, 72),
    selected = Color3.fromRGB(55, 90, 130),
}

local selectedPlayer = nil
local minimized = false
local spectating = false
local highlightEnabled = false

local currentScale = 0.80
local MIN_SCALE = 0.50
local MAX_SCALE = 1.50
local SCALE_STEP = 0.10
local TELEPORT_OFFSET = CFrame.new(0, 0, 4)

local currentHighlight = nil
local selectedCharacterConnection = nil
local playerButtons = {}

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleportGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(290, 390)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Parent = gui

local guiScale = Instance.new("UIScale")
guiScale.Scale = currentScale
guiScale.Parent = main

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.border
mainStroke.Transparency = 0.3
mainStroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = COLORS.surface
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = COLORS.surface
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -180, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER TOOLS"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = COLORS.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local scaleMinus = Instance.new("TextButton")
scaleMinus.Size = UDim2.fromOffset(24, 24)
scaleMinus.Position = UDim2.new(1, -164, 0.5, -12)
scaleMinus.BackgroundColor3 = COLORS.surface2
scaleMinus.BorderSizePixel = 0
scaleMinus.Text = "−"
scaleMinus.TextColor3 = COLORS.text
scaleMinus.TextSize = 16
scaleMinus.Font = Enum.Font.GothamBold
scaleMinus.Parent = titleBar
Instance.new("UICorner", scaleMinus).CornerRadius = UDim.new(0, 6)

local scaleLabel = Instance.new("TextLabel")
scaleLabel.Size = UDim2.fromOffset(52, 24)
scaleLabel.Position = UDim2.new(1, -136, 0.5, -12)
scaleLabel.BackgroundTransparency = 1
scaleLabel.TextColor3 = COLORS.subtext
scaleLabel.TextSize = 10
scaleLabel.Font = Enum.Font.GothamSemibold
scaleLabel.Parent = titleBar

local scalePlus = Instance.new("TextButton")
scalePlus.Size = UDim2.fromOffset(24, 24)
scalePlus.Position = UDim2.new(1, -82, 0.5, -12)
scalePlus.BackgroundColor3 = COLORS.surface2
scalePlus.BorderSizePixel = 0
scalePlus.Text = "+"
scalePlus.TextColor3 = COLORS.text
scalePlus.TextSize = 15
scalePlus.Font = Enum.Font.GothamBold
scalePlus.Parent = titleBar
Instance.new("UICorner", scalePlus).CornerRadius = UDim.new(0, 6)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 28)
minimize.Position = UDim2.new(1, -58, 0, 6)
minimize.BackgroundTransparency = 1
minimize.Text = "—"
minimize.TextColor3 = COLORS.text
minimize.TextSize = 18
minimize.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -30, 0, 6)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = COLORS.text
close.TextSize = 21
close.Parent = titleBar

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(0, 40)
content.Size = UDim2.new(1, 0, 1, -40)
content.BackgroundTransparency = 1
content.Parent = main

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 34)
searchBox.Position = UDim2.fromOffset(10, 10)
searchBox.BackgroundColor3 = COLORS.surface
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search player..."
searchBox.PlaceholderColor3 = COLORS.subtext
searchBox.Text = ""
searchBox.TextColor3 = COLORS.text
searchBox.TextSize = 13
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = content
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 0, 190)
list.Position = UDim2.fromOffset(10, 52)
list.BackgroundColor3 = COLORS.surface
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = COLORS.primary
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = content
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 7)
padding.PaddingBottom = UDim.new(0, 7)
padding.PaddingLeft = UDim.new(0, 7)
padding.PaddingRight = UDim.new(0, 7)
padding.Parent = list

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -20, 0, 22)
selectedLabel.Position = UDim2.fromOffset(10, 248)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = "Selected: none"
selectedLabel.TextColor3 = COLORS.subtext
selectedLabel.TextSize = 11
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
selectedLabel.Parent = content

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, -20, 0, 36)
teleportButton.Position = UDim2.fromOffset(10, 274)
teleportButton.BackgroundColor3 = COLORS.primary
teleportButton.BorderSizePixel = 0
teleportButton.Text = "TELEPORT"
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.TextSize = 13
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = content
Instance.new("UICorner", teleportButton).CornerRadius = UDim.new(0, 8)

local spectateButton = Instance.new("TextButton")
spectateButton.Size = UDim2.new(0.5, -15, 0, 36)
spectateButton.Position = UDim2.fromOffset(10, 318)
spectateButton.BackgroundColor3 = COLORS.surface2
spectateButton.BorderSizePixel = 0
spectateButton.Text = "SPECTATE: OFF"
spectateButton.TextColor3 = Color3.new(1, 1, 1)
spectateButton.TextSize = 11
spectateButton.Font = Enum.Font.GothamBold
spectateButton.Parent = content
Instance.new("UICorner", spectateButton).CornerRadius = UDim.new(0, 8)

local highlightButton = Instance.new("TextButton")
highlightButton.Size = UDim2.new(0.5, -15, 0, 36)
highlightButton.Position = UDim2.new(0.5, 5, 0, 318)
highlightButton.BackgroundColor3 = COLORS.surface2
highlightButton.BorderSizePixel = 0
highlightButton.Text = "HIGHLIGHT: OFF"
highlightButton.TextColor3 = Color3.new(1, 1, 1)
highlightButton.TextSize = 10
highlightButton.Font = Enum.Font.GothamBold
highlightButton.Parent = content
Instance.new("UICorner", highlightButton).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.fromOffset(10, 357)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = COLORS.subtext
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = content

local function clearPlayers()
    for _, button in pairs(playerButtons) do
        if button then button:Destroy() end
    end
    table.clear(playerButtons)
end

local function getCharacter(player)
    return player and player.Character or nil
end

local function getRoot(player)
    local character = getCharacter(player)
    return character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function getHumanoid(player)
    local character = getCharacter(player)
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function updateScale()
    currentScale = math.clamp(currentScale, MIN_SCALE, MAX_SCALE)
    guiScale.Scale = currentScale
    scaleLabel.Text = tostring(math.floor(currentScale * 100 + 0.5)) .. "%"
end

local function destroyHighlight()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

local function applyHighlight()
    destroyHighlight()
    if not highlightEnabled or not selectedPlayer then return end

    local character = selectedPlayer.Character
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SelectedPlayerHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 215, 70)
    highlight.FillTransparency = 0.55
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    currentHighlight = highlight
end

local function stopHighlight(message)
    highlightEnabled = false
    destroyHighlight()
    highlightButton.Text = "HIGHLIGHT: OFF"
    highlightButton.BackgroundColor3 = COLORS.surface2
    if message then statusLabel.Text = message end
end

local function startHighlight()
    if not selectedPlayer then
        statusLabel.Text = "Select a player first"
        return
    end

    highlightEnabled = true
    highlightButton.Text = "HIGHLIGHT: ON"
    highlightButton.BackgroundColor3 = COLORS.warning
    applyHighlight()
    statusLabel.Text = "Highlighted " .. selectedPlayer.DisplayName
end

local function stopSpectate(message)
    spectating = false
    local camera = workspace.CurrentCamera
    local humanoid = getHumanoid(LocalPlayer)
    if camera and humanoid then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = humanoid
    end
    spectateButton.Text = "SPECTATE: OFF"
    spectateButton.BackgroundColor3 = COLORS.surface2
    if message then statusLabel.Text = message end
end

local function startSpectate()
    if not selectedPlayer then
        statusLabel.Text = "Select a player first"
        return
    end

    local targetHumanoid = getHumanoid(selectedPlayer)
    local camera = workspace.CurrentCamera
    if not targetHumanoid or not camera then
        statusLabel.Text = "Target character unavailable"
        return
    end

    spectating = true
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = targetHumanoid
    spectateButton.Text = "SPECTATE: ON"
    spectateButton.BackgroundColor3 = COLORS.success
    statusLabel.Text = "Watching " .. selectedPlayer.DisplayName
end

local function connectSelectedPlayerRespawn()
    if selectedCharacterConnection then
        selectedCharacterConnection:Disconnect()
        selectedCharacterConnection = nil
    end
    if not selectedPlayer then return end

    selectedCharacterConnection = selectedPlayer.CharacterAdded:Connect(function()
        task.wait(0.25)
        if highlightEnabled then applyHighlight() end
        if spectating then
            local targetHumanoid = getHumanoid(selectedPlayer)
            local camera = workspace.CurrentCamera
            if targetHumanoid and camera then
                camera.CameraType = Enum.CameraType.Custom
                camera.CameraSubject = targetHumanoid
            end
        end
    end)
end

local function refreshPlayers()
    clearPlayers()
    local filter = string.lower(searchBox.Text)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local username = player.Name
            local displayName = player.DisplayName
            local combined = string.lower(displayName .. " " .. username)

            if filter == "" or string.find(combined, filter, 1, true) then
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 0, 40)
                button.BackgroundColor3 = COLORS.surface2
                button.BorderSizePixel = 0
                button.Text = ""
                button.AutoButtonColor = false
                button.Parent = list
                Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, -10, 0, 20)
                nameLabel.Position = UDim2.fromOffset(8, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = displayName
                nameLabel.TextColor3 = COLORS.text
                nameLabel.TextSize = 13
                nameLabel.Font = Enum.Font.GothamSemibold
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = button

                local userLabel = Instance.new("TextLabel")
                userLabel.Size = UDim2.new(1, -10, 0, 15)
                userLabel.Position = UDim2.fromOffset(8, 21)
                userLabel.BackgroundTransparency = 1
                userLabel.Text = "@" .. username
                userLabel.TextColor3 = COLORS.subtext
                userLabel.TextSize = 10
                userLabel.Font = Enum.Font.Gotham
                userLabel.TextXAlignment = Enum.TextXAlignment.Left
                userLabel.TextTruncate = Enum.TextTruncate.AtEnd
                userLabel.Parent = button

                button.Activated:Connect(function()
                    if selectedPlayer ~= player then
                        if spectating then stopSpectate() end
                        if highlightEnabled then destroyHighlight() end
                    end

                    selectedPlayer = player
                    selectedLabel.Text = "Selected: " .. player.DisplayName .. " (@" .. player.Name .. ")"
                    connectSelectedPlayerRespawn()
                    if highlightEnabled then applyHighlight() end

                    for targetPlayer, otherButton in pairs(playerButtons) do
                        if otherButton then
                            otherButton.BackgroundColor3 = (targetPlayer == player) and COLORS.selected or COLORS.surface2
                        end
                    end
                end)

                button.MouseEnter:Connect(function()
                    if selectedPlayer ~= player then
                        TweenService:Create(button, TweenInfo.new(0.12), {
                            BackgroundColor3 = Color3.fromRGB(48, 53, 64)
                        }):Play()
                    end
                end)

                button.MouseLeave:Connect(function()
                    if selectedPlayer ~= player then
                        TweenService:Create(button, TweenInfo.new(0.12), {
                            BackgroundColor3 = COLORS.surface2
                        }):Play()
                    end
                end)

                playerButtons[player] = button
            end
        end
    end
end

local function moveLocalCharacterTo(targetCFrame)
    local character = getCharacter(LocalPlayer)
    local root = getRoot(LocalPlayer)
    local humanoid = getHumanoid(LocalPlayer)
    if not character or not root then return false end

    if humanoid and humanoid.SeatPart then humanoid.Sit = false end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    character:PivotTo(targetCFrame)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function teleportToPlayer(player)
    if not player then
        statusLabel.Text = "Select a player first"
        return
    end

    local targetRoot = getRoot(player)
    if not targetRoot then
        statusLabel.Text = "Target character unavailable"
        return
    end

    for _ = 1, 6 do
        if not player.Parent then break end
        local freshTargetRoot = getRoot(player)
        if not freshTargetRoot then break end
        moveLocalCharacterTo(freshTargetRoot.CFrame * TELEPORT_OFFSET)
        RunService.Heartbeat:Wait()
    end

    statusLabel.Text = "Teleported to " .. player.DisplayName
end

teleportButton.Activated:Connect(function()
    teleportToPlayer(selectedPlayer)
end)

spectateButton.Activated:Connect(function()
    if spectating then stopSpectate("Spectate stopped") else startSpectate() end
end)

highlightButton.Activated:Connect(function()
    if highlightEnabled then stopHighlight("Highlight stopped") else startHighlight() end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    refreshPlayers()
end)

Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        if spectating then stopSpectate("Target left the server") end
        if highlightEnabled then stopHighlight("Target left the server") end
        if selectedCharacterConnection then
            selectedCharacterConnection:Disconnect()
            selectedCharacterConnection = nil
        end
        selectedPlayer = nil
        selectedLabel.Text = "Selected: none"
    end
    task.wait()
    refreshPlayers()
end)

scaleMinus.Activated:Connect(function()
    currentScale -= SCALE_STEP
    updateScale()
end)

scalePlus.Activated:Connect(function()
    currentScale += SCALE_STEP
    updateScale()
end)

minimize.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(290, 40)
        minimize.Text = "+"
    else
        main.Size = UDim2.fromOffset(290, 390)
        minimize.Text = "—"
    end
end)

close.Activated:Connect(function()
    if spectating then stopSpectate() end
    if highlightEnabled then stopHighlight() else destroyHighlight() end
    if selectedCharacterConnection then
        selectedCharacterConnection:Disconnect()
        selectedCharacterConnection = nil
    end
    gui:Destroy()
end)

local dragging = false
local dragInput
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

teleportButton.MouseEnter:Connect(function()
    TweenService:Create(teleportButton, TweenInfo.new(0.12), {
        BackgroundColor3 = COLORS.primaryHover
    }):Play()
end)

teleportButton.MouseLeave:Connect(function()
    TweenService:Create(teleportButton, TweenInfo.new(0.12), {
        BackgroundColor3 = COLORS.primary
    }):Play()
end)

updateScale()
refreshPlayers()
