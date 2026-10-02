# AGENTS.md

## Repository Overview

Hammerspoon Spoon 플러그인 모음 저장소입니다.

## Structure

- `*.spoon/init.lua`: 각 스푼의 메인 모듈
- `SpoonLoader.spoon`: `spoons.yaml` 설정을 읽어 스푼을 자동으로 초기화하고 실행

## Spoons

- `WebView.spoon`: 메뉴바 아이콘 연동 웹뷰 팝오버 표시. 외부 클릭 감지(`hs.eventtap`), 포커스 감지(`focusChange`), 창 재오픈 시 W3C 표준 이벤트(`visibilitychange`, `focus`) 전달, `reloadOnOpen` 옵션 및 우측 하단 페이지 리로드 버튼(`showReloadButton`) 지원.
- `DarkMode.spoon`, `ExitOnClose.spoon`, `FullScreen.spoon`, `KillAppOnLock.spoon`, `MuteOnBattery.spoon`, `RestoreBrightness.spoon`, `SimpleMenu.spoon`, `StickWindow.spoon`, `TinyYaml.spoon`

## Guidelines

- 저장소 변경 작업 전 `git fetch` 및 최신 상태 확인
- 커밋, 푸시 등 저장소 영향 행위는 반드시 사용자 사전 승인 후 진행
- 작업 후 `README.md` 및 `AGENTS.md` 동기화
