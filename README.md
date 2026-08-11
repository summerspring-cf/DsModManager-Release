# DsCppModManager — Releases

Distribution repository for **DsCppModManager**, an in-game mod manager for
*DragonSword: Awakening* (Unreal Engine 5.3.2, Steam).

It adds a **모드매니저 (Mod Manager)** entry to the title menu, opening a panel built from the
game's own settings widgets, where you can enable and disable mods, drag them into the order
you want, and change each mod's settings — without editing any config file.

It manages **Lua mods, C++ mods and `.pak` content mods** side by side.

**➜ [Download the latest release](../../releases/latest)**

Two builds are published:

| File | For | UE4SS |
|---|---|---|
| **DsCppModManager_&lt;ver&gt;.zip** | Most people (all-in-one) | **Included** |
| **DsCppModManager-NoUE4SS_&lt;ver&gt;.zip** | You already run UE4SS | **Not included** |

Both contain the same manager. The no-UE4SS build is tiny; the all-in-one carries UE4SS.

This repository holds **release archives only**. Nothing is built here.

---

## Install

1. **Close the game completely.**
   A running game locks the mod DLL and the install will fail.
2. Extract the archive and double-click **`install.bat`**.
   If your game is not on the default Steam path, drag your game folder onto the `install.bat` icon.
3. A popup shows the install path and the version.
   Launch the game — **모드매니저** appears in the title menu.

If you see *Access denied*, right-click `install.bat` and choose **Run as administrator**.

**The all-in-one build includes UE4SS** — you do not need to download it separately, and
`install.bat` leaves an existing UE4SS installation completely alone. If you already run UE4SS,
the **no-UE4SS** build is a tiny download; its `install.bat` stops with a message if UE4SS
isn't installed yet.

### Adding your mods

Put each mod into:

```
…\DS\Binaries\Win64\ue4ss\Mods\DsCppModManager\plugins\<ModName>\
```

A `.zip` dropped in that folder is unpacked automatically, and the manager finds the mod even
if the archive unpacks into a deep folder tree.
In game: **모드매니저 → 기본 → [폴더 바로가기]** opens that folder for you.

### Uninstall

- Turn it off: delete `Mods\DsCppModManager\enabled.txt`
- Remove it: delete the `Mods\DsCppModManager` folder

---

## Features

- **Enable / disable mods** — Lua, C++ and `.pak` content mods alike
- **Per-mod settings** — up to 16 options per mod, 8 control types:
  toggle · stepper · dropdown · **key binding** · **colour picker** · checkbox · action button · **slider**
- **Order tab** — drag mods into the order you want
- **No copies of your mods** — they live only in `plugins\`; enabling creates a directory junction
- **`.zip` auto-extract** and deep discovery, so any packaging layout works
- **Full gamepad support** — navigate the panel with the pad; on the title screen press **Y**
  to open the manager (this game's title menu can't stop the D-pad on the manager row, so a
  dedicated Y button is the entry point)
- **Korean / English UI** — follows the game's language automatically
- **Safety guard** — on a game patch or a crashed previous run, all mods are switched off at startup

---

## ⚠ UE4SS is not my work

By size, **98.6 % of the archive is not mine.**

| | Size | Share | Author |
|---|---|---|---|
| `DsCppModManager/` — the mod | ~240 KB | **1.4 %** | Me |
| `UE4SS/` — the loader | ~16.6 MB | **98.6 %** | [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), MIT License, Copyright (c) 2022 Narknon. **Unmodified official build.** |

UE4SS is a prerequisite — the mod cannot load without it. Most players of this game have never
installed it and have no `ue4ss` folder at all, and installing it by hand is the step people get
wrong, because the files go next to the game executable rather than into a mods folder.
So `install.bat` unpacks the bundled copy **only when that folder is missing**, and never
touches an existing installation.

Bundled build: experimental channel, commit `c838a8ac`, `UE4SS.dll` 16,519,168 bytes.
The mod DLL is linked against this build's export table; on a different build the mod DLL is
simply refused (the game still launches, the mod just never appears). That is why a verified
build is pinned rather than left to the user to fetch.

UE4SS is redistributed under its own MIT License; the full text ships as `ue4ss/LICENSE`
inside every archive.

---

## Making a mod that plugs into this

If you write mods for this game, the manager can render **your** settings too — ship one small
`dsplugin.ini` next to your mod and you get toggles, dropdowns, key binds, colour pickers and
sliders on the title screen, with no code to link against.

**➜ [PLUGIN_GUIDE.md](PLUGIN_GUIDE.md)** — the full contract, in English and Korean.
[`dsmm_options.lua`](dsmm_options.lua) (optional Lua helper) and
[`dsplugin.ini.example`](dsplugin.ini.example) are in this repository, free to copy.

---

## Verifying what you downloaded

SHA-256 hashes for every archive and for every DLL inside it are published in
**[SECURITY.md](SECURITY.md)**, together with a description of what the mod does at runtime.

## Other places to get it

| | |
|---|---|
| **[Hangul Patch Studio](https://hangulpatchstudio.com/g/%EB%93%9C%EB%9E%98%EA%B3%A4%EC%86%8C%EB%93%9C-%EB%AA%A8%EB%93%9C%EB%A7%A4%EB%8B%88%EC%A0%80)** | My own distribution page (Korean). Direct download, no account needed. |
| Nexus Mods | Pending — the upload is under automated review. |

## Licence

**All rights reserved.** Do not redistribute these archives or publish modified builds.
Ask first if you need to modify, redistribute, or reuse assets.
`vendor` content — the bundled UE4SS — is not covered by this notice; it is MIT licensed as
described above.

---

# 한국어

*DragonSword: Awakening* 의 **인게임 모드매니저** 배포 저장소입니다.
타이틀 메뉴에 **모드매니저** 항목이 생기고, 게임 설정창과 같은 패널에서 모드를 켜고 끄고
순서와 세부 설정을 바꿉니다. **Lua · C++ · `.pak` 콘텐츠 모드**를 함께 관리합니다.

**➜ [최신 배포본 받기](../../releases/latest)**

배포본은 두 가지입니다.

| 파일 | 대상 | UE4SS |
|---|---|---|
| **DsCppModManager_&lt;버전&gt;.zip** | 대부분의 사용자 (올인원) | **동봉** |
| **DsCppModManager-NoUE4SS_&lt;버전&gt;.zip** | 이미 UE4SS 를 쓰는 경우 | **미동봉** |

둘 다 같은 매니저입니다. 미동봉판은 아주 작고, 올인원은 UE4SS 를 함께 담습니다.

이 저장소에는 **배포본만** 있습니다. 여기서 빌드하지 않습니다.

## 설치

1. **게임을 완전히 종료합니다.**
   실행 중이면 DLL 이 잠겨 설치가 실패합니다.
2. 압축을 풀고 **`install.bat`** 을 더블클릭합니다.
   기본 스팀 경로가 아니면 게임 폴더를 `install.bat` 아이콘 위로 드래그하세요.
3. 설치 경로와 버전이 팝업으로 뜨면 끝입니다.
   게임을 실행하면 타이틀 메뉴에 **모드매니저** 가 나타납니다.

*Access denied* 가 나오면 `install.bat` 우클릭 → **관리자 권한으로 실행**.

**올인원 배포본에는 UE4SS 가 함께 들어 있습니다.** 따로 받지 않으셔도 되고, 이미 UE4SS 를
쓰고 계시면 `install.bat` 이 그쪽을 전혀 건드리지 않습니다. 이미 UE4SS 가 있다면 **미동봉판**
을 받으셔도 됩니다 — 아주 작고, UE4SS 가 없으면 안내 후 설치를 중단합니다.

### 모드 넣는 곳

```
…\DS\Binaries\Win64\ue4ss\Mods\DsCppModManager\plugins\<모드이름>\
```

이 폴더에 `.zip` 을 그대로 넣어도 자동으로 풀리고, 압축이 깊은 폴더 구조로 풀려도
매니저가 찾아냅니다. 게임 안에서 **모드매니저 → 기본 → [폴더 바로가기]** 로 열 수 있습니다.

### 제거

- 잠시 끄기: `Mods\DsCppModManager\enabled.txt` 삭제
- 완전 제거: `Mods\DsCppModManager` 폴더 삭제

## 기능

- **모드 켜고 끄기** — Lua · C++ · `.pak` 콘텐츠 모드 전부
- **모드별 세부 설정** — 모드당 옵션 16개, 컨트롤 8종
  (토글 · 스테퍼 · 드롭다운 · **키 지정** · **색상 선택** · 체크박스 · 실행 버튼 · **슬라이더**)
- **순서 탭** — 마우스로 끌어서 모드 순서 지정
- **모드 사본을 만들지 않음** — `plugins\` 한 곳에만 존재하고, 켜면 정션이 생깁니다
- **`.zip` 자동 해제**, 10단계 깊이 탐색 — 어떻게 압축했든 인식합니다
- **게임패드 전면 지원** — 패드로 패널 조작, 타이틀 화면에서 **Y** 로 매니저 열기
  (이 게임의 타이틀 메뉴는 방향키가 매니저 항목에 멈추지 못해 전용 Y 버튼을 진입 경로로 둡니다)
- **한국어 / English UI** — 게임 언어를 자동으로 따라감
- **안전장치** — 게임 패치나 직전 크래시를 감지하면 시작할 때 모드를 전부 끕니다

## ⚠ UE4SS 는 제가 만든 것이 아닙니다

배포본의 **98.6% 는 제 코드가 아닙니다.**

| | 크기 | 비중 | 저자 |
|---|---|---|---|
| `DsCppModManager/` — 실제 모드 | ~240 KB | **1.4%** | 제가 만든 것 |
| `UE4SS/` — 로더 | ~16.6 MB | **98.6%** | [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), MIT, Copyright (c) 2022 Narknon. **공식 원본 그대로.** |

UE4SS 는 전제 조건이라 그것 없이는 모드가 로드되지 않습니다. 그런데 이 게임 플레이어
대부분은 `ue4ss` 폴더 자체가 없고, 수동 설치는 파일을 모드 폴더가 아니라 **게임 실행파일
옆에** 둬야 해서 사람들이 제일 많이 틀리는 단계입니다. 그래서 `install.bat` 이 **폴더가
없을 때만** 동봉본을 풀고, 이미 있으면 손대지 않습니다.

동봉 빌드: experimental 채널 커밋 `c838a8ac`, `UE4SS.dll` 16,519,168 바이트.
모드 DLL 이 이 빌드의 export 로 링크되어 있어 다른 판에서는 로드가 거부됩니다
(게임은 정상 실행되고 모드만 안 뜹니다). 그래서 검증된 판을 고정해 동봉합니다.

## 이 매니저에 붙는 모드 만들기

모드를 만드시면 **당신의 설정도** 이 패널에 그릴 수 있습니다. 모드 옆에 작은
`dsplugin.ini` 하나만 두면 토글·드롭다운·키 지정·색상 선택·슬라이더가 타이틀 화면에
생깁니다. 링크할 코드는 없습니다.

**➜ [PLUGIN_GUIDE.md](PLUGIN_GUIDE.md)** — 전체 계약 (영문·한국어).
[`dsmm_options.lua`](dsmm_options.lua) 와 [`dsplugin.ini.example`](dsplugin.ini.example) 도
이 저장소에 있고 자유롭게 복사하셔도 됩니다.

## 받은 파일 검증

배포본과 그 안의 모든 DLL 에 대한 SHA-256 이 **[SECURITY.md](SECURITY.md)** 에 있습니다.

## 다른 배포 경로

[한글패치스튜디오](https://hangulpatchstudio.com/g/%EB%93%9C%EB%9E%98%EA%B3%A4%EC%86%8C%EB%93%9C-%EB%AA%A8%EB%93%9C%EB%A7%A4%EB%8B%88%EC%A0%80) —
직접 다운로드, 계정 불필요.

## 라이선스

**All rights reserved.** 배포본 재배포·개조판 배포 금지. 필요하면 먼저 문의할 것.
동봉된 UE4SS 는 이 조항의 적용 대상이 아니며 MIT 를 따릅니다.

---

made by **SummerSpring**
