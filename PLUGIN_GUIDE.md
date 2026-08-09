# Plugin guide — put your mod's settings in the Mod Manager

For **mod authors**. If your mod has a toggle key, a colour, a threshold, or an on/off switch,
you no longer have to send users to a `config.ini` they have to alt-tab out to edit.

Ship **one small text file** with your mod and the manager renders your settings as real UI
controls on the game's title screen — toggles, dropdowns, key binds, colour pickers, sliders.

There is **no registration call and no API to link against.** The manager finds your mod by the
shape of its folder and reads your manifest if one is there.

> This guide is self-contained. A copy of `dsmm_options.lua` (the optional Lua helper) is in
> this repository, and everything else is plain text files.

---

## 1. How the manager finds your mod

Users drop mods into the manager's `plugins` folder:

```
…\DS\Binaries\Win64\ue4ss\Mods\DsCppModManager\plugins\<YourMod>\
```

A folder is recognised as a mod if it contains **any one** of these:

| Contains | Recognised as |
|---|---|
| `Scripts\main.lua` | Lua mod |
| `dlls\main.dll` | C++ mod |
| `*.pak` at the top level | `.pak` content mod |

Nothing else is required. Discovery walks up to 10 folder levels deep, so an archive that
unpacks as `Win64\ue4ss\Mods\YourMod\…` is still found, and a `.zip` dropped into `plugins`
is extracted automatically.

Your mod shows up in the panel with an on/off toggle even with no manifest at all.
Add the manifest only when you want options.

---

## 2. On and off — two layers

The manager separates *"is the mod loaded"* from *"is the mod working right now"*.

| File | Layer | Written when |
|---|---|---|
| `enabled.txt` (empty file) | **Load layer** — UE4SS starts your mod because this exists | Toggled on |
| `dsruntime.txt` (contains `1` or `0`) | **Runtime layer** — whether you should be doing anything | Toggled, and once at game start |

**If your mod polls `dsruntime.txt` about once a second, users get restart-free on/off.**
Treat a missing file as "on". Lua mods get this for free from the helper in §5.

C++ mods cannot be unloaded until the process exits, so the manager shows a "restart required"
popup when a C++ mod is switched on for the first time in a session. That is handled for you.

---

## 3. `dsplugin.ini` — the manifest

Put it in your mod's root folder, next to `Scripts\` or `dlls\`. **Save it as UTF-8.**

```ini
[plugin]
; Optional. Shown in the panel's mod list. Any language.
; If omitted, the folder name is used. File operations always use the folder
; name, so changing this never affects installing or toggling.
name=My Mod

[option:enabled]
label=Enable
type=bool
default=1

[option:radius]
label=Detection radius (m)
type=int
min=20
max=200
step=10
default=60
```

- The `<key>` in `[option:<key>]` is the key written to the settings file.
  ASCII letters, digits and `_`, up to 31 characters.
- `label` is what the user sees. Any language, UTF-8.
- **Up to 16 options per mod.** If more than 7 are visible the manager folds them and adds an
  expand/collapse row, so declare the ones people change most often first.

---

## 4. The eight control types

| `type=` | Control | Value stored |
|---|---|---|
| `bool` | On/off toggle | `0` / `1` |
| `int` | `◀ 60 ▶` stepper (`min` · `max` · `step`) | integer |
| `int` + `choices=` | Dropdown | 0-based index |
| `key` | Key binding | virtual-key code (`0` = none) |
| `color` | Colour swatch + picker | `0xRRGGBB` as a decimal integer |
| `check` | Checkbox | `0` / `1` |
| `button` | Action button | **press count** |
| `slider` | Horizontal gauge | integer, range `0`–`1000` |

### Dropdown

```ini
[option:foodkind]
label=Food type
type=int
choices=Anything, HP recovery only, Revival only
default=0
```

Comma-separated, **max 10 items**, 23 characters each. The stored value is the **index**, so
"Revival only" saves as `foodkind=2`. `min`/`max`/`step` are ignored.

### Key binding

```ini
[option:togglekey]
label=Toggle display
type=key
```

The user clicks the pill, it says *"press a key"*, and the next key pressed is stored as a
Windows virtual-key code.

- **Omit `default=`.** The binding then starts empty, which is the convention the game's own
  key-rebinding screen uses. (`default=F7` or a raw number also works.)
- **`Delete` clears the binding** back to `0`. `Escape` cancels without changing it.
  So `Delete` itself cannot be bound.
- **Treat `0` as "no key".** Do not pass it to `GetAsyncKeyState`.

```c
if (opts.togglekey != 0 && (GetAsyncKeyState(opts.togglekey) & 0x8000)) { … }
```

### Colour

```ini
[option:markercolor]
label=Marker colour
type=color
default=#FFD60A
```

Clicking opens a picker with a saturation/brightness square, a hue strip, 12 presets, and
`#RRGGBB` typing. Square and strip respond to **click-and-drag**.

Stored as `0xRRGGBB` (written to the file in decimal):
`R = (v>>16)&0xFF`, `G = (v>>8)&0xFF`, `B = v&0xFF`.

### Checkbox

```ini
[option:showtimer]
label=Show remaining time
type=check
default=1
```

Same `0`/`1` value as `bool`, just a smaller control. Good for minor toggles where a full
on/off pill is too heavy.

### Action button

```ini
[option:rescan]
label=Re-scan chests
type=button
button=Run now          ; optional caption; defaults to "실행" (Run)
```

Not a value — a **"do this once"** command. The stored value is the **number of times it has
been pressed**. Act when it grows, and remember the value you last acted on:

```lua
local last = opts.rescan or 0
-- inside your 1-second poll
if (opts.rescan or 0) > last then
    last = opts.rescan
    rescan_now()
end
```

Because you take the current value as your baseline at startup, it never fires spuriously on
first launch. **Do not set `default=`** — starting from `0` is the convention.

### Slider

```ini
[option:opacity]
label=Overlay opacity
type=slider
min=0
max=100
default=80
```

Drag the handle or click anywhere on the track. The value appears to the right and is saved
when the user lets go.

- Allowed range is **0 – 1000**. Values outside that are clamped by the manager.
  Omit `min`/`max` and you get `0`–`100`.
- Need decimals? Use `min=0 max=1000` and divide by 1000 in your mod.
- Dragging sideways on a slider does **not** scroll the panel; the slider claims that drag.

---

## 5. Child options — show settings only when they matter

```ini
[option:autoswap]
label=Auto food swap
type=bool
default=0

[option:foodkind]
label=Food type
type=int
choices=Anything, HP recovery only, Revival only
default=0
parent=autoswap        ; only shown while autoswap is on
;parent_value=2        ; optional: only when the parent equals exactly this
```

- Without `parent_value`, the child shows while the parent is non-zero.
  With it, only when the parent equals that number (use the index for dropdowns).
- Declare children **immediately after** their parent — display order is declaration order.
- Grandchildren work too. Hidden options **keep their values**; nothing is lost.

---

## 6. Reading the values back

The manager writes plain `key=value` lines to **`dsoptions.txt`** next to your mod:

```
sound=1
radius=80
togglekey=118
markercolor=16766986
```

Values are written **the moment the user changes them**. When they take effect is up to how
often you read the file — once a second is the recommendation, and it gives you restart-free
settings.

### Lua — use the bundled helper

Copy [`dsmm_options.lua`](dsmm_options.lua) from this repository into your mod's `Scripts\`
folder. It is free to copy and ship, no attribution needed.

```lua
local mm = require("dsmm_options")

-- A: read once at startup, merged with your defaults
local opts = mm.load({ sound = 1, radius = 60 })
print(opts.radius)

-- B: poll (handles the on/off layer and the options together, 1s cache)
LoopInGameThreadWithDelay(1000, function()
    local enabled, opts = mm.poll({ sound = 1, radius = 60 })
    if not enabled then return end   -- switched off in the manager: stand down
    -- use opts.sound, opts.radius …
end)
```

### C++ — just read two text files

```
<your dll folder>\..\dsoptions.txt    "key=integer" lines
<your dll folder>\..\dsruntime.txt    a single character, '1' or '0'
```

Standard file I/O. No dependency on the manager, and everything degrades gracefully when the
files are absent — use your defaults.

---

## 7. Asking the manager to show a restart popup

Some settings can only take effect after a restart, and only your mod knows which. Write
**`dsnotify.txt`** in your mod folder and the manager shows a game-styled popup for you,
then deletes the file (one shot).

```lua
if opts.big_feature ~= applied_big_feature then
    mm.requestRestartPopup()                                    -- default wording
    -- mm.requestRestartPopup("Combat changes apply after a restart.")
end
```

The file contains either `restart` (default wording) or your own message.
C++ mods write the same file with a single `fwrite`. Detection happens on the title screen,
where the manager is active.

---

## 8. Rules and gotchas

- **A mod with no `dsplugin.ini` still works.** It is listed and toggleable; you only lose the
  options UI.
- **Clamp defensively.** The manager validates `min`/`max`, but check again in your mod.
- **Changing `name=` is safe.** All file and folder operations use the folder name.

### Living with the safety guard

At every launch the manager checks for a **game patch** and for a **crash on the previous
run**. If either is true it **switches every mod off** and tells the user. Two consequences:

- Your mod may be off without the user having asked. That is normal — never assume you are on.
  The list of what was disabled is left in `safemode_last.txt`.
- After a crash, the mod that **wrote to its log most recently** is named in the popup as a
  suspect, with an explicit note that this is a hint and not proof. So:
  **log one line right before anything risky** — it makes your own crashes far easier to trace.
  But **do not write a log line every second when nothing is happening**, or you will be blamed
  for someone else's crash.

### ★ Never hard-code game addresses

A game patch shifts every function address. Calling a stale one **kills the game instantly** —
this has already happened in this game's modding scene. Resolve what you need at runtime, and
if a signature matches in more than one place, treat it as a failure rather than guessing.

---

## 9. `.pak` content mods

A folder containing `.pak` files at its top level is managed too. Enabling hard-links the pak
files into the game's `Paks` folder; disabling unlinks them. The default target is `LogicMods`
(loaded by UE4SS's `BPModLoaderMod`); ask for the plain mount point with:

```ini
[plugin]
pak_target=paks        ; links into Content\Paks\~mods\ instead of LogicMods\
```

One folder is classified as **one** kind. A folder holding both `Scripts\main.lua` and a `.pak`
is treated as a Lua mod and its pak is **not** linked — ship those as two separate folders.

---

# 한국어

**모드 제작자용.** 토글키·색상·임계값·켬끔 스위치가 필요할 때, 사용자를 `config.ini` 로
보내지 않아도 됩니다. 모드 옆에 **작은 텍스트 파일 하나**만 두면 매니저가 게임 타이틀
화면에 진짜 UI 컨트롤로 그려 줍니다.

**등록 함수 호출도, 링크할 API 도 없습니다.** 폴더 생김새로 찾아내고, 매니페스트가 있으면
읽습니다.

## 1. 어떻게 인식되나

사용자는 모드를 여기에 넣습니다.

```
…\DS\Binaries\Win64\ue4ss\Mods\DsCppModManager\plugins\<내모드>\
```

아래 **하나만** 있으면 모드로 인식됩니다.

| 들어 있으면 | 인식 |
|---|---|
| `Scripts\main.lua` | Lua 모드 |
| `dlls\main.dll` | C++ 모드 |
| 최상단에 `*.pak` | pak 콘텐츠 모드 |

탐색이 10단계까지 내려가므로 `Win64\ue4ss\Mods\내모드\…` 형태로 풀려도 찾아내고,
`plugins` 에 넣은 `.zip` 은 자동으로 풀립니다. 매니페스트가 없어도 켬끔 토글은 붙습니다.

## 2. 켬/끔은 두 겹입니다

| 파일 | 계층 |
|---|---|
| `enabled.txt` (빈 파일) | **로드 계층** — UE4SS 가 이게 있어야 모드를 시작합니다 |
| `dsruntime.txt` (`1` 또는 `0`) | **런타임 계층** — 지금 일할지 말지 |

**`dsruntime.txt` 를 1초마다 읽으면 재시작 없는 켬끔**이 됩니다. 파일이 없으면 "켜짐"으로
보세요. Lua 는 §5 헬퍼가 알아서 해 줍니다.

## 3. `dsplugin.ini`

모드 루트에 두고 **UTF-8 로 저장**합니다.

```ini
[plugin]
name=내 모드              ; 생략하면 폴더명. 파일 동작은 항상 폴더명 기준입니다

[option:radius]
label=탐지 반경 (m)
type=int
min=20
max=200
step=10
default=60
```

- `[option:<키>]` 의 `<키>` 가 저장 파일의 키입니다 (영문/숫자/`_`, 31자 이내)
- **모드당 16개까지.** 보이는 옵션이 8개 이상이면 자동으로 접히니, 자주 쓰는 것을 먼저
  선언하세요

## 4. 컨트롤 8종

| `type=` | 컨트롤 | 저장값 |
|---|---|---|
| `bool` | 켜기/끄기 토글 | `0` / `1` |
| `int` | `◀ 60 ▶` 스테퍼 | 정수 |
| `int` + `choices=` | 드롭다운 | 0기준 인덱스 |
| `key` | 키 지정 | 가상키 코드 (`0` = 없음) |
| `color` | 색 견본 + 팔레트 | `0xRRGGBB` (파일엔 10진수) |
| `check` | 체크박스 | `0` / `1` |
| `button` | 실행 버튼 | **누른 횟수** |
| `slider` | 가로 게이지 | 정수, `0`~`1000` |

**키 지정** — `default=` 를 **생략**하세요. 비어 있는 상태에서 시작하는 것이 게임 키 변경
UI 의 관례입니다. `Delete` 는 해제(값 `0`), `Escape` 는 취소입니다.
**모드는 `0` 을 "키 없음"으로 다뤄야 합니다** — 그대로 `GetAsyncKeyState` 에 넘기지 마세요.

**실행 버튼** — 값이 아니라 "한 번 시켜라" 입니다. 저장값이 누른 횟수이므로,
**지난번보다 커졌을 때** 한 번 일하고 그 값을 기억하면 됩니다. 시작할 때 현재 값을
기준으로 잡으므로 첫 실행에 저절로 눌리지 않습니다. `default=` 는 적지 마세요.

**슬라이더** — 허용 범위 `0`~`1000` (생략 시 `0`~`100`). 소수가 필요하면 1000배로 받아
모드에서 나누세요. 슬라이더 위에서 좌우로 끌어도 패널이 스크롤되지 않습니다.

## 5. 자식 옵션

```ini
[option:autoswap]
label=음식 자동교체
type=bool
default=0

[option:foodkind]
label=음식 종류
type=int
choices=아무거나, 체력 회복만, 부활만
default=0
parent=autoswap        ; autoswap 이 켜졌을 때만 표시
;parent_value=2        ; (선택) 부모가 정확히 이 값일 때만
```

부모 **바로 다음에** 선언하세요(표시 순서 = 선언 순서). 숨겨져도 값은 보존됩니다.

## 6. 값 읽기

모드 옆 **`dsoptions.txt`** 에 `key=value` 로 저장됩니다. 바꾸는 즉시 파일에 반영되고,
적용 시점은 모드의 읽기 주기입니다(1초 폴링 권장).

**Lua** — 이 저장소의 [`dsmm_options.lua`](dsmm_options.lua) 를 `Scripts\` 에 복사하세요.
자유롭게 복사·배포해도 되고 표기 의무도 없습니다.

```lua
local mm = require("dsmm_options")

LoopInGameThreadWithDelay(1000, function()
    local enabled, opts = mm.poll({ sound = 1, radius = 60 })
    if not enabled then return end   -- 매니저에서 꺼짐
    -- opts.sound, opts.radius 사용
end)
```

**C++** — 파일 둘만 읽으면 됩니다. `dsoptions.txt`(`키=정수` 줄들) 와
`dsruntime.txt`(`1` 또는 `0` 한 글자). 없으면 기본값으로 두면 됩니다.

## 7. 재시작 안내 팝업 요청

모드 폴더에 **`dsnotify.txt`** 를 쓰면(내용 = `restart` 또는 직접 쓴 문구) 매니저가 게임식
팝업을 대신 띄우고 파일을 지웁니다(1회성). Lua 는 `mm.requestRestartPopup()`,
C++ 은 같은 파일에 한 줄 쓰면 됩니다.

## 8. 규칙과 함정

- `dsplugin.ini` 가 없어도 모드는 인식되고 토글됩니다 — 옵션 UI 만 안 생깁니다
- `min`/`max` 는 매니저가 검증하지만 모드에서도 방어적으로 클램프하세요

**안전장치와 함께 살기** — 매니저는 게임이 켜질 때마다 게임 패치와 직전 크래시를 확인하고,
걸리면 **모든 모드를 끕니다.** 내 모드가 사용자 동의 없이 꺼져 있을 수 있으니 켜져 있음을
전제로 설계하지 마세요. 크래시 뒤에는 **마지막으로 로그를 남긴 모드**가 용의자로 지목되니,
**위험한 작업 직전에 한 줄 남기면** 추적이 쉬워집니다. 반대로 아무 일 없는데 1초마다 쓰면
남의 크래시에 억울하게 지목됩니다.

**★ 게임 주소를 코드에 박지 마세요.** 게임이 패치되면 함수 주소가 전부 밀리고, 그대로
호출하면 **게임이 즉사**합니다. 실행할 때마다 찾고, 시그니처가 2곳 이상 걸리면 추측하지
말고 실패로 처리하세요.

## 9. pak 콘텐츠 모드

최상단에 `.pak` 이 있는 폴더도 관리됩니다. 켜면 게임 `Paks` 폴더로 하드링크하고 끄면
끊습니다. 기본 목적지는 `LogicMods`(UE4SS 의 `BPModLoaderMod` 가 로드), `pak_target=paks`
로 선언하면 `Content\Paks\~mods\` 로 갑니다.

⚠ 한 폴더는 **한 종류로만** 분류됩니다. `Scripts\main.lua` 와 `.pak` 을 함께 든 폴더는
Lua 모드로 잡히고 pak 은 링크되지 않습니다 — 두 폴더로 나눠 배포하세요.

---

궁금한 점은 [이 저장소의 Issues](../../issues) 로.
