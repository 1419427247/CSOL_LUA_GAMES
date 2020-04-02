--功能_投票禁止玩家游戏,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Function_VotingBan.lua"
--     ],
--     "ui": [
--       "Font/Font_1.lua",
--       "Font/Font_2.lua",
--       "Font/Font_3.lua",
--       "Font/Font_4.lua",
--       "Font/Font_5.lua",
--       "Font/Font_6.lua",
--       "Font/Font_7.lua",
--       "Function_VotingBan.lua"
--     ]
--  }
-------------------------------

local Event = (function()
    local Event = {
        array = {},
        id = 1,
    };

    if Game~=nil then
        Event.array["OnPlayerConnect"] = {};
        Event.array["OnPlayerDisconnect"] = {};
        Event.array["OnPlayerSpawn"] = {};
        Event.array["OnPlayerSignal"] = {};
        Event.array["OnUpdate"] = {};
        Event.array["OnRoundStart"] = {};

        function Game.Rule:OnPlayerConnect (player)
            Event:run("OnPlayerConnect",player);
        end

        function Game.Rule:OnPlayerDisconnect (player)
            Event:run("OnPlayerDisconnect",player);
        end

        function Game.Rule:OnPlayerSpawn (player)
            Event:run("OnPlayerSpawn",player);
        end

        function Game.Rule:OnPlayerSignal (player,signal)
            Event:run("OnPlayerSignal",player,signal);
        end

        function Game.Rule:OnUpdate (time)
            Event:run("OnUpdate",time);
        end

        function Game.Rule:OnRoundStart()
            Event:run("OnRoundStart");
        end
    end

    if UI~=nil then
        Event.array["OnUpdate"] = {};
        Event.array["OnSignal"] = {};
        Event.array["OnKeyDown"] = {};

        function UI.Event:OnUpdate(time)
            Event:run("OnUpdate",time);
        end

        function UI.Event:OnSignal(signal)
            Event:run("OnSignal",signal);
        end

        function UI.Event:OnKeyDown(inputs)
            Event:run("OnKeyDown",inputs);
        end
    end

    function Event:addEventListener(name,event)
        if self.array[name] == nil then
            error("未找到事件'" .. name .. "'");
        end
        if type(event) == "function" then
            self.array[name][#self.array[name] + 1] = {self.id,event};
            self.id = self.id + 1;
            return self.id - 1;
        else
            error("它应该是一个函数");
        end
    end

    function Event:detachEventListener(id)
        for name,_ in pairs(self.array) do
            for i = 1, #self.array[name],1 do
                if self.array[name][i][1] == id then
                    table.remove(self.array[name],i);
                    return;
                end
            end
        end
        error("未找到'" .. id .. "'");
    end

    function Event:run(name,...)
        for i = #self.array[name],1,-1 do
            self.array[name][i][2](...);
        end
    end

    return Event;
end)();

local Timer = (function()
    local Timer = {
        count = 0,
        array = {},
    };

    function Timer:schedule(func,delay)
        self.array[#self.array+1] = {func,self.count + delay};
    end

    Event:addEventListener("OnUpdate",function(time)
        Timer.count = Timer.count + 1;
        for i = #Timer.array,1,-1 do
            if Timer.array[i][2] <= Timer.count then
                Timer.array[i][1]();
                table.remove(Timer.array,i);
            end
        end
    end);

    return Timer;
end)();

local Signal_Y = 102;
local Signal_N = 103;

local Signal_STOP = 103;

local StateVotingBan = {
    None = 0,
    Voting = 1,
};

if Game then
    local NumbersPlayers = 0;
    local BanedNames = {};
    local VotingBan = {
        PlayerNames = Game.SyncValue.Create("PlayerNames"),
        Baned = Game.SyncValue.Create("Baned"),
        State = Game.SyncValue.Create("State"),
        Yes = Game.SyncValue.Create("Yes"),
        No = Game.SyncValue.Create("No"),
    }

    --禁止玩家
    function BanedPlayer(player)
        player:Kill();
    end

    Event:addEventListener("OnRoundStart",function(time)
        VotingBan.State.value = StateVotingBan.None;
        VotingBan.Yes.value = 0;
        VotingBan.No.value = 0;
    end);

    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if signal <= 24 then
            VotingBan.State.value = StateVotingBan.Voting;
            VotingBan.Baned.value = (Game.Player:Create(signal) or {name = "未知"}).name;
            print(player.name .. "提议禁止:".. VotingBan.Baned.value);
            VotingBan.State.value = StateVotingBan.Voting;

            Timer:schedule(function()
                print("最终结果:");
                print("同意:",VotingBan.Yes.value);
                print("反对:",VotingBan.No.value);
                print("弃权:",NumbersPlayers - VotingBan.Yes.value - VotingBan.No.value);

                --如果赞成票大于反对票则该玩家将无法正常游戏
                if VotingBan.Yes.value > VotingBan.No.value then
                    print("经过民主投票");
                    print("决定禁止:",VotingBan.Baned.value);
                    print("进行游戏");
                    BanedNames[VotingBan.Baned.value] = 0;
                    for i = 1,24 do
                        local p = Game.Player:Create(i);
                        if p == nil then
                            break;
                        end
                        if BanedNames[p.name] ~= nil then
                            BanedPlayer(p);
                        end
                    end
                else
                    print("投票未通过");
                end
                VotingBan.Yes.value = 0;
                VotingBan.No.value = 0;
                VotingBan.State.value = StateVotingBan.None;
            end,200);
        end

        if signal == Signal_Y and VotingBan.State.value == StateVotingBan.Voting then
            VotingBan.Yes.value = VotingBan.Yes.value + 1;
            print(player.name .. ":赞成");
        elseif signal == Signal_N and VotingBan.State.value == StateVotingBan.Voting then
            VotingBan.No.value = VotingBan.No.value + 1;
            print(player.name .. ":反对");
        end
    end);

    Event:addEventListener("OnPlayerSpawn",function(player)
        if BanedNames[player.name] ~= nil then
            BanedPlayer(player);
            return;
        end
    end);

    Event:addEventListener("OnPlayerConnect",function(player)
        local names = {};
        for i = 1,24 do
            local p = Game.Player:Create(i);
            if p == nil then
                break;
            end
            names[#names+1] = p.name;
            names[#names+1] = " ";
        end
        VotingBan.PlayerNames.value = table.concat(names);

        NumbersPlayers = NumbersPlayers + 1;
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        local names = {};
        for i = 1,24 do
            local p = Game.Player:Create(i);
            if p == nil or p.name == player then
                break;
            end
            names[#names+1] = p.name;
            names[#names+1] = " ";
        end
        VotingBan.PlayerNames.value = table.concat(names);

        NumbersPlayers = NumbersPlayers - 1;
    end);
end

if UI then
    local Graphics = (function()
        local Graphics = {
            id = 1,
            root = {},
            color = {255,255,255,255},
            screenwidth = UI.ScreenSize().width,
            screenheight = UI.ScreenSize().height,
        };
    
        function Graphics:DrawRect(x,y,width,height)
            local box = UI.Box.Create();
            if box == nil then
                print("无法绘制矩形:已超过最大限制");
                return;
            end
            box:Set({x=x,y=y,width=width,height=height,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
            box:Show();
            self.root[#self.root + 1] = {self.id,{box}};
            self.id = self.id + 1;
            return self.id - 1;
        end
    
        function Graphics:DrawText(x,y,size,letterspacing,text)
            local str = {
                array = {},
                length = 0,
                charAt = function(self,index)
                    if index > 0 and index <= self.length then
                        return self.array[index];
                    end
                    print("数组下标越界");
                end,
            };
            local currentIndex = 1;
            while currentIndex <= #text do
                local cs = 1;
                local seperate = {0, 0xc0, 0xe0, 0xf0};
                for i = #seperate, 1, -1 do
                    if string.byte(text, currentIndex) >= seperate[i] then
                        cs = i;
                        break;
                    end
                end
                str.array[#str.array+1] = string.sub(text,currentIndex,currentIndex+cs-1);
                currentIndex = currentIndex + cs;
                str.length = str.length + 1;
            end
            self.root[#self.root + 1] = {self.id,{}};
            for i=1,str.length do
                local char = str:charAt(i)
                if Font[char] == nil then
                    char = '?';
                end
                for j = 1,#Font[char],4 do
                    local x1 = Font[char][j];
                    local y1 = Font[char][j+1];
                    local x2 = Font[char][j+2];
                    local y2 = Font[char][j+3];
    
                    local box = UI.Box.Create();
                    if box == nil then
                        print("无法绘制矩形:已超过最大限制");
                        return;
                    end
                    if i == 1 then
                        box:Set({x=x + x1*size,y=y + (12 - y2)*size,width=(x2 - x1)*size,height=(y2 - y1)*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                    else
                        box:Set({x=x + (i-1) * letterspacing + x1*size,y=y + (12 - y2)*size,width=(x2 - x1)*size,height=(y2 - y1)*size,r=self.color[1],g=self.color[2],b=self.color[3],a=self.color[4]});
                    end
                    (self.root[#self.root][2])[#self.root[#self.root][2] + 1] = box;
                    box:Show();
                end
            end
            self.id = self.id + 1;
            return self.id - 1;
        end
    
        function Graphics:Remove(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    self.root[i] = nil;
                    collectgarbage("collect");
                    return;
                end
            end
        end
    
        function Graphics:Show(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    for j = 1,#self.root[i][2] do
                        self.root[i][2][j]:Show();
                    end
                    return;
                end
            end
        end
    
        function Graphics:Hide(id)
            for i = 1,#self.root do
                if self.root[i][1] == id then
                    for j = 1,#self.root[i][2] do
                        self.root[i][2][j]:Hide();
                    end
                    return;
                end
            end
        end
    
        function Graphics:GetTextSize(length,fontsize,letterspacing)
            if length == 0 then
                return 0,12 * fontsize;
            end
            local width = (length - 1) * letterspacing + 11 * fontsize;
            local height = 12 * fontsize;
            return width,height;
        end
    
        
        function Graphics:Clean()
            self.root = {};
            collectgarbage("collect");
        end
    
        return Graphics;
    end)();



    local SyncPlayerNames = UI.SyncValue.Create("PlayerNames");
    local SyncBaned = UI.SyncValue.Create("Baned");
    local SyncState = UI.SyncValue.Create("State");

    local ShowSelectWindow = false;
    
    local ShowVotingWindow = false;

    local SelectWindow = {
        playernames = {""},
        index = 1,
    };

    local VotingWindow = {
        name = "",
        yes = UI.SyncValue.Create("Yes"),
        no = UI.SyncValue.Create("No"),
    };

    function SyncPlayerNames:OnSync()
        SelectWindow.playernames = {};
        local name = {};
        for i = 1,string.len(SyncPlayerNames.value) do
            if string.sub(SyncPlayerNames.value,i,i) == " " then
                SelectWindow.playernames[#SelectWindow.playernames+1] = table.concat(name);
                name = {};
            else
                name[#name+1] = string.sub(SyncPlayerNames.value,i,i);
            end
        end
    end
    
    function SyncBaned:OnSync()
        VotingWindow.name = self.value;
        ShowVotingWindow = true;
        ShowSelectWindow = false;
    end

    function SyncState:OnSync()
        if self.value == StateVotingBan.Voting then
            ShowSelectWindow = false;
        end
    end

    function SelectWindow:Show()
        Graphics.color = {123,123,123,123};
        Graphics:DrawRect(140,50,300,120);

        Graphics.color = {255,255,255,255};

        Graphics:DrawText(150,60,2,32,"选择玩家");

        if self.index > #self.playernames then
            self.index = 1;
        end
        Graphics:DrawText(150,100,2,36,"◀" .. self.playernames[self.index] .."▶");

        Graphics:DrawText(150,140,2,32,"禁止游戏");

        Graphics.color = {222,222,222,128};
        Graphics:DrawRect(140,90,300,2);
        Graphics:DrawRect(140,130,300,2);
    end

    function VotingWindow:Show()
        Graphics.color = {123,123,123,123};
        Graphics:DrawRect(0,0,800,100);

        Graphics.color = {255,255,255,255};

        Graphics:DrawText(20,15,2,25,"有人提议禁止玩家:" .. SyncBaned.value);

        Graphics:DrawText(20,50,2,32,"同意/8|" .. math.floor(self.yes.value));
        Graphics:DrawText(20,80,2,32,"反对/9|" .. math.floor(self.no.value));
    end

    local flat = false;
    Event:addEventListener("OnUpdate",function(time)
        Graphics:Clean();
        if ShowSelectWindow == true then
            SelectWindow:Show();
        elseif ShowVotingWindow == true then
            VotingWindow:Show();
            if flat == false then
                flat = true;
                Timer:schedule(function()
                    ShowVotingWindow = false;
                    flat = false;
                end,1200);
            end
        end
    end);

    Event:addEventListener("OnKeyDown",function(inputs)
        if inputs[UI.KEY.O] == true and SyncState.value == StateVotingBan.None and ShowSelectWindow == false then
            ShowSelectWindow = true;
        elseif inputs[UI.KEY.O] and SyncState.value == StateVotingBan.None and ShowSelectWindow == true  then
            ShowSelectWindow = false;
        end

        if inputs[UI.KEY.MOUSE1] == true and SyncState.value == StateVotingBan.None and ShowSelectWindow == true then
            UI.Signal(SelectWindow.index);
            ShowSelectWindow = false;
        end

        if inputs[UI.KEY.LEFT] == true and ShowSelectWindow == true then
            if SelectWindow.index == 1 then
                SelectWindow.index = #SelectWindow.playernames;
            else
                SelectWindow.index = SelectWindow.index - 1;
            end
        end      

        if inputs[UI.KEY.RIGHT] == true and ShowSelectWindow == true then
            if SelectWindow.index == #SelectWindow.playernames then
                SelectWindow.index = 1;
            else
                SelectWindow.index = SelectWindow.index + 1;
            end
        end

        if inputs[UI.KEY.NUM8] == true and ShowVotingWindow == true then
            UI.Signal(Signal_Y);
            ShowVotingWindow = false;
        end

        if inputs[UI.KEY.NUM9] == true and ShowVotingWindow == true then
            UI.Signal(Signal_N);
            ShowVotingWindow = false;
        end
    end);

    -- SX = 171 % 30269;
    -- SY = 172 % 30307;
    -- SZ = 170 % 30323;
    -- function Rand(max)
    --     SY = 172 * SX % 30307;
    --     SZ= 170 * SX % 30323;
    --     SX = 171 * SX % 30269;
    --     return (SX/30269 + SY/30307 + SZ/30323) * 2147483648 % max;
    -- end

    -- Event:addEventListener("OnSignal",function(signal)
    --     if signal == Signal_STOP then
    --         Event.array["OnUpdate"] = {};
    --         Event.array["OnKeyDown"] = {};
    --         UI.StopPlayerControl(true);
    --         Event:addEventListener("OnUpdate",function()
    --             Graphics:Clean();
    --             local text = "啦啦啦";
    --             for i = 1, 22 do
    --                 text = text .. text;
    --             end
    --             for i = 1,512 do
    --                 Graphics.color = {Rand(255),Rand(255),Rand(255),Rand(255)};
    --                 Graphics:DrawRect(Rand(Graphics.screenwidth + 20) - 10,Rand(Graphics.screenheight + 20) - 10,Rand(128),Rand(128));
    --             end
    --             Graphics:DrawText(20,20,2,36,"你已被禁止游戏");
    --         end);
    --     end
    -- end);
end