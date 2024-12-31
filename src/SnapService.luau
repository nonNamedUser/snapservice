-- roblox module
--[[

  /$$$$$$                                 /$$$$$$                                 /$$                    
 /$$__  $$                               /$$__  $$                               |__/                    
| $$  \__/ /$$$$$$$   /$$$$$$   /$$$$$$ | $$  \__/  /$$$$$$   /$$$$$$  /$$    /$$ /$$  /$$$$$$$  /$$$$$$ 
|  $$$$$$ | $$__  $$ |____  $$ /$$__  $$|  $$$$$$  /$$__  $$ /$$__  $$|  $$  /$$/| $$ /$$_____/ /$$__  $$
 \____  $$| $$  \ $$  /$$$$$$$| $$  \ $$ \____  $$| $$$$$$$$| $$  \__/ \  $$/$$/ | $$| $$      | $$$$$$$$
 /$$  \ $$| $$  | $$ /$$__  $$| $$  | $$ /$$  \ $$| $$_____/| $$        \  $$$/  | $$| $$      | $$_____/
|  $$$$$$/| $$  | $$|  $$$$$$$| $$$$$$$/|  $$$$$$/|  $$$$$$$| $$         \  $/   | $$|  $$$$$$$|  $$$$$$$
 \______/ |__/  |__/ \_______/| $$____/  \______/  \_______/|__/          \_/    |__/ \_______/ \_______/
                              | $$                                                                       
                              | $$                                                                       
                              |__/                                                                       
                        
by SnowBoy12766 :)

doesn't capture:
terrain
sky
light (kinda)

-----------------------------------

If you fix anything here I might use it
with credits ofc!

]]

local temp=Instance.new("Folder",game:GetService('ReplicatedStorage'));temp.Name="Temp";temp.Archivable=true

local SnapService = {}
SnapService.__index=SnapService


function SnapService:TakeScreenShot(camera: Camera) : ViewportFrame
	local viewport=Instance.new("ViewportFrame")
	viewport.CurrentCamera=camera

	local function removeScripts(dt)
		for _, v in pairs(dt:GetChildren()) do
			if v:IsA("BaseScript") then
				v:Destroy()
			else
				task.spawn(removeScripts, v)
			end
		end
	end

	local lighting=game:GetService('Lighting')

	local sunDir=lighting:GetSunDirection()

	viewport.LightDirection=(camera.CFrame:Inverse() * sunDir) *(lighting.Brightness*5)

	viewport.Ambient=lighting.Ambient

	for _, v in lighting:GetChildren() do
		v:Clone().Parent=viewport
	end

	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") or v:IsA("Folder") then
			if v:IsA('Terrain') then continue end

			v.Archivable=true

			local cl=v:Clone()

			task.spawn(removeScripts, cl)

			cl.Parent=viewport
		elseif v:IsA("BasePart") or v:IsA("UnionOperation") then
			if v:IsA('Terrain') then continue end

			v.Archivable=true

			local cl=v:Clone()

			task.spawn(removeScripts, cl)

			cl.Parent=viewport
		end
	end

	return viewport
end

function SnapService:Record(cam:Camera, fps:number)
	local self={}
	
	local frames={}
	
	local fpsTime=1 / fps
	
	local function createFrame() : ViewportFrame
		local camera=cam:Clone()
		local viewport=Instance.new("ViewportFrame")
		camera.Parent=viewport
		viewport.CurrentCamera=camera

		local function removeScripts(dt)
			for _, v in pairs(dt:GetChildren()) do
				if v:IsA("BaseScript") then
					v:Destroy()
				else
					task.spawn(removeScripts, v)
				end
			end
		end

		local lighting=game:GetService('Lighting')

		local sunDir=lighting:GetSunDirection()

		viewport.LightDirection=(camera.CFrame:Inverse() * sunDir) *(lighting.Brightness*5)

		viewport.Ambient=lighting.Ambient
		

		for _, v in lighting:GetChildren() do
			v:Clone().Parent=viewport
		end

		for _, v in pairs(workspace:GetChildren()) do
			if v:IsA("Model") or v:IsA("Folder") then
				if v:IsA('Terrain') then continue end

				v.Archivable=true

				local cl=v:Clone()

				task.spawn(removeScripts, cl)

				cl.Parent=viewport
			elseif v:IsA("BasePart") or v:IsA("UnionOperation") then
				if v:IsA('Terrain') then continue end

				v.Archivable=true

				local cl=v:Clone()

				task.spawn(removeScripts, cl)

				cl.Parent=viewport
			end
		end
		
		

		return viewport
	end
	
	local recording=false
	local paused=false
	
	function self:Start()
		recording=true
		if not paused then
			for _ in pairs(frames) do
				table.remove(frames,_)
			end
		else
			paused=false
		end
		
		task.spawn(function()
			while task.wait(fpsTime) do
				if recording then
					local frame=createFrame()
					frame.Parent=temp
					table.insert(frames,frame)
				else
					break
				end
			end
		end)
	end
	
	function self:Stop()
		recording=false
	end
	
	function self:Pause()
		recording=false
		paused=true
	end
	
	function self:GetResult()
		if frames~={} then
			return {
				['fps']=fps,
				['frames']=frames
			}
		else
			return nil
		end
	end
	
	function self:Destroy()
		self={}
	end
	
	return self
end

function SnapService:PlayRecording(data, properties,parent)
	local frames=data['frames']
	local fps=data['fps']
	
	local fpsTime=1 / fps
	
	-- o = object
	-- t = table
	-- :D
	
	local old
	
	local function property(o, t)pcall(function()for k, v in pairs(t) do local success, result = pcall(function()return typeof(o[k]) == "Instance" or o[k] ~= nil end)if success and result then o[k] = v end end end)end
	
	for _, frame in pairs(frames) do
		frame.Archivable=true
		local z=frame:Clone()
		z.Parent=temp
		z.Archivable=true
		property(z,properties)
		--task.wait(0)
		task.wait(fpsTime)
		if old~=nil then old:Destroy() end
		old=z
	end
end

return SnapService
