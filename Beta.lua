local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--==================================================
-- REMOTE
--==================================================

local Remote = ReplicatedStorage:FindFirstChild("NaturalDebrisRemote")

if not Remote then
	Remote = Instance.new("RemoteEvent")
	Remote.Name = "NaturalDebrisRemote"
	Remote.Parent = ReplicatedStorage
end

--==================================================
-- SETTINGS
--==================================================

local MAX_DEBRIS = 30

local DEFAULT_RADIUS = 10
local DEFAULT_SPEED = 100

local MAX_RADIUS = 150
local MAX_SPEED = 5000

local active = {}

--==================================================
-- FIND REAL DEBRIS
--==================================================

local function getDebris()

	local result = {}

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("BasePart") then

			local character =
				object:FindFirstAncestorOfClass("Model")

			local humanoid =
				character and
				character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				table.insert(result, object)
			end
		end
	end

	return result
end

--==================================================
-- STOP
--==================================================

local function stop(player)

	local data = active[player]

	if not data then
		return
	end

	for _, info in ipairs(data.parts) do

		local part = info.part

		if part and part.Parent then

			part.Anchored = info.anchored
			part.CanCollide = info.canCollide
			part.CFrame = info.originalCFrame

		end
	end

	active[player] = nil
end

--==================================================
-- START
--==================================================

local function start(player, target)

	stop(player)

	if not target or not target:IsA("Player") then
		target = player
	end

	if not target.Parent then
		return
	end

	local character = target.Character

	if not character then
		return
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local debris = getDebris()

	if #debris == 0 then
		return
	end

	local selected = {}

	for i = 1, math.min(MAX_DEBRIS, #debris) do
		table.insert(selected, debris[i])
	end

	local data = {

		target = target,

		parts = {},

		time = 0,

		radius = DEFAULT_RADIUS,

		speed = DEFAULT_SPEED
	}

	active[player] = data

	--==================================================
	-- PREPARE REAL DEBRIS
	--==================================================

	for _, part in ipairs(selected) do

		table.insert(data.parts, {

			part = part,

			originalCFrame = part.CFrame,

			anchored = part.Anchored,

			canCollide = part.CanCollide

		})

		part.Anchored = true
		part.CanCollide = false

	end
end

--==================================================
-- REMOTE
--==================================================

Remote.OnServerEvent:Connect(function(
	player,
	action,
	value
)

	-- START
	if action == "Start" then

		local target = value

		if typeof(target) ~= "Instance"
			or not target:IsA("Player")
			or not target.Parent then

			target = player
		end

		start(player, target)

		return
	end

	-- STOP
	if action == "Stop" then

		stop(player)

		return
	end

	-- RADIUS
	if action == "SetRadius" then

		local data = active[player]

		if not data then
			return
		end

		if typeof(value) ~= "number" then
			return
		end

		data.radius =
			math.clamp(
				value,
				1,
				MAX_RADIUS
			)

		return
	end

	-- SPEED
	if action == "SetSpeed" then

		local data = active[player]

		if not data then
			return
		end

		if typeof(value) ~= "number" then
			return
		end

		data.speed =
			math.clamp(
				value,
				0,
				MAX_SPEED
			)

		return
	end

	-- TARGET
	if action == "SetTarget" then

		local data = active[player]

		if not data then
			return
		end

		if typeof(value) ~= "Instance"
			or not value:IsA("Player")
			or not value.Parent then

			return
		end

		data.target = value

		return
	end
end)

--==================================================
-- MOVEMENT
--==================================================

RunService.Heartbeat:Connect(function(dt)

	for owner, data in pairs(active) do

		local target = data.target

		if not target or not target.Parent then

			stop(owner)

			continue
		end

		local character = target.Character

		if not character then
			continue
		end

		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		if not root then
			continue
		end

		data.time += dt

		local t = data.time

		local count =
			#data.parts

		for index, info in ipairs(data.parts) do

			local part = info.part

			if not part or not part.Parent then
				continue
			end

			--==================================================
			-- FIVE SPECIAL DEBRIS
			--==================================================

			if index <= 5 then

				local offsets = {

					Vector3.new(
						0,
						7,
						0
					),

					Vector3.new(
						0,
						-4,
						0
					),

					Vector3.new(
						-7,
						0,
						0
					),

					Vector3.new(
						7,
						0,
						0
					),

					Vector3.new(
						0,
						0,
						-7
					)
				}

				local offset =
					offsets[index]

				local wave =
					math.sin(
						t * 2 +
						index
					) * 0.5

				local position =
					root.CFrame:PointToWorldSpace(

						offset +

						Vector3.new(
							0,
							wave,
							0
						)
					)

				local rotation =
					CFrame.Angles(

						t * data.speed * 0.01,

						t * data.speed * 0.007,

						t * data.speed * 0.004
					)

				part.CFrame =
					CFrame.new(position) *
					rotation

			--==================================================
			-- RING
			--==================================================

			else

				local ringIndex =
					index - 6

				local ringCount =
					math.max(
						count - 5,
						1
					)

				local angle =
					(
						ringIndex /
						ringCount
					) *
					math.pi *
					2

					+

					t *
					data.speed *
					0.01

				local x =
					math.cos(angle) *
					data.radius

				local z =
					math.sin(angle) *
					data.radius

				local y =
					math.sin(
						t * 2 +
						ringIndex
					) * 0.8

				local position =
					root.Position +

					Vector3.new(
						x,
						y,
						z
					)

				local direction =
					Vector3.new(
						-math.sin(angle),
						0,
						math.cos(angle)
					)

				local facing =
					CFrame.lookAt(
						position,
						position + direction
					)

				local spin =
					CFrame.Angles(

						t *
						data.speed *
						0.02,

						t *
						data.speed *
						0.015,

						t *
						data.speed *
						0.01
					)

				part.CFrame =
					facing *
					spin
			end
		end
	end
end)

--==================================================
-- CLEANUP
--==================================================

Players.PlayerRemoving:Connect(function(player)

	stop(player)

end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remote =
	ReplicatedStorage:WaitForChild(
		"NaturalDebrisRemote"
	)

--==================================================
-- RAYFIELD
--==================================================

local Rayfield = loadstring(
	game:HttpGet(
		"https://sirius.menu/rayfield"
	)
)()

local Window = Rayfield:CreateWindow({

	Name = "Natural Disaster | Debris",

	LoadingTitle =
		"Natural Disaster",

	LoadingSubtitle =
		"Real Debris System",

	ConfigurationSaving = {
		Enabled = false
	},

	KeySystem = false
})

--==================================================
-- MAIN / TROLL
--==================================================

local MainTab = Window:CreateTab(
	"Troll/Main",
	"zap"
)

--==================================================
-- VARIABLES
--==================================================

local Enabled = false

local TargetPlayer =
	LocalPlayer

local CurrentRadius = 10
local CurrentSpeed = 100

--==================================================
-- PLAYER LIST
--==================================================

local function GetPlayerNames()

	local names = {}

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		table.insert(
			names,
			player.Name
		)

	end

	return names
end

--==================================================
-- TARGET
--==================================================

local PlayerDropdown =
	MainTab:CreateDropdown({

		Name = "Target Player",

		Options =
			GetPlayerNames(),

		CurrentOption = {
			LocalPlayer.Name
		},

		MultipleOptions = false,

		Callback = function(option)

			local name =
				option[1]

			local player =
				Players:FindFirstChild(
					name
				)

			if not player then
				return
			end

			TargetPlayer =
				player

			if Enabled then

				Remote:FireServer(
					"SetTarget",
					TargetPlayer
				)

			end
		end
	})

--==================================================
-- ENABLE
--==================================================

MainTab:CreateToggle({

	Name = "Enable Real Debris",

	CurrentValue = false,

	Callback = function(value)

		Enabled = value

		if value then

			Remote:FireServer(
				"Start",
				TargetPlayer
			)

			task.wait()

			Remote:FireServer(
				"SetRadius",
				CurrentRadius
			)

			Remote:FireServer(
				"SetSpeed",
				CurrentSpeed
			)

		else

			Remote:FireServer(
				"Stop"
			)

		end
	end
})

--==================================================
-- RADIUS
--==================================================

MainTab:CreateSlider({

	Name = "Debris Radius",

	Range = {
		1,
		150
	},

	Increment = 1,

	Suffix = " studs",

	CurrentValue = 10,

	Callback = function(value)

		CurrentRadius = value

		if Enabled then

			Remote:FireServer(
				"SetRadius",
				value
			)

		end
	end
})

--==================================================
-- ROTATION SPEED
--==================================================

MainTab:CreateSlider({

	Name = "Rotation Speed",

	Range = {
		0,
		5000
	},

	Increment = 1,

	Suffix = " speed",

	CurrentValue = 100,

	Callback = function(value)

		CurrentSpeed = value

		if Enabled then

			Remote:FireServer(
				"SetSpeed",
				value
			)

		end
	end
})

--==================================================
-- REFRESH
--==================================================

MainTab:CreateButton({

	Name = "Refresh Players",

	Callback = function()

		PlayerDropdown:Refresh(
			GetPlayerNames()
		)

		Rayfield:Notify({

			Title = "Players",

			Content =
				"Player list refreshed.",

			Duration = 2
		})
	end
})

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function()

	task.wait(0.2)

	PlayerDropdown:Refresh(
		GetPlayerNames()
	)

end)

Players.PlayerRemoving:Connect(function()

	task.wait(0.2)

	PlayerDropdown:Refresh(
		GetPlayerNames()
	)

	if not TargetPlayer.Parent then

		TargetPlayer =
			LocalPlayer

	end
end)

--==================================================
-- READY
--==================================================

Rayfield:Notify({

	Title =
		"Real Debris System",

	Content =
		"Ready. Maximum radius: 150 studs | Maximum speed: 5000",

	Duration = 4
})
