--游戏_方块掘战,作者@iPad水晶,QQ:1419427247
--  project.json
-------------------------------
--  {
--     "common":[
      
--      ],
--     "game": [
--       "Game_SquareDiggingWar.lua"
--     ],
--     "ui": [
--       "Game_SquareDiggingWar.lua"
--     ]
--  }
-------------------------------
local State = {
    None = 0,
    Start = 1,
}
local GameState = State.None;
local Signal_SuperJump = 3;

--难度列表
local DifficultyList = {
    easy = 6, --简单
    medium = 5, --中等
    difficult = 4, --困难
};

--游戏难度,默认设置为中等
local Difficulty = DifficultyList.medium;

if Game then
    local Count = 0;
    local Blocks = {};
    local BlocksSet = {};
    local Players = {};

    local ki = 0;
    function Game.Rule:OnUpdate(time)
        Count = Count + 1;
        if ki ~= 1 then
            ki = 1;
            return;
        end
        ki = 0;
        if GameState == State.Start then
            for i = 1,#Players do
                local block = Game.EntityBlock:Create({
                    x = Players[i].position.x,
                    y = Players[i].position.y,
                    z = Players[i].position.z - 1,
                });
                if block ~= nil and block.id == 225 and BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] == nil then
                    BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] = 0;
                    Blocks[#Blocks+1] = {Count + Difficulty - 1,block};
                end

                if Game.RandomInt(1,Difficulty - 3) == 1 then
                    local block = Game.EntityBlock:Create({
                        x = Players[i].position.x + Game.RandomInt(-1,1),
                        y = Players[i].position.y + Game.RandomInt(-1,1),
                        z = Players[i].position.z - 1,
                    });
                    if block ~= nil and block.id == 225 and BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] == nil then
                        BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] = 0;
                        Blocks[#Blocks+1] = {Count + Difficulty,block};
                    end
                end
            end
        end

        for i = #Blocks,1,-1 do
            if Blocks[i][1] < Count then
                Blocks[i][2]:Event({action = "signal"}, true);
                table.remove(Blocks,i);
            end
        end
    end

    function Game.Rule:OnRoundStart()
        Count = 0;
        Blocks = {};
        BlocksSet = {};
        Players = {};

        print("回合开始")
        GameState = State.Ready;
        Game.Rule:Respawn();
        for i = 1,24 do
            Players[#Players + 1] = Game.Player:Create(i);
            if Players[#Players] == nil then
                break;
            else
                Players[#Players].health = 99999;
            end
        end
    end

    --收到信号之后给予玩家一个向上的速度
    function Game.Rule:OnPlayerSignal(player,signal)
        if signal == Signal_SuperJump then
            player.velocity = {
                x = player.velocity.x,
                y = player.velocity.y,
                z = 500,
            }
        end
    end

    function Game.Rule:OnPlayerDisconnect(player)
        for i=1,#Players do
            if Players[i] == player then
                table.remove(Players,i)
                break;
            end
        end
        if #Players == 1 then
            Players[1]:Win(false);
        end
    end

    function Game.Rule:OnPlayerKilled (victim, killer, weapontype, hitbox)
        if #Players == 1 then
            Players[1]:Win(false);
            return;
        end
        for i=1,#Players do
            if Players[i] == victim then
                table.remove(Players,i)
                break;
            end
        end
        if #Players == 1 then
            Players[1]:Win(false);
            return;
        end
    end

    --执行此方法时游戏正式开始
    function GameStart(self,difficult)
        GameState = State.Start;
        Game.Rule.respawnable = false;
        Difficulty = tonumber(difficult);
    end
end

if UI then
    local superjump = true;

    function UI.Event:OnRoundStart()
        superjump = true;
    end

    function UI.Event:OnKeyDown(inputs)
        if superjump == true and inputs[UI.KEY.SHIFT] == true then
            UI.Signal(Signal_SuperJump);
            superjump = false;
        end
    end
end