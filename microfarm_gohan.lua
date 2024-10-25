print("V1.41----------------")

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- id del usuario
local userId = Player.UserId

--datos del usuario
local playerData = ReplicatedStorage.Datas[userId]

--datos de las misiones
local activeQuest = playerData.Quest
local questProgress = playerData.QuestProgress

--eventos
local teleportEvent = ReplicatedStorage.Package.Events.TP
local getQuestEvent = ReplicatedStorage.Package.Events.Qaction
local punchEvent = ReplicatedStorage.Package.Events.p
local rebEvent = ReplicatedStorage.Package.Events.reb
local chargeEvent = ReplicatedStorage.Package.Events.cha
local mel = ReplicatedStorage.Package.Events.mel

-- función para obtener el character
local function getCharacter () 
    local c = Player.Character or Player.CharacterAdded:Wait()
    return c
end

-- función para tomar una quest
local function getQuest(questName)
    local questGiver = workspace.Others.NPCs[questName]
    local c = getCharacter()
    c.HumanoidRootPart.CFrame = questGiver.HumanoidRootPart.CFrame
    task.wait(2)
    getQuestEvent:InvokeServer(questGiver)
end

-- función para matar a gohan
local function farmNPC(npc)
    print("Blocking")
    game:GetService("ReplicatedStorage").Package.Events.block:InvokeServer(true)
    local gohan = workspace.Living:WaitForChild(npc)
    if not gohan or not gohan:FindFirstChild("Humanoid") then
        return 
    end

    if gohan.Humanoid.Health > 0 then
        while _G.farm and gohan.Humanoid.Health > 0 and task.wait() do
            
            -- mover el personaje hasta gohan
            coroutine.wrap(function()
                -- character del player
                local c = getCharacter()
                -- HumanoidRootPart del player
                local cHRP = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart")
                -- HumanoidRootPart de gohan 
                local eHRP = gohan:FindFirstChild("HumanoidRootPart") or gohan:WaitForChild("HumanoidRootPart")

                if not eHRP then return end

                -- actualizar la posicion del personaje
                while _G.farm and gohan.Humanoid.Health > 0 and task.wait() do
                    if not eHRP then break end
                    if not cHRP then cHRP = c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart") end
                    local direction = (eHRP.Position - cHRP.Position).unit -- Obtiene la dirección normalizada
                    cHRP.CFrame = CFrame.new(eHRP.Position + direction) * CFrame.Angles(0, math.pi / 2, 0) -- Ajusta la posición y la orientación
                    task.wait(.5)
                end
            end)()

            -- atacar
            for i = 1, 4 do
                punchEvent:FireServer("Blacknwhite27", i)
            end

            task.wait()
        end
    end
end



-- main loop
while _G.farm and task.wait() do

    if _G.rebirth then
        rebEvent:InvokeServer()
    end

    local currentTime = game.Lighting.ClockTime
    if currentTime > 0 and currentTime < 12 then 
        teleportEvent:InvokeServer("Earth")
    end

    coroutine.wrap(function() 
            while _G.farm and task.wait() do
                chargeEvent:InvokeServer("Blacknwhite27")
                task.wait()
            end
    end)()
    
    if activeQuest.Value == "" then
        getQuest("Kid Nohag")
    end

    if activeQuest.Value ~= "" then
        farmNPC("Kid Nohag")
    end
end
