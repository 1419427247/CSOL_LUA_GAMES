--游戏_危机长夜，作者@iPad水晶,QQ:1419427247
--灵感来自于黎明杀机，游戏分成两个阵营：人类与僵尸，人类手无寸铁要躲避僵尸的追杀，每隔一段时间人类的生命就会减少，
--为了活命人类必须要到指定的地点恢复生命，人类必须利用地形，视角，技能来躲避僵尸的追杀
--不过我现在不想搞了，感觉好无聊，很累啊（＞人＜；）
local Event = (function()
    local Event = {
        array = {},
        id = 1,
    };

    function Event:__add(name)
        if not self.array[name] then
            self.array[name] = {};
            return self;
        end
        error("事件:''" ..name.. "'已经存在,请勿重复添加");
    end

    function Event:__sub(name)
        if self.array[name] then
            self.array[name] = nil;
            return self;
        end
        error("事件:'" ..name.."'不存在");
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
            -- if not pcall(self.array[name][i][2],...) then
            --     print("Event ".. name ..":ID为:[" .. 1 .. "]的监听器发生了异常");
            -- end
            self.array[name][i][2](...);
        end
    end
    Event.__index = Event;

    return setmetatable({},Event);
end)();

local Timer = (function()
    local Timer = {
        id = 1,
        tasks = {},
        destroyedtasks = {}
    };

    function Timer:onUpdate(time)
        for i = 1 , #self.destroyedtasks do
            self.tasks[i] = nil;
        end
        self.destroyedtasks = {};
        for key, value in pairs(self.tasks) do
            if value.time < time then
                if not pcall(value.func) then
                    self.tasks[key] = nil;
                    print("Timer:ID为:[" .. key .. "]的函数发生了异常");
                elseif value.period == nil then
                    self.tasks[key] = nil;
                else
                    value.time = time + value.period;
                end
            end
        end
    end

    function Timer:schedule(fun,delay,period)
        if Game ~= nil then
            self.tasks[self.id] = {func = fun,time = Game.GetTime() + delay,period = period};
        end
        if UI ~= nil then
            self.tasks[self.id] = {func = fun,time = UI.GetTime() + delay,period = period};
        end
        self.id = self.id + 1;
        return self.id - 1;
    end

    function Timer:cancel(id)
        self.destroyedtasks[#self.destroyedtasks + 1] = id;
    end

    function Timer:purge()
        self.tasks = {}
    end

    return Timer;
end)();

local Graphics = (function()
    if UI==nil then
        return nil;
    end
    local Graphics = {
        root = {},
        color = {red = 255,green = 255,blue=255,alpha=255},
        opacity = 1
    };

    function Graphics:drawRect(x,y,width,height,rect)
        local box = UI.Box.Create();
        if box == nil then
                error("无法绘制矩形:已超过最大限制");
        end
        if rect~=nil then
                if x > rect.x + rect.width then
                    return;
                end
                if y > rect.y + rect.height then
                    return;
                end
                if x + width < rect.x or y + height < rect.y then
                    return;
                end
                if x < rect.x then
                     x = rect.x;
                end
                if y < rect.y then
                     y = rect.y;
                end
                if x + width > rect.x + rect.width then
                    width = rect.x + rect.width - x;
                end
                if y + height > rect.y + rect.height then
                    height = rect.y + rect.height - y;
                end
                box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        else
                box:Set({x=x,y=y,width=width,height=height,r=self.color.red,g=self.color.green,b=self.color.blue,a=self.color.alpha * self.opacity});
        end
        box:Show();
        self.root[#self.root+1] = box;
    end

    function Graphics:drawText(x,y,size,letterspacing,text,rect)
        local str = {
                array = {},
                length = 0,
                charAt = function(self,index)
                    if index > 0 and index <= self.length then
                        return self.array[index];
                    end
                    error("数组下标越界");
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
                    if i == 1 then
                        self:drawRect(x + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    else
                        self:drawRect(x + (i-1) * letterspacing + x1*size,y + (12 - y2)*size, (x2 - x1)*size, (y2 - y1)*size,rect);
                    end
                end
        end
    end

    function Graphics:getTextSize(length,fontsize,letterspacing)
        if length == 0 then
            return 0,12 * fontsize;
        end
        local width = (length - 1) * letterspacing + 11 * fontsize;
        local height = 12 * fontsize;
        return width,height;
    end

    function Graphics:clean()
        for i = 1, #self.root, 1 do
            self.root[i] = nil;
        end
        self.root = {};
        collectgarbage("collect");
    end

    return Graphics;
end)();

(function()
    if Game~=nil then
        Event = Event
        + "OnPlayerConnect"
        + "OnPlayerDisconnect"
        + "OnRoundStart"
        + "OnRoundStartFinished"
        + "OnPlayerSpawn"
        + "OnPlayerJoiningSpawn"
        + "OnPlayerKilled"
        + "OnKilled"
        + "OnPlayerSignal"
        + "OnUpdate"
        + "OnPlayerAttack"
        + "OnTakeDamage"
        + "CanBuyWeapon"
        + "CanHaveWeaponInHand"
        + "OnGetWeapon"
        + "OnReload"
        + "OnReloadFinished"
        + "OnSwitchWeapon"
        + "PostFireWeapon"
        + "OnGameSave"
        + "OnLoadGameSave"
        + "OnClearGameSave";

        function Game.Rule:OnPlayerConnect (player)
            Event:run("OnPlayerConnect",player);
        end

        function Game.Rule:OnPlayerDisconnect (player)
            Event:run("OnPlayerDisconnect",player);
        end

        function Game.Rule:OnRoundStart ()
            Event:run("OnRoundStart");
        end

        function Game.Rule:OnRoundStartFinished ()
            Event:run("OnRoundStartFinished");
        end

        function Game.Rule:OnPlayerSpawn (player)
            Event:run("OnPlayerSpawn",player);
        end

        function Game.Rule:OnPlayerJoiningSpawn (player)
            Event:run("OnPlayerJoiningSpawn",player);
        end

        function Game.Rule:OnPlayerKilled (victim, killer, weapontype, hitbox)
            Event:run("OnPlayerKilled",victim, killer, weapontype, hitbox);
        end

        function Game.Rule:OnKilled (victim,killer)
            Event:run("OnKilled",victim,killer);
        end

        function Game.Rule:OnPlayerSignal (player,signal)
            Event:run("OnPlayerSignal",player,signal);
        end

        function Game.Rule:OnUpdate (time)
            Event:run("OnUpdate",time);
        end

        function Game.Rule:OnPlayerAttack (victim, attacker, damage, weapontype, hitbox)
            Event:run("OnPlayerAttack",victim, attacker, damage, weapontype, hitbox);
        end

        function Game.Rule:OnTakeDamage (victim, attacker, damage, weapontype, hitbox)
            Event:run("OnTakeDamage",victim, attacker, damage, weapontype, hitbox);
        end

        function Game.Rule:CanBuyWeapon (player, weaponid)
            Event:run("CanBuyWeapon",player,weaponid);
        end

        function Game.Rule:CanHaveWeaponInHand (player, weaponid, weapon)
            Event:run("CanHaveWeaponInHand",player, weaponid, weapon);
        end

        function Game.Rule:OnGetWeapon (player, weaponid, weapon)
            Event:run("OnGetWeapon",player, weaponid, weapon);
        end

        function Game.Rule:OnReload (player, weapon, time)
            Event:run("OnReload",player, weapon, time);
        end

        function Game.Rule:OnReloadFinished (player, weapon)
            Event:run("OnReloadFinished",player, weapon);
        end

        function Game.Rule:OnSwitchWeapon (player)
            Event:run("OnSwitchWeapon",player);
        end

        function Game.Rule:PostFireWeapon (player, weapon, time)
            Event:run("PostFireWeapon",player, weapon, time);
        end

        function Game.Rule:OnGameSave (player)
            Event:run("OnGameSave",player);
        end

        function Game.Rule:OnLoadGameSave (player)
            Event:run("OnLoadGameSave",player);
        end

        function Game.Rule:OnClearGameSave (player)
            Event:run("OnClearGameSave",player);
        end
    end

    if UI~=nil then
        Event = Event
        + "OnRoundStart"
        + "OnSpawn"
        + "OnKilled"
        + "OnInput"
        + "OnUpdate"
        + "OnChat"
        + "OnSignal"
        + "OnKeyDown"
        + "OnKeyUp";

        function UI.Event:OnRoundStart()
            Event:run("OnRoundStart");
        end

        function UI.Event:OnSpawn()
            Event:run("OnSpawn");
        end

        function UI.Event:OnKilled()
            Event:run("OnKilled");
        end

        function UI.Event:OnInput (inputs)
            Event:run("OnInput",inputs);
        end

        function UI.Event:OnUpdate(time)
            Event:run("OnUpdate",time);
        end

        function UI.Event:OnChat (text)
            Event:run("OnChat",text);
        end

        function UI.Event:OnSignal(signal)
            Event:run("OnSignal",signal);
        end

        function UI.Event:OnKeyDown(inputs)
            Event:run("OnKeyDown",inputs);
        end

        function UI.Event:OnKeyUp (inputs)
            Event:run("OnKeyUp",inputs);
        end
    end

    Event:addEventListener("OnUpdate",function(time)
        Timer:onUpdate(time);
    end);
end)();

local NONE = 0;
local SKILL = {
    WORLD = {
        TOBEZOMBIE = {NAME = "变身怪物",SIGNAL = 1,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {}},
        TOBEHUMAN = {NAME = "变身人类",SIGNAL = 2,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {}},
        SLOWDOWN = {NAME = "减速",SIGNAL = 3,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {DURATION = 3,SPEED = 1}},
        DISCOLOR = {NAME = "变色",SIGNAL = 4,ISFREEZE = false,COOLDOWNTIME = 0,MEMORY = {DURATION = 3,COLOR = {r = 255,g = 255,b = 255}}},
    },
    --僵尸技能
    ZOMBIE = {
        FATALBLOW = {NAME = "致命打击",SIGNAL = 101,ISFREEZE = false,COOLDOWNTIME = 60,MEMORY = {DURATION = 30}},
        SUPERJUMP = {NAME = "火箭跳跃",SIGNAL = 102,ISFREEZE = false,COOLDOWNTIME = 10,MEMORY = {}},
        GHOSTSTEP = {NAME = "鬼影步",SIGNAL = 103,ISFREEZE = false,COOLDOWNTIME = 5,MEMORY = {}},
        LIGHTWEIGHT = {NAME = "轻如鸿毛",SIGNAL = 104,ISFREEZE = false,COOLDOWNTIME = 25,MEMORY = {DURATION = 10}},
        GRAVITY = {NAME = "地心引力",SIGNAL = 105,ISFREEZE = false,COOLDOWNTIME = 20,MEMORY = {}},
        HITGROUND = {NAME = "撼地一击",SIGNAL = 106,ISFREEZE = false,COOLDOWNTIME = 15,MEMORY = {}},
        LISTEN = {NAME = "聆听",SIGNAL = 107,ISFREEZE = false,COOLDOWNTIME = 20,MEMORY = {}},
        SEARCHER = {NAME = "追踪者",SIGNAL = 108,ISFREEZE = false,COOLDOWNTIME = 90,MEMORY = {DURATION = 30}},
        SURVEILLANCE = {NAME = "监控娃娃",SIGNAL = 109,ISFREEZE = false,COOLDOWNTIME = 5,MEMORY = {DURATION = 90}},
    },
    --人类技能
    HUMAN = {
        STEEL = {NAME = "铜头铁骨",SIGNAL = 201,ISFREEZE = false,COOLDOWNTIME = 45,MEMORY = {}},
        SPRINTBURST = {NAME = "冲刺爆发",SIGNAL = 202,ISFREEZE = false,COOLDOWNTIME = 5,MEMORY = {}},
        CURE = {NAME = "自我愈合",SIGNAL = 203,ISFREEZE = false,COOLDOWNTIME = 60,MEMORY = {}},
        FIRESTRIKE = {NAME = "火力打击",SIGNAL = 204,ISFREEZE = false,COOLDOWNTIME = 90,MEMORY = {}},
        VAMPIRE = {NAME = "吸血鬼",SIGNAL = 205,ISFREEZE = false,COOLDOWNTIME = 90,MEMORY = {}},
	},
}

local State = {
    Ready = 1,
    Start = 2,
    End = 3,
};

if Game ~= nil then
    local GameState = State.Ready;

    local Players = {};

    local Zombie = {
        Players = {},
        SkillsUsed = {},
    };

    local Human = {
        Players = {},
        SkillsUsed = {},
    };

    --变身人类
    function SKILL.WORLD.TOBEHUMAN:CALL(player)
        Human.Players[#Human.Players + 1] = player;
        player.model = Game.MODEL.DEFAULT;
        player.maxhealth = 1000;
        player.health = 1000;
        player.user.ishuman = true;
        player.user.ismonster = false;
        player:SetThirdPersonView(90,90);

        player:Signal(SKILL.WORLD.TOBEHUMAN.SIGNAL);
        player:Signal(0);
    end

    --变身僵尸
    function SKILL.WORLD.TOBEZOMBIE:CALL(player)
        Zombie.Players[#Zombie.Players + 1] = player;
        player.model = Game.MODEL.BLOTTER_ZOMBIE_HOST;
        player.maxhealth = 10000;
        player.health = 10000;
        player.user.ishuman = false;
        player.user.ismonster = true;
        player.flinch = 0;
        player.knockback = 0;
        player:SetFirstPersonView();

        player:Signal(SKILL.WORLD.TOBEZOMBIE.SIGNAL);
        player:Signal(0);
    end

    --减速
    function SKILL.WORLD.SLOWDOWN:CALL(player)
        local id = Event:addEventListener("OnUpdate",function(time)
            if player ~= nil then
                player.velocity = {
                    x = player.velocity.x * self.MEMORY.SPEED,
                    y = player.velocity.y * self.MEMORY.SPEED,
                    z = player.velocity.z * self.MEMORY.SPEED,
                };
            end
        end);
        Timer:schedule(function()
            Event:detachEventListener(id);
        end,self.MEMORY.DURATION);
    end

    --变色
    function SKILL.WORLD.DISCOLOR:CALL(player)
        player:SetRenderFX(Game.RENDERFX.GLOWSHELL);
        player:SetRenderColor(self.MEMORY.COLOR);
        if self.MEMORY.DURATION ~= 0 then
            Timer:schedule(function()
                if player ~= nil then
                    player:SetRenderFX(Game.RENDERFX.NONE);
                end
            end,self.MEMORY.DURATION);
        end
    end

    --致命打击
    function SKILL.ZOMBIE.FATALBLOW:CALL(zombie)
        local id = Event:addEventListener("OnTakeDamage",function(victim, attacker, damage, weapontype, hitbox)
            if attacker~= nil then
                return;
            end
            if not attacker:IsPlayer() then
                return;
            end
            if attacker:ToPlayer().name == zombie.name then
                victim.health = 0;
            end
        end);
        Timer:schedule(function()
            Event:detachEventListener(id);
        end,self.MEMORY.DURATION);

    end

    --火箭跳跃
    function SKILL.ZOMBIE.SUPERJUMP:CALL(zombie)
        zombie.velocity = {
            x = zombie.velocity.x,
            y = zombie.velocity.y,
            z = zombie.velocity.z + self.MEMORY.VALUE * 5,
        };

        SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 1.5;
        SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 128,g = 244,b = 244};
        SKILL.WORLD.DISCOLOR:CALL(zombie);
    end

    --鬼影步
    function SKILL.ZOMBIE.GHOSTSTEP:CALL(zombie)
        local length = math.sqrt(zombie.velocity.x * zombie.velocity.x +
        zombie.velocity.y * zombie.velocity.y +
        zombie.velocity.z * zombie.velocity.z);

        Timer:schedule(function()
            zombie.position = {
                x = math.floor(zombie.position.x + self.MEMORY.VALUE * self.MEMORY.VALUE / 300 * zombie.velocity.x / length),
                y = math.floor(zombie.position.y + self.MEMORY.VALUE * self.MEMORY.VALUE / 300 * zombie.velocity.y / length),
                z = math.floor(zombie.position.z),
            };
        end,0);
        Timer:schedule(function()
            zombie.position = {
                x = math.floor(zombie.position.x + self.MEMORY.VALUE * self.MEMORY.VALUE / 350 * zombie.velocity.x / length),
                y = math.floor(zombie.position.y + self.MEMORY.VALUE * self.MEMORY.VALUE / 350 * zombie.velocity.y / length),
                z = math.floor(zombie.position.z),
            };
        end,0.15);
        Timer:schedule(function()
            zombie.position = {
                x = math.floor(zombie.position.x + self.MEMORY.VALUE * self.MEMORY.VALUE / 400 * zombie.velocity.x / length),
                y = math.floor(zombie.position.y + self.MEMORY.VALUE * self.MEMORY.VALUE / 400 * zombie.velocity.y / length),
                z = math.floor(zombie.position.z),
            };
            SKILL.WORLD.SLOWDOWN.MEMORY.DURATION = 3;
            SKILL.WORLD.SLOWDOWN.MEMORY.SPEED = 0.1;
            SKILL.WORLD.SLOWDOWN:CALL(zombie);
    
            SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 1.5;
            SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 255,g = 32,b = 32};
            SKILL.WORLD.DISCOLOR:CALL(zombie);
        end,0.3);
    end

    --轻如鸿毛
    function SKILL.ZOMBIE.LIGHTWEIGHT:CALL(zombie)
        local value = self.MEMORY.VALUE;
        local id = Event:addEventListener("OnUpdate",function(time)
            if zombie.velocity.z > 0 then
                zombie.velocity = {
                    x = zombie.velocity.x,
                    y = zombie.velocity.y,
                    z = zombie.velocity.z + 1.5 * value,
                };
                value = value / 2;
            else
                value = self.MEMORY.VALUE;
                zombie.velocity = {
                    x = zombie.velocity.x,
                    y = zombie.velocity.y,
                    z = zombie.velocity.z * 0.5,
                };
            end
        end);
        Timer:schedule(function()
            Event:detachEventListener(id);
            SKILL.WORLD.SLOWDOWN.MEMORY.DURATION = 3;
            SKILL.WORLD.SLOWDOWN.MEMORY.SPEED = 0.5;
            SKILL.WORLD.SLOWDOWN:CALL(zombie);
        end,self.DURATION);
    end

    --地心引力
    function SKILL.ZOMBIE.GRAVITY:CALL(zombie)

    end

    --撼地一击
    function SKILL.ZOMBIE.HITGROUND:CALL(zombie)
        for i=1,#Human.Players do
	        local length = (zombie.position.x - Human.Players[i].position.x) * (zombie.position.x - Human.Players[i].position.x) +
            (zombie.position.y - Human.Players[i].position.y) * (zombie.position.y - Human.Players[i].position.y) +
            (zombie.position.z - Human.Players[i].position.z) * (zombie.position.z - Human.Players[i].position.z);
            if length < 400 then
                Human.Players[i].velocity = {
                    x = Human.Players[i].velocity.x,
                    y = Human.Players[i].velocity.y,
                    z = 1200,
                };
                Human.Players[i].health = Human.Players[i].health - (500 - length) / 2;
            end
        end
        SKILL.WORLD.SLOWDOWN.MEMORY.DURATION = 3;
        SKILL.WORLD.SLOWDOWN.MEMORY.SPEED = 0.5;
        SKILL.WORLD.SLOWDOWN:CALL(zombie);

        SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 1.5;
        SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 255,g = 128,b = 128};
        SKILL.WORLD.DISCOLOR:CALL(zombie);
    end

    --聆听
    function SKILL.ZOMBIE.LISTEN:CALL(zombie)

    end

    --追踪者
    function SKILL.ZOMBIE.SEARCHER:CALL(zombie)
        if #Human.Players > 0 then
            local monster = Game.Monster:Create(Game.MONSTERTYPE.PUMPKINHEAD,zombie.position);
            local human = Human.Players[Game.RandomInt(1, #Human.Players)];
            if monster ~= nil and human ~= nil then
                SKILL.WORLD.DISCOLOR.MEMORY.DURATION = self.MEMORY.DURATION;
                SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 255,g = 128,b = 128};
                SKILL.WORLD.DISCOLOR:CALL(monster);
                monster.speed = 0.8;
                local id = Timer:schedule(function()
                    if human ~= nil then
                        monster:MoveTo(human.position);
                    end
                end,0,1.5);
                Timer:schedule(function()
                    Timer:cancel(id);
                    if monster ~= nil then
                        print("怪物停止追踪");
                    end
                end,self.MEMORY.DURATION) ;
            end
        end
    end

    --监控娃娃
    function SKILL.ZOMBIE.SURVEILLANCE:CALL(zombie)
        if self.MEMORY.MONSTER == nil then
            self.MEMORY.MONSTER = Game.Monster:Create(Game.MONSTERTYPE.A104RL,zombie.position);
            if self.MEMORY.MONSTER ~= nil then
                self.MEMORY.MONSTER:Stop(true);
                self.MEMORY.MONSTER.user.name = zombie.name;
                SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 0;
                SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 64,g = 64,b = 198};
                SKILL.WORLD.DISCOLOR:CALL(self.MEMORY.MONSTER);
                Timer:schedule(function()
                    if self.MEMORY.MONSTER ~= nil then
                        self.MEMORY.MONSTER:Hold(true);
                        SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 0;
                        SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 198,g = 64,b = 64};
                        SKILL.WORLD.DISCOLOR:CALL(self.MEMORY.MONSTER);
                    end
                end,5);
            end
        else
            zombie.position = self.MEMORY.MONSTER.position;
            --self.MEMORY.MONSTER ;
            self.MEMORY.MONSTER = nil;
        end
    end

    --铜头铁骨
    function SKILL.HUMAN.STEEL:CALL(human)

    end

    --冲刺爆发
    function SKILL.HUMAN.SPRINTBURST:CALL(human)
        local length = math.sqrt(human.velocity.x * human.velocity.x +
        human.velocity.y * human.velocity.y +
        human.velocity.z * human.velocity.z);
        if human.velocity.z ~= 0 then
            human.velocity = {
                x = human.velocity.x / length * 500,
                y = human.velocity.y / length * 500,
                z = human.velocity.z,
            };
        else
            human.velocity = {
                x = human.velocity.x / length * 1000,
                y = human.velocity.y / length * 1000,
                z = human.velocity.z,
            };
        end
        SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 0.5;
        SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 24,g = 24,b = 128};
        SKILL.WORLD.DISCOLOR:CALL(human);
    end

    --自我愈合
    function SKILL.HUMAN.CURE:CALL(human)
        if human.health + 150 < human.maxhealth then
            human.health = human.health + 150;
        else
            human.health = human.maxhealth;
        end
        SKILL.WORLD.DISCOLOR.MEMORY.DURATION = 0.5;
        SKILL.WORLD.DISCOLOR.MEMORY.COLOR = {r = 24,g = 177,b = 128};
        SKILL.WORLD.DISCOLOR:CALL(human);
    end

    --火力打击
    function SKILL.HUMAN.FIRESTRIKE:CALL(human)
        
    end

    --吸血鬼
    function SKILL.HUMAN.VAMPIRE:CALL(human)
        
    end

    local SignalState = NONE;
    Event:addEventListener("OnPlayerSignal",function(player,signal)
        if player.user.ishuman == true then
            for key,value in pairs(SKILL.HUMAN) do
                if signal == value.SIGNAL then
                    Human.SkillsUsed[#Human.SkillsUsed + 1] = {player,value};
                    return;
                end
            end
            return;
        elseif player.user.ismonster == true then
            if SignalState == NONE then
                SignalState = signal;
                return;
            end
            for key,value in pairs(SKILL.ZOMBIE) do
                if SignalState == value.SIGNAL then
                    value.MEMORY.VALUE = signal;
                    Zombie.SkillsUsed[#Zombie.SkillsUsed + 1] = {player,value};
                    SignalState = NONE;
                    return;
                end
            end
        end
    end);

    local SyncGameState = Game.SyncValue.Create("游戏状态");
    SyncGameState.value = GameState;

    Event:addEventListener("OnPlayerSpawn",function(player)
        SKILL.WORLD.TOBEHUMAN:CALL(player);
    end);

    Event:addEventListener("OnUpdate",function(time)
        if GameState == State.Ready then
            if #Players >= 1 then

                SKILL.WORLD.TOBEZOMBIE:CALL(Players[1]);

                GameState = State.Start;
                SyncGameState.value = GameState;
            end
        elseif GameState == State.Start then
            for i=1,#Zombie.SkillsUsed do
	            pcall(Zombie.SkillsUsed[i][2].CALL,Zombie.SkillsUsed[i][2],Zombie.SkillsUsed[i][1]);
            end

            for i=1,#Human.SkillsUsed do
	            pcall(Human.SkillsUsed[i][2].CALL,Human.SkillsUsed[i][2],Human.SkillsUsed[i][1]);
            end
            Zombie.SkillsUsed = {};
            Human.SkillsUsed = {};
        end
    end);

    --没5秒减少玩家生命值
    Timer:schedule(function()
        for i = 1,#Human.Players do
            print("玩家".. Human.Players[i].name .."生命减少10点");
            Human.Players[i].health = Human.Players[i].health - 10;
        end
    end,0,5);

    Event:addEventListener("OnPlayerConnect",function(player)
        Players[#Players + 1] = player;
    end);

    Event:addEventListener("OnPlayerDisconnect",function(player)
        for i=1,#Players do
            if Players[i] == player then
                table.remove(Players,i)
                break;
            end
        end
    end);

    --玩家被攻击后会被击飞，而攻击者得到3秒减速效果
    Event:addEventListener("OnTakeDamage",function(victim, attacker, damage, weapontype, hitbox)
            if attacker.user.ismonster then
                victim.velocity = {
                    x = 700 * (victim.position.x - attacker.position.x),
                    y = 700 * (victim.position.y - attacker.position.y),
                    z = 300,
                };
                SKILL.WORLD.SLOWDOWN.MEMORY.DURATION = 3;
                SKILL.WORLD.SLOWDOWN.MEMORY.SPEED = 0.2;
                SKILL.WORLD.SLOWDOWN:CALL(attacker);
            end
    end);
end

if UI ~= nil then
    local OnInputs = {};
    local InputsOnKeyDown = {};
    local InputsOnKeyUp = {};

    local GameState = "未知";
    local SelfType = "人类";

    local SyncGameState = UI.SyncValue.Create("游戏状态");

    function SKILL.WORLD.TOBEZOMBIE:CALL()
        SelfType = "怪物";
    end

    function SKILL.WORLD.TOBEHUMAN:CALL()
        SelfType = "人类";
    end

    function SyncGameState:OnSync()
        GameState = self.value;
    end

    --僵尸技能列表
    local ZombieSkillList = {SKILL.ZOMBIE.SURVEILLANCE,SKILL.ZOMBIE.SUPERJUMP,SKILL.ZOMBIE.GHOSTSTEP,SKILL.ZOMBIE.LIGHTWEIGHT};
    
    --人类技能列表
    local HumanSkillList = {SKILL.HUMAN.STEEL,SKILL.HUMAN.SPRINTBURST,SKILL.HUMAN.CURE,SKILL.HUMAN.FIRESTRIKE};
    
    local SkillIndex = 1;

    local Bar = 0;

    Event:addEventListener("OnUpdate",function(time)
        Graphics:clean();
        if GameState == State.Ready then
            Graphics.color = {red = 255,green = 255,blue=255,alpha=255};
            Graphics:drawText(40,25,2,30,"等待开始");
        elseif GameState == State.Start then
            if SelfType == "怪物" then
                Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                Graphics:drawRect(36,30,120,24);
                Graphics.color = {red = 222,green = 222,blue=222,alpha=255};
                if ZombieSkillList[SkillIndex].ISFREEZE == true then
                    Graphics.color = {red = 222,green = 30,blue=30,alpha=255};
                end
                Graphics:drawText(40,30,2,30,ZombieSkillList[SkillIndex].NAME);
                if OnInputs[UI.KEY.NUM1] == true then
                    SkillIndex = 1;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM2] == true then
                    SkillIndex = 2;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM3] == true then
                    SkillIndex = 3;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM4] == true then
                    SkillIndex = 4;
                    Bar = 0;
                end
                if ZombieSkillList[SkillIndex].ISFREEZE == false then
                    if OnInputs[UI.KEY.SHIFT] == true then
                        Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                        Graphics:drawRect(18,28,14,102);
                        Graphics.color = {red = 255,green = 255,blue=255,alpha=255};
                        Graphics:drawRect(20,30,10,Bar);
                        if Bar < 100 then
                            Bar = Bar + 1;
                        else
                            
                        end
                    elseif InputsOnKeyUp[UI.KEY.SHIFT] == true then
                        UI.Signal(ZombieSkillList[SkillIndex].SIGNAL);
                        UI.Signal(Bar);

                        Bar = 0;
                        ZombieSkillList[SkillIndex].ISFREEZE = true;

                        local i = SkillIndex;
                        Timer:schedule(function()
                            ZombieSkillList[i].ISFREEZE = false;
                            print(ZombieSkillList[i].NAME,"冷却完成")
                        end,ZombieSkillList[i].COOLDOWNTIME);
                    end
                end
            elseif SelfType == "人类" then
                Graphics.color = {red = 25,green = 25,blue=25,alpha=255};
                Graphics:drawRect(36,30,120,24);
                Graphics.color = {red = 222,green = 222,blue=222,alpha=255};
                if HumanSkillList[SkillIndex].ISFREEZE == true then
                    Graphics.color = {red = 222,green = 30,blue=30,alpha=255};
                end
                Graphics:drawText(40,30,2,30,HumanSkillList[SkillIndex].NAME);
                if OnInputs[UI.KEY.NUM1] == true then
                    SkillIndex = 1;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM2] == true then
                    SkillIndex = 2;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM3] == true then
                    SkillIndex = 3;
                    Bar = 0;
                elseif OnInputs[UI.KEY.NUM4] == true then
                    SkillIndex = 4;
                    Bar = 0;
                end
                if HumanSkillList[SkillIndex].ISFREEZE == false and InputsOnKeyDown[UI.KEY.SHIFT] == true  then
                    UI.Signal(HumanSkillList[SkillIndex].SIGNAL);
                    HumanSkillList[SkillIndex].ISFREEZE = true;
                    local i = SkillIndex;
                    Timer:schedule(function()
                        HumanSkillList[i].ISFREEZE = false;
                        print(HumanSkillList[i].NAME,"冷却完成")
                    end,HumanSkillList[i].COOLDOWNTIME);
                end
            end
        end
        OnInputs = {};
        InputsOnKeyDown = {};
        InputsOnKeyUp = {};
    end);

    local SignalState = NONE;
    Event:addEventListener("OnSignal",function(signal)
        if SignalState == NONE then
            SignalState = signal;
            return;
        end

        for key,value in pairs(SKILL.WORLD) do
            if SignalState == value.SIGNAL then
                value.MEMORY.VALUE = signal;
                value:CALL();
                SignalState = NONE;
                return;
            end
        end
    end);

    Event:addEventListener("OnInput",function(inputs)
        OnInputs = inputs;
    end);

    Event:addEventListener("OnKeyDown",function(inputs)
        InputsOnKeyDown = inputs;
    end);

    Event:addEventListener("OnKeyUp",function(inputs)
        InputsOnKeyUp = inputs;
    end);

end
