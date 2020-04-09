--[[ 修正遊戲選項 ]]
Common.UseWeaponInven(true) -- 使用武器背包功能
Common.SetSaveCurrentWeapons(true) -- 設定將目前裝備中的武器們儲存
Common.SetSaveWeaponInven(true) -- 設定儲存武器背包內容(需先設定UseWeaponInven)
Common.SetAutoLoad(true) -- 自動執行讀取儲存資訊。
Common.DisableWeaponParts(true) -- 關閉武器部件功能
Common.DisableWeaponEnhance(true) -- 關閉武器強化功能
Common.DontGiveDefaultItems(true) -- 遊戲開始時不會給予基本武器
Common.DontCheckTeamKill(true) -- 團隊擊殺也會算為正常擊殺
Common.UseScenarioBuymenu(true) -- 商店使用災厄之章商店視窗
Common.SetNeedMoney(true) -- 購買槍枝時需要金錢
Common.UseAdvancedMuzzle(true) -- 發射時槍口效果以新型態呈現(不套用Scale)
Common.SetMuzzleScale(1.0) -- 修正發射時槍口效果大小
Common.SetBloodScale(2) -- 修正被攻擊時血的效果大小
Common.SetGunsparkScale(10) -- 修正子彈射到牆壁等時的效果大小
Common.SetHitboxScale(2.5) -- 修正准心大小
Common.SetMouseoverOutline(true, {r = 255, g = 0, b = 0}) -- 當游標移到怪物等的實體上時標示外框
Common.SetUnitedPrimaryAmmoPrice(50) -- 所有主武器每個彈匣價格相同
Common.SetUnitedSecondaryAmmoPrice(0) -- 所有輔助武器每個彈匣價格相同

BuymenuWeaponList =	{
	Common.WEAPON.P228,
	Common.WEAPON.DualBeretta,
	Common.WEAPON.FiveSeven,
	Common.WEAPON.Glock18C,
	Common.WEAPON.USP45,
	Common.WEAPON.DesertEagle50C,
	Common.WEAPON.DualInfinity,
	Common.WEAPON.Galil,
	Common.WEAPON.FAMAS,
	Common.WEAPON.M4A1,
	Common.WEAPON.AK47,
	Common.WEAPON.OICW,
	Common.WEAPON.MAC10,
	Common.WEAPON.UMP45,
	Common.WEAPON.MP5,
	Common.WEAPON.TMP,
	Common.WEAPON.P90,
	Common.WEAPON.MP7A1ExtendedMag,
	Common.WEAPON.Needler,
	Common.WEAPON.M3,
	Common.WEAPON.XM1014,
	Common.WEAPON.DoubleBarrelShotgun,
	Common.WEAPON.WinchesterM1887,
	Common.WEAPON.USAS12,
	Common.WEAPON.FireVulcan,
	Common.WEAPON.M249,
	Common.WEAPON.MG3,
	Common.WEAPON.M134Minigun,
	Common.WEAPON.K3,
	Common.WEAPON.QBB95,
	Common.WEAPON.M32MGL,
	Common.WEAPON.Leviathan,
	Common.WEAPON.Salamander,
	Common.WEAPON.RPG7
}

-- 設定商店武器清單 (須設定UseScenarioBuymenu)
Common.SetBuymenuWeaponList(BuymenuWeaponList)

function SetOption(weaponid, price, grade, level, red, green, blue)
	option = Common.GetWeaponOption(weaponid)
	option.price = price
	option.user.grade = grade
	option.user.level = level

	if red ~= nil then
		option:SetBulletColor({r = red, g = green, b = blue});
	end
end

SetOption(Common.WEAPON.XM1014,80000,1,1);