--------Join us for more https://t.me/AttcTrDevelopers---------@AttcConfigTechnician ---------
-- ============================================================
-- ISIM DEGISTIR + KAYDET POPUP (V20.9) - tek parca
-- 1) ASAGIDAKI BLOK: dosyada "ISIM (BeysaName.ini)" bolumunden
--    "===== V20.7 SONU =====" satirina kadar olan kismin yerine gecer.
--    Ayni bolumde FILES, post, F, GetCanvas, LegalMsg, GameplayData, UEnums
--    onceden tanimli olmali (sende zaten var).
-- 2) MENU PARCALARI (2a, 2b): menu metni ve menu satiri.
-- Owner PatronPubgBeysa & Creator Neysa
-- ============================================================

--BeyzaStudios
    local N = { name = "" }
    _G.BeysaName = N

    local function loadName()
        local f = io.open(NAME_INI, "r")
        if not f then
            local w = io.open(NAME_INI, "w")
            if w then w:write("[Name]\nNAME=\n") w:close() end
            N.name = ""
            return
        end
        local txt = f:read("*a")
        f:close()
        local v = txt:match("NAME%s*=%s*([^\r\n]*)") or ""
        v = v:gsub("^%s+", ""):gsub("%s+$", "")
        N.name = v
    end
    pcall(loadName)

    function N.apply()
        if N.name == "" then return false end
        local DM = _G.DataMgr
        if not DM or not DM.roleData or type(DM.UpdateNickName) ~= "function" then return false end
        local ok = pcall(DM.UpdateNickName, N.name)
        if not ok then return false end
        post("EVENTTYPE_WARDROBE", "EVENTID_WARDROBE_UPDATE_ITEM_LIST")
        post("EVENTTYPE_ROLEINFO", "EVENTID_ROLEINFO_UPDATE_ROLENAME")
        return true
    end

    function N.reloadAndApply()
        pcall(loadName)
        local ok = N.apply()
        pcall(function()
            if ShowNotice and ok then ShowNotice(49951) end
        end)
        return ok
    end
--LuaCodeHub
    local function saveNameIni(v)
        local w = io.open(NAME_INI, "w")
        if w then w:write("[Name]\nNAME=" .. v .. "\n") w:close() end
    end

    local P = { box = nil, shown = false, lastApplied = nil, X = 0, Y = 25, W = 340, H = 44 }

    function _G.BeysaDlog(msg)
        pcall(function()
            local f = io.open(FILES .. "BeysaName.log", "a")
            if f then f:write(os.date("%H:%M:%S") .. " " .. tostring(msg) .. "\n") f:flush() f:close() end
        end)
    end
    local function plog(msg) _G.BeysaDlog("[popup] " .. tostring(msg)) end
--LuaSafe
    local function newObj(path)
        local o = nil
        pcall(function() o = CGame:NewObjectFromPath(path) end)
        if o and slua.isValid(o) then return o end
        return nil
    end

    local function later(sec, fn)
        local ok = false
        pcall(function()
            local pc = GameplayData.GetPlayerCharacter()
            if slua.isValid(pc) then pc:AddGameTimer(sec, false, fn) ok = true end
        end)
        if not ok then pcall(function() F.later(sec, fn) end) end
    end

    function P.getText()
        local t = ""
        pcall(function() if P.box and slua.isValid(P.box) then t = tostring(P.box:GetText()) end end)
        t = t:gsub("[\r\n]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        return t
    end

    function P.vis(show)
        P.shown = show and true or false
        pcall(function()
            if P.box and slua.isValid(P.box) then
                local E = UEnums.ESlateVisibility
                P.box:SetVisibility(show and E.Visible or E.Collapsed)
            end
        end)
    end

    function P.build()
        if P.box and slua.isValid(P.box) then return true end
        plog("kutu olusturuluyor")
        local box = newObj("/Script/UMG.EditableTextBox")
        if not box then plog("kutu yaratilamadi") return false end
        pcall(function() box:SetHintText("Yeni isim") end)
        pcall(function() box:SetForegroundColor(FLinearColor(1, 1, 1, 1)) end)
        local added = false
        pcall(function()
            local hud = require("game_frontend_hud")
            if hud and hud.AddToContainer and UIContainers and UIContainers.Top then
                hud.AddToContainer(UIContainers.Top, box, 10001)
                added = true
            end
        end)
        if not added then
            local canvas = GetCanvas()
            if canvas then pcall(function() canvas:AddChildToCanvas(box) added = true end) end
        end
        plog("kutu eklendi=" .. tostring(added))
        if not added then return false end
        pcall(function()
            local WLL = import("WidgetLayoutLibrary")
            local slot = WLL.SlotAsCanvasSlot(box)
            if slot then
                slot:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
                slot:SetAlignment(FVector2D(0.5, 0.5))
                slot:SetPosition(FVector2D(P.X, P.Y))
                slot:SetSize(FVector2D(P.W, P.H))
            end
        end)
        P.box = box
        return true
    end

    function P.doApply()
        local t = P.getText()
        if t == "" or #t > 40 then plog("bos/uzun isim, uygulanmadi") return false end
        if t ~= P.lastApplied then
            P.lastApplied = t
            N.name = t
            saveNameIni(t)
            pcall(N.apply)
        end
        pcall(function()
            local pc = GameplayData.GetPlayerCharacter()
            if slua.isValid(pc) and N.applyInMatch then N.applyInMatch(pc) end
        end)
        plog("uygulandi: " .. t)
        return true
    end

--Sumwyyewmmm
    function N.togglePopup()
        plog("togglePopup")
        local okb = P.build()
        if okb then P.vis(true) end
        local cur = (N.name ~= "" and N.name) or "-"
        local okp, errp = pcall(function()
            LegalMsg.ShowOnePopUI({
                tabType = 999,
                title = " İSİM DEĞİŞTİR",
                content = "Mevcut isim: " .. cur .. "\n\nYeni ismi kutuya yaz, Uygula'ya bas.\n\n\n",
                btnOKText = "Uygula",
                btnCancleText = "Kapat",
                acceptFunc = function() pcall(P.doApply) P.vis(false) end,
                refuseFunc = function() P.vis(false) end
            })
        end)
        plog("popup ok=" .. tostring(okp) .. " err=" .. tostring(errp))
        if not okp then P.vis(false) end
        later(60.0, function() P.vis(false) end)
        return okp
    end
    -- ===== V20.7 SONU =====

-- ============================================================
-- 2a) MENU METNI: [999112] satirini su olsun
-- ============================================================
        [999112] = "İsim Değiştir",

-- ============================================================
-- 2b) MENU SATIRI: Key = "SkinMenu_ApplyName" olan blogun tamami
-- ============================================================
        {
            Key = "SkinMenu_ApplyName",
            UI = AliasMap.Switcher,
            Text = 999112,
            GetFunc = function() return false end,
            SetFunc = function(c, v)
                if v and _G.BeysaName then pcall(_G.BeysaName.togglePopup) end
                return true
            end
        },
--------Join us for more https://t.me/AttcTrDevelopers---------@AttcConfigTechnician ---------
