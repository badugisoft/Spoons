# Spoons

Hammerspoon Spoons collection.

## Spoons

- **DarkMode.spoon**: 다크 모드 전환 스푼
- **ExitOnClose.spoon**: 창 닫기 시 앱 종료 스푼
- **FullScreen.spoon**: 전체 화면 토글 스푼
- **KillAppOnLock.spoon**: 화면 잠금 시 앱 강제 종료 스푼
- **MuteOnBattery.spoon**: 배터리 사용 시 음소거 스푼
- **RestoreBrightness.spoon**: 전원/잠금 해제 시 화면 밝기 복원 스푼
- **SimpleMenu.spoon**: 메뉴바 간편 메뉴 구성 스푼
- **SpoonLoader.spoon**: YAML 기반 스푼 일괄 로더
- **StickWindow.spoon**: 창 고정 및 위치 이동 스푼
- **TinyYaml.spoon**: 경량 YAML 파서
- **WebView.spoon**: 메뉴바 아이콘 클릭 시 웹뷰 팝오버를 표시하는 스푼

### WebView.spoon 설정 옵션

`spoons.yaml`에서 다음과 같이 설정할 수 있습니다:

```yaml
- name: WebView
  start: true
  config:
    items:
      - title: "📈"
        url: "https://stock.badugi.net"
        width: 480
        height: 320
        keepInBackground: true  # 창이 닫혀도 백그라운드에 웹뷰 유지 (기본값: true)
        closeOnBlur: true       # 포커스를 잃거나 외부 클릭 시 창 닫기 (기본값: true)
        reloadOnOpen: false     # 창이 다시 열릴 때 전체 새로고침 여부 (기본값: false, 창 열릴 때 visibilitychange/focus 이벤트 전달)
```