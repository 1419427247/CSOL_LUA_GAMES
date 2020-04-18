--游戏_角斗场,无限的尸潮,最后活下来的才是胜利者,作者@iPad水晶,QQ:1419427247
--游戏初始时需要使用脚本调用方块设置一次怪物出生地, 函数名:CreateMonsterBirthplace 参数:CT 或者 TR
--请使用虚拟对手集结装置让怪物移动到指定的区域
-- {
--     "common":[
--       "Game_Arena.lua"
--      ],
--     "game": [
--       "Game_Arena.lua"
--     ],
--     "ui": [
--       "Font/Font_1.lua",
--       "Font/Font_2.lua",
--       "Font/Font_3.lua",
--       "Font/Font_4.lua",
--       "Font/Font_5.lua",
--       "Font/Font_6.lua",
--       "Font/Font_7.lua",
--       "Game_Arena.lua"
--     ]
--   }

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
        Event.array["OnPlayerAttack"] = {};
        Event.array["OnKilled"] = {};

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

        function Game.Rule:OnPlayerAttack(victim,attacker,damage,weapontype,hitbox)
            Event:run("OnPlayerAttack",victim,attacker,damage,weapontype,hitbox);
        end
        
        function Game.Rule:OnKilled (victim,killer)
            Event:run("OnKilled",victim,killer);
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
        if type(event) == "function" then
            self.array[name][#self.array[name] + 1] = {self.id,event};
            self.id = self.id + 1;
            return self.id - 1;
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
        id = 1,
        tasks = {},
        destroyedtasks = {}
    };

    function Timer:schedule(fun,delay,period)
        if Game ~= nil then
            self.tasks[tostring(self.id)] = {func = fun,time = Game.GetTime() + delay,period = period};
        end
        if UI ~= nil then
            self.tasks[tostring(self.id)] = {func = fun,time = UI.GetTime() + delay,period = period};
        end
        self.id = self.id + 1;
        return self.id - 1;
    end

    function Timer:cancel(id)
        self.destroyedtasks[#self.destroyedtasks + 1] = tostring(id);
    end

    function Timer:purge()
        self.tasks = {}
    end

    Event:addEventListener("OnUpdate",function(time)
        for i = 1,#Timer.destroyedtasks do
            Timer.tasks[Timer.destroyedtasks[i]] = nil;
        end
        Timer.destroyedtasks = {};
        for key, value in pairs(Timer.tasks) do
            if value.time < time then
                if not pcall(value.func) then
                    Timer.tasks[key] = nil;
                    print("Timer:ID为:[" .. key .. "]的函数发生了异常");
                elseif value.period == nil then
                    Timer.tasks[key] = nil;
                else
                    value.time = time + value.period;
                end
            end
        end
    end);

    return Timer;
end)();

local Graphics = (function()
    if not UI then
        return;
    end
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

    function Graphics:Clean()
        self.root = {};
        collectgarbage("collect");
    end

    return Graphics;
end)();

------------------------------------------------
local SIGNAL = {
    OPEN_WEAPON_PACK = 1,
    MONSTER_LEVEL_UP = 2,
    PLAYER_LEVEL_UP = 3,
};

if Common then
    Common.UseWeaponInven(true);
    Common.UseScenarioBuymenu(true);
    Common.SetNeedMoney(true);
end

if Game then
    local Players = {
        CT = {},
        TR = {},
    };

    --储存怪物的初始信息
    local Monster = {
      NORMAL0 = {type = Game.MONSTERTYPE.NORMAL0,damage = 10,speed = 0.5,health = 40,coin = 150},
      NORMAL1 = {type = Game.MONSTERTYPE.NORMAL1,damage = 12,speed = 0.64,health = 37,coin = 180},
      NORMAL2 = {type = Game.MONSTERTYPE.NORMAL2,damage = 15,speed = 0.69,health = 26,coin = 190},
      NORMAL3 = {type = Game.MONSTERTYPE.NORMAL3,damage = 18,speed = 0.78,health = 26,coin = 190},
      NORMAL4 = {type = Game.MONSTERTYPE.NORMAL4,damage = 19,speed = 0.92,health = 20,coin = 250},
      NORMAL5 = {type = Game.MONSTERTYPE.NORMAL5,damage = 22,speed = 0.94,health = 25,coin = 260},
      NORMAL6 = {type = Game.MONSTERTYPE.NORMAL6,damage = 23,speed = 1.1,health = 30,coin = 270},

      RUNNER0 = {type = Game.MONSTERTYPE.RUNNER0,damage = 5,speed = 0.6,health = 3,coin = 225},
      RUNNER1 = {type = Game.MONSTERTYPE.RUNNER1,damage = 8,speed = 0.7,health = 6,coin = 230},
      RUNNER2 = {type = Game.MONSTERTYPE.RUNNER2,damage = 9,speed = 0.8,health = 9,coin = 235},
      RUNNER3 = {type = Game.MONSTERTYPE.RUNNER3,damage = 10,speed = 0.9,health = 18,coin = 240},
      RUNNER4 = {type = Game.MONSTERTYPE.RUNNER4,damage = 12,speed = 1.0,health = 21,coin = 245},
      RUNNER5 = {type = Game.MONSTERTYPE.RUNNER5,damage = 14,speed = 1.1,health = 24,coin = 280},
      RUNNER6 = {type = Game.MONSTERTYPE.RUNNER6,damage = 16,speed = 1.2,health = 35,coin = 325},

      HEAVY1 = {type = Game.MONSTERTYPE.HEAVY1,damage = 15,speed = 0.8,health = 220,coin = 380},
      HEAVY2 = {type = Game.MONSTERTYPE.HEAVY2,damage = 20,speed = 0.9,health = 220,coin = 380},

      GHOST = {type = Game.MONSTERTYPE.GHOST,damage = 30,speed = 0.7,health = 80,coin = 370},
      PUMPKIN = {type = Game.MONSTERTYPE.PUMPKIN,damage = 44,speed = 1.3,health = 120,coin = 430},
      PUMPKINHEAD = {type = Game.MONSTERTYPE.PUMPKINHEAD,damage = 50,speed = 1.4,health = 120,coin = 410},

      A101AR = {type = Game.MONSTERTYPE.A101AR,damage = 40,speed = 0.8,health = 300,coin = 730},
      A104RL = {type = Game.MONSTERTYPE.A104RL,damage = 35,speed = 0.6,health = 300,coin = 930},
    };
    
    local MonsterList = {
        {1,{Monster.NORMAL0,Monster.NORMAL2}},
        {3,{Monster.NORMAL0,Monster.NORMAL1,Monster.NORMAL2}},
        {4,{Monster.NORMAL0,Monster.RUNNER0,Monster.NORMAL1,Monster.NORMAL2,Monster.NORMAL3}},
        {6,{Monster.NORMAL0,Monster.NORMAL1,Monster.NORMAL2,Monster.NORMAL3}},
        {7,{Monster.NORMAL0,Monster.RUNNER0,Monster.RUNNER0,Monster.NORMAL2,Monster.NORMAL3}},
        {9,{Monster.NORMAL0,Monster.RUNNER1,Monster.RUNNER2,Monster.NORMAL3,Monster.NORMAL3}},
        {11,{Monster.NORMAL0,Monster.RUNNER2,Monster.RUNNER3,Monster.NORMAL4,Monster.NORMAL4}},
        {13,{Monster.NORMAL0,Monster.RUNNER3,Monster.RUNNER4,Monster.NORMAL5,Monster.NORMAL5}},
        {15,{Monster.RUNNER4,Monster.RUNNER5,Monster.NORMAL6,Monster.NORMAL6}},
        {18,{Monster.RUNNER4,Monster.RUNNER5,Monster.NORMAL6,Monster.HEAVY1,Monster.HEAVY2}},
        {20,{Monster.A101AR,Monster.A104RL,Monster.PUMPKINHEAD,Monster.PUMPKIN,Monster.HEAVY2,Monster.RUNNER6}},
}

    local MonsterListIndex = 1;

    local GameStarted = false;
    local NewRound = false;

    --升级怪物需要的硬币数
    local Monster_Update_Coin = 6000;
    --升级玩家需要的硬币数
    local Player_Update_Coin = 2000;

    --游戏回合数
    local Round = Game.SyncValue:Create("Round");

    local CTKills = Game.SyncValue:Create("CTKills");
    local TRKills = Game.SyncValue:Create("TRKills");

    local CTLevel = Game.SyncValue:Create("CTLevel");
    local TRLevel = Game.SyncValue:Create("TRLevel");

    --每个回合的时长
    local Count = Game.SyncValue:Create("Count");
    local Message = Game.SyncValue:Create("Message");

    Round.value = 0;
    TRKills.value = 0;
    CTKills.value = 0;

    CTLevel.value = 1;
    TRLevel.value = 1;

    Count.value = 0;
    Message.value = "";

    local MonsterBirthplace = {
        CT = {},
        TR = {},
    };

    --单个阵营允许刷新的最大僵尸数
    local MaxMonsterNumber = 20;

    local CTMonsters = 0;
    local TRMonsters = 0;

    function CreateMonsterBirthplace(self,team)
        local position = Game.GetScriptCaller().position;
        if team == "CT" then
            MonsterBirthplace.CT[#MonsterBirthplace.CT+1] = position;
        elseif team == "TR" then
            MonsterBirthplace.TR[#MonsterBirthplace.TR+1] = position;
        end
    end

    function CreateMonster(team,monster)
        local p_monster;
        if team == Game.TEAM.CT and #MonsterBirthplace.TR > 0 then
            p_monster = Game.Monster:Create(monster.type,MonsterBirthplace.CT[math.random(1,#MonsterBirthplace.CT)]);
        elseif team == Game.TEAM.TR and #MonsterBirthplace.CT > 0 then
            p_monster = Game.Monster:Create(monster.type,MonsterBirthplace.TR[math.random(1,#MonsterBirthplace.TR)]);
        end

        if p_monster ~= nil then
            p_monster.user.team = team;
            p_monster.checkAngle = 360;
            p_monster.viewDistance = 360;
            if team == Game.TEAM.CT then
                p_monster.health = math.floor(monster.health * (1 + CTLevel.value / 3));
                p_monster.damage = math.floor(monster.damage * (1 + CTLevel.value / 5));
                p_monster.speed = monster.speed + CTLevel.value * 0.04;
                p_monster.coin = monster.coin + math.floor(CTLevel.value * 8.75);
                CTMonsters = CTMonsters + 1;
            elseif team == Game.TEAM.TR then
                p_monster.health = math.floor(monster.health * (1 + TRLevel.value / 3));
                p_monster.damage = math.floor(monster.damage * (1 + TRLevel.value / 5));
                p_monster.speed = monster.speed + TRLevel.value * 0.04;
                p_monster.coin = monster.coin + math.floor(TRLevel.value * 8.75);
                TRMonsters = TRMonsters + 1;
            end
        end
    end

    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if signal == SIGNAL.OPEN_WEAPON_PACK then
            player:ShowBuymenu();

        elseif signal == SIGNAL.MONSTER_LEVEL_UP then
            if player.coin >= Monster_Update_Coin then
                if player.team == Game.TEAM.CT then
                    Message.value = "CT升级了僵尸";
                    TRLevel.value = TRLevel.value + 1;
                else
                    Message.value = "TR升级了僵尸";
                    CTLevel.value = CTLevel.value + 1;
                end
                player.coin = player.coin - Monster_Update_Coin;
            end

        elseif signal == SIGNAL.PLAYER_LEVEL_UP then
            if player.coin >= Player_Update_Coin then
                player.user.level = player.user.level + 1;

                player.maxhealth = player.maxhealth + 5;
                player.health = player.maxhealth;
                
                player.maxarmor = player.maxarmor + 5;
                player.armor = player.maxarmor;
                
                player.coin = player.coin - Player_Update_Coin;
                Message.value = player.name .. player.user.level .. "级";
            end
        end
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        if player.team == Game.TEAM.CT then
            for i=1,#Players.CT do
                if Players.CT[i].name == player.name then
                    table.remove(Players.CT,i)
                    break;
                end
            end
        else
            for i=1,#Players.TR do
                if Players.TR[i].name == player.name then
                    table.remove(Players.TR,i)
                    break;
                end
            end
        end

        if #Players.CT == 0 then
            NewRound = false;
            Game.Rule:Win(Game.TEAM.TR);
        elseif #Players.TR == 0 then
            NewRound = false;
            Game.Rule:Win(Game.TEAM.CT);
        end
    end);

    Event:addEventListener("OnPlayerAttack",function(victim,attacker,damage,weapontype,hitbox)
        if victim.health - damage > victim.maxhealth / 3 * 2 then
            victim:SetRenderColor({r = 0,g = 255,b = 0});
        elseif victim.health - damage > victim.maxhealth / 3 then
            victim:SetRenderColor({r = 255,g = 255,b = 0});
        else
            victim:SetRenderColor({r = 255,g = 0,b = 0});
        end
    end);

    Event:addEventListener("OnKilled",function(victim,killer)
        if victim:IsPlayer() then
            victim = victim:ToPlayer();

             -- 玩家死亡后扣除25%的硬币
            victim.coin = victim.coin - math.floor(victim.coin * 0.25);

            if victim.team == Game.TEAM.CT then
                for i=1,#Players.CT do
                    if Players.CT[i].name == victim.name then
                        table.remove(Players.CT,i)
                        break;
                    end
                end
            else
                for i=1,#Players.TR do
                    if Players.TR[i].name == victim.name then
                        table.remove(Players.TR,i)
                        break;
                    end
                end
            end

            if #Players.CT == 0 then
                Game.Rule:Win(Game.TEAM.TR);
                Game.SetTrigger("CTWin",true);
            elseif #Players.TR == 0 then
                Game.Rule:Win(Game.TEAM.CT);
                Game.SetTrigger("TRWin",true);
            end
        elseif victim:IsMonster() and killer then
            victim = victim:ToMonster();
            if victim.user.team == Game.TEAM.TR then
                TRKills.value = TRKills.value + 1;
                TRMonsters = TRMonsters - 1;
            end
            if victim.user.team == Game.TEAM.CT then
                CTKills.value = CTKills.value + 1;
                CTMonsters = CTMonsters - 1;
            end
        end

    end);

    local Tid = -1;
    function OnNewRound()
        NewRound = true;
        Game.Rule.respawnable = true;
        
        Timer:cancel(Tid);

        Game.KillAllMonsters();
        
        Round.value = Round.value + 1;
        TRKills.value = 0;
        CTKills.value = 0;

        CTMonsters = 0;
        TRMonsters = 0;

        Count.value = 90;

        for i = 1,24 do
            local player = Game.Player:Create(i);
            if player == nil then
                break;
            end
            player:SetRenderFX(Game.RENDERFX.GLOWSHELL);
            player:SetRenderColor({r = 0,g = 255,b = 0});
    
            player.user.level = player.user.level or 1;
    
            if player.team == Game.TEAM.CT then
                Players.CT[#Players.CT + 1] = player;
            elseif player.team == Game.TEAM.TR then
                Players.TR[#Players.TR + 1] = player;
            end
        end

        for i = 1,#MonsterList do
            if MonsterList[i][1] <= Round.value then
                MonsterListIndex = i;
            else
                break;
            end
        end

        Timer:schedule(function()
            GameStarted = true;
            Game.Rule.respawnable = false;
            Message.value = "回合开始";
            Game.SetTrigger("OnRoundStart",true);
            Tid = Timer:schedule(function()
                if GameStarted then
                    Count.value = Count.value - 1;
                    if Count.value == 0 then
                        Game.SetTrigger("OnRoundOver",true);
                        --本回合杀敌最多的阵营，存活的人回满生命和护甲，并得到金钱奖励
                        if CTKills.value > TRKills.value then
                            Message.value = "CT胜利";
                            for i = 1,#Players.CT do
                                Players.CT[i].health = Players.CT[i].maxhealth;
                                Players.CT[i].armor = Players.CT[i].maxarmor;
                                Players.CT[i].coin = Players.CT[i].coin + #Players.CT * 100;
                            end
                        elseif CTKills.value < TRKills.value then
                            Message.value = "T胜利";
                            for i = 1,#Players.TR do
                                Players.TR[i].health = Players.TR[i].maxhealth;
                                Players.TR[i].armor = Players.TR[i].maxarmor;
                                Players.TR[i].coin = Players.TR[i].coin + #Players.TR * 100;
                            end
                        else
                            Message.value = "平局";
                        end
                        NewRound = false;
                        GameStarted = false;
                        Players = {
                            CT = {},
                            TR = {},
                        };
                    end
                end
            end,0,1);
        end,5);
        
    end

    Timer:schedule(function()
        if NewRound == false then
            OnNewRound();
        else
            if GameStarted then
                if #MonsterBirthplace.CT > 0 and CTMonsters < MaxMonsterNumber then
                    CreateMonster(Game.TEAM.CT,MonsterList[MonsterListIndex][2][math.random(1,#MonsterList[MonsterListIndex][2])]);
                end
                if #MonsterBirthplace.TR > 0 and TRMonsters < MaxMonsterNumber then
                    CreateMonster(Game.TEAM.TR,MonsterList[MonsterListIndex][2][math.random(1,#MonsterList[MonsterListIndex][2])]);
                end
            end
        end
    end,0,0.2);
end

if UI then
    local Round = UI.SyncValue:Create("Round");
    local CTKills = UI.SyncValue:Create("CTKills");
    local TRKills = UI.SyncValue:Create("TRKills");

    local CTLevel = UI.SyncValue:Create("CTLevel");
    local TRLevel = UI.SyncValue:Create("TRLevel");

    local Count = UI.SyncValue:Create("Count");
    local Message = UI.SyncValue:Create("Message");

    local MessageAlpha = 255;
    function Message:OnSync()
        MessageAlpha = 255;
    end

    Timer:schedule(function()
        Graphics:Clean();
        Graphics.color = {255,255,255,255};
        Graphics:DrawText(Graphics.screenwidth / 2 - 16,10,2,22,tostring(math.floor(Round.value or 0)));

        Graphics:DrawText(Graphics.screenwidth - 64,10,2,22,tostring(math.floor(Count.value or 0)));
        
        if MessageAlpha - 12 >= 0 then
            MessageAlpha = MessageAlpha - 12;
        end
        Graphics.color = {255,255,255,MessageAlpha};
        Graphics:DrawText(0,Graphics.screenheight - 300,2,24,Message.value or "");

        Graphics.color = {0,0,255,255};
        Graphics:DrawText(0,15,2,22,"等级:"..tostring(math.floor(CTLevel.value or 0)));
        Graphics:DrawText(Graphics.screenwidth / 2 + 98,25,2,22,tostring(math.floor(CTKills.value or 0)));

        Graphics.color = {255,0,0,255};
        Graphics:DrawText(0,50,2,22,"等级:"..tostring(math.floor(TRLevel.value or 0)));
        Graphics:DrawText(Graphics.screenwidth / 2 - 98,25,2,22,tostring(math.floor(TRKills.value or 0)));
    
        Graphics:DrawText(Graphics.screenwidth - 228,Graphics.screenheight - 208,2,22,"E:僵尸升级 6k");
        Graphics:DrawText(Graphics.screenwidth - 228,Graphics.screenheight - 242,2,22,"U:自身升级 2k");
        
    end,1,0.5);

    Event:addEventListener("OnKeyDown",function(inputs)
        if inputs[UI.KEY.B] then
            UI.Signal(SIGNAL.OPEN_WEAPON_PACK);
            return;
        end
        if inputs[UI.KEY.E] then
            UI.Signal(SIGNAL.MONSTER_LEVEL_UP);
            return;
        end
        if inputs[UI.KEY.U] then
            UI.Signal(SIGNAL.PLAYER_LEVEL_UP);
            return;
        end
    end);
end