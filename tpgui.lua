--// PLAYER TELEPORT GUI
--// Local/client-side
--// Выбор игрока -> Teleport

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CLEAN OLD GUI
--==================================================

local old = PlayerGui:FindFirstChild("PlayerTeleportGUI")

if old then
	old:Destroy()
end

--==================================================
-- COLORS
--==================================================

local COLORS = {
	bg = Color3.fromRGB(18, 20, 25),
	surface = Color3.fromRGB(28, 31, 38),
	surface2 = Color3.fromRGB(38, 42, 51),

	primary = Color3.fromRGB(88, 166, 255),
	primaryHover = Color3.fromRGB(110, 180, 255),

	success = Color3.fromRGB(55, 190, 110),

	text = Color3.fromRGB(240, 243, 247),
	subtext = Color3.fromRGB(155, 165, 180),

	border = Color3.fromRGB(55, 60, 72),

	selected = Color3.fromRGB(55, 90, 130),
}

--==================================================
-- STATE
--==================================================

local selectedPlayer = nil
local minimized = false

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleportGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(360, 470)
main.Position = UDim2.new(0.5, -180, 0.5, -235)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.border
mainStroke.Transparency = 0.3
mainStroke.Parent = main

--==================================================
-- TITLE BAR
--==================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = COLORS.surface
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = COLORS.surface
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "PLAYER TELEPORT"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = COLORS.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 32)
minimize.Position = UDim2.new(1, -72, 0, 8)
minimize.BackgroundTransparency = 1
minimize.Text = "—"
minimize.TextColor3 = COLORS.text
minimize.TextSize = 20
minimize.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -38, 0, 8)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = COLORS.text
close.TextSize = 24
close.Parent = titleBar

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(0, 48)
content.Size = UDim2.new(1, 0, 1, -48)
content.BackgroundTransparency = 1
content.Parent = main

--==================================================
-- SEARCH
--==================================================

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -24, 0, 40)
searchBox.Position = UDim2.fromOffset(12, 12)
searchBox.BackgroundColor3 = COLORS.surface
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search player..."
searchBox.PlaceholderColor3 = COLORS.subtext
searchBox.Text = ""
searchBox.TextColor3 = COLORS.text
searchBox.TextSize = 14
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.Parent = content

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

--==================================================
-- PLAYER LIST
--==================================================

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -24, 0, 285)
list.Position = UDim2.fromOffset(12, 62)
list.BackgroundColor3 = COLORS.surface
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = COLORS.primary
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = content

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = list

--==================================================
-- SELECTED INFO
--==================================================

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -24, 0, 28)
selectedLabel.Position = UDim2.fromOffset(12, 355)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = "Selected: none"
selectedLabel.TextColor3 = COLORS.subtext
selectedLabel.TextSize = 13
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedLabel.Parent = content

--==================================================
-- TELEPORT BUTTON
--==================================================

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, -24, 0, 46)
teleportButton.Position = UDim2.fromOffset(12, 389)
teleportButton.BackgroundColor3 = COLORS.primary
teleportButton.BorderSizePixel = 0
teleportButton.Text = "TELEPORT"
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.TextSize = 15
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Parent = content

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 9)
tpCorner.Parent = teleportButton

--==================================================
-- PLAYER BUTTON CREATION
--==================================================

local playerButtons = {}

local function clearPlayers()
	for _, button in pairs(playerButtons) do
		if button then
			button:Destroy()
		end
	end

	table.clear(playerButtons)
end

local function getRoot(player)
	if not player then
		return nil
	end

	local character = player.Character

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function refreshPlayers()
	clearPlayers()

	local filter = string.lower(searchBox.Text)

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local username = player.Name
			local displayName = player.DisplayName

			local combined =
				string.lower(displayName .. " " .. username)

			if filter == ""
				or string.find(combined, filter, 1, true)
			then

				local button = Instance.new("TextButton")

				button.Size =
					UDim2.new(1, 0, 0, 48)

				button.BackgroundColor3 =
					COLORS.surface2

				button.BorderSizePixel = 0
				button.Text = ""
				button.AutoButtonColor = false

				button.Parent = list

				local corner =
					Instance.new("UICorner")

				corner.CornerRadius =
					UDim.new(0, 7)

				corner.Parent = button

				-- display name
				local nameLabel =
					Instance.new("TextLabel")

				nameLabel.Size =
					UDim2.new(1, -12, 0, 24)

				nameLabel.Position =
					UDim2.fromOffset(10, 3)

				nameLabel.BackgroundTransparency = 1

				nameLabel.Text =
					displayName

				nameLabel.TextColor3 =
					COLORS.text

				nameLabel.TextSize = 14

				nameLabel.Font =
					Enum.Font.GothamSemibold

				nameLabel.TextXAlignment =
					Enum.TextXAlignment.Left

				nameLabel.Parent = button

				-- username
				local userLabel =
					Instance.new("TextLabel")

				userLabel.Size =
					UDim2.new(1, -12, 0, 18)

				userLabel.Position =
					UDim2.fromOffset(10, 25)

				userLabel.BackgroundTransparency = 1

				userLabel.Text =
					"@" .. username

				userLabel.TextColor3 =
					COLORS.subtext

				userLabel.TextSize = 11

				userLabel.Font =
					Enum.Font.Gotham

				userLabel.TextXAlignment =
					Enum.TextXAlignment.Left

				userLabel.Parent = button

				button.MouseButton1Click:Connect(function()

					selectedPlayer = player

					selectedLabel.Text =
						"Selected: "
						.. player.DisplayName
						.. " (@"
						.. player.Name
						.. ")"

					for targetPlayer, otherButton
						in pairs(playerButtons)
					do

						if otherButton then

							if targetPlayer == player then

								otherButton.BackgroundColor3 =
									COLORS.selected

							else

								otherButton.BackgroundColor3 =
									COLORS.surface2

							end
						end
					end
				end)

				button.MouseEnter:Connect(function()

					if selectedPlayer ~= player then

						TweenService:Create(
							button,
							TweenInfo.new(0.15),
							{
								BackgroundColor3 =
									Color3.fromRGB(
										48,
										53,
										64
									)
							}
						):Play()

					end
				end)

				button.MouseLeave:Connect(function()

					if selectedPlayer ~= player then

						TweenService:Create(
							button,
							TweenInfo.new(0.15),
							{
								BackgroundColor3 =
									COLORS.surface2
							}
						):Play()

					end
				end)

				playerButtons[player] = button
			end
		end
	end
end

--==================================================
-- TELEPORT
--==================================================

local function teleportToPlayer(player)

	if not player then

		selectedLabel.Text =
			"Select a player first"

		return
	end

	local myRoot =
		getRoot(LocalPlayer)

	local targetRoot =
		getRoot(player)

	if not myRoot then

		selectedLabel.Text =
			"Your character is not ready"

		return
	end

	if not targetRoot then

		selectedLabel.Text =
			"Target character unavailable"

		return
	end

	-- Teleport slightly behind target,
	-- so both characters don't occupy same position.

	local destination =
		targetRoot.CFrame
		* CFrame.new(0, 0, 3)

	myRoot.CFrame = destination

	selectedLabel.Text =
		"Teleported to "
		.. player.DisplayName
end

teleportButton.MouseButton1Click:Connect(function()
	teleportToPlayer(selectedPlayer)
end)

--==================================================
-- SEARCH
--==================================================

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	refreshPlayers()
end)

--==================================================
-- AUTO REFRESH
--==================================================

Players.PlayerAdded:Connect(function()
	task.wait(0.3)
	refreshPlayers()
end)

Players.PlayerRemoving:Connect(function(player)

	if selectedPlayer == player then

		selectedPlayer = nil

		selectedLabel.Text =
			"Selected: none"

	end

	task.wait()
	refreshPlayers()
end)

--==================================================
-- MINIMIZE
--==================================================

minimize.MouseButton1Click:Connect(function()

	minimized =
		not minimized

	content.Visible =
		not minimized

	if minimized then

		main.Size =
			UDim2.fromOffset(
				360,
				48
			)

		minimize.Text = "+"

	else

		main.Size =
			UDim2.fromOffset(
				360,
				470
			)

		minimize.Text = "—"

	end
end)

--==================================================
-- CLOSE
--==================================================

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragInput
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)

	if input.UserInputType ==
			Enum.UserInputType.MouseButton1
		or input.UserInputType ==
			Enum.UserInputType.Touch
	then

		dragging = true

		dragStart =
			input.Position

		startPosition =
			main.Position

		input.Changed:Connect(function()

			if input.UserInputState ==
				Enum.UserInputState.End
			then

				dragging = false

			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)

	if input.UserInputType ==
			Enum.UserInputType.MouseMovement
		or input.UserInputType ==
			Enum.UserInputType.Touch
	then

		dragInput = input

	end
end)

UIS.InputChanged:Connect(function(input)

	if input == dragInput
		and dragging
	then

		local delta =
			input.Position
			- dragStart

		main.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
	end
end)

--==================================================
-- BUTTON HOVER
--==================================================

teleportButton.MouseEnter:Connect(function()

	TweenService:Create(
		teleportButton,
		TweenInfo.new(0.15),
		{
			BackgroundColor3 =
				COLORS.primaryHover
		}
	):Play()

end)

teleportButton.MouseLeave:Connect(function()

	TweenService:Create(
		teleportButton,
		TweenInfo.new(0.15),
		{
			BackgroundColor3 =
				COLORS.primary
		}
	):Play()

end)

--==================================================
-- INIT
--==================================================

refreshPlayers()