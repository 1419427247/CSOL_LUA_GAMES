--游戏_方块掘战
local State = {
    None = 0,
    Ready = 1,
    Start = 2,
    End = 3,
}
local GameState = State.Ready;

if Game then
    local Count = 0;
    local Blocks = {};
    local BlocksSet = {};
    local Players = {};
    function Game.Rule:OnUpdate(time)
        if GameState == State.Ready then

        elseif GameState == State.Start then
            Count = Count + 1;
            for i = 1,#Players do
                local block = Game.EntityBlock:Create({
                    x = Players[i].position.x,
                    y = Players[i].position.y,
                    z = Players[i].position.z - 1,
                });
                if block ~= nil and block.id == 225 and BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] == nil then
                    BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] = 0;
                    Blocks[#Blocks+1] = {Count + 5,block};
                end

                if Game.RandomInt(1,2) == 1 then
                    local block = Game.EntityBlock:Create({
                        x = Players[i].position.x + Game.RandomInt(-1,1),
                        y = Players[i].position.y + Game.RandomInt(-1,1),
                        z = Players[i].position.z - 1,
                    });
                    if block ~= nil and block.id == 225 and BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] == nil then
                        BlocksSet[block.position.x .. "," .. block.position.y .. "," .. block.position.z] = 0;
                        Blocks[#Blocks+1] = {Count + 6,block};
                    end
                end
            end
            for i = #Blocks,1,-1 do
                if Blocks[i][1] < Count then
                    Blocks[i][2]:Event({action = "signal"}, true);
                    table.remove(Blocks,i);
                end
            end
        elseif GameState == State.End then

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

    function Game.Rule:OnRoundStart()
        Count = 0;
        Blocks = {};
        BlocksSet = {};
        Players = {};

        print("回合开始")
        GameState = State.Ready;
        Game.Rule:Respawn();
        Game.Rule.respawnable = false;
        for i = 1,24 do
            Players[#Players + 1] = Game.Player:Create(i);
            if Players[#Players] == nil then
                break;
            else
                Players[#Players].health = 99999;
                Players[#Players].gravity = 0.8;
            end
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
    end

    function GameStart()
        GameState = State.Start;
        for i = 1, #Players do
            Players[i].health = 999999;
        end
    end
end

if UI then
    
end

if Common then
    Common.UseWeaponInven(true);
    Common.DontGiveDefaultItems(true);
    local option = Common.GetWeaponOption(Common.WEAPON.AWP);
    option.damage = 0;
end
