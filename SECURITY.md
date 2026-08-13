# Verifying these releases

Hashes for every archive published here, and a plain statement of what the mod does at
runtime. This page is self-contained — everything you need to verify a download is here.

---

## 1. What is mine and what is not

**I did not write UE4SS.** By size, **98.6 % of the all-in-one archive is not my code.**
(The separate **no-UE4SS** build contains none of it — it is only the `DsCppModManager/` folder
plus `install.bat`, and is 100 % my code.)

| | Size | Share | Author |
|---|---|---|---|
| `DsCppModManager/` — the mod | ~240 KB | **1.4 %** | Me |
| `UE4SS/` — the loader | ~16.6 MB | **98.6 %** | [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), MIT License, Copyright (c) 2022 Narknon |

The `UE4SS/` folder is the **unmodified official build**, byte for byte, from the experimental
channel at commit `c838a8acaade1a0f860bdf249f039e58f4e10088`. It is bundled purely so that
players with no `ue4ss` folder do not have to install it by hand; `install.bat` unpacks it only
when the folder is missing and never touches an existing installation.

The hashes in §2 let you verify the bundled copy against the upstream release yourself,
without running anything.

---

## 2. SHA-256

### v0.50

All-in-one (UE4SS bundled):

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `DsCppModManager_0.50.zip` | 7,376,721 | `f9921558f764bf467123e9199551d3989fa4f6f552741736d5f46ff6cb9978d0` |
| ↳ `DsCppModManager/dlls/main.dll` | 284,672 | `e7fbe5962471cf1ea3c21e1bfa9065ae1df01ee4f09a1e7eee7f3b9bdcbacfe9` |
| ↳ `UE4SS/ue4ss/UE4SS.dll` | 16,519,168 | `d0107f63e567313cb6a15c505b5db2bdba38130964a04e019bda7611c6178022` |
| ↳ `UE4SS/dwmapi.dll` | 71,680 | `cfbd121b9e464b3ff35baba0f065d860aaffa7eb90f703748cd8e5b7730fa97e` |

No-UE4SS (for players who already run UE4SS):

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `DsCppModManager-NoUE4SS_0.50.zip` | 196,658 | `ec473e9afb1a4e09df26249773b2adcf676d41af57404971c7d40c3292357e79` |
| ↳ `DsCppModManager/dlls/main.dll` | 284,672 | `e7fbe5962471cf1ea3c21e1bfa9065ae1df01ee4f09a1e7eee7f3b9bdcbacfe9` |

### v0.40

All-in-one (UE4SS bundled):

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `DsCppModManager_0.40.zip` | 7,372,473 | `845ff7f735a6e6c226d8d8490645225064e3a36768fb2c67f730d79de5209da0` |
| ↳ `DsCppModManager/dlls/main.dll` | 276,992 | `c169def1555d2f57f8c65ddeea2523422c9ae7e71f0e6c4dfd3e3591ac7acfea` |
| ↳ `UE4SS/ue4ss/UE4SS.dll` | 16,519,168 | `d0107f63e567313cb6a15c505b5db2bdba38130964a04e019bda7611c6178022` |
| ↳ `UE4SS/dwmapi.dll` | 71,680 | `cfbd121b9e464b3ff35baba0f065d860aaffa7eb90f703748cd8e5b7730fa97e` |

No-UE4SS (for players who already run UE4SS):

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `DsCppModManager-NoUE4SS_0.40.zip` | 192,410 | `156f23fbde6200c0c70ee9197f59bd05f974d6ad4e777821df67103eb0247569` |
| ↳ `DsCppModManager/dlls/main.dll` | 276,992 | `c169def1555d2f57f8c65ddeea2523422c9ae7e71f0e6c4dfd3e3591ac7acfea` |

### v0.30

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `DsCppModManager_0.30.zip` | 7,322,855 | `a5ca651e95d37634b669b31a65a9eb78fc31f6449a6504aed246cbd2dee9cbf3` |
| ↳ `DsCppModManager/dlls/main.dll` | 224,768 | `f98d63242aaff6d4008d0debb6680880493caa7201e99d971f88a625d6d4250b` |
| ↳ `UE4SS/ue4ss/UE4SS.dll` | 16,519,168 | `d0107f63e567313cb6a15c505b5db2bdba38130964a04e019bda7611c6178022` |
| ↳ `UE4SS/dwmapi.dll` | 71,680 | `cfbd121b9e464b3ff35baba0f065d860aaffa7eb90f703748cd8e5b7730fa97e` |

Checking a download on Windows:

```
certutil -hashfile DsCppModManager_0.30.zip SHA256
```

The same archive is served from [Hangul Patch Studio](https://hangulpatchstudio.com/g/%EB%93%9C%EB%9E%98%EA%B3%A4%EC%86%8C%EB%93%9C-%EB%AA%A8%EB%93%9C%EB%A7%A4%EB%8B%88%EC%A0%80).
If a copy from anywhere does not match the hash above, do not run it.

---

## 3. What the mod does, and does not do

`dlls/main.dll` is the only binary here that I wrote. It is a UE4SS C++ mod, loaded into the
game process by UE4SS, and it draws a settings panel on the game's title screen.

**It does not:**

- touch the network in any way — there is **no network code at all**: no sockets, no
  WinINet/WinHTTP, no downloads, no telemetry, no update check
- read or write the registry
- call `VirtualProtect`, `WriteProcessMemory`, `LoadLibrary`, `CreateRemoteThread` or
  `SetWindowsHookEx` — all engine hooking goes through UE4SS's public mod API
- install any service, scheduled task, autorun entry or other persistence
- write anything outside the game's own installation folder
- use obfuscation, packing, or anti-analysis of any kind

**Two behaviours worth stating explicitly:**

1. **Keyboard polling.** The mod reads keyboard state with `GetAsyncKeyState`. Continuously it
   reads exactly two keys — left mouse button and Escape — for its own panel UI. There is also
   a loop over all virtual-key codes, but it runs **only** while you have clicked a *key
   binding* option and the panel is showing "press a key". It stops at the first key pressed,
   stores that one key code as your chosen binding, and stops scanning. No sequence is
   recorded and nothing is kept beyond that single integer.

2. **One child process.** The manager can auto-extract a `.zip` **you placed yourself** in its
   `plugins` folder. To do that it runs Windows' own `%SystemRoot%\System32\tar.exe`, resolved
   with `GetSystemDirectoryW` rather than from `PATH`, so a planted `tar.exe` cannot be picked
   up. That is the only process the mod ever creates. (`ShellExecuteW` is also used once, to
   open the `plugins` folder in Explorer when you click the "폴더 바로가기" button.)

**Files it writes** — all inside the game installation: a text log, `dsoptions.txt` /
`dsruntime.txt` next to each managed mod, UE4SS's own `enabled.txt` markers, and its own
`dsorder.txt` / `bootstate.txt` / `safemode_last.txt`. Enabling a mod creates a **directory
junction** under `Mods\` pointing at the single copy in `plugins\` (rather than duplicating
files); `.pak` content mods are **hard-linked** into the game's `Paks` folder and unlinked when
disabled.

---

## 4. Why antivirus and upload scanners flag this

Four properties of the archive match malware heuristics. All four are inherent to how Unreal
Engine modding works on Windows, and three of them belong to UE4SS rather than to my code.

| What a scanner sees | What it is |
|---|---|
| `dwmapi.dll` placed next to the game executable | UE4SS's **proxy loader**. As a pattern this is textbook DLL search-order hijacking — and it is openly, by design, how UE4SS loads. Unmodified official file. |
| `UE4SS.dll`, 15.8 MB, unsigned | A widely used Unreal Engine scripting framework. Unmodified official build; hash in §2. |
| An unsigned DLL hooking an engine function | My mod. It registers a pre-callback on `UObject::ProcessEvent` **through UE4SS's public C++ mod API**. It does not patch code itself. |
| `install.bat` writing into `C:\Program Files (x86)\Steam\…` | The installer, copying the mod into the game's own UE4SS `Mods` directory. |

None of these involve persistence, privilege escalation, injection into other processes, or
network activity.

---

## Contact

Issues on this repository, or the mod's Nexus Mods comments section.
