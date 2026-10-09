--// ONESHOT v5  (GLASS + 4K + GALAXY)
--// LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

--==================================================
-- CONFIG
--==================================================

local CFG = {
	GUI_NAME = "ONESHOT",
	OPEN_KEY = Enum.KeyCode.Delete,
	ZOOM_KEY = Enum.KeyCode.Z,

	-- WORLD GUI
	PanelW = 12,
	PanelH = 9,
	PanelPPS = 60,
	PanelDistance = 8,
	PanelHeight = 1.5,

	-- GLASS (больше = прозрачнее)
	GlassBg = 0.38,

	-- INVINFO
	InventoryDistance = 35,
	InventoryHeight = 3.25,
	BobSpeed = 5,
	BobAmount = 0.035,

	-- SELF GLOW
	GlowFillColor = Color3.fromRGB(255, 205, 70),
	GlowOutlineColor = Color3.fromRGB(255, 230, 120),
	GlowFillTransparency = 0.35,
	GlowOutlineTransparency = 0,

	-- WINGS
	FEATHERS_PER_LAYER = 14,
	FLAP = true,
	FLAP_SPEED = 2,
	FLAP_AMOUNT = 0.12,
	PLATE_POS = Vector3.new(0, 0.1, 0.65),
	BACK_SWEEP = 0.45,

	-- KORBLOX
	LEG_LENGTH = 0.75,
	THICK_TOP = 0.45,
	THICK_TIP = 0.05,
	BLUE_START = 0.75,
	SEG_DENSITY = 6,

	-- AURA
	AuraColor = Color3.fromRGB(255, 255, 255),
	AuraRateOpen = 30,
	AuraRateClosed = 45,
	AuraDensity = 1,
	GhostInterval = 0.08,
	GhostLife = 0.7,
	GhostMinSpeed = 2,

	-- 4:3
	StretchY = 0.75,

	-- GLOSS
	GlossAmount = 0.25,

	-- WORLD PARTICLES
	FireflyRate = 10,
	StarfallRate = 12,

	-- SPACE
	NebulaRate = 1.2,
	PlanetDistance = 1200,
	MeteorInterval = 1.6,
	DustRate = 40,
	GravityScale = 0.35,

	-- GRAPHICS
	MotionBlurAmount = 1.5,

	-- JUMP / CLICK
	JumpCount = 30,
	ClickCount = 40,
	ClickColor = Color3.fromRGB(255, 140, 190),

	-- FOV
	FOV = 90,
	FovBoost = 12,
	ZoomFov = 35,

	-- DAY CYCLE (часов в секунду)
	DaySpeed = 0.4,

	-- SKY
	SkySpinSpeed = 1.5,
	Skies = {
		{
			name = "Sunset", clock = 17.6, stars = 0, brightness = 2,
			ambient = Color3.fromRGB(110, 80, 90), outdoor = Color3.fromRGB(160, 110, 100),
			atmos = {color = Color3.fromRGB(255, 170, 120), decay = Color3.fromRGB(255, 110, 80), density = 0.33, haze = 1.6, glare = 0.6},
		},
		{
			name = "Night", clock = 0, stars = 3000, brightness = 1,
			ambient = Color3.fromRGB(40, 45, 80), outdoor = Color3.fromRGB(60, 70, 110),
			atmos = {color = Color3.fromRGB(60, 70, 120), decay = Color3.fromRGB(30, 30, 70), density = 0.25, haze = 0.5, glare = 0},
		},
		{
			name = "Purple", clock = 18.4, stars = 1500, brightness = 1.6,
			ambient = Color3.fromRGB(90, 60, 120), outdoor = Color3.fromRGB(130, 90, 170),
			atmos = {color = Color3.fromRGB(200, 140, 255), decay = Color3.fromRGB(120, 60, 200), density = 0.35, haze = 2, glare = 0.4},
		},
		{
			name = "Galaxy", clock = 0, stars = 6000, brightness = 1,
			ambient = Color3.fromRGB(70, 50, 125), outdoor = Color3.fromRGB(90, 70, 160),
			atmos = {color = Color3.fromRGB(120, 80, 220), decay = Color3.fromRGB(40, 20, 90), density = 0.1, haze = 0.3, glare = 0},
		},
		{
			name = "Nebula", clock = 0, stars = 4500, brightness = 1.2,
			ambient = Color3.fromRGB(120, 55, 130), outdoor = Color3.fromRGB(160, 75, 170),
			atmos = {color = Color3.fromRGB(255, 100, 200), decay = Color3.fromRGB(90, 30, 120), density = 0.18, haze = 0.9, glare = 0.2},
		},
		{
			name = "Custom", clock = 14, stars = 0, brightness = 2,
			ambient = Color3.fromRGB(120, 120, 130), outdoor = Color3.fromRGB(150, 150, 160),
			atmos = {color = Color3.fromRGB(199, 220, 255), decay = Color3.fromRGB(106, 112, 125), density = 0.2, haze = 0.3, glare = 0},
			box = {Bk = "", Dn = "", Ft = "", Lf = "", Rt = "", Up = ""}, -- 6 ID: "rbxassetid://123..."
		},
	},

	-- CATALOG
	CatalogHosts = {"https://catalog.roblox.com", "https://catalog.roproxy.com"},
}

local GalaxySkyIndex = 1
for i, s in ipairs(CFG.Skies) do
	if s.name == "Galaxy" then GalaxySkyIndex = i end
end

local AURA_COLORS = {
	{"White", Color3.fromRGB(255, 255, 255)},
	{"Ice", Color3.fromRGB(190, 230, 255)},
	{"Pink", Color3.fromRGB(255, 170, 215)},
	{"Gold", Color3.fromRGB(255, 215, 120)},
	{"Violet", Color3.fromRGB(200, 160, 255)},
}
local AuraColorIndex = 1

--==================================================
-- HELPERS
--==================================================

local WHITE = Color3.new(1, 1, 1)

local function New(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		o[k] = v
	end
	if parent then o.Parent = parent end
	return o
end

local function tw(obj, t, props, style, dir)
	local tween = TweenService:Create(obj,
		TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

local function setc(obj, prop, color, instant)
	if instant then
		obj[prop] = color
	else
		tw(obj, 0.4, {[prop] = color})
	end
end

local function corner(parent, r)
	return New("UICorner", {CornerRadius = UDim.new(0, r)}, parent)
end

-- обводка с "жидким стеклом": яркий блик сверху-слева, тусклая середина
local function stroke(parent, color, thickness)
	local s = New("UIStroke", {Color = color, Thickness = thickness or 1, Transparency = 0.1}, parent)
	New("UIGradient", {
		Rotation = 45,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.45, 0.72),
			NumberSequenceKeypoint.new(0.55, 0.72),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
	}, s)
	return s
end

local function Http(url)
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		local ok, res = pcall(req, {Url = url, Method = "GET"})
		if ok and res and res.Body and (res.Success or res.StatusCode == 200) then
			return res.Body
		end
	end
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	ok, body = pcall(function() return HttpService:GetAsync(url) end)
	if ok and type(body) == "string" then return body end
	return nil
end

local function SetHidden(inst, prop, val)
	pcall(function()
		if sethiddenproperty then
			sethiddenproperty(inst, prop, val)
		else
			inst[prop] = val
		end
	end)
end

--==================================================
-- CLEANUP OF OLD RUN
--==================================================

do
	for _, n in ipairs({CFG.GUI_NAME, "ONESHOT_PanelGui", "ONESHOT_Bars"}) do
		local g = player.PlayerGui:FindFirstChild(n)
		if g then g:Destroy() end
	end
	for _, o in ipairs(workspace:GetChildren()) do
		if string.sub(o.Name, 1, 8) == "ONESHOT_" then o:Destroy() end
	end
	for _, n in ipairs({"ONESHOT_StretchPre", "ONESHOT_StretchPost", "ONESHOT_Fov", "ONESHOT_MotionBlur"}) do
		pcall(function() RunService:UnbindFromRenderStep(n) end)
	end
	for _, o in ipairs(Lighting:GetChildren()) do
		if string.sub(o.Name, 1, 8) == "ONESHOT_" then o:Destroy() end
	end
end

--==================================================
-- STATE
--==================================================

local InvInfoEnabled, GlowEnabled, WingsEnabled, KorbloxEnabled = false, false, false, false
local AuraEnabled, SkyEnabled, ShadersEnabled = false, false, false
local StretchEnabled, GlossEnabled, FirefliesEnabled = false, false, false
local JumpFXEnabled, ClickFXEnabled = false, false
local HaloEnabled, OrbsEnabled, RipplesEnabled = false, false, false
local StarfallEnabled, TimeEnabled = false, false
local FovEnabled, SpeedFovEnabled = false, false
local NebulaEnabled, PlanetsEnabled, MeteorsEnabled, BlackHoleEnabled = false, false, false, false
local DustEnabled, AuroraEnabled, LowGravEnabled, CometEnabled = false, false, false, false
local MagicEnabled, RainbowEnabled = false, false
local MotionBlurEnabled, BarsEnabled, GlassBlurEnabled = false, false, true
local GuiOpen = true

local character, humanoid

local function GetCharacter()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:FindFirstChildOfClass("Humanoid")
	return character
end
GetCharacter()

--==================================================
-- INVINFO
--==================================================

local InventoryPart, InventoryGui, InventoryItems

local function GetTargetPlayer()
	local target = mouse.Target
	if not target then return nil end
	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	return Players:GetPlayerFromCharacter(model)
end

local function CreateInventoryPart()
	if InventoryPart then InventoryPart:Destroy() end

	InventoryPart = New("Part", {
		Name = "ONESHOT_InvInfo", Size = Vector3.new(5.5, 2.7, 0.08), Anchored = true,
		CanCollide = false, CanTouch = false, CanQuery = false, CastShadow = false, Transparency = 1,
	}, workspace)

	InventoryGui = New("SurfaceGui", {
		Name = "InventorySurface", Face = Enum.NormalId.Front, AlwaysOnTop = true, LightInfluence = 0,
		SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 45, Enabled = false,
	}, InventoryPart)

	local bg = New("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(18, 7, 13),
		BackgroundTransparency = 0.25, BorderSizePixel = 0,
	}, InventoryGui)
	corner(bg, 12)
	stroke(bg, Color3.fromRGB(230, 120, 170), 2)

	New("TextLabel", {
		Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 7), BackgroundTransparency = 1,
		Text = "INVENTORY", TextColor3 = Color3.fromRGB(255, 220, 230), Font = Enum.Font.GothamBold,
		TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
	}, bg)
	New("Frame", {
		Size = UDim2.new(1, -20, 0, 1), Position = UDim2.fromOffset(10, 42),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.75, BorderSizePixel = 0,
	}, bg)

	InventoryItems = New("TextLabel", {
		Size = UDim2.new(1, -20, 1, -52), Position = UDim2.fromOffset(10, 49), BackgroundTransparency = 1,
		Text = "EMPTY", TextColor3 = Color3.fromRGB(210, 185, 195), Font = Enum.Font.GothamMedium,
		TextSize = 14, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, bg)
end

local function UpdateInventory()
	if not InventoryPart or not InventoryPart.Parent then
		CreateInventoryPart()
	end

	if not InvInfoEnabled then
		InventoryGui.Enabled = false
		return
	end

	local targetPlayer = GetTargetPlayer()
	if not targetPlayer or targetPlayer == player then
		InventoryGui.Enabled = false
		return
	end

	local tc = targetPlayer.Character
	local targetRoot = tc and (tc:FindFirstChild("HumanoidRootPart")
		or tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
	if not targetRoot then
		InventoryGui.Enabled = false
		return
	end

	local cam = workspace.CurrentCamera
	if (cam.CFrame.Position - targetRoot.Position).Magnitude > CFG.InventoryDistance then
		InventoryGui.Enabled = false
		return
	end

	local bob = math.sin(os.clock() * CFG.BobSpeed) * CFG.BobAmount
	local position = targetRoot.Position + Vector3.new(0, CFG.InventoryHeight + bob, 0)
	if (cam.CFrame.Position - position).Magnitude > 0.01 then
		InventoryPart.CFrame = CFrame.lookAt(position, cam.CFrame.Position)
	end

	local lines = {}
	for _, object in ipairs(tc:GetChildren()) do
		if object:IsA("Tool") then
			table.insert(lines, "• " .. object.Name)
		end
	end

	if #lines == 0 then
		InventoryItems.Text = "EMPTY / NO DATA"
		InventoryItems.TextColor3 = Color3.fromRGB(145, 120, 130)
	else
		InventoryItems.Text = table.concat(lines, "\n")
		InventoryItems.TextColor3 = Color3.fromRGB(235, 210, 220)
	end

	InventoryGui.Enabled = true
end

CreateInventoryPart()
RunService.RenderStepped:Connect(UpdateInventory)

--==================================================
-- SELF GLOW
--==================================================

local SelfGlow

local function RemoveSelfGlow()
	if SelfGlow then
		SelfGlow:Destroy()
		SelfGlow = nil
	end
end

local function CreateSelfGlow()
	RemoveSelfGlow()
	if not character then return end
	SelfGlow = New("Highlight", {
		Name = "ONESHOT_SelfGlow", Adornee = character,
		FillColor = CFG.GlowFillColor, OutlineColor = CFG.GlowOutlineColor,
		FillTransparency = CFG.GlowFillTransparency, OutlineTransparency = CFG.GlowOutlineTransparency,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
	}, character)
end

--==================================================
-- WINGS
--==================================================

local WingsModel, WingsConnection

local function DestroyWings()
	if WingsConnection then
		WingsConnection:Disconnect()
		WingsConnection = nil
	end
	if WingsModel then
		WingsModel:Destroy()
		WingsModel = nil
	end
end

local function BuildWings()
	DestroyWings()
	if not character then GetCharacter() end

	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then return end

	local TAN = Color3.fromRGB(200, 172, 120)
	local LAYERS = {
		{color = Color3.fromRGB(205, 208, 225), z = -0.05, ds = 0.02, scale = 1.00},
		{color = Color3.fromRGB(236, 238, 250), z = 0.05, ds = -0.015, scale = 0.96},
	}
	local ARC = {{0.55, 0.2}, {0.8, 0.75}, {1.1, 1.08}, {1.78, 1.35}, {2.6, 1.3}, {3.35, 1.0}}

	local cum = {0}
	for i = 2, #ARC do
		local dx = ARC[i][1] - ARC[i - 1][1]
		local dy = ARC[i][2] - ARC[i - 1][2]
		cum[i] = cum[i - 1] + math.sqrt(dx * dx + dy * dy)
	end
	local total = cum[#ARC]

	local function arcPoint(s)
		local d = math.clamp(s, 0, 1) * total
		for i = 2, #ARC do
			if d <= cum[i] then
				local t = (d - cum[i - 1]) / (cum[i] - cum[i - 1])
				return ARC[i - 1][1] + (ARC[i][1] - ARC[i - 1][1]) * t,
					ARC[i - 1][2] + (ARC[i][2] - ARC[i - 1][2]) * t
			end
		end
		return ARC[#ARC][1], ARC[#ARC][2]
	end

	WingsModel = New("Model", {Name = "WingsModel"}, character)

	local function newPart(size, color, ball)
		local p = New("Part", {
			Size = size, Color = color, Material = Enum.Material.SmoothPlastic,
			CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
			TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
		}, WingsModel)
		if ball then
			New("SpecialMesh", {MeshType = Enum.MeshType.Sphere}, p)
		end
		return p
	end

	local function weld(p0, p1, c0)
		return New("Weld", {Part0 = p0, Part1 = p1, C0 = c0}, p1)
	end

	local plate = newPart(Vector3.new(1.4, 0.7, 0.4), TAN, true)
	plate.Name = "Plate"
	weld(torso, plate, CFrame.new(CFG.PLATE_POS))

	local function makeWing(side)
		local root = newPart(Vector3.new(0.2, 0.2, 0.2), TAN)
		root.Transparency = 1
		root.Name = side == 1 and "RootR" or "RootL"
		local rootWeld = weld(torso, root, CFrame.new(CFG.PLATE_POS))

		local function pos(s)
			local x, y = arcPoint(s)
			return Vector3.new(side * x, y, CFG.BACK_SWEEP * s)
		end

		for i = 1, #ARC - 1 do
			local a = pos(cum[i] / total)
			local b = pos(cum[i + 1] / total)
			local seg = newPart(Vector3.new(0.1, 0.1, (b - a).Magnitude), TAN)
			weld(root, seg, CFrame.new((a + b) / 2, b))
		end

		for _, idx in ipairs({4, 6}) do
			local knob = newPart(Vector3.new(0.28, 0.28, 0.28), TAN, true)
			weld(root, knob, CFrame.new(pos(cum[idx] / total)))
		end

		for _, layer in ipairs(LAYERS) do
			for i = 1, CFG.FEATHERS_PER_LAYER do
				local s = 0.03 + (i - 1) / (CFG.FEATHERS_PER_LAYER - 1) * 0.97 + layer.ds
				s = math.clamp(s, 0, 1)
				local p = pos(s)
				local phi = math.rad(4 + 72 * s ^ 1.15)
				local len = (2.7 + 3.6 * s - 4 * s * s) * layer.scale

				local f = newPart(Vector3.new(0.62, len, 0.05), layer.color, true)
				f.Name = "Feather"
				weld(root, f,
					CFrame.new(p.X, p.Y, p.Z + layer.z)
					* CFrame.Angles(0, 0, side * phi)
					* CFrame.new(0, -len / 2, 0))
			end
		end

		return rootWeld
	end

	local rightWeld = makeWing(1)
	local leftWeld = makeWing(-1)
	local baseR, baseL = rightWeld.C0, leftWeld.C0

	if CFG.FLAP then
		local t = 0
		WingsConnection = RunService.RenderStepped:Connect(function(dt)
			if not WingsModel or not WingsModel.Parent then
				if WingsConnection then
					WingsConnection:Disconnect()
					WingsConnection = nil
				end
				return
			end
			t += dt
			local a = math.sin(t * CFG.FLAP_SPEED) * CFG.FLAP_AMOUNT
			rightWeld.C0 = baseR * CFrame.Angles(0, 0, a)
			leftWeld.C0 = baseL * CFrame.Angles(0, 0, -a)
		end)
	end
end

--==================================================
-- KORBLOX
--==================================================

local KorbloxModel
local KorbloxHidden = {}

local function DestroyKorblox()
	if KorbloxModel then
		KorbloxModel:Destroy()
		KorbloxModel = nil
	end
	for _, p in ipairs(KorbloxHidden) do
		if p and p.Parent then p.Transparency = 0 end
	end
	KorbloxHidden = {}
end

local function BuildKorblox()
	DestroyKorblox()
	if not character then GetCharacter() end

	local BLACK = Color3.fromRGB(14, 14, 20)
	local BLUE = Color3.fromRGB(140, 215, 255)

	local chain = {}
	local upper = character:FindFirstChild("RightUpperLeg")

	if upper then
		local lower = character:WaitForChild("RightLowerLeg")
		local foot = character:WaitForChild("RightFoot")
		chain = {
			{ref = upper, span = upper.Size.Y},
			{ref = lower, span = lower.Size.Y + foot.Size.Y},
		}
		for _, p in ipairs({upper, lower, foot}) do
			p.Transparency = 1
			table.insert(KorbloxHidden, p)
		end
	else
		local leg = character:WaitForChild("Right Leg")
		chain = {{ref = leg, span = leg.Size.Y}}
		leg.Transparency = 1
		table.insert(KorbloxHidden, leg)
	end

	for _, c in ipairs(chain) do
		c.span *= CFG.LEG_LENGTH
	end

	local total = 0
	for _, c in ipairs(chain) do total += c.span end

	KorbloxModel = New("Model", {Name = "KorbloxLeg"}, character)

	local function addPart(ref, size, color, cf, ball)
		local p = New("Part", {
			Size = size, Color = color, Material = Enum.Material.SmoothPlastic,
			CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
			TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
		}, KorbloxModel)
		if ball then
			New("SpecialMesh", {MeshType = Enum.MeshType.Sphere}, p)
		else
			p.Shape = Enum.PartType.Cylinder
		end
		New("Weld", {Part0 = ref, Part1 = p, C0 = cf}, p)
	end

	local travelled = 0
	for _, c in ipairs(chain) do
		local n = math.max(2, math.ceil(c.span * CFG.SEG_DENSITY))
		local seg = c.span / n
		local top = c.ref.Size.Y / 2

		for j = 1, n do
			local offset = (j - 0.5) * seg
			local t = (travelled + offset) / total
			local thick = CFG.THICK_TIP + (CFG.THICK_TOP - CFG.THICK_TIP) * (1 - t) ^ 1.15
			local blend = math.clamp((t - CFG.BLUE_START) / (1 - CFG.BLUE_START), 0, 1)

			addPart(c.ref, Vector3.new(seg * 1.08, thick, thick), BLACK:Lerp(BLUE, blend),
				CFrame.new(0, top - offset, 0) * CFrame.Angles(0, 0, math.pi / 2))
		end
		travelled += c.span
	end

	addPart(chain[1].ref, Vector3.new(0.55, 0.55, 0.55), BLACK,
		CFrame.new(0, chain[1].ref.Size.Y / 2, 0), true)

	if chain[2] then
		addPart(chain[2].ref, Vector3.new(0.42, 0.42, 0.42), BLACK,
			CFrame.new(0, chain[2].ref.Size.Y / 2, 0), true)
	end
end

--==================================================
-- AURA
--==================================================

local AuraObjects = {}
local AuraEmitters = {}
local AuraTrail
local AuraConn
local ghostTimer = 0

local function ApplyAuraMode()
	local trailMode = AuraEnabled and not GuiOpen

	for _, e in ipairs(AuraEmitters) do
		if e and e.Parent then
			if trailMode then
				e.LockedToPart = false
				e.Rate = CFG.AuraRateClosed * CFG.AuraDensity
				e.Lifetime = NumberRange.new(1.4, 2.2)
				e.Speed = NumberRange.new(1, 3)
				e.Acceleration = Vector3.new(0, 1.5, 0)
			else
				e.LockedToPart = true
				e.Rate = CFG.AuraRateOpen * CFG.AuraDensity
				e.Lifetime = NumberRange.new(0.5, 0.9)
				e.Speed = NumberRange.new(2, 4)
				e.Acceleration = Vector3.new(0, 7, 0)
			end
		end
	end

	if AuraTrail then
		AuraTrail.Enabled = trailMode
	end
end

local function DestroyAura()
	if AuraConn then
		AuraConn:Disconnect()
		AuraConn = nil
	end
	for _, o in ipairs(AuraObjects) do
		if o then o:Destroy() end
	end
	AuraObjects = {}
	AuraEmitters = {}
	AuraTrail = nil
end

local function SpawnGhosts()
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Transparency < 1 then
			local g = New("Part", {
				Name = "ONESHOT_Ghost", Anchored = true, CanCollide = false, CanQuery = false,
				CanTouch = false, CastShadow = false, Size = obj.Size, CFrame = obj.CFrame,
				Material = Enum.Material.Neon, Color = CFG.AuraColor, Transparency = 0.35,
			}, workspace)

			tw(g, CFG.GhostLife, {Transparency = 1, Size = obj.Size * 1.25})
			Debris:AddItem(g, CFG.GhostLife + 0.1)
		end
	end
end

local function BuildAura()
	DestroyAura()
	if not character then GetCharacter() end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
			local e = New("ParticleEmitter", {
				Name = "ONESHOT_Aura",
				Texture = "rbxasset://textures/particles/fire_main.dds",
				Color = ColorSequence.new(CFG.AuraColor),
				LightEmission = 1, LightInfluence = 0,
				Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0)}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.2),
					NumberSequenceKeypoint.new(0.7, 0.5),
					NumberSequenceKeypoint.new(1, 1),
				}),
				Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-60, 60),
				SpreadAngle = Vector2.new(25, 25), EmissionDirection = Enum.NormalId.Top,
			}, obj)
			table.insert(AuraObjects, e)
			table.insert(AuraEmitters, e)
		end
	end

	local a0 = New("Attachment", {Name = "ONESHOT_T0", Position = Vector3.new(0, 1.4, 0)}, root)
	local a1 = New("Attachment", {Name = "ONESHOT_T1", Position = Vector3.new(0, -1.4, 0)}, root)

	AuraTrail = New("Trail", {
		Name = "ONESHOT_Trail", Attachment0 = a0, Attachment1 = a1,
		Color = ColorSequence.new(CFG.AuraColor), LightEmission = 1, Lifetime = 0.9,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)}),
		Enabled = false,
	}, root)

	local light = New("PointLight", {
		Name = "ONESHOT_AuraLight", Color = CFG.AuraColor, Range = 14, Brightness = 2,
	}, root)

	table.insert(AuraObjects, a0)
	table.insert(AuraObjects, a1)
	table.insert(AuraObjects, AuraTrail)
	table.insert(AuraObjects, light)

	ghostTimer = 0
	AuraConn = RunService.Heartbeat:Connect(function(dt)
		if not AuraEnabled or GuiOpen then return end
		ghostTimer += dt
		if ghostTimer < CFG.GhostInterval then return end
		ghostTimer = 0

		if not character or not root.Parent then return end
		if root.AssemblyLinearVelocity.Magnitude < CFG.GhostMinSpeed then return end
		SpawnGhosts()
	end)

	ApplyAuraMode()
end

--==================================================
-- HALO
--==================================================

local HaloModel, HaloConn

local function DestroyHalo()
	if HaloConn then
		HaloConn:Disconnect()
		HaloConn = nil
	end
	if HaloModel then
		HaloModel:Destroy()
		HaloModel = nil
	end
end

local function BuildHalo()
	DestroyHalo()
	local head = character and character:FindFirstChild("Head")
	if not head then return end

	local color = Color3.fromRGB(255, 235, 170)
	HaloModel = New("Model", {Name = "ONESHOT_Halo"}, character)

	local hub = New("Part", {
		Name = "HaloRoot", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1,
		CanCollide = false, CanQuery = false, CanTouch = false, Massless = true,
	}, HaloModel)
	local baseY = head.Size.Y / 2 + 0.75
	local w = New("Weld", {Part0 = head, Part1 = hub, C0 = CFrame.new(0, baseY, 0)}, hub)

	local N, R = 18, 1.05
	for i = 1, N do
		local a = (i / N) * math.pi * 2
		local bar = New("Part", {
			Name = "ONESHOT_HaloBar", Size = Vector3.new(0.4, 0.08, 0.13), Material = Enum.Material.Neon,
			Color = color, CanCollide = false, CanQuery = false, CanTouch = false, Massless = true, CastShadow = false,
		}, HaloModel)
		New("Weld", {Part0 = hub, Part1 = bar, C0 = CFrame.Angles(0, a, 0) * CFrame.new(0, 0, R)}, bar)
	end
	New("PointLight", {Color = color, Range = 10, Brightness = 1.5}, hub)

	local t = 0
	HaloConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		if w.Parent then
			w.C0 = CFrame.new(0, baseY + math.sin(t * 2) * 0.06, 0) * CFrame.Angles(0, t * 1.2, 0)
		end
	end)
end

--==================================================
-- ORBS
--==================================================

local OrbParts, OrbConn = {}, nil

local function DestroyOrbs()
	if OrbConn then
		OrbConn:Disconnect()
		OrbConn = nil
	end
	for _, o in ipairs(OrbParts) do
		if o then o:Destroy() end
	end
	OrbParts = {}
end

local function BuildOrbs()
	DestroyOrbs()
	local colors = {
		Color3.fromRGB(255, 200, 230), Color3.fromRGB(200, 230, 255), Color3.fromRGB(255, 245, 190),
	}

	for i = 1, 3 do
		local orb = New("Part", {
			Name = "ONESHOT_Orb", Shape = Enum.PartType.Ball, Size = Vector3.new(0.7, 0.7, 0.7),
			Material = Enum.Material.Neon, Color = colors[i], Anchored = true, CanCollide = false,
			CanQuery = false, CanTouch = false, CastShadow = false,
		}, workspace)
		local a0 = New("Attachment", {Position = Vector3.new(0, 0.3, 0)}, orb)
		local a1 = New("Attachment", {Position = Vector3.new(0, -0.3, 0)}, orb)
		New("Trail", {
			Attachment0 = a0, Attachment1 = a1, Color = ColorSequence.new(colors[i]),
			LightEmission = 1, Lifetime = 0.6,
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)}),
		}, orb)
		New("PointLight", {Color = colors[i], Range = 8, Brightness = 1.2}, orb)
		table.insert(OrbParts, orb)
	end

	local t = 0
	OrbConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for i, orb in ipairs(OrbParts) do
			local a = t * 1.6 + (i - 1) * (math.pi * 2 / 3)
			local y = 0.5 + math.sin(t * 2 + i) * 0.9
			orb.Position = root.Position + Vector3.new(math.cos(a) * 3.6, y, math.sin(a) * 3.6)
		end
	end)
end

--==================================================
-- FX HELPERS / RIPPLES / JUMP / CLICK
--==================================================

local function MakeFxPart(position, life)
	local p = New("Part", {
		Name = "ONESHOT_FX", Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
		CastShadow = false, Transparency = 1, Size = Vector3.new(1, 1, 1), Position = position,
	}, workspace)
	Debris:AddItem(p, life)
	return p
end

local function BurstSparkles(position, count, color)
	local p = MakeFxPart(position, 3)
	local e = New("ParticleEmitter", {
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new(color), LightEmission = 1, LightInfluence = 0,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0)}),
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
		Lifetime = NumberRange.new(0.6, 1.1), Speed = NumberRange.new(8, 16),
		SpreadAngle = Vector2.new(180, 180), Drag = 3, Acceleration = Vector3.new(0, -4, 0),
		Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-180, 180),
		Rate = 0, Enabled = false,
	}, p)
	e:Emit(count)
end

local function BurstDust(position, count)
	local p = MakeFxPart(position, 3)
	local e = New("ParticleEmitter", {
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(235, 235, 245)), LightEmission = 0.3,
		Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 2.8)}),
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}),
		Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(4, 8),
		EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(85, 85), Drag = 4,
		Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-60, 60),
		Rate = 0, Enabled = false,
	}, p)
	e:Emit(count)
end

local function Ring(cf, color, startSize, endSize, life, startTransparency)
	local r = New("Part", {
		Name = "ONESHOT_Ring", Shape = Enum.PartType.Cylinder, Anchored = true, CanCollide = false,
		CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.Neon,
		Color = color, Transparency = startTransparency or 0.2,
		Size = Vector3.new(0.12, startSize, startSize), CFrame = cf,
	}, workspace)

	tw(r, life, {Size = Vector3.new(0.05, endSize, endSize), Transparency = 1})
	Debris:AddItem(r, life + 0.1)
end

local function FloorPos(root)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -8, 0), params)
	if hit then
		return hit.Position + Vector3.new(0, 0.1, 0)
	end
	return root.Position - Vector3.new(0, 3, 0)
end

-- ripples under feet
local RippleConn
local rippleTimer = 0

local function SetRipples(on)
	if RippleConn then
		RippleConn:Disconnect()
		RippleConn = nil
	end
	if not on then return end

	RippleConn = RunService.Heartbeat:Connect(function(dt)
		rippleTimer += dt
		if rippleTimer < 0.32 then return end
		rippleTimer = 0

		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not humanoid then return end
		if humanoid.MoveDirection.Magnitude < 0.1 or humanoid.FloorMaterial == Enum.Material.Air then return end

		Ring(CFrame.new(FloorPos(root)) * CFrame.Angles(0, 0, math.pi / 2),
			CFG.AuraColor, 0.5, 4.5, 0.6, 0.55)
	end)
end

-- jump
local JumpConn

local function SetupJumpFX()
	if JumpConn then
		JumpConn:Disconnect()
		JumpConn = nil
	end
	if not humanoid then return end

	JumpConn = humanoid.StateChanged:Connect(function(_, new)
		if new ~= Enum.HumanoidStateType.Jumping or not JumpFXEnabled then return end
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local pos = FloorPos(root)
		BurstDust(pos, math.floor(CFG.JumpCount * 0.6))
		BurstSparkles(pos, CFG.JumpCount, Color3.fromRGB(255, 255, 255))
		Ring(CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), Color3.fromRGB(255, 255, 255), 1, 11, 0.55)
	end)
end

-- click on player
local function ClickFX(position)
	local cam = workspace.CurrentCamera
	BurstSparkles(position, CFG.ClickCount, CFG.ClickColor)
	Ring(CFrame.lookAt(position, cam.CFrame.Position) * CFrame.Angles(0, math.pi / 2, 0),
		CFG.ClickColor, 0.6, 5, 0.5)
end

--==================================================
-- SKY
--==================================================

local SkyIndex = 1
local SavedLighting, SavedSky, SavedAtmos
local OurSky, OurAtmos, SkySpin

local function RemoveSky()
	if SkySpin then
		SkySpin:Disconnect()
		SkySpin = nil
	end
	if OurSky then OurSky:Destroy() OurSky = nil end
	if OurAtmos then OurAtmos:Destroy() OurAtmos = nil end

	if SavedSky then SavedSky.Parent = Lighting SavedSky = nil end
	if SavedAtmos then SavedAtmos.Parent = Lighting SavedAtmos = nil end

	if SavedLighting then
		for k, v in pairs(SavedLighting) do
			Lighting[k] = v
		end
		SavedLighting = nil
	end
end

local function ApplySky()
	local cfg = CFG.Skies[SkyIndex]

	if not SavedLighting then
		SavedLighting = {
			ClockTime = Lighting.ClockTime,
			Brightness = Lighting.Brightness,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
		}
		for _, o in ipairs(Lighting:GetChildren()) do
			if o:IsA("Sky") and o.Name ~= "ONESHOT_Sky" and not SavedSky then
				SavedSky = o
			elseif o:IsA("Atmosphere") and o.Name ~= "ONESHOT_Atmosphere" and not SavedAtmos then
				SavedAtmos = o
			end
		end
		if SavedSky then SavedSky.Parent = nil end
		if SavedAtmos then SavedAtmos.Parent = nil end
	end

	if OurSky then OurSky:Destroy() end
	if OurAtmos then OurAtmos:Destroy() end

	OurSky = New("Sky", {Name = "ONESHOT_Sky", StarCount = cfg.stars})
	if cfg.box then
		for face, id in pairs(cfg.box) do
			if id ~= "" then
				OurSky["Skybox" .. face] = id
			end
		end
	end
	OurSky.Parent = Lighting

	OurAtmos = New("Atmosphere", {
		Name = "ONESHOT_Atmosphere", Color = cfg.atmos.color, Decay = cfg.atmos.decay,
		Density = cfg.atmos.density, Haze = cfg.atmos.haze, Glare = cfg.atmos.glare,
	}, Lighting)

	Lighting.ClockTime = cfg.clock
	Lighting.Brightness = cfg.brightness
	Lighting.Ambient = cfg.ambient
	Lighting.OutdoorAmbient = cfg.outdoor

	if not SkySpin then
		SkySpin = RunService.Heartbeat:Connect(function(dt)
			if OurSky then
				local o = OurSky.SkyboxOrientation
				OurSky.SkyboxOrientation = Vector3.new(0, (o.Y + CFG.SkySpinSpeed * dt) % 360, 0)
			end
		end)
	end
end

--==================================================
-- SHADERS
--==================================================

local ShaderObjects = {}

local function DisableShaders()
	for _, o in ipairs(ShaderObjects) do
		if o then o:Destroy() end
	end
	ShaderObjects = {}
end

local function EnableShaders()
	DisableShaders()

	local function add(inst)
		inst.Name = "ONESHOT_" .. inst.ClassName
		inst.Parent = Lighting
		table.insert(ShaderObjects, inst)
		return inst
	end

	add(New("BloomEffect", {Intensity = 0.6, Size = 28, Threshold = 0.9}))
	add(New("ColorCorrectionEffect", {
		Brightness = 0.02, Contrast = 0.12, Saturation = 0.18, TintColor = Color3.fromRGB(255, 245, 250),
	}))
	add(New("SunRaysEffect", {Intensity = 0.12, Spread = 0.8}))
	add(New("DepthOfFieldEffect", {FarIntensity = 0.15, NearIntensity = 0, FocusDistance = 30, InFocusRadius = 60}))
end

--==================================================
-- 4:3 STRETCH (безопасная версия)
--==================================================

local CleanCF
local StretchActive = false
local StretchCurrent = 1

RunService:BindToRenderStep("ONESHOT_StretchPre", Enum.RenderPriority.Camera.Value - 1, function()
	if StretchActive and CleanCF then
		workspace.CurrentCamera.CFrame = CleanCF
	end
end)

RunService:BindToRenderStep("ONESHOT_StretchPost", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local cam = workspace.CurrentCamera
	-- растяжение действует только когда панель закрыта
	local target = (StretchEnabled and not GuiOpen) and CFG.StretchY or 1
	StretchCurrent += (target - StretchCurrent) * math.min(1, dt * 10)
	if math.abs(target - StretchCurrent) < 0.002 then
		StretchCurrent = target
	end

	if StretchCurrent ~= 1 then
		CleanCF = cam.CFrame
		cam.CFrame = CleanCF * CFrame.new(0, 0, 0, 1, 0, 0, 0, StretchCurrent, 0, 0, 0, 1)
		StretchActive = true
	else
		StretchActive = false
	end
end)

--==================================================
-- GLOSS
--==================================================

local GlossOriginal = setmetatable({}, {__mode = "k"})
local GlossConn
local SavedSpecular
local GlossToken = 0

local GLOSS_MULT = {
	[Enum.Material.Metal] = 1.6, [Enum.Material.DiamondPlate] = 1.6, [Enum.Material.CorrodedMetal] = 1.1,
	[Enum.Material.Foil] = 1.8, [Enum.Material.Glass] = 1.3, [Enum.Material.Ice] = 1.3,
	[Enum.Material.Glacier] = 1.2, [Enum.Material.Marble] = 1.5, [Enum.Material.Granite] = 1.3,
	[Enum.Material.Slate] = 1.1, [Enum.Material.Basalt] = 1.0, [Enum.Material.Limestone] = 0.9,
	[Enum.Material.Concrete] = 1.0, [Enum.Material.Pavement] = 1.0, [Enum.Material.Asphalt] = 1.0,
	[Enum.Material.SmoothPlastic] = 1.2, [Enum.Material.Plastic] = 1.0, [Enum.Material.Brick] = 0.9,
	[Enum.Material.Cobblestone] = 0.9, [Enum.Material.Pebble] = 0.8, [Enum.Material.Rock] = 0.7,
	[Enum.Material.Wood] = 0.5, [Enum.Material.WoodPlanks] = 0.5, [Enum.Material.Fabric] = 0.15,
	[Enum.Material.Grass] = 0.1, [Enum.Material.LeafyGrass] = 0.1, [Enum.Material.Sand] = 0.1,
	[Enum.Material.Snow] = 0.2, [Enum.Material.Mud] = 0.2, [Enum.Material.Ground] = 0.1,
	[Enum.Material.Sandstone] = 0.4, [Enum.Material.Salt] = 0.5,
}

local function IsCharacterPart(p)
	local m = p:FindFirstAncestorOfClass("Model")
	return m ~= nil and m:FindFirstChildOfClass("Humanoid") ~= nil
end

local function GlossPart(p)
	if not p:IsA("BasePart") or p:IsA("Terrain") then return end
	if p.Material == Enum.Material.Neon or string.sub(p.Name, 1, 8) == "ONESHOT_" then return end
	if IsCharacterPart(p) then return end

	if GlossOriginal[p] == nil then
		GlossOriginal[p] = p.Reflectance
	end
	local mult = GLOSS_MULT[p.Material] or 0.8
	p.Reflectance = math.clamp(math.max(GlossOriginal[p], CFG.GlossAmount * mult), 0, 0.9)
end

local function GlossRefresh()
	GlossToken += 1
	local token = GlossToken
	task.spawn(function()
		local n = 0
		for _, d in ipairs(workspace:GetDescendants()) do
			if token ~= GlossToken then return end
			GlossPart(d)
			n += 1
			if n % 400 == 0 then task.wait() end
		end
	end)
end

local function EnableGloss()
	if SavedSpecular == nil then
		SavedSpecular = Lighting.EnvironmentSpecularScale
	end
	Lighting.EnvironmentSpecularScale = 1

	if not Lighting:FindFirstChild("ONESHOT_GlossBloom") then
		New("BloomEffect", {Name = "ONESHOT_GlossBloom", Intensity = 0.35, Size = 24, Threshold = 0.85}, Lighting)
	end

	GlossRefresh()

	if GlossConn then GlossConn:Disconnect() end
	GlossConn = workspace.DescendantAdded:Connect(function(d)
		if GlossEnabled then
			task.defer(GlossPart, d)
		end
	end)
end

local function DisableGloss()
	GlossToken += 1
	if GlossConn then
		GlossConn:Disconnect()
		GlossConn = nil
	end
	for p, orig in pairs(GlossOriginal) do
		if p.Parent then p.Reflectance = orig end
	end
	local b = Lighting:FindFirstChild("ONESHOT_GlossBloom")
	if b then b:Destroy() end
	if SavedSpecular ~= nil then
		Lighting.EnvironmentSpecularScale = SavedSpecular
		SavedSpecular = nil
	end
end

--==================================================
-- FIREFLIES / STARFALL (world particles)
--==================================================

local FireflyPart, FireflyEmitter, FireflyConn
local StarPart, StarEmitter, StarConn

local function DestroyFireflies()
	if FireflyConn then FireflyConn:Disconnect() FireflyConn = nil end
	if FireflyPart then FireflyPart:Destroy() FireflyPart = nil end
	FireflyEmitter = nil
end

local function BuildFireflies()
	DestroyFireflies()

	FireflyPart = New("Part", {
		Name = "ONESHOT_FireflyZone", Size = Vector3.new(80, 18, 80), Anchored = true, CanCollide = false,
		CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1,
	}, workspace)

	FireflyEmitter = New("ParticleEmitter", {
		Name = "Fireflies",
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new(Color3.fromRGB(200, 255, 130), Color3.fromRGB(255, 235, 140)),
		LightEmission = 1, LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 0.45), NumberSequenceKeypoint.new(1, 0),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(0.35, 0.6), NumberSequenceKeypoint.new(0.55, 0.1),
			NumberSequenceKeypoint.new(0.8, 0.5), NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(6, 10), Rate = CFG.FireflyRate, Speed = NumberRange.new(0.4, 1.4),
		SpreadAngle = Vector2.new(180, 180), Drag = 0.6, Acceleration = Vector3.new(0, 0.15, 0),
		Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-40, 40), LockedToPart = false,
		Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
	}, FireflyPart)

	FireflyConn = RunService.Heartbeat:Connect(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and FireflyPart then
			FireflyPart.Position = root.Position + Vector3.new(0, 4, 0)
		end
	end)
end

local function DestroyStarfall()
	if StarConn then StarConn:Disconnect() StarConn = nil end
	if StarPart then StarPart:Destroy() StarPart = nil end
	StarEmitter = nil
end

local function BuildStarfall()
	DestroyStarfall()

	StarPart = New("Part", {
		Name = "ONESHOT_StarfallZone", Size = Vector3.new(70, 1, 70), Anchored = true, CanCollide = false,
		CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1,
	}, workspace)

	StarEmitter = New("ParticleEmitter", {
		Name = "Starfall",
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 230)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 215, 255)),
		}),
		LightEmission = 1, LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 0.6), NumberSequenceKeypoint.new(1, 0.1),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.2),
			NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(8, 11), Rate = CFG.StarfallRate, Speed = NumberRange.new(2, 4),
		EmissionDirection = Enum.NormalId.Bottom, SpreadAngle = Vector2.new(8, 8),
		Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-90, 90), LockedToPart = false,
		Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
	}, StarPart)

	StarConn = RunService.Heartbeat:Connect(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and StarPart then
			StarPart.Position = root.Position + Vector3.new(0, 30, 0)
		end
	end)
end

--==================================================
-- DAY CYCLE
--==================================================

local TimeConn, SavedClock

local function SetTimeCycle(on)
	if TimeConn then
		TimeConn:Disconnect()
		TimeConn = nil
	end
	if on then
		if SavedClock == nil then SavedClock = Lighting.ClockTime end
		TimeConn = RunService.Heartbeat:Connect(function(dt)
			Lighting.ClockTime = (Lighting.ClockTime + dt * CFG.DaySpeed) % 24
		end)
	elseif SavedClock ~= nil then
		Lighting.ClockTime = SavedClock
		SavedClock = nil
	end
end

--==================================================
-- FOV
--==================================================

local FovOrig, FovCurrent
local ZoomHeld = false

RunService:BindToRenderStep("ONESHOT_Fov", Enum.RenderPriority.Camera.Value + 2, function(dt)
	local cam = workspace.CurrentCamera
	if FovEnabled then
		if not FovOrig then
			FovOrig = cam.FieldOfView
			FovCurrent = cam.FieldOfView
		end
		local target = CFG.FOV
		if SpeedFovEnabled then
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				target += CFG.FovBoost * math.clamp(root.AssemblyLinearVelocity.Magnitude / 40, 0, 1)
			end
		end
		if ZoomHeld then target = CFG.ZoomFov end
		FovCurrent += (target - FovCurrent) * math.min(1, dt * 9)
		cam.FieldOfView = FovCurrent
	elseif FovOrig then
		FovCurrent += (FovOrig - FovCurrent) * math.min(1, dt * 9)
		cam.FieldOfView = FovCurrent
		if math.abs(FovCurrent - FovOrig) < 0.05 then
			cam.FieldOfView = FovOrig
			FovOrig = nil
		end
	end
end)

--==================================================
-- SPACE: helpers
--==================================================

local function SpacePart(props, parent)
	local base = {
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
		CastShadow = false, Material = Enum.Material.Neon,
		TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
	}
	for k, v in pairs(props) do base[k] = v end
	return New("Part", base, parent)
end

-- кольцо из сегментов, приваренных к якорной части root (двигаем только root)
local function MakeRing(root, R, width, count, color, transparency)
	local segLen = 2 * math.pi * R / count * 1.08
	for i = 1, count do
		local a = (i / count) * math.pi * 2
		local seg = New("Part", {
			Size = Vector3.new(segLen, math.max(R * 0.006, 0.08), width),
			Material = Enum.Material.Neon, Color = color, Transparency = transparency,
			CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Massless = true,
			TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
		}, root.Parent)
		New("Weld", {Part0 = root, Part1 = seg, C0 = CFrame.Angles(0, a, 0) * CFrame.new(0, 0, R)}, seg)
	end
end

-- звезда (гексаграмма) из двух треугольников
local function MakeStar(root, R, color)
	for k = 0, 1 do
		for j = 0, 2 do
			local a = k * math.pi / 3 + j * 2 * math.pi / 3
			local b = a + 2 * math.pi / 3
			local va = Vector3.new(math.sin(a) * R, 0.02, math.cos(a) * R)
			local vb = Vector3.new(math.sin(b) * R, 0.02, math.cos(b) * R)
			local seg = New("Part", {
				Size = Vector3.new(0.1, 0.05, (vb - va).Magnitude), Material = Enum.Material.Neon,
				Color = color, Transparency = 0.15, CanCollide = false, CanQuery = false,
				CanTouch = false, CastShadow = false, Massless = true,
			}, root.Parent)
			New("Weld", {Part0 = root, Part1 = seg, C0 = CFrame.lookAt((va + vb) / 2, vb)}, seg)
		end
	end
end

--==================================================
-- SPACE: NEBULA (огромные цветные облака в небе)
--==================================================

local NebulaPart, NebulaConn

local function DestroyNebula()
	if NebulaConn then NebulaConn:Disconnect() NebulaConn = nil end
	if NebulaPart then NebulaPart:Destroy() NebulaPart = nil end
end

local function BuildNebula()
	DestroyNebula()

	NebulaPart = New("Part", {
		Name = "ONESHOT_Nebula", Size = Vector3.new(500, 60, 500), Anchored = true, CanCollide = false,
		CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1,
	}, workspace)

	local palette = {
		Color3.fromRGB(255, 80, 200), Color3.fromRGB(110, 90, 255), Color3.fromRGB(60, 200, 255),
	}
	for i, c in ipairs(palette) do
		local e = New("ParticleEmitter", {
			Name = "Cloud" .. i,
			Texture = "rbxasset://textures/particles/smoke_main.dds",
			Color = ColorSequence.new(c), LightEmission = 1, LightInfluence = 0,
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 70), NumberSequenceKeypoint.new(0.5, 120), NumberSequenceKeypoint.new(1, 90),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.82),
				NumberSequenceKeypoint.new(0.8, 0.86), NumberSequenceKeypoint.new(1, 1),
			}),
			Lifetime = NumberRange.new(14, 20), Rate = CFG.NebulaRate, Speed = NumberRange.new(1, 3),
			SpreadAngle = Vector2.new(180, 180), Drag = 0.2,
			Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-4, 4), LockedToPart = false,
			Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
		}, NebulaPart)
		e:Emit(10)
	end

	NebulaConn = RunService.Heartbeat:Connect(function()
		if NebulaPart then
			NebulaPart.Position = workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 140, 0)
		end
	end)
end

--==================================================
-- SPACE: PLANETS
--==================================================

local PlanetFolder, PlanetConn

local function DestroyPlanets()
	if PlanetConn then PlanetConn:Disconnect() PlanetConn = nil end
	if PlanetFolder then PlanetFolder:Destroy() PlanetFolder = nil end
end

local function BuildPlanets()
	DestroyPlanets()
	PlanetFolder = New("Folder", {Name = "ONESHOT_Planets"}, workspace)

	local defs = {
		{dir = Vector3.new(0.75, 0.32, -0.58), size = 380, color = Color3.fromRGB(235, 150, 80), rings = true,
			ringA = Color3.fromRGB(255, 225, 170), ringB = Color3.fromRGB(190, 140, 100)},
		{dir = Vector3.new(-0.85, 0.22, -0.35), size = 230, color = Color3.fromRGB(70, 150, 235)},
		{dir = Vector3.new(0.15, 0.55, 0.8), size = 160, color = Color3.fromRGB(220, 70, 90)},
		{dir = Vector3.new(-0.35, 0.88, 0.25), size = 95, color = Color3.fromRGB(205, 205, 225)},
	}

	local list = {}
	for _, d in ipairs(defs) do
		local core = SpacePart({
			Name = "ONESHOT_PlanetCore", Shape = Enum.PartType.Ball,
			Size = Vector3.one * d.size, Color = d.color:Lerp(Color3.new(0, 0, 0), 0.3),
		}, PlanetFolder)
		local halo = SpacePart({
			Name = "ONESHOT_PlanetHalo", Shape = Enum.PartType.Ball,
			Size = Vector3.one * d.size * 1.1, Color = d.color:Lerp(WHITE, 0.35), Transparency = 0.82,
		}, PlanetFolder)

		local ringRoot
		if d.rings then
			ringRoot = SpacePart({Name = "ONESHOT_PlanetRing", Size = Vector3.one, Transparency = 1}, PlanetFolder)
			MakeRing(ringRoot, d.size * 0.74, d.size * 0.07, 72, d.ringA, 0.25)
			MakeRing(ringRoot, d.size * 0.9, d.size * 0.1, 80, d.ringB, 0.45)
			MakeRing(ringRoot, d.size * 1.02, d.size * 0.03, 90, d.ringA, 0.5)
		end

		table.insert(list, {core = core, halo = halo, ring = ringRoot, dir = d.dir.Unit})
	end

	local t = 0
	PlanetConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local cp = workspace.CurrentCamera.CFrame.Position
		local sway = CFrame.Angles(0, t * 0.004, 0)
		for _, p in ipairs(list) do
			local cf = CFrame.new(cp + sway:VectorToWorldSpace(p.dir) * CFG.PlanetDistance)
			p.core.CFrame = cf
			p.halo.CFrame = cf
			if p.ring then
				p.ring.CFrame = cf * CFrame.Angles(0.42, 0, 0.3) * CFrame.Angles(0, t * 0.03, 0)
			end
		end
	end)
end

--==================================================
-- SPACE: BLACK HOLE
--==================================================

local BHFolder, BHConn

local function DestroyBlackHole()
	if BHConn then BHConn:Disconnect() BHConn = nil end
	if BHFolder then BHFolder:Destroy() BHFolder = nil end
end

local function BuildBlackHole()
	DestroyBlackHole()
	BHFolder = New("Folder", {Name = "ONESHOT_BlackHole"}, workspace)

	local S = 150
	local core = SpacePart({
		Name = "ONESHOT_BHCore", Shape = Enum.PartType.Ball, Size = Vector3.one * S,
		Color = Color3.new(0, 0, 0), Material = Enum.Material.SmoothPlastic,
	}, BHFolder)
	local halo = SpacePart({
		Name = "ONESHOT_BHHalo", Shape = Enum.PartType.Ball, Size = Vector3.one * S * 1.35,
		Color = Color3.fromRGB(255, 140, 50), Transparency = 0.88,
	}, BHFolder)

	local ringRoot = SpacePart({Name = "ONESHOT_BHRing", Size = Vector3.one, Transparency = 1}, BHFolder)
	MakeRing(ringRoot, S * 0.7, S * 0.07, 64, Color3.fromRGB(255, 240, 220), 0.1)
	MakeRing(ringRoot, S * 0.9, S * 0.15, 72, Color3.fromRGB(255, 150, 50), 0.2)
	MakeRing(ringRoot, S * 1.2, S * 0.2, 84, Color3.fromRGB(255, 80, 40), 0.45)

	local dir = Vector3.new(0.25, 0.42, -0.87).Unit
	local t = 0
	BHConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local cp = workspace.CurrentCamera.CFrame.Position
		local cf = CFrame.new(cp + dir * CFG.PlanetDistance * 0.85)
		core.CFrame = cf
		halo.CFrame = cf
		ringRoot.CFrame = cf * CFrame.Angles(1.15, 0, 0.2) * CFrame.Angles(0, t * 0.6, 0)
	end)
end

--==================================================
-- SPACE: METEOR SHOWER
--==================================================

local MeteorToken = 0
local METEOR_COLORS = {
	Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 220, 255),
	Color3.fromRGB(255, 160, 220), Color3.fromRGB(255, 220, 130),
}

local function SpawnMeteor()
	local cp = workspace.CurrentCamera.CFrame.Position
	local ang = math.random() * math.pi * 2
	local start = cp + Vector3.new(math.cos(ang) * 350, 140 + math.random() * 180, math.sin(ang) * 350)
	local drift = ang + math.pi + (math.random() - 0.5) * 1.2
	local dir = Vector3.new(math.cos(drift), -0.3 - math.random() * 0.2, math.sin(drift)).Unit
	local finish = start + dir * (450 + math.random() * 350)
	local color = METEOR_COLORS[math.random(1, #METEOR_COLORS)]

	local m = SpacePart({
		Name = "ONESHOT_Meteor", Shape = Enum.PartType.Ball, Size = Vector3.new(3, 3, 3),
		Color = color, CFrame = CFrame.lookAt(start, finish),
	}, workspace)
	local a0 = New("Attachment", {Position = Vector3.new(0, 1.5, 0)}, m)
	local a1 = New("Attachment", {Position = Vector3.new(0, -1.5, 0)}, m)
	New("Trail", {
		Attachment0 = a0, Attachment1 = a1,
		Color = ColorSequence.new(color, Color3.fromRGB(120, 120, 255)),
		LightEmission = 1, Lifetime = 1.3,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
		WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
	}, m)

	local life = 1.8 + math.random() * 0.8
	tw(m, life, {CFrame = CFrame.lookAt(finish, finish + dir)}, Enum.EasingStyle.Linear)
	Debris:AddItem(m, life + 1.5)
end

local function SetMeteors(on)
	MeteorToken += 1
	if not on then return end
	local token = MeteorToken
	task.spawn(function()
		while token == MeteorToken do
			SpawnMeteor()
			task.wait(CFG.MeteorInterval * (0.4 + math.random() * 1.2))
		end
	end)
end

--==================================================
-- SPACE: COSMIC DUST
--==================================================

local DustPart, DustEmitter, DustConn

local function DestroyDust()
	if DustConn then DustConn:Disconnect() DustConn = nil end
	if DustPart then DustPart:Destroy() DustPart = nil end
	DustEmitter = nil
end

local function BuildDust()
	DestroyDust()

	DustPart = New("Part", {
		Name = "ONESHOT_DustZone", Size = Vector3.new(70, 30, 70), Anchored = true, CanCollide = false,
		CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1,
	}, workspace)

	DustEmitter = New("ParticleEmitter", {
		Name = "CosmicDust",
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 210)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(110, 220, 255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(170, 120, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 225, 130)),
		}),
		LightEmission = 1, LightInfluence = 0,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.5, 0.5), NumberSequenceKeypoint.new(1, 0),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.15), NumberSequenceKeypoint.new(1, 1),
		}),
		Lifetime = NumberRange.new(5, 9), Rate = CFG.DustRate, Speed = NumberRange.new(0.5, 2),
		SpreadAngle = Vector2.new(180, 180), Drag = 0.4, Acceleration = Vector3.new(0, 0.3, 0),
		Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-80, 80), LockedToPart = false,
		Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume,
	}, DustPart)

	DustConn = RunService.Heartbeat:Connect(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and DustPart then
			DustPart.Position = root.Position + Vector3.new(0, 6, 0)
		end
	end)
end

--==================================================
-- SPACE: AURORA
--==================================================

local AuroraPart, AuroraConn

local function DestroyAurora()
	if AuroraConn then AuroraConn:Disconnect() AuroraConn = nil end
	if AuroraPart then AuroraPart:Destroy() AuroraPart = nil end
end

local function BuildAurora()
	DestroyAurora()

	AuroraPart = SpacePart({Name = "ONESHOT_Aurora", Size = Vector3.one, Transparency = 1}, workspace)

	local defs = {
		{z = 0, y = 0, c0 = Color3.fromRGB(80, 255, 170), c1 = Color3.fromRGB(70, 160, 255), w = 70},
		{z = -60, y = 40, c0 = Color3.fromRGB(150, 90, 255), c1 = Color3.fromRGB(80, 255, 200), w = 55},
		{z = 60, y = -20, c0 = Color3.fromRGB(255, 110, 200), c1 = Color3.fromRGB(110, 140, 255), w = 45},
	}

	local beams = {}
	for _, d in ipairs(defs) do
		local a0 = New("Attachment", {Position = Vector3.new(-450, d.y, d.z)}, AuroraPart)
		local a1 = New("Attachment", {Position = Vector3.new(450, d.y + 20, d.z)}, AuroraPart)
		local b = New("Beam", {
			Attachment0 = a0, Attachment1 = a1, Color = ColorSequence.new(d.c0, d.c1),
			LightEmission = 1, LightInfluence = 0, FaceCamera = true, Segments = 40,
			Width0 = d.w, Width1 = d.w, CurveSize0 = 80, CurveSize1 = -80,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.55),
				NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(0.8, 0.55),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}, AuroraPart)
		table.insert(beams, {beam = b, w = d.w})
	end

	local t = 0
	AuroraConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		AuroraPart.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 260, -300))
		for i, b in ipairs(beams) do
			b.beam.CurveSize0 = 90 * math.sin(t * 0.4 + i)
			b.beam.CurveSize1 = -90 * math.sin(t * 0.3 + i * 2)
			local w = b.w * (1 + 0.3 * math.sin(t * 0.5 + i))
			b.beam.Width0 = w
			b.beam.Width1 = w
		end
	end)
end

--==================================================
-- BODY: MAGIC CIRCLE / COMET TRAIL / RAINBOW / GRAVITY
--==================================================

local MagicFolder, MagicConn

local function DestroyMagic()
	if MagicConn then MagicConn:Disconnect() MagicConn = nil end
	if MagicFolder then MagicFolder:Destroy() MagicFolder = nil end
end

local function BuildMagic()
	DestroyMagic()
	MagicFolder = New("Folder", {Name = "ONESHOT_MagicCircle"}, workspace)

	local outer = SpacePart({Name = "ONESHOT_MCOuter", Size = Vector3.one, Transparency = 1}, MagicFolder)
	local inner = SpacePart({Name = "ONESHOT_MCInner", Size = Vector3.one, Transparency = 1}, MagicFolder)

	MakeRing(outer, 3.6, 0.22, 48, Color3.fromRGB(120, 220, 255), 0.15)
	MakeRing(outer, 3.0, 0.08, 44, Color3.fromRGB(235, 225, 255), 0.3)
	MakeStar(outer, 2.9, Color3.fromRGB(190, 160, 255))
	MakeRing(inner, 1.7, 0.16, 32, Color3.fromRGB(255, 140, 200), 0.1)
	MakeStar(inner, 1.6, Color3.fromRGB(255, 200, 235))

	local t = 0
	MagicConn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local fp = FloorPos(root) + Vector3.new(0, 0.12, 0)
		outer.CFrame = CFrame.new(fp) * CFrame.Angles(0, t * 0.7, 0)
		inner.CFrame = CFrame.new(fp + Vector3.new(0, 0.02, 0)) * CFrame.Angles(0, -t * 1.1, 0)
	end)
end

local CometObjs, CometConn = {}, nil

local function DestroyComet()
	if CometConn then CometConn:Disconnect() CometConn = nil end
	for _, o in ipairs(CometObjs) do
		if o then o:Destroy() end
	end
	CometObjs = {}
end

local function BuildComet()
	DestroyComet()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local a0 = New("Attachment", {Name = "ONESHOT_CT0", Position = Vector3.new(0, 1.5, 0)}, root)
	local a1 = New("Attachment", {Name = "ONESHOT_CT1", Position = Vector3.new(0, -1.5, 0)}, root)
	local trail = New("Trail", {
		Name = "ONESHOT_CometTrail", Attachment0 = a0, Attachment1 = a1, LightEmission = 1, Lifetime = 1.4,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)}),
		WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2)}),
	}, root)
	CometObjs = {a0, a1, trail}

	CometConn = RunService.Heartbeat:Connect(function()
		local h = (os.clock() * 0.2) % 1
		trail.Color = ColorSequence.new(Color3.fromHSV(h, 0.7, 1), Color3.fromHSV((h + 0.18) % 1, 0.8, 1))
	end)
end

local RainbowConn

local function SetRainbowGlow(on)
	if RainbowConn then RainbowConn:Disconnect() RainbowConn = nil end
	if not on then
		if SelfGlow then
			SelfGlow.FillColor = CFG.GlowFillColor
			SelfGlow.OutlineColor = CFG.GlowOutlineColor
		end
		return
	end
	RainbowConn = RunService.Heartbeat:Connect(function()
		if SelfGlow then
			local h = (os.clock() * 0.15) % 1
			SelfGlow.FillColor = Color3.fromHSV(h, 0.75, 1)
			SelfGlow.OutlineColor = Color3.fromHSV((h + 0.08) % 1, 0.55, 1)
		end
	end)
end

local SavedGravity
local function SetLowGravity(on)
	if on then
		SavedGravity = SavedGravity or workspace.Gravity
		workspace.Gravity = SavedGravity * CFG.GravityScale
	elseif SavedGravity then
		workspace.Gravity = SavedGravity
		SavedGravity = nil
	end
end

--==================================================
-- GRAPHICS: 4K / ULTRA HD
-- Roblox не даёт скрипту менять реальное разрешение экрана, поэтому
-- режимы HD / Ultra HD / 4K выставляют максимум качества рендера,
-- будущее освещение, мягкие тени и "чёткий" цветокор.
--==================================================

local RES_NAMES = {"Native", "HD", "Ultra HD", "4K"}
local RES_BADGE = {"", "HD", "ULTRA HD", "4K ULTRA HD"}
local ResMode = 0
local GfxSaved
local GfxObjects = {}
local ResBadge, ResButton

local function UpdateResUI()
	if ResButton then ResButton.Text = "Resolution: " .. RES_NAMES[ResMode + 1] end
	if ResBadge then ResBadge.Text = RES_BADGE[ResMode + 1] end
end

local function ApplyGraphics(mode)
	ResMode = mode

	for _, o in ipairs(GfxObjects) do
		if o then o:Destroy() end
	end
	GfxObjects = {}

	if not GfxSaved then
		GfxSaved = {}
		pcall(function() GfxSaved.Quality = settings().Rendering.QualityLevel end)
		pcall(function() GfxSaved.MeshDetail = settings().Rendering.MeshPartDetailLevel end)
		pcall(function() GfxSaved.Shadows = Lighting.GlobalShadows end)
		pcall(function() GfxSaved.Diffuse = Lighting.EnvironmentDiffuseScale end)
		pcall(function() GfxSaved.Spec = Lighting.EnvironmentSpecularScale end)
		pcall(function() GfxSaved.Exposure = Lighting.ExposureCompensation end)
		pcall(function() if gethiddenproperty then GfxSaved.Tech = gethiddenproperty(Lighting, "Technology") end end)
	end

	if mode == 0 then
		pcall(function() if GfxSaved.Quality then settings().Rendering.QualityLevel = GfxSaved.Quality end end)
		pcall(function() if GfxSaved.MeshDetail then settings().Rendering.MeshPartDetailLevel = GfxSaved.MeshDetail end end)
		pcall(function() if GfxSaved.Shadows ~= nil then Lighting.GlobalShadows = GfxSaved.Shadows end end)
		pcall(function() if GfxSaved.Diffuse then Lighting.EnvironmentDiffuseScale = GfxSaved.Diffuse end end)
		pcall(function() if GfxSaved.Spec then Lighting.EnvironmentSpecularScale = GfxSaved.Spec end end)
		pcall(function() if GfxSaved.Exposure then Lighting.ExposureCompensation = GfxSaved.Exposure end end)
		if GfxSaved.Tech then SetHidden(Lighting, "Technology", GfxSaved.Tech) end
		UpdateResUI()
		return
	end

	local levels = {10, 17, 21}
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel[string.format("Level%02d", levels[mode])]
	end)
	if mode >= 2 then
		pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 end)
	end

	pcall(function()
		Lighting.GlobalShadows = true
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
	end)

	if mode >= 2 then
		SetHidden(Lighting, "Technology", Enum.Technology.Future)
	end

	local function gadd(inst)
		inst.Parent = Lighting
		table.insert(GfxObjects, inst)
	end

	if mode >= 2 then
		gadd(New("BloomEffect", {
			Name = "ONESHOT_GfxBloom", Intensity = mode == 3 and 0.45 or 0.3, Size = 22, Threshold = 0.92,
		}))
		gadd(New("ColorCorrectionEffect", {
			Name = "ONESHOT_GfxCC", Contrast = mode == 3 and 0.16 or 0.1,
			Saturation = mode == 3 and 0.28 or 0.14, Brightness = 0.01,
		}))
	end
	if mode == 3 then
		gadd(New("SunRaysEffect", {Name = "ONESHOT_GfxRays", Intensity = 0.1, Spread = 0.9}))
		pcall(function() workspace.Terrain.Decoration = true end)
	end

	UpdateResUI()
end

-- Lighting-эффекты по переключателю
local function LightingFx(name, class, props)
	local inst
	return function(on)
		if inst then inst:Destroy() inst = nil end
		if on then
			props.Name = "ONESHOT_" .. name
			inst = New(class, props, Lighting)
		end
	end
end

local SetGrade = LightingFx("Grade", "ColorCorrectionEffect", {
	TintColor = Color3.fromRGB(255, 232, 210), Contrast = 0.16, Saturation = 0.3, Brightness = 0.01,
})
local SetHDR = LightingFx("HDRBloom", "BloomEffect", {Intensity = 1.1, Size = 40, Threshold = 0.75})
local SetFlare = LightingFx("LensFlare", "SunRaysEffect", {Intensity = 0.28, Spread = 1})

-- water
local WaterSaved
local function SetWater(on)
	local t = workspace.Terrain
	pcall(function()
		if on then
			if not WaterSaved then
				WaterSaved = {t.WaterReflectance, t.WaterTransparency, t.WaterWaveSize}
			end
			t.WaterReflectance = 1
			t.WaterTransparency = 0.8
			t.WaterWaveSize = 0.35
		elseif WaterSaved then
			t.WaterReflectance, t.WaterTransparency, t.WaterWaveSize = WaterSaved[1], WaterSaved[2], WaterSaved[3]
			WaterSaved = nil
		end
	end)
end

-- shadows
local ShadowSaved
local function SetShadows(on)
	pcall(function()
		if on then
			if not ShadowSaved then ShadowSaved = {Lighting.ShadowSoftness, Lighting.GlobalShadows} end
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.05
		elseif ShadowSaved then
			Lighting.ShadowSoftness = ShadowSaved[1]
			Lighting.GlobalShadows = ShadowSaved[2]
			ShadowSaved = nil
		end
	end)
end

-- cinematic bars (только когда меню закрыто)
local BarsGui, BarTop, BarBottom
local function UpdateBars()
	local on = BarsEnabled and not GuiOpen
	if not BarsGui then
		BarsGui = New("ScreenGui", {
			Name = "ONESHOT_Bars", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = -1,
		}, player.PlayerGui)
		BarTop = New("Frame", {
			Size = UDim2.new(1, 0, 0.11, 0), Position = UDim2.new(0, 0, -0.11, 0),
			BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
		}, BarsGui)
		BarBottom = New("Frame", {
			Size = UDim2.new(1, 0, 0.11, 0), Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
		}, BarsGui)
	end
	tw(BarTop, 0.6, {Position = on and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 0, -0.11, 0)}, Enum.EasingStyle.Quint)
	tw(BarBottom, 0.6, {Position = on and UDim2.new(0, 0, 0.89, 0) or UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Quint)
end

-- glass blur: размытие мира за меню (меню остаётся в фокусе)
local GlassDof
local function UpdateGlassDof()
	if not GlassDof then
		GlassDof = New("DepthOfFieldEffect", {
			Name = "ONESHOT_GlassDoF", FarIntensity = 0.85, NearIntensity = 0,
			FocusDistance = CFG.PanelDistance, InFocusRadius = 14, Enabled = false,
		}, Lighting)
	end
	GlassDof.FocusDistance = CFG.PanelDistance
	GlassDof.Enabled = GlassBlurEnabled and GuiOpen
end

-- motion blur
local MotionBlur, LastLook
RunService:BindToRenderStep("ONESHOT_MotionBlur", Enum.RenderPriority.Camera.Value + 3, function(dt)
	if not MotionBlurEnabled then
		if MotionBlur then
			MotionBlur.Size = MotionBlur.Size > 0.05 and MotionBlur.Size * 0.8 or 0
		end
		return
	end
	if not MotionBlur then
		MotionBlur = New("BlurEffect", {Name = "ONESHOT_MotionBlur", Size = 0}, Lighting)
	end

	local look = workspace.CurrentCamera.CFrame.LookVector
	LastLook = LastLook or look
	local ang = math.acos(math.clamp(look:Dot(LastLook), -1, 1))
	LastLook = look

	local speed = ang / math.max(dt, 1e-3)
	local target = GuiOpen and 0 or math.clamp(speed * CFG.MotionBlurAmount * 1.2, 0, 22)
	MotionBlur.Size += (target - MotionBlur.Size) * math.min(1, dt * 12)
end)

--==================================================
-- CATALOG (бесплатные вещи, только визуально на мне)
--==================================================

local CAT = {
	Types = {{"Accessories", 11}, {"Clothing", 3}, {"All", 1}},
	Keywords = {"", "hat", "hair", "wings", "mask", "crown", "glasses", "cat", "horns", "halo", "cape", "jacket", "pants"},
	TypeIndex = 1,
	KwIndex = 1,
	Items = {},
	Cursor = nil,
	Page = 1,
	Loading = false,
	Status = "",
	PendingNext = false,
}
local PER_PAGE = 8

local Worn = {}          -- [id] = {kind = "...", cleanup = function}
local WornOrder = {}
local AssetCache = {}

local CatGrid, CatStatus, CatPageLabel

local function LoadItem(id)
	if AssetCache[id] then return AssetCache[id] end

	local obj
	local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
	if ok and res and res[1] then obj = res[1] end
	if not obj then
		ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
		if ok and res then obj = res end
	end
	if not obj then return nil end

	local inst
	if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
		or obj:IsA("ShirtGraphic") or obj:IsA("Decal") then
		inst = obj
	else
		inst = obj:FindFirstChildWhichIsA("Accessory", true)
			or obj:FindFirstChildWhichIsA("Shirt", true)
			or obj:FindFirstChildWhichIsA("Pants", true)
			or obj:FindFirstChildWhichIsA("ShirtGraphic", true)
			or obj:FindFirstChildWhichIsA("Decal", true)
	end

	if inst then AssetCache[id] = inst end
	return inst
end

local function UnwearItem(id)
	local entry = Worn[id]
	if not entry then return end
	pcall(entry.cleanup)
	Worn[id] = nil
	for i, v in ipairs(WornOrder) do
		if v == id then
			table.remove(WornOrder, i)
			break
		end
	end
end

local function WearItem(id)
	if Worn[id] then return true end
	if not character or not humanoid then return false end

	local src = LoadItem(id)
	if not src then return false end

	local inst = src:Clone()
	local kind
	local cleanup

	if inst:IsA("Accessory") then
		kind = "Accessory"
		inst.Name = "ONESHOT_" .. inst.Name
		humanoid:AddAccessory(inst)
		cleanup = function() inst:Destroy() end

	elseif inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") then
		kind = inst.ClassName
		for oid, e in pairs(Worn) do
			if e.kind == kind then UnwearItem(oid) end
		end
		local old = character:FindFirstChildOfClass(kind)
		if old then old.Parent = nil end
		inst.Parent = character
		cleanup = function()
			inst:Destroy()
			if old and character then old.Parent = character end
		end

	elseif inst:IsA("Decal") then
		kind = "Face"
		for oid, e in pairs(Worn) do
			if e.kind == kind then UnwearItem(oid) end
		end
		local head = character:FindFirstChild("Head")
		local face = head and (head:FindFirstChild("face") or head:FindFirstChildWhichIsA("Decal"))
		if not face then return false end
		local oldTexture = face.Texture
		face.Texture = inst.Texture
		cleanup = function() face.Texture = oldTexture end

	else
		return false
	end

	Worn[id] = {kind = kind, cleanup = cleanup}
	table.insert(WornOrder, id)
	return true
end

local function UnwearAll()
	local list = table.clone(WornOrder)
	for _, id in ipairs(list) do
		UnwearItem(id)
	end
end

local function MakeCard(item, order)
	local isWorn = Worn[item.id] ~= nil

	local Card = New("TextButton", {
		Name = "Card", BackgroundColor3 = Color3.fromRGB(60, 60, 80), BackgroundTransparency = 0.5,
		AutoButtonColor = false, Text = "", LayoutOrder = order, ClipsDescendants = true, BorderSizePixel = 0,
	}, CatGrid)
	corner(Card, 12)
	local St = stroke(Card, isWorn and Color3.fromRGB(255, 120, 170) or Color3.fromRGB(190, 190, 215), isWorn and 2 or 1)

	local Thumb = New("ImageLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromOffset(120, 120), Position = UDim2.new(0.5, -60, 0, 8),
		Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", item.id),
		ImageTransparency = 1,
	}, Card)
	tw(Thumb, 0.3 + order * 0.04, {ImageTransparency = 0})

	New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 20), Position = UDim2.fromOffset(6, 132),
		Text = item.name, TextColor3 = Color3.fromRGB(240, 232, 240), Font = Enum.Font.GothamMedium,
		TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
	}, Card)

	local Tag = New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 16), Position = UDim2.fromOffset(6, 153),
		Text = isWorn and "WORN" or "FREE",
		TextColor3 = isWorn and Color3.fromRGB(255, 120, 170) or Color3.fromRGB(130, 220, 160),
		Font = Enum.Font.GothamBold, TextSize = 12,
	}, Card)

	Card.MouseEnter:Connect(function()
		tw(Card, 0.15, {BackgroundTransparency = 0.3})
		tw(Thumb, 0.2, {Size = UDim2.fromOffset(128, 128), Position = UDim2.new(0.5, -64, 0, 4)}, Enum.EasingStyle.Back)
	end)
	Card.MouseLeave:Connect(function()
		tw(Card, 0.15, {BackgroundTransparency = 0.5})
		tw(Thumb, 0.2, {Size = UDim2.fromOffset(120, 120), Position = UDim2.new(0.5, -60, 0, 8)})
	end)

	Card.MouseButton1Click:Connect(function()
		if Worn[item.id] then
			UnwearItem(item.id)
			Tag.Text = "FREE"
			Tag.TextColor3 = Color3.fromRGB(130, 220, 160)
			St.Color = Color3.fromRGB(190, 190, 215)
			St.Thickness = 1
		else
			Tag.Text = "LOADING"
			task.spawn(function()
				if WearItem(item.id) then
					Tag.Text = "WORN"
					Tag.TextColor3 = Color3.fromRGB(255, 120, 170)
					St.Color = Color3.fromRGB(255, 120, 170)
					St.Thickness = 2
				else
					Tag.Text = "FAILED"
					task.wait(1.5)
					Tag.Text = "FREE"
				end
			end)
		end
	end)
end

local function RenderCatalog()
	if not CatGrid then return end

	for _, c in ipairs(CatGrid:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end

	local first = (CAT.Page - 1) * PER_PAGE
	for i = 1, PER_PAGE do
		local item = CAT.Items[first + i]
		if item then MakeCard(item, i) end
	end

	local pages = math.max(1, math.ceil(#CAT.Items / PER_PAGE))
	CatPageLabel.Text = string.format("%d/%d%s", CAT.Page, pages, CAT.Cursor and "+" or "")

	local text = CAT.Loading and "Loading..." or CAT.Status
	CatStatus.Text = text
	CatStatus.Visible = text ~= "" and #CAT.Items == 0
end

local function CatalogFetch(reset)
	if CAT.Loading then return end
	CAT.Loading = true

	if reset then
		CAT.Items = {}
		CAT.Cursor = nil
		CAT.Page = 1
		CAT.PendingNext = false
	end
	CAT.Status = ""
	RenderCatalog()

	task.spawn(function()
		local query = string.format("Category=%d&Limit=30&MaxPrice=0&MinPrice=0&Keyword=%s",
			CAT.Types[CAT.TypeIndex][2], HttpService:UrlEncode(CAT.Keywords[CAT.KwIndex]))
		if CAT.Cursor then
			query ..= "&Cursor=" .. HttpService:UrlEncode(CAT.Cursor)
		end

		local body
		for _, host in ipairs(CFG.CatalogHosts) do
			body = Http(host .. "/v1/search/items/details?" .. query)
			if body then break end
		end

		local before = #CAT.Items
		local ok, data = false, nil
		if body then
			ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		end

		if ok and data and data.data then
			for _, it in ipairs(data.data) do
				if (it.itemType == nil or it.itemType == "Asset") and (it.price == nil or it.price == 0) then
					table.insert(CAT.Items, {id = it.id, name = it.name or ("#" .. tostring(it.id))})
				end
			end
			CAT.Cursor = data.nextPageCursor
			CAT.Status = (#CAT.Items == 0) and "No free items found" or ""
			if CAT.PendingNext and #CAT.Items > before then
				CAT.Page += 1
			end
		else
			CAT.Status = "Catalog unavailable (HTTP blocked)"
		end

		CAT.PendingNext = false
		CAT.Loading = false
		RenderCatalog()
	end)
end

--==================================================
-- THEMES + WORLD GUI (LIQUID GLASS)
--==================================================

local THEMES = {
	{name = "Wine", accent = Color3.fromRGB(145, 35, 75), bg = Color3.fromRGB(20, 8, 14), bg2 = Color3.fromRGB(42, 12, 28),
		top = Color3.fromRGB(29, 9, 18), cell = Color3.fromRGB(27, 10, 18), line = Color3.fromRGB(75, 24, 42),
		idle = Color3.fromRGB(55, 25, 35), sub = Color3.fromRGB(170, 90, 115), rim = Color3.fromRGB(115, 25, 55)},
	{name = "Ocean", accent = Color3.fromRGB(35, 110, 170), bg = Color3.fromRGB(7, 13, 22), bg2 = Color3.fromRGB(12, 34, 56),
		top = Color3.fromRGB(9, 18, 30), cell = Color3.fromRGB(10, 20, 32), line = Color3.fromRGB(25, 55, 85),
		idle = Color3.fromRGB(25, 38, 52), sub = Color3.fromRGB(90, 140, 180), rim = Color3.fromRGB(30, 80, 125)},
	{name = "Emerald", accent = Color3.fromRGB(30, 150, 100), bg = Color3.fromRGB(7, 20, 15), bg2 = Color3.fromRGB(12, 46, 34),
		top = Color3.fromRGB(9, 28, 21), cell = Color3.fromRGB(10, 27, 20), line = Color3.fromRGB(24, 75, 55),
		idle = Color3.fromRGB(25, 52, 40), sub = Color3.fromRGB(90, 175, 140), rim = Color3.fromRGB(25, 115, 80)},
	{name = "Gold", accent = Color3.fromRGB(200, 150, 40), bg = Color3.fromRGB(22, 16, 7), bg2 = Color3.fromRGB(52, 38, 12),
		top = Color3.fromRGB(32, 23, 9), cell = Color3.fromRGB(30, 22, 10), line = Color3.fromRGB(90, 66, 24),
		idle = Color3.fromRGB(60, 46, 25), sub = Color3.fromRGB(190, 160, 100), rim = Color3.fromRGB(140, 100, 25)},
	{name = "Violet", accent = Color3.fromRGB(130, 70, 200), bg = Color3.fromRGB(14, 8, 24), bg2 = Color3.fromRGB(34, 18, 60),
		top = Color3.fromRGB(21, 10, 34), cell = Color3.fromRGB(20, 11, 32), line = Color3.fromRGB(60, 34, 95),
		idle = Color3.fromRGB(42, 28, 60), sub = Color3.fromRGB(155, 120, 205), rim = Color3.fromRGB(95, 50, 150)},
}
-- светлее и "молочнее" для стеклянного вида
for _, th in ipairs(THEMES) do
	th.line = th.line:Lerp(WHITE, 0.4)
	th.cell = th.cell:Lerp(WHITE, 0.1)
	th.sub = th.sub:Lerp(WHITE, 0.25)
end

local ThemeIndex = 1
local Theme = THEMES[1]
local ThemeListeners = {}

local function OnTheme(fn)
	table.insert(ThemeListeners, fn)
	fn(true)
end

local function ApplyTheme(index)
	ThemeIndex = index
	Theme = THEMES[index]
	for _, fn in ipairs(ThemeListeners) do
		fn(false)
	end
end

local COL_TEXT = Color3.fromRGB(245, 235, 242)

local Panel, PanelGui, Root, RootGrad
local SetGuiOpen -- объявлена ниже
local Pages, Tabs, TabIndex = {}, {}, {}
local ShowPage
local T = {}                 -- toggles по имени
local SkyPresetBtn

-- стеклянная прозрачность
local GlassFrames = {}
local function Glassify(frame, extra)
	frame.BackgroundTransparency = math.clamp(CFG.GlassBg + extra, 0, 0.97)
	table.insert(GlassFrames, {frame, extra})
end

local function ApplyGlass()
	for i = #GlassFrames, 1, -1 do
		local g = GlassFrames[i]
		if g[1] and g[1].Parent then
			g[1].BackgroundTransparency = math.clamp(CFG.GlassBg + g[2], 0, 0.97)
		else
			table.remove(GlassFrames, i)
		end
	end
	if Root then Root.BackgroundTransparency = CFG.GlassBg end
end

local PanelDir, PanelOrigin, PanelBaseY = Vector3.new(0, 0, -1), Vector3.zero, 0
local PanelCurrent = Vector3.zero
local LiftValue = Instance.new("NumberValue")
LiftValue.Value = -2
local panelToken = 0

local function CreateToggle(page, name, order, callback, default)
	local Holder = New("Frame", {Name = name, BackgroundColor3 = Theme.cell, BorderSizePixel = 0, LayoutOrder = order}, page)
	Glassify(Holder, 0.12)
	corner(Holder, 10)
	local St = stroke(Holder, Theme.line, 1)

	New("TextLabel", {
		Size = UDim2.new(1, -90, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
		Text = name, TextColor3 = COL_TEXT, Font = Enum.Font.GothamMedium, TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, Holder)

	local Button = New("TextButton", {
		Size = UDim2.fromOffset(56, 28), Position = UDim2.new(1, -70, 0.5, -14),
		BackgroundColor3 = Theme.idle, BackgroundTransparency = 0.25, Text = "", AutoButtonColor = false,
	}, Holder)
	corner(Button, 14)

	local Circle = New("Frame", {
		Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(4, 4),
		BackgroundColor3 = Color3.fromRGB(165, 140, 150), BorderSizePixel = 0,
	}, Button)
	corner(Circle, 10)

	local state = default == true

	local function Visual(instant)
		local btn = state and Theme.accent or Theme.idle
		local circ = state and Color3.fromRGB(255, 235, 242) or Color3.fromRGB(165, 140, 150)
		local pos = state and UDim2.fromOffset(32, 4) or UDim2.fromOffset(4, 4)
		local strokeColor = state and Theme.accent:Lerp(WHITE, 0.35) or Theme.line

		if instant then
			Button.BackgroundColor3 = btn
			Circle.BackgroundColor3 = circ
			Circle.Position = pos
			St.Color = strokeColor
		else
			tw(Button, 0.2, {BackgroundColor3 = btn})
			tw(Circle, 0.25, {BackgroundColor3 = circ, Position = pos}, Enum.EasingStyle.Back)
			tw(St, 0.2, {Color = strokeColor})
		end
	end

	OnTheme(function(instant)
		setc(Holder, "BackgroundColor3", Theme.cell, instant)
		Visual(instant)
	end)

	Holder.MouseEnter:Connect(function()
		tw(Holder, 0.15, {BackgroundColor3 = Theme.cell:Lerp(Theme.accent, 0.3)})
	end)
	Holder.MouseLeave:Connect(function()
		tw(Holder, 0.2, {BackgroundColor3 = Theme.cell})
	end)

	Button.MouseButton1Click:Connect(function()
		state = not state
		Visual(false)
		tw(Circle, 0.08, {Size = UDim2.fromOffset(26, 20)})
		task.delay(0.08, function()
			tw(Circle, 0.18, {Size = UDim2.fromOffset(20, 20)}, Enum.EasingStyle.Back)
		end)
		callback(state)
	end)

	local api = {}
	function api.Set(v)
		if state == v then return end
		state = v
		Visual(false)
		callback(v)
	end
	function api.Get() return state end

	if default == true then callback(true) end
	return api
end

local function CreateButton(page, text, order, onClick)
	local Btn = New("TextButton", {
		BackgroundColor3 = Theme.cell, BorderSizePixel = 0, LayoutOrder = order, Text = text,
		TextColor3 = COL_TEXT, Font = Enum.Font.GothamMedium, TextSize = 16, AutoButtonColor = false,
	}, page)
	Glassify(Btn, 0.12)
	corner(Btn, 10)
	local St = stroke(Btn, Theme.line, 1)

	OnTheme(function(instant)
		setc(Btn, "BackgroundColor3", Theme.cell, instant)
		setc(St, "Color", Theme.line, instant)
	end)

	Btn.MouseEnter:Connect(function()
		tw(Btn, 0.15, {BackgroundColor3 = Theme.cell:Lerp(Theme.accent, 0.35)})
	end)
	Btn.MouseLeave:Connect(function()
		tw(Btn, 0.2, {BackgroundColor3 = Theme.cell})
	end)
	Btn.MouseButton1Click:Connect(function()
		tw(Btn, 0.07, {TextSize = 13})
		task.delay(0.07, function()
			tw(Btn, 0.2, {TextSize = 16}, Enum.EasingStyle.Back)
		end)
		onClick(Btn)
	end)
	return Btn
end

local function CreateStepper(page, text, order, key, min, max, step, onChange)
	local Holder = New("Frame", {Name = text, BackgroundColor3 = Theme.cell, BorderSizePixel = 0, LayoutOrder = order}, page)
	Glassify(Holder, 0.12)
	corner(Holder, 10)
	local St = stroke(Holder, Theme.line, 1)

	New("TextLabel", {
		Size = UDim2.new(1, -150, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
		Text = text, TextColor3 = COL_TEXT, Font = Enum.Font.GothamMedium, TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
	}, Holder)

	local function makeBtn(txt, x)
		local b = New("TextButton", {
			Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, x, 0.5, -18),
			BackgroundColor3 = Theme.accent, BackgroundTransparency = 0.2, Text = txt,
			TextColor3 = Color3.fromRGB(255, 235, 242),
			Font = Enum.Font.GothamBold, TextSize = 22, AutoButtonColor = false,
		}, Holder)
		corner(b, 8)
		return b
	end

	local Minus = makeBtn("-", -136)
	local Plus = makeBtn("+", -40)

	local Value = New("TextLabel", {
		Size = UDim2.fromOffset(52, 36), Position = UDim2.new(1, -96, 0.5, -18), BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 235, 242), Font = Enum.Font.GothamBold, TextSize = 16,
	}, Holder)

	OnTheme(function(instant)
		setc(Holder, "BackgroundColor3", Theme.cell, instant)
		setc(St, "Color", Theme.line, instant)
		setc(Minus, "BackgroundColor3", Theme.accent, instant)
		setc(Plus, "BackgroundColor3", Theme.accent, instant)
	end)

	local function refresh()
		Value.Text = tostring(math.floor(CFG[key] * 100 + 0.5) / 100)
	end

	local function press(btn)
		tw(btn, 0.07, {TextSize = 15})
		tw(Value, 0.07, {TextSize = 21})
		task.delay(0.07, function()
			tw(btn, 0.2, {TextSize = 22}, Enum.EasingStyle.Back)
			tw(Value, 0.2, {TextSize = 16}, Enum.EasingStyle.Back)
		end)
	end

	local function change(dir, btn)
		local v = math.round((CFG[key] + dir * step) / step) * step
		CFG[key] = math.floor(math.clamp(v, min, max) * 1000 + 0.5) / 1000
		refresh()
		press(btn)
		if onChange then onChange(CFG[key]) end
	end

	Minus.MouseButton1Click:Connect(function() change(-1, Minus) end)
	Plus.MouseButton1Click:Connect(function() change(1, Plus) end)
	refresh()
end

local function SummonPanel()
	local cam = workspace.CurrentCamera
	local look = cam.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	PanelDir = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)

	local camPos = cam.CFrame.Position
	PanelOrigin = Vector3.new(camPos.X, 0, camPos.Z)

	local root = character and character:FindFirstChild("HumanoidRootPart")
	PanelBaseY = root and root.Position.Y or camPos.Y

	PanelCurrent = Vector3.new(PanelOrigin.X, PanelBaseY + CFG.PanelHeight, PanelOrigin.Z) + PanelDir * CFG.PanelDistance
end

local function PanelTarget()
	return Vector3.new(PanelOrigin.X, PanelBaseY + CFG.PanelHeight, PanelOrigin.Z) + PanelDir * CFG.PanelDistance
end

-- "Galaxy mode": включает всё космическое одним тумблером
local function GalaxyMode(v)
	if v then
		SkyIndex = GalaxySkyIndex
		if SkyPresetBtn then SkyPresetBtn.Text = "Sky preset: " .. CFG.Skies[SkyIndex].name end
		if SkyEnabled then ApplySky() elseif T.Sky then T.Sky.Set(true) end
	elseif T.Sky then
		T.Sky.Set(false)
	end
	for _, k in ipairs({"Nebula", "Planets", "Meteors", "Dust", "Aurora", "Starfall"}) do
		if T[k] then T[k].Set(v) end
	end
end

local function BuildPanel()
	Panel = New("Part", {
		Name = "ONESHOT_Panel", Size = Vector3.new(CFG.PanelW, CFG.PanelH, 0.1), Anchored = true,
		CanCollide = false, CanTouch = false, CastShadow = false, Transparency = 1,
	}, workspace)
	mouse.TargetFilter = Panel

	PanelGui = New("SurfaceGui", {
		Name = "ONESHOT_PanelGui", Adornee = Panel, Face = Enum.NormalId.Front, AlwaysOnTop = true,
		LightInfluence = 0, ResetOnSpawn = false, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		PixelsPerStud = CFG.PanelPPS, Enabled = false,
	}, player.PlayerGui)

	-- ROOT: полупрозрачное стекло
	Root = New("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = WHITE, BackgroundTransparency = CFG.GlassBg, BorderSizePixel = 0, GroupTransparency = 1,
	}, PanelGui)
	corner(Root, 24)
	local RootStroke = stroke(Root, Theme.accent:Lerp(WHITE, 0.65), 2)
	RootGrad = New("UIGradient", {Rotation = 45}, Root)

	-- верхний блик стекла
	local Gloss = New("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0,
	}, Root)
	New("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(1, 1)}),
	}, Gloss)

	-- TOP
	local Top = New("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.top, BorderSizePixel = 0}, Root)
	Glassify(Top, 0.18)
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.75, BorderSizePixel = 0,
	}, Top)

	New("TextLabel", {
		Size = UDim2.new(1, -80, 0, 32), Position = UDim2.fromOffset(18, 6), BackgroundTransparency = 1,
		Text = "ONESHOT", TextColor3 = Color3.fromRGB(255, 235, 242), Font = Enum.Font.GothamBold,
		TextSize = 26, TextXAlignment = Enum.TextXAlignment.Left,
	}, Top)

	local SubTitle = New("TextLabel", {
		Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(18, 38), BackgroundTransparency = 1,
		Text = "WORLD PANEL  |  DELETE = OPEN / CLOSE  |  Z = ZOOM", TextColor3 = Theme.sub,
		Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
	}, Top)

	ResBadge = New("TextLabel", {
		Size = UDim2.fromOffset(170, 22), Position = UDim2.new(1, -230, 0, 19), BackgroundTransparency = 1,
		Text = RES_BADGE[ResMode + 1], TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, Top)

	local Close = New("TextButton", {
		Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -52, 0, 10),
		BackgroundColor3 = Color3.fromRGB(190, 45, 80), BackgroundTransparency = 0.25, Text = "X",
		TextColor3 = Color3.fromRGB(255, 235, 242),
		Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false,
	}, Top)
	corner(Close, 20)
	stroke(Close, WHITE, 1)
	Close.MouseEnter:Connect(function()
		tw(Close, 0.25, {Rotation = 90, BackgroundColor3 = Color3.fromRGB(235, 60, 100)}, Enum.EasingStyle.Back)
	end)
	Close.MouseLeave:Connect(function()
		tw(Close, 0.25, {Rotation = 0, BackgroundColor3 = Color3.fromRGB(190, 45, 80)})
	end)
	Close.MouseButton1Click:Connect(function()
		SetGuiOpen(false)
	end)

	-- SHEEN (блик, пробегает по панели)
	local Sheen = New("Frame", {
		Size = UDim2.new(0.12, 0, 1.6, 0), Position = UDim2.new(-0.3, 0, -0.3, 0), Rotation = 18,
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 50,
	}, Root)
	task.spawn(function()
		while Root and Root.Parent do
			task.wait(5)
			Sheen.Position = UDim2.new(-0.3, 0, -0.3, 0)
			tw(Sheen, 1.6, {Position = UDim2.new(1.2, 0, -0.3, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		end
	end)

	-- TABS
	local TAB_W, TAB_GAP = 112, 4
	local TabBar = New("Frame", {
		Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 66), BackgroundTransparency = 1,
	}, Root)

	-- "таблетка" под активной вкладкой
	local Underline = New("Frame", {
		Size = UDim2.fromOffset(TAB_W, 36), Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.accent, BackgroundTransparency = 0.45, BorderSizePixel = 0,
	}, TabBar)
	corner(Underline, 18)
	stroke(Underline, WHITE, 1)

	local PageHolder = New("Frame", {
		Size = UDim2.new(1, -24, 0, 414), Position = UDim2.fromOffset(12, 114), BackgroundTransparency = 1,
	}, Root)

	local currentPage = "BODY"

	function ShowPage(name, instant)
		currentPage = name
		for n, f in pairs(Pages) do
			if n == name then
				f.Visible = true
				if not instant then
					f.GroupTransparency = 1
					f.Position = UDim2.fromOffset(0, 14)
					tw(f, 0.3, {GroupTransparency = 0, Position = UDim2.fromOffset(0, 0)}, Enum.EasingStyle.Quint)
				end
			else
				f.Visible = false
			end
		end
		for n, b in pairs(Tabs) do
			tw(b, 0.2, {TextColor3 = (n == name) and WHITE or Theme.sub})
		end
		tw(Underline, 0.3, {Position = UDim2.fromOffset((TabIndex[name] - 1) * (TAB_W + TAB_GAP), 0)}, Enum.EasingStyle.Quint)

		if name == "CATALOG" and #CAT.Items == 0 and not CAT.Loading then
			CatalogFetch(true)
		end
	end

	-- kind: "grid" | "scroll" | nil
	local function NewPage(name, order, kind)
		TabIndex[name] = order

		local tab = New("TextButton", {
			Size = UDim2.fromOffset(TAB_W, 36), Position = UDim2.fromOffset((order - 1) * (TAB_W + TAB_GAP), 0),
			BackgroundTransparency = 1, Text = name, TextColor3 = Theme.sub, Font = Enum.Font.GothamBold,
			TextSize = 14, AutoButtonColor = false,
		}, TabBar)
		Tabs[name] = tab

		local page = New("CanvasGroup", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false,
		}, PageHolder)
		Pages[name] = page

		local target = page
		if kind == "grid" then
			New("UIGridLayout", {
				CellSize = UDim2.new(0.5, -4, 0, 52), CellPadding = UDim2.fromOffset(8, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, page)
		elseif kind == "scroll" then
			target = New("ScrollingFrame", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
				ScrollBarThickness = 5, ScrollBarImageColor3 = WHITE, ScrollBarImageTransparency = 0.5,
				CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			}, page)
			New("UIGridLayout", {
				CellSize = UDim2.new(0.5, -10, 0, 52), CellPadding = UDim2.fromOffset(8, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, target)
		end

		tab.MouseButton1Click:Connect(function()
			if currentPage ~= name then ShowPage(name) end
		end)
		return target
	end

	local Body = NewPage("BODY", 1, "grid")
	local World = NewPage("WORLD", 2, "grid")
	local Space = NewPage("SPACE", 3, "grid")
	local Gfx = NewPage("GFX", 4, "grid")
	local Tune = NewPage("TUNE", 5, "scroll")
	local Cat = NewPage("CATALOG", 6)

	OnTheme(function(instant)
		setc(Top, "BackgroundColor3", Theme.top, instant)
		setc(SubTitle, "TextColor3", Theme.sub, instant)
		setc(Underline, "BackgroundColor3", Theme.accent, instant)
		setc(RootStroke, "Color", Theme.accent:Lerp(WHITE, 0.65), instant)
		ResBadge.TextColor3 = Theme.accent:Lerp(WHITE, 0.6)
		RootGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.bg:Lerp(Theme.accent, 0.25)),
			ColorSequenceKeypoint.new(1, Theme.bg2:Lerp(Theme.accent, 0.15)),
		})
		for n, b in pairs(Tabs) do
			b.TextColor3 = (n == currentPage) and WHITE or Theme.sub
		end
	end)

	-- BODY
	CreateToggle(Body, "InvInfo", 1, function(v) InvInfoEnabled = v end)
	CreateToggle(Body, "Glow", 2, function(v)
		GlowEnabled = v
		if v then CreateSelfGlow() else RemoveSelfGlow() end
		if RainbowEnabled then SetRainbowGlow(true) end
	end)
	CreateToggle(Body, "Wings", 3, function(v)
		WingsEnabled = v
		if v then BuildWings() else DestroyWings() end
	end)
	CreateToggle(Body, "Korblox", 4, function(v)
		KorbloxEnabled = v
		if v then BuildKorblox() else DestroyKorblox() end
	end)
	CreateToggle(Body, "Aura", 5, function(v)
		AuraEnabled = v
		if v then BuildAura() else DestroyAura() end
	end)
	CreateToggle(Body, "Halo", 6, function(v)
		HaloEnabled = v
		if v then BuildHalo() else DestroyHalo() end
	end)
	CreateToggle(Body, "Orbs", 7, function(v)
		OrbsEnabled = v
		if v then BuildOrbs() else DestroyOrbs() end
	end)
	CreateToggle(Body, "Step ripples", 8, function(v)
		RipplesEnabled = v
		SetRipples(v)
	end)
	CreateToggle(Body, "Jump particles", 9, function(v) JumpFXEnabled = v end)
	CreateToggle(Body, "Click particles", 10, function(v) ClickFXEnabled = v end)
	CreateToggle(Body, "Rainbow glow", 11, function(v)
		RainbowEnabled = v
		SetRainbowGlow(v)
	end)
	CreateToggle(Body, "Cosmic trail", 12, function(v)
		CometEnabled = v
		if v then BuildComet() else DestroyComet() end
	end)
	CreateToggle(Body, "Magic circle", 13, function(v)
		MagicEnabled = v
		if v then BuildMagic() else DestroyMagic() end
	end)
	CreateToggle(Body, "Low gravity", 14, function(v)
		LowGravEnabled = v
		SetLowGravity(v)
	end)

	-- WORLD
	T.Sky = CreateToggle(World, "Sky", 1, function(v)
		SkyEnabled = v
		if v then ApplySky() else RemoveSky() end
	end)
	SkyPresetBtn = CreateButton(World, "Sky preset: " .. CFG.Skies[SkyIndex].name, 2, function(btn)
		SkyIndex = SkyIndex % #CFG.Skies + 1
		btn.Text = "Sky preset: " .. CFG.Skies[SkyIndex].name
		if SkyEnabled then ApplySky() end
	end)
	T.Shaders = CreateToggle(World, "Shaders", 3, function(v)
		ShadersEnabled = v
		if v then EnableShaders() else DisableShaders() end
	end)
	CreateToggle(World, "4:3 stretch", 4, function(v) StretchEnabled = v end)
	CreateToggle(World, "Gloss", 5, function(v)
		GlossEnabled = v
		if v then EnableGloss() else DisableGloss() end
	end)
	CreateToggle(World, "Fireflies", 6, function(v)
		FirefliesEnabled = v
		if v then BuildFireflies() else DestroyFireflies() end
	end)
	T.Starfall = CreateToggle(World, "Starfall", 7, function(v)
		StarfallEnabled = v
		if v then BuildStarfall() else DestroyStarfall() end
	end)
	CreateToggle(World, "Day cycle", 8, function(v)
		TimeEnabled = v
		SetTimeCycle(v)
	end)
	CreateToggle(World, "FOV", 9, function(v) FovEnabled = v end)
	CreateToggle(World, "Speed FOV", 10, function(v) SpeedFovEnabled = v end)

	-- SPACE
	CreateToggle(Space, "GALAXY MODE", 1, GalaxyMode)
	T.Nebula = CreateToggle(Space, "Nebula", 2, function(v)
		NebulaEnabled = v
		if v then BuildNebula() else DestroyNebula() end
	end)
	T.Planets = CreateToggle(Space, "Planets", 3, function(v)
		PlanetsEnabled = v
		if v then BuildPlanets() else DestroyPlanets() end
	end)
	T.Meteors = CreateToggle(Space, "Meteor shower", 4, function(v)
		MeteorsEnabled = v
		SetMeteors(v)
	end)
	CreateToggle(Space, "Black hole", 5, function(v)
		BlackHoleEnabled = v
		if v then BuildBlackHole() else DestroyBlackHole() end
	end)
	T.Dust = CreateToggle(Space, "Cosmic dust", 6, function(v)
		DustEnabled = v
		if v then BuildDust() else DestroyDust() end
	end)
	T.Aurora = CreateToggle(Space, "Aurora", 7, function(v)
		AuroraEnabled = v
		if v then BuildAurora() else DestroyAurora() end
	end)

	-- GFX
	ResButton = CreateButton(Gfx, "Resolution: " .. RES_NAMES[ResMode + 1], 1, function()
		ApplyGraphics((ResMode + 1) % 4)
	end)
	CreateToggle(Gfx, "FPS unlock", 2, function(v)
		pcall(function()
			if setfpscap then setfpscap(v and 360 or 60) end
		end)
	end)
	CreateToggle(Gfx, "Motion blur", 3, function(v) MotionBlurEnabled = v end)
	CreateToggle(Gfx, "Cinematic bars", 4, function(v)
		BarsEnabled = v
		UpdateBars()
	end)
	CreateToggle(Gfx, "Cinema grade", 5, SetGrade)
	CreateToggle(Gfx, "HDR bloom", 6, SetHDR)
	CreateToggle(Gfx, "Lens flare", 7, SetFlare)
	CreateToggle(Gfx, "Water reflections", 8, SetWater)
	CreateToggle(Gfx, "Crisp shadows", 9, SetShadows)
	CreateToggle(Gfx, "Future lighting", 10, function(v)
		SetHidden(Lighting, "Technology", v and Enum.Technology.Future or Enum.Technology.ShadowMap)
	end)
	CreateToggle(Gfx, "Glass blur", 11, function(v)
		GlassBlurEnabled = v
		UpdateGlassDof()
	end, true)

	-- TUNE
	CreateStepper(Tune, "Glass clarity", 1, "GlassBg", 0.1, 0.75, 0.05, function() ApplyGlass() end)
	CreateStepper(Tune, "Aura density", 2, "AuraDensity", 0.25, 3, 0.25, function() ApplyAuraMode() end)
	CreateStepper(Tune, "Wing flap speed", 3, "FLAP_SPEED", 0.5, 6, 0.5)
	CreateStepper(Tune, "Firefly rate", 4, "FireflyRate", 2, 30, 2, function(v)
		if FireflyEmitter then FireflyEmitter.Rate = v end
	end)
	CreateStepper(Tune, "Gloss amount", 5, "GlossAmount", 0, 0.6, 0.05, function()
		if GlossEnabled then GlossRefresh() end
	end)
	CreateStepper(Tune, "4:3 squash (0.75)", 6, "StretchY", 0.5, 1, 0.05)
	CreateStepper(Tune, "Jump particles", 7, "JumpCount", 10, 80, 10)
	CreateStepper(Tune, "Sky spin speed", 8, "SkySpinSpeed", 0, 6, 0.5)
	CreateStepper(Tune, "Day speed", 9, "DaySpeed", 0.1, 3, 0.1)
	CreateStepper(Tune, "FOV value", 10, "FOV", 40, 120, 5)
	CreateStepper(Tune, "Speed FOV boost", 11, "FovBoost", 0, 40, 4)
	CreateStepper(Tune, "Panel distance", 12, "PanelDistance", 5, 14, 1)
	CreateStepper(Tune, "Panel height", 13, "PanelHeight", -1, 5, 0.5)
	CreateStepper(Tune, "Nebula density", 14, "NebulaRate", 0.3, 4, 0.3, function(v)
		if NebulaPart then
			for _, c in ipairs(NebulaPart:GetChildren()) do
				if c:IsA("ParticleEmitter") then c.Rate = v end
			end
		end
	end)
	CreateStepper(Tune, "Planet distance", 15, "PlanetDistance", 600, 1800, 100)
	CreateStepper(Tune, "Meteor delay (sec)", 16, "MeteorInterval", 0.4, 5, 0.2)
	CreateStepper(Tune, "Dust rate", 17, "DustRate", 10, 120, 10, function(v)
		if DustEmitter then DustEmitter.Rate = v end
	end)
	CreateStepper(Tune, "Gravity scale", 18, "GravityScale", 0.1, 1, 0.1, function(v)
		if LowGravEnabled and SavedGravity then workspace.Gravity = SavedGravity * v end
	end)
	CreateStepper(Tune, "Motion blur power", 19, "MotionBlurAmount", 0.5, 4, 0.5)
	CreateButton(Tune, "Theme: " .. Theme.name, 20, function(btn)
		ApplyTheme(ThemeIndex % #THEMES + 1)
		btn.Text = "Theme: " .. Theme.name
	end)
	CreateButton(Tune, "Aura color: " .. AURA_COLORS[AuraColorIndex][1], 21, function(btn)
		AuraColorIndex = AuraColorIndex % #AURA_COLORS + 1
		CFG.AuraColor = AURA_COLORS[AuraColorIndex][2]
		btn.Text = "Aura color: " .. AURA_COLORS[AuraColorIndex][1]
		if AuraEnabled then BuildAura() end
	end)

	-- CATALOG
	local Controls = New("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1}, Cat)
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, Controls)

	local function ctl(text, width, order, onClick)
		local b = CreateButton(Controls, text, order, onClick)
		b.Size = UDim2.fromOffset(width, 44)
		return b
	end

	ctl("Type: " .. CAT.Types[CAT.TypeIndex][1], 150, 1, function(btn)
		CAT.TypeIndex = CAT.TypeIndex % #CAT.Types + 1
		btn.Text = "Type: " .. CAT.Types[CAT.TypeIndex][1]
		CatalogFetch(true)
	end)
	ctl("Tag: all", 150, 2, function(btn)
		CAT.KwIndex = CAT.KwIndex % #CAT.Keywords + 1
		local kw = CAT.Keywords[CAT.KwIndex]
		btn.Text = "Tag: " .. (kw == "" and "all" or kw)
		CatalogFetch(true)
	end)
	ctl("<", 60, 3, function()
		if CAT.Page > 1 then
			CAT.Page -= 1
			RenderCatalog()
		end
	end)

	CatPageLabel = New("TextLabel", {
		Size = UDim2.fromOffset(80, 44), BackgroundTransparency = 1, Text = "1/1", TextColor3 = COL_TEXT,
		Font = Enum.Font.GothamBold, TextSize = 16, LayoutOrder = 4,
	}, Controls)

	ctl(">", 60, 5, function()
		if CAT.Page * PER_PAGE < #CAT.Items then
			CAT.Page += 1
			RenderCatalog()
		elseif CAT.Cursor and not CAT.Loading then
			CAT.PendingNext = true
			CatalogFetch(false)
		end
	end)
	ctl("Clear worn", 156, 6, function()
		UnwearAll()
		RenderCatalog()
	end)

	CatGrid = New("Frame", {
		Size = UDim2.new(1, 0, 0, 362), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1,
	}, Cat)
	New("UIGridLayout", {
		CellSize = UDim2.fromOffset(168, 177), CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, CatGrid)

	CatStatus = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 362), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1,
		Text = "", TextColor3 = COL_TEXT, Font = Enum.Font.GothamMedium, TextSize = 20, Visible = false, ZIndex = 5,
	}, Cat)

	ApplyGlass()
	ShowPage("BODY", true)
end

BuildPanel()

function SetGuiOpen(open)
	panelToken += 1
	local token = panelToken
	GuiOpen = open

	if open then
		SummonPanel()
		Panel.CanQuery = true
		PanelGui.Enabled = true
		LiftValue.Value = -2
		Root.GroupTransparency = 1
		Root.Size = UDim2.fromScale(0.86, 0.86)
		tw(Root, 0.5, {GroupTransparency = 0, Size = UDim2.fromScale(1, 1)}, Enum.EasingStyle.Back)
		tw(LiftValue, 0.6, {Value = 0}, Enum.EasingStyle.Quint)
	else
		tw(Root, 0.25, {GroupTransparency = 1, Size = UDim2.fromScale(0.9, 0.9)}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tw(LiftValue, 0.3, {Value = -1.5}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.28, function()
			if token == panelToken then
				PanelGui.Enabled = false
				Panel.CanQuery = false
			end
		end)
	end

	ApplyAuraMode()
	UpdateGlassDof()
	UpdateBars()
end

-- панель стоит в мире, плавно догоняет цель, покачивается и смотрит на камеру
RunService.RenderStepped:Connect(function(dt)
	if not PanelGui.Enabled then return end
	local t = os.clock()

	PanelCurrent = PanelCurrent:Lerp(PanelTarget(), math.min(1, dt * 8))
	local cp = workspace.CurrentCamera.CFrame.Position
	local pos = PanelCurrent + Vector3.new(0, LiftValue.Value + math.sin(t * 1.5) * 0.08, 0)
	local target = Vector3.new(cp.X, pos.Y, cp.Z)

	if (target - pos).Magnitude > 0.1 then
		Panel.CFrame = CFrame.lookAt(pos, target)
			* CFrame.Angles(math.sin(t * 0.9) * 0.008, math.sin(t * 0.7) * 0.015, math.sin(t * 0.6) * 0.006)
	end

	RootGrad.Rotation = (t * 10) % 360
end)

-- кнопка-открывалка для телефона
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	local launcher = New("ScreenGui", {Name = CFG.GUI_NAME, ResetOnSpawn = false}, player.PlayerGui)
	local lb = New("TextButton", {
		Size = UDim2.fromOffset(46, 46), Position = UDim2.fromOffset(12, 70),
		BackgroundColor3 = Color3.fromRGB(110, 25, 50), BackgroundTransparency = 0.3, Text = "OS",
		TextColor3 = Color3.fromRGB(255, 225, 235),
		Font = Enum.Font.GothamBold, TextSize = 16,
	}, launcher)
	corner(lb, 23)
	stroke(lb, WHITE, 1)
	lb.MouseButton1Click:Connect(function()
		SetGuiOpen(not GuiOpen)
	end)
end

--==================================================
-- INPUT
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == CFG.OPEN_KEY then
		SetGuiOpen(not GuiOpen)
		return
	end

	if input.KeyCode == CFG.ZOOM_KEY then
		ZoomHeld = true
		return
	end

	if not ClickFXEnabled then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local target = mouse.Target
	if not target then return end
	local model = target:FindFirstAncestorOfClass("Model")
	local clicked = model and Players:GetPlayerFromCharacter(model)
	if clicked then
		ClickFX(mouse.Hit.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == CFG.ZOOM_KEY then
		ZoomHeld = false
	end
end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid", 5)

	task.wait(0.35)

	RemoveSelfGlow()
	DestroyWings()
	DestroyKorblox()
	DestroyAura()
	DestroyHalo()
	DestroyComet()

	if GlowEnabled then CreateSelfGlow() end
	if WingsEnabled then BuildWings() end
	if KorbloxEnabled then BuildKorblox() end
	if AuraEnabled then BuildAura() end
	if HaloEnabled then BuildHalo() end
	if CometEnabled then BuildComet() end

	SetupJumpFX()

	-- вернуть надетые вещи из каталога
	local list = table.clone(WornOrder)
	Worn = {}
	WornOrder = {}
	for _, id in ipairs(list) do
		task.spawn(WearItem, id)
	end
end)

--==================================================
-- START
--==================================================

SetupJumpFX()
SetGuiOpen(true)
