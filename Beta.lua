local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--==================================================
-- CONFIG
--==================================================

local MAP = workspace:WaitForChild("Map")
local HOUSES = MAP:WaitForChild("Houses")

local MAX_RADIUS = 150
local MAX_SPEED = 5000

local DEFAULT_RADIUS = 25
local DEFAULT_SPEED = 100

-- Kalau debris jatuh sejauh ini dari posisi awal,
-- otomatis ditarik kembali.
local RETURN_DISTANCE = 250

-- Kalau jatuh sampai di bawah map sejauh ini,
-- otomatis ditarik kembali.
local RETURN_Y_OFFSET = 150

--==================================================
-- REMOTE
--==================================================

local Remote = ReplicatedStorage:FindFirstChild("NaturalDisasterRemote")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "NaturalDisasterRemote"
	Remote.Parent = ReplicatedStorage
end

--==================================================
-- DATA DEBRIS
--==================================================

local DebrisData = {}

local function RegisterDebris(part)
	if not part:IsA("BasePart") then
		return
	end

	if DebrisData[part] then
		return
	end

	DebrisData[part] = {
		Part = part,
		CFrame = part.CFrame,
		Anchored = part.Anchored,
		CanCollide = part.CanCollide,
		Transparency = part.Transparency,
		Size = part.Size,
	}
end

local function ScanHouses()
	for _, house in ipairs(HOUSES:GetChildren()) do
		if house:IsA("Model") or house:IsA("Folder") then

			local debrisFolder = house:FindFirstChild("Debris")

			if debrisFolder then
				for _, object in ipairs(debrisFolder:GetDescendants()) do
					if object:IsA("BasePart") then
						RegisterDebris(object)
					end
				end
			end
		end
	end
end

ScanHouses()

--==================================================
-- RESTORE
--==================================================

local function RestorePart(data)
	local part = data.Part

	if not part or not part.Parent then
		return
	end

	part.CFrame = data.CFrame
	part.Anchored = data.Anchored
	part.CanCollide = data.CanCollide
	part.Transparency = data.Transparency
	part.Size = data.Size

	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
end

local function RestoreAll()
	for _, data in pairs(DebrisData) do
		RestorePart(data)
	end
end

--==================================================
-- FIND TARGET
--==================================================

local function GetTargetPosition(targetPlayer)
	if targetPlayer and targetPlayer.Character then
		local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

		if root then
			return root.Position
		end
	end

	return nil
end

--==================================================
-- NATURAL DISASTER
--==================================================

local Active = false
local ActiveTarget = nil
local ActiveRadius = DEFAULT_RADIUS
local ActiveSpeed = DEFAULT_SPEED

local StartTime = 0

local function StartDisaster(player, radius, speed)
	Active = true
	ActiveTarget = player

	ActiveRadius = math.clamp(
		tonumber(radius) or DEFAULT_RADIUS,
		1,
		MAX_RADIUS
	)

	ActiveSpeed = math.clamp(
		tonumber(speed) or DEFAULT_SPEED,
		0,
		MAX_SPEED
	)

	StartTime = os.clock()

	-- Pastikan data terbaru ikut terdaftar
	ScanHouses()

	for _, data in pairs(DebrisData) do
		local part = data.Part

		if part and part.Parent then
			part.Anchored = true
			part.CanCollide = true
		end
	end
end

local function StopDisaster()
	Active = false
	ActiveTarget = nil

	RestoreAll()
end

--==================================================
-- UPDATE DEBRIS
--==================================================

RunService.Heartbeat:Connect(function()

	if not Active then
		return
	end

	local targetPosition = GetTargetPosition(ActiveTarget)

	if not targetPosition then
		return
	end

	local elapsed = os.clock() - StartTime

	-- Kecepatan putaran
	local angularSpeed = ActiveSpeed / 100

	local angle = elapsed * angularSpeed

	for _, data in pairs(DebrisData) do

		local part = data.Part

		if part and part.Parent then

			local originalPosition = data.CFrame.Position

			-- Cek apakah part sudah terlalu jauh
			local distanceFromOriginal =
				(part.Position - originalPosition).Magnitude

			local tooFar =
				distanceFromOriginal > RETURN_DISTANCE

			-- Cek kalau jatuh terlalu bawah
			local tooLow =
				part.Position.Y < originalPosition.Y - RETURN_Y_OFFSET

			--==================================================
			-- AUTO RETURN
			--==================================================

			if tooFar or tooLow then

				part.CFrame = data.CFrame

				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero

			else

				--==================================================
				-- DEBRIS ORBIT
				--==================================================

				local offset = originalPosition - targetPosition

				local flatOffset =
					Vector3.new(offset.X, 0, offset.Z)

				if flatOffset.Magnitude > 0 then

					local currentAngle =
						math.atan2(
							flatOffset.Z,
							flatOffset.X
						)

					local newAngle =
						currentAngle + angle

					local distance =
						math.min(
							flatOffset.Magnitude,
							ActiveRadius
						)

					local newPosition =
						targetPosition
						+ Vector3.new(
							math.cos(newAngle) * distance,
							originalPosition.Y,
							math.sin(newAngle) * distance
						)

					part.CFrame =
						CFrame.new(newPosition)
						* CFrame.Angles(
							angle,
							angle * 0.7,
							angle * 0.4
						)
				end
			end
		end
	end
end)

--==================================================
-- REMOTE COMMANDS
--==================================================

Remote.OnServerEvent:Connect(function(player, command, target, radius, speed)

	if command == "Start" then

		if typeof(target) ~= "Instance"
			or not target:IsA("Player") then
			return
		end

		StartDisaster(
			target,
			radius,
			speed
		)

	elseif command == "Stop" then

		StopDisaster()

	elseif command == "Refresh" then

		ScanHouses()
	end
end)

--==================================================
-- PLAYER LEAVES
--==================================================

Players.PlayerRemoving:Connect(function(player)

	if ActiveTarget == player then
		StopDisaster()
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("NaturalDisasterRemote")

local Rayfield = loadstring(
	game:HttpGet("https://sirius.menu/rayfield")
)()

local Window = Rayfield:CreateWindow({
	Name = "Natural Disaster",
	LoadingTitle = "Natural Disaster",
	LoadingSubtitle = "House Debris System",
	Theme = "Ocean",
	ConfigurationSaving = {
		Enabled = false
	}
})

local MainTab = Window:CreateTab("Troll", 4483362458)

local TargetPlayer = nil
local Radius = 25
local Speed = 100

--==================================================
-- TARGET
--==================================================

local function GetPlayerNames()

	local names = {}

	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(names, player.Name)
	end

	return names
end

local TargetDropdown = MainTab:CreateDropdown({
	Name = "Target Player",
	Options = GetPlayerNames(),
	CurrentOption = {},
	MultipleOptions = false,

	Callback = function(option)

		local name = option[1]

		if name then
			TargetPlayer = Players:FindFirstChild(name)
		end
	end
})

Players.PlayerAdded:Connect(function()
	TargetDropdown:Refresh(GetPlayerNames())
end)

Players.PlayerRemoving:Connect(function(player)

	if TargetPlayer == player then
		TargetPlayer = nil
	end

	TargetDropdown:Refresh(GetPlayerNames())
end)

--==================================================
-- RADIUS
--==================================================

MainTab:CreateSlider({
	Name = "Disaster Radius",
	Range = {1, 150},
	Increment = 1,
	Suffix = " studs",
	CurrentValue = 25,

	Callback = function(value)
		Radius = value
	end
})

--==================================================
-- SPEED
--==================================================

MainTab:CreateSlider({
	Name = "Debris Speed",
	Range = {0, 5000},
	Increment = 10,
	Suffix = "",
	CurrentValue = 100,

	Callback = function(value)
		Speed = value
	end
})

--==================================================
-- START
--==================================================

MainTab:CreateButton({
	Name = "Start Natural Disaster",

	Callback = function()

		if not TargetPlayer then
			Rayfield:Notify({
				Title = "No Target",
				Content = "Select a player first.",
				Duration = 3
			})

			return
		end

		Remote:FireServer(
			"Start",
			TargetPlayer,
			Radius,
			Speed
		)

		Rayfield:Notify({
			Title = "Natural Disaster",
			Content = "House debris activated.",
			Duration = 3
		})
	end
})

--==================================================
-- STOP
--==================================================

MainTab:CreateButton({
	Name = "Stop Natural Disaster",

	Callback = function()

		Remote:FireServer("Stop")

		Rayfield:Notify({
			Title = "Natural Disaster",
			Content = "All debris restored.",
			Duration = 3
		})
	end
})

--==================================================
-- REFRESH
--==================================================

MainTab:CreateButton({
	Name = "Refresh House Debris",

	Callback = function()

		Remote:FireServer("Refresh")

		Rayfield:Notify({
			Title = "Debris",
			Content = "House debris list refreshed.",
			Duration = 2
		})
	end
})
