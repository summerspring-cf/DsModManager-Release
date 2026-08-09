--[[
  dsmm_options.lua — DsCppModManager 연동 헬퍼 (모드 Scripts 폴더에 복사해서 require)

  제공 기능:
    mm.load(defaults)  -> 옵션 테이블 (dsoptions.txt 를 defaults 와 병합)
    mm.enabled()       -> 런타임 켬/끔 (dsruntime.txt; 없으면 true)
    mm.poll(defaults)  -> enabled, opts  (1초 캐시 폴링 -- 루프에서 그냥 호출)
    mm.dir()           -> 이 모드 폴더의 절대 경로

  파일 계약 상세는 PLUGIN_GUIDE.md 참고.
]]
local M = {}

local src = debug.getinfo(1, "S").source:gsub("^@", "")
local modDir = src:match("^(.*)[/\\]Scripts[/\\]") or "."

local function readAll(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local d = f:read("*a")
    f:close()
    return d
end

function M.dir()
    return modDir
end

function M.load(defaults)
    local out = {}
    for k, v in pairs(defaults or {}) do out[k] = v end
    local d = readAll(modDir .. "/dsoptions.txt")
    if d then
        for line in d:gmatch("[^\r\n]+") do
            local k, v = line:match("^%s*([%w_]+)%s*=%s*(%-?%d+)%s*$")
            if k and out[k] ~= nil then out[k] = tonumber(v) end
        end
    end
    return out
end

function M.enabled()
    local d = readAll(modDir .. "/dsruntime.txt")
    if not d then return true end
    return d:find("1", 1, true) ~= nil
end

local cacheT, cacheOpts, cacheEn = -10, nil, true
function M.poll(defaults)
    local now = os.clock()
    if now - cacheT >= 1.0 then
        cacheT = now
        cacheOpts = M.load(defaults)
        cacheEn = M.enabled()
    end
    return cacheEn, cacheOpts
end

--[[
  재시작 안내 팝업 요청 (v0.14): 옵션 변경이 재시작 후에만 적용된다고 모드가
  판단했을 때 호출하면, 모드매니저가 게임식 안내 팝업을 대신 띄워준다.
  msg 를 생략하면 "『모드이름』 변경 사항은 게임 재시작 후 적용됩니다." 기본 문구.
  신호는 1회성(매니저가 팝업 표시 후 자동 소거)이며 타이틀 화면에서 감지된다.
]]
function M.requestRestartPopup(msg)
    local f = io.open(modDir .. "/dsnotify.txt", "w")
    if not f then return false end
    f:write(msg or "restart")
    f:close()
    return true
end

return M
