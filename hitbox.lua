-- ==========================================
-- ระบบหลัก (Core System)
-- อย่าแก้ถ้าไม่จำเป็น
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ตารางเก็บ RootPart ที่ถูกแก้ไขไว้ เพื่อเอาไว้รีเซ็ตตอนปิด
local modifiedRootParts = {}
local ORIGINAL_SIZE = Vector3.new(2, 2, 1)

-- GUI Creation (เหมือนเดิม)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Name = "TargetHitboxGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 80)
MainFrame.Active = true

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 20)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Target Hitbox: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

-- ระบบลาก GUI (เหมือนเดิม)
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- *** ฟังก์ชันแก้ไข Hitbox แบบกำหนดเป้าหมาย (Deep Search) ***
local active = false

local function updateTargetHitboxes()
    if not active then return end -- ถ้าปิดอยู่ ไม่ต้องทำอะไร

    pcall(function()
        local config = getgenv().HitboxSettings
        local targetFolderNames = config["TargetFolders"]
        local targetParts = {}

        -- 1. ค้นหาโฟลเดอร์เป้าหมายแบบทะลุทะลวงใน Workspace
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if (obj:IsA("Folder") or obj:IsA("Model")) and table.find(targetFolderNames, obj.Name) then
                -- 2. ดึง Descendants ทั้งหมดจากโฟลเดอร์ที่เจอ
                for _, descendant in pairs(obj:GetDescendants()) do
                    table.insert(targetParts, descendant)
                end
            end
        end

        -- 3. ตรวจสอบและแก้ไข Hitbox
        for _, v in pairs(targetParts) do
            if v:IsA("Humanoid") and v.Parent and v.Parent:IsA("Model") then
                local model = v.Parent

                -- ข้ามตัวผู้เล่นเอง และผู้เล่นคนอื่น
                if model == LocalPlayer.Character then continue end
                if Players:GetPlayerFromCharacter(model) then continue end

                local rootPart = model:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    -- เก็บไว้ในตารางเพื่อรีเซ็ต
                    if not table.find(modifiedRootParts, rootPart) then
                        table.insert(modifiedRootParts, rootPart)
                    end

                    -- แก้ไข Hitbox
                    rootPart.Size = config["HitboxSize"]
                    rootPart.Transparency = config["HitboxTransparency"]
                    rootPart.BrickColor = config["HitboxColor"]
                    rootPart.Material = Enum.Material.Neon
                    rootPart.CanCollide = false
                end
            end
        end
    end)
end

-- *** ฟังก์ชันรีเซ็ต Hitbox กลับเป็นค่าเดิม ***
local function resetHitboxes()
    for _, rootPart in ipairs(modifiedRootParts) do
        if rootPart and rootPart.Parent then -- ตรวจสอบว่า Part ยังอยู่ไหม
            pcall(function()
                rootPart.Size = ORIGINAL_SIZE
                rootPart.Transparency = 1
                rootPart.BrickColor = BrickColor.new("Medium stone grey")
                rootPart.Material = Enum.Material.Plastic
                rootPart.CanCollide = true
            end)
        end
    end
    -- ล้างตาราง
    modifiedRootParts = {}
end

-- Button Logic
ToggleButton.MouseButton1Click:Connect(function()
    active = not active
    if active then
        ToggleButton.Text = "Target Hitbox: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        --updateTargetHitboxes() -- ทำทันทีหนึ่งครั้ง
    else
        ToggleButton.Text = "Target Hitbox: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        resetHitboxes() -- รีเซ็ตค่าทันที
    end
end)

-- Loop ทำงาน
RunService.RenderStepped:Connect(function()
    if active then
        updateTargetHitboxes()
    end
end)
