# Solas Flow — code-only user-usage audit

**Date:** 2026-10-11  
**Baseline:** `f9d99b2`  
**Previous audit:** [APP_AUDIT_2026-10-11.md](APP_AUDIT_2026-10-11.md), preserved as the first-pass record.

## Result

**52 retained user-usage findings: 3 high, 47 medium, 2 low.** Parent classification: **43 newly identified usage flaws and 9 concrete extensions of earlier findings.** Duplicate reports of the same journey/root defect were merged; supporting reviewers are listed beside each retained item. Prior structural defects that were merely reconfirmed are listed separately and are not counted again.

Twelve concurrent reviewers completed their assignments; their results were joined before consolidation. The parent separately traced ordinary landscape navigation, built-in Help instructions and Custom input validation, and verified high-impact completion/restore/chain paths plus representative sleep, backup, native queue and speech-control contracts. One reviewer returned current-baseline observations in its explanation rather than its patch-oriented findings array; those observations were independently inspected and merged. A clean diff or its `overall_correctness` field is **not** a verdict that the existing app works correctly.

### Method and limits

- This pass obeyed the request to navigate **through code files only**. Each item starts from an actual control, route, shortcut, native widget or supported backup action and traces its callback, state, async boundary, persistence and resulting navigation/feedback.
- **No app/UI/browser launch, screenshot, device/ADB interaction, runtime diagnostic, test, analyzer, build, formatter, download, import, systemd operation, dependency installation or environment change ran in this pass.** Read-only repository inspection and the documentation checkpoint are not app execution.
- **Source-traced** means the stated result follows from the inspected branch/state transitions given the preconditions. It does not mean the behavior was reproduced on a device. **[INFERENCE]** identifies timing/platform-dependent triggering conditions or consequences. Three retained findings explicitly require a narrow async/queue interleaving; other entries state their platform/failure prerequisites without claiming those were exercised.
- High: loss/corruption of an active user run or failure of the advertised multi-stage timer. Medium: supported controls fail, produce contradictory state, lose session data or misrepresent operations. Low: actionable guidance/validation-feedback defects.
- At initial audit publication, no fixes had been applied. The audit remains the full baseline; subsequent repair progress is recorded below. A source-only audit cannot guarantee every possible usage flaw has been found.

## Repair progress

Implementation status is source-reviewed, not device/UI reproduced. Findings not listed here remain open; partial remediation does not close a finding.

| Findings | Repair status |
|---|---|
| U01, U04, U06, U07 | Fixed in code: stale timer completion work/dialog results cannot replace or idle a newer run; foreground/background expired chains share one advancement path. |
| U03, U16, U17, U42–U45 | Fixed in code: restored timer selection, persisted stopwatch laps, interval-based tagging/accounting, dashboard invalidation and daily rollover refresh. |
| U08, U13, U15, U21–U25, U28, U31 | Fixed in code: notification audio is stopped on timer replacement/master mute; delayed speech is revalidated after waits; clock schedule changes invalidate pending batches; sleep deadlines recheck current mode/window and resume audio at the quiet-window end; disabling timer speech suppresses pending timer items; TTS boost no longer changes shared Android media gain. |
| U35–U36 | Fixed in code: backup exports avoid same-minute collisions, write failures remain errors, and invalid/incomplete imports are rejected rather than treated as cancellation/default settings. |
| U32–U34 | Fixed in code: restore reschedules/stops Clock from imported state, stops current speech and muted audio, and rebinds Android TTS from the imported engine selection. |
| U37 | Scope clarified in Settings UI and restore confirmation: JSON backups cover app preferences, not local desktop offline-model selections; restore leaves those local selections unchanged. |
| U18–U19, U38–U41, U49–U52 | Fixed in code: explicit stopwatch speech no longer depends on periodic speech/running state; reset/pause/schedule changes invalidate old stopwatch messages; fullscreen focus requests update the open route and timer dismissal preserves unrelated focus; Start 25m uses timer replacement; stale native confirmations expire from tap time; landscape retains tabs; Help copy and Custom input validation match reachable behavior. |
| U02, U05, U10, U12, U14, U26–U27 | Fixed in code: paused chain edits update persisted runtime configuration; selecting the current chain preset is a no-op; Repeat Same Timer preserves exact seconds; clock quotes run without time speech and delayed time announcements use the current time; English Rotate is retained and voice/language changes cancel stale speech callbacks. |
| U11 | Partial: delayed completion speech checks the finished run/revision before firing. An already-speaking completion message is not selectively interrupted on dismissal/restart; finding remains open. |

Verification after the latest timer/clock/voice edits: `dart analyze lib/main.dart lib/models/speech_item.dart` reported no issues. No app runtime, Android/Kotlin build, UI/device interaction or tests were run; platform and timing behavior remains unverified.

## Most urgent journeys at the audit baseline

1. **Finish timer → notification Repeat → old completion dialog Close:** the new runtime becomes idle while its interval remains non-null, leaving a frozen countdown.
2. **Reach a segment boundary with the UI ticker unavailable → reopen a chain:** background/restore paths mark the intermediate segment finished instead of advancing the advertised sequence.
3. **Choose a new preset while old completion awaits persistence [INFERENCE]:** the old continuation overwrites the new timer's visible state and can later dismiss its runtime.
4. **Enable speech-only boost on Android → finish speech → disable boost:** shared device media volume remains at maximum, also affecting ambient audio.
5. **Pause/change chain → switch apps → return:** the last stored runtime overwrites the user's new chain settings.
6. **Restore enabled Clock / a different Android engine:** Settings reports the new values, but the live scheduler or engine does not apply them.
7. **Fullscreen stopwatch Reset → return → record Lap:** prior laps survive and the new run continues old numbering.

## Reviewer coverage

| Reviewer | User journeys traced | Result |
|---|---|---|
| TimerFlow | Countdown start/pause/resume/reset, adjusted durations, replacement, fresh-state restore and rapid actions. | Completed, source-only |
| PresetChains | Preset selection, active/paused chain edits, reselection, segment advancement, background/expired restore and completed-cycle restart. | Completed, source-only |
| TimerCompletion | Normal/focus completion, close/repeat/custom/preset results, notification interaction, completion audio and delayed speech. | Completed, source-only |
| ClockUsage | Sound/Noise/Quotes combinations, intervals/repeats/category/delay, pending announcements, mute/resume and clock scheduling. | Completed, source-only |
| StopwatchUsage | Start/pause/reset, lap session ownership/restoration, explicit speech, automatic announcements and mixed surfaces. | Completed, source-only |
| AudioSpeechUsage | Global/module mute, English rotation and pinned voices, delayed language changes, strict engines, volumes and Android media gain. | Completed, source-only |
| NightMuteUsage | Quiet-hour edits, Manual/Automatic behavior, real activity, start/end boundaries, in-flight audio and ambient recovery. | Completed, source-only |
| SettingsBackupUsage | Picker cancellation/failures, backup collision/contract, valid and invalid restore, live controls and applying restored runtime effects. | Completed, source-only |
| FocusDriveUsage | Entry/close across modules, timer alerts over unrelated focus, Drive controls and native mode requests into an existing route. | Completed, source-only |
| AndroidExternalUsage | Native queue/intents/acknowledgement, launcher shortcuts, confirmation timing, notification actions and dependency reboot guards. | Completed, source-only |
| HistoryTaggingUsage | Mid-run tagging, stale recording provenance, pause/chain/restoration accounting, dashboard refresh and day rollover. | Completed, source-only |
| DesktopRecoveryUsage | Window-close/Exit/hide recovery, autostart controls, external speech cancellation, downloads/cancellation and custom model selection. | Completed, source-only |
| Parent | Landscape tab access, Help-to-native feature consistency, Custom invalid input and consolidation checks. | Completed, source-only |

## Complete finding index

| ID | Severity | Relation | Usage flaw |
|---|---|---|---|
| U01 | HIGH | new | Late completion can overwrite a newer timer |
| U02 | MEDIUM | extends | Paused chain edits revert after switching away and returning |
| U03 | MEDIUM | extends | Restored timer Reset → Start uses the default 25 minutes |
| U04 | HIGH | new | Background/restored chains stop at an intermediate segment |
| U05 | MEDIUM | new | Reselecting the active chain preset resets its position and repeats a break |
| U06 | MEDIUM | new | A completed chain can restart at its final break after restoration |
| U07 | HIGH | extends | Notification Repeat followed by old-dialog Close freezes the new timer |
| U08 | MEDIUM | new | Starting the next timer leaves the previous desktop completion sound playing |
| U09 | MEDIUM | extends | Restored Repeat Same Timer starts 25 minutes instead of the finished duration |
| U10 | MEDIUM | new | Repeat Same Timer rounds an adjusted one-second timer up to one minute |
| U11 | MEDIUM | new | Retired timer runs can still announce Timer finished |
| U12 | MEDIUM | new | Quotes On produces no quotes when Sound is Off |
| U13 | MEDIUM | new | Turning Quotes/Sound off does not retire already-delayed clock items |
| U14 | MEDIUM | extends | Delayed clock speech announces the old minute |
| U15 | MEDIUM | new | Changing the interval leaves announcements from the old schedule pending |
| U16 | MEDIUM | new | Fullscreen stopwatch Reset retains old lap history and numbering |
| U17 | MEDIUM | new | Restored stopwatch elapsed time survives but its laps disappear |
| U18 | MEDIUM | new | Drive Speak now is silent for a paused stopwatch or automatic Speech Off |
| U19 | MEDIUM | new | Reset → Start allows old stopwatch announcements into the new run |
| U20 | MEDIUM | extends | Quiet-hours rows retain old times after the user changes them |
| U21 | MEDIUM | new | Automatic sleep treats active in-app use as inactivity |
| U22 | MEDIUM | new | Automatic sleep does not arm when quiet hours begin while backgrounded |
| U23 | MEDIUM | new | Enabling Manual sleep does not stop an already-playing utterance |
| U24 | MEDIUM | new | An old automatic-mute deadline can stop audio after quiet hours end |
| U25 | MEDIUM | new | Ambient audio stays paused after sleep mute ends |
| U26 | MEDIUM | new | English Rotate voices selection is discarded and keeps using one voice |
| U27 | MEDIUM | extends | Voice/language changes leave old delayed announcements alive |
| U28 | MEDIUM | new | Timer Speech Off does not suppress a pending timer announcement |
| U29 | MEDIUM | new | System TTS only / Sherpa only can be bypassed by Malayalam asset clips |
| U30 | MEDIUM | new | Linux system-fallback speech ignores the speech-volume and boost controls |
| U31 | MEDIUM | new | Speech-only boost leaves shared Android media volume at maximum after speech |
| U32 | MEDIUM | new | Restored enabled clock settings do not start or reschedule the clock |
| U33 | MEDIUM | new | Restoring Master Audio Off allows in-flight speech to finish |
| U34 | MEDIUM | new | Restored Android engine selection is displayed but not rebound |
| U35 | MEDIUM | new | Two backups in the same minute silently overwrite the first file |
| U36 | MEDIUM | new | Backup/import failure is silently treated as user cancellation |
| U37 | MEDIUM | new | Export all settings omits the selected local desktop model |
| U38 | MEDIUM | new | Closing a timer alert also closes unrelated Clock/Stopwatch focus |
| U39 | MEDIUM | new | Widget mode requests are acknowledged but the existing focus shows the wrong module |
| U40 | MEDIUM | new | Launcher Start 25m does not replace a running timer |
| U41 | MEDIUM | new | Cold-start queued widget taps bypass the real three-second confirmation window |
| U42 | MEDIUM | new | Enabling Tagging mid-run records none of the enabled portion |
| U43 | MEDIUM | new | Reset with Tagging Off leaves stale session provenance for the next run |
| U44 | MEDIUM | new | Dashboard stays stale when a timer logs while the route remains open |
| U45 | MEDIUM | new | Timer today summary keeps yesterday totals after midnight |
| U46 | MEDIUM | new | Master mute/Exit cannot cancel the active Linux fallback speech subprocess |
| U47 | MEDIUM | new | Cancel at completed-download verification can still install Kokoro |
| U48 | MEDIUM | extends | Kokoro becomes Ready but its voices stay unavailable until Settings reopens |
| U49 | MEDIUM | new | Landscape removes the only ordinary tab navigation on mobile |
| U50 | MEDIUM | new | Help sends users to an Accessibility Service that does not exist |
| U51 | LOW | extends | Help advertises a timer slider absent from Timer Setup |
| U52 | LOW | new | Invalid Custom timer input makes Set silently do nothing |

## Detailed journeys and evidence

## Countdown, presets and chain transitions

### U01 — [HIGH] Late completion can overwrite a newer timer

**Evidence level:** Interleaving risk [INFERENCE], with source-traced consequences  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3284-3293`  
**Review origin:** TimerFlow #2

Timer tab sequence: with Chain off, start a 1-minute timer and tap another preset, such as 5 minutes, after its deadline
is reached but while `_completeTimerRun` is awaiting its persisted finished-state write. Expected: the new preset
remains running with a working Pause control; actual for this permitted interleaving: the old completion clears the new
timer's interval handle, displays zero/finished state, and opens the old completion dialog. `_completeTimerRun` cancels
the old interval, marks its runtime finished and executes `await _timerRuntimeStore.save(_timerRuntime)` at
lib/main.dart:3273-3284 without disabling the controls; TimerPanel always supplies enabled Reset and preset callbacks at
lib/widgets/timer_panel.dart:313-344. `_onPresetTap` → `choosePreset` → `resetTimer` → `startTimer` at
lib/main.dart:3761-3791,3817-3822 establishes a new run, revision and periodic interval synchronously during that await.
The old continuation checks only `mounted` and then unconditionally executes `timerInterval = null; seconds = 0; ...
_isTimerFinished = true` at :3285-3293, followed by the alarm/dialog at :3318-3330; it does not compare run ID or
revision. The newer periodic timer is not canceled by clearing its handle, so it can continue updating a display whose
primary button is now labeled Start rather than Pause, and closing the stale dialog can replace its runtime with idle
through :3354-3371 and :1819-1829. Severity: high; timing/platform risk is [INFERENCE], not a reproduced race, but the
resulting divergent state is directly determined by the shown interleaving. Repair by capturing and validating a
transition generation/run/revision after every completion await, invalidating pending completion when reset/start/preset
changes occur, and committing completion state only for the still-current run; apply the same guard to the chain
rollover continuation at :3251-3257. Prior audit relation: new.

### U02 — [MEDIUM] Paused chain edits revert after switching away and returning

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#31)  
**Primary source anchor:** `lib/main.dart:4029-4038`  
**Review origin:** TimerFlow #3; corroborated by PresetChains #2

Timer tab sequence: start a preset with Chain off, pause it, enable Chain and optionally choose 'Quick 15-3x3', switch
to another application, then return to Solas Flow. Expected: the selected Chain mode and sequence remain selected for
the next Start; actual: Chain is turned off again and the previous sequence is restored, even though the same UI process
remains alive. This is source-traced: Pause persists `_timerRuntime.copyWith(status: TimerRuntimeStatus.paused, ...)` at
lib/main.dart:3743-3751 while retaining its original chain fields; the visible Chain toggle and sequence picker invoke
callbacks at lib/widgets/timer_panel.dart:366-371,455-468,581-588, but the callbacks at lib/main.dart:4029-4042 update
only `chainModeOn`, `chainPresetKey`, `chainIndex` and `_lsSave()`, not the runtime. `_lsSave` writes the AppSettings
snapshot and widget payload at :1985-1991, with no chain fields in the widget payload at :2079-2090. On resume,
`didChangeAppLifecycleState` calls `_restoreTimerRuntime` whenever the timer is paused at :2739-2746; loading the same
run/revision is accepted because the revision guard rejects only strictly older revisions at :3147-3151, and
`_applyTimerRuntime` then executes `chainModeOn = next.chainModeOn; chainPresetKey = next.chainPresetKey; chainIndex =
next.chainIndex` at :3173-3175. Severity: medium; repair by updating and saving the authoritative runtime chain fields
when the visible controls change them, or by separating upcoming configuration from active-run configuration so
restoration does not silently overwrite the user's newer choices. Prior audit relation: extends finding 31, 'Settings
mutation and persistence are separate manual choreography; idle chain configuration is not saved', with a same-process
paused-app-switch journey rather than only restart persistence.

### U03 — [MEDIUM] Restored timer Reset → Start uses the default 25 minutes

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#30)  
**Primary source anchor:** `lib/main.dart:3170-3178`  
**Review origin:** TimerFlow #4

Timer tab sequence: with Chain off, tap the 5-minute preset, pause partway through, have the UI process interrupted
without the in-app Exit action, reopen the saved paused timer, then tap Reset followed by Start. Expected: Reset/Start
uses the previously selected 5-minute duration; actual: it starts 25 minutes, and immediately after restoration the
quick-preset grid already highlights 25 minutes despite the saved 5-minute run. This is source-traced: `sliderValue`
initializes to 25 at lib/main.dart:483-484; `_applyTimerRuntime` correctly restores `seconds` and
`_activeTimerDurationSeconds` from the saved runtime at :3170-3172 but never restores `sliderValue`. TimerPanel receives
`sliderValue` at :3967 and uses it as `PresetGrid.selectedValue` at lib/widgets/timer_panel.dart:336-342. `resetTimer`
clears `seconds` and `_activeTimerDurationSeconds` at lib/main.dart:3768-3777 without correcting that selection, and
`startTimer` subsequently follows `seconds = sliderValue * 60` at :3699-3707. Normal tab switching does not cause this
problem because the parent State survives; the stated precondition is restoration into a fresh State. Severity: medium;
repair by retaining/restoring the selected start duration alongside the runtime, initializing the preset selection from
that authority, and ensuring Reset/Start uses it instead of the constructor default. Prior audit relation: extends
finding 30 with a specific restored-state label and subsequent wrong-duration action.

### U04 — [HIGH] Background/restored chains stop at an intermediate segment

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:149-158`  
**Review origin:** PresetChains #1; corroborated by HistoryTaggingUsage #4, AndroidExternalUsage observation #5

High severity; new relative to APP_AUDIT_2026-10-11.md (its #03 concerns missing background history, not premature chain
termination). Preconditions: an Android chain is running and the foreground UI ticker is unavailable while the
foreground task continues; reaching that platform condition is not device-verified, but the resulting transition is
source-traced. Steps: enable Chain, select Quick 15-3x3, Start from zero, background the app, and reopen after the first
15-minute deadline. Expected: continue the advertised [15,3,15,3,15,3] sequence rather than declare the entire run
finished at its first boundary. Actual: SolasFlowTaskHandler._reconcile unconditionally executes `status:
TimerRuntimeStatus.finished` when remaining becomes zero (lib/main.dart:142-159), preserving `chainModeOn: true`,
`chainPresetKey: Quick 15-3x3`, and `chainIndex: 0`; no branch advances to the 3-minute break. Bootstrap →
_restoreTimerRuntime → _applyTimerRuntime adopts that finished snapshot and opens the completion dialog (3119-3189);
even if the task has not written finished, restoration independently converts any expired running snapshot to finished
(3153-3163). Only the UI _completeTimerRun has the segment-advancement branch (3235-3268). Repair: share the chain
transition between UI ticking, background reconciliation and expired-runtime restoration, defining catch-up from
persisted segment deadlines and marking finished only after the final segment; do not depend on the UI isolate to
execute the remaining chain.

**Parent qualification:** Background/reboot continuation requires the platform to keep or restart the foreground task. Its finished-without-chain-advance branch and expired-runtime restore branch are source-traced; no device execution is claimed.

### U05 — [MEDIUM] Reselecting the active chain preset resets its position and repeats a break

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:4034-4041`  
**Review origin:** PresetChains #3

Medium severity; new. Preconditions: Quick 15-3x3 is running its first 3-minute break, so chainIndex is 1 and the panel
displays Step 2. Steps: open Preset sequence and tap the already-selected Quick 15-3x3 row; allow the countdown to
finish. Expected: unchanged selection leaves the existing [15,3,15,3,15,3] run at Step 2, then advances to a 15-minute
work segment. Actual: the selected ListTile remains tappable and always calls `onChainPresetChanged(entry.key)`
(lib/widgets/timer_panel.dart:558-591), and the callback unconditionally performs `chainPresetKey = val; chainIndex = 0`
without changing the break's remaining time (lib/main.dart:4034-4041). The panel now displays Step 1 for that same
break; at its deadline _completeTimerRun increments the reset index to 1 and starts another 3-minute break (3235-3247),
producing consecutive breaks and inserting extra segments. The same reset occurs if the running break is paused before
reselecting and resumed without a lifecycle restoration. Repair: make selecting the current preset a no-op; for a
genuinely different preset, explicitly reconcile the current countdown and sequence position rather than relabel an
unchanged segment as the first segment.

### U06 — [MEDIUM] A completed chain can restart at its final break after restoration

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3277-3283`  
**Review origin:** PresetChains #5

Medium severity; new, not a duplicate of chain-history accounting. Preconditions: a Quick 15-3x3 chain completes all six
segments in the foreground and its finished snapshot survives a subsequent app relaunch. Steps: reopen the completion
dialog, choose Close timer, then press Start with Chain still on. Expected: start a fresh Quick chain at its first
15-minute work segment, as Close timer → Start does without relaunch. Actual: final completion executes the local-only
`chainIndex = 0` (lib/main.dart:3270), then persists `_timerRuntime.copyWith(status: finished, ...)` without a
chainIndex argument (3277-3283). The runtime therefore retains the final segment's index 5, duration 180 and enabled
Quick configuration. Relaunch restores index 5 (3173-3175); Close timer calls _dismissFinishedTimer, which writes an
idle runtime but only clears `_isTimerFinished` in local state and leaves the restored chainIndex untouched (1820-1830).
Start sees zero remaining time and uses `sequence[chainIndex] * 60` (3699-3703); its bounds check accepts 5 because it
is less than length 6. Consequently it starts another isolated 3-minute final break and immediately finishes after that
break, never running the first five segments. Repair: persist the intended next-start index when completing the chain,
and reconcile the local index when dismissing/adopting finished state so a completed cycle cannot resume from its last
segment.

## Completion dialogs, Repeat and alarms

### U07 — [HIGH] Notification Repeat followed by old-dialog Close freezes the new timer

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#51)  
**Primary source anchor:** `lib/main.dart:1748-1750`  
**Review origin:** TimerCompletion #1; corroborated by AndroidExternalUsage observation #3

Source-traced; high severity; extends prior audit #51 with a deterministic timer-freeze journey. Preconditions: Android,
a completed timer with its dialog still open. Actions: select Repeat in the notification, return to the still-open
completion dialog after the running snapshot has been adopted, then press Close timer or Back. Expected: the old modal
is retired by Repeat and cannot dismiss the new run. Actual: notification Repeat writes a running runtime and sends
{'type': 'runtime', 'snapshot': runtime.toJson()} (lib/main.dart:250-268); _handleTaskData only calls _applyTimerRuntime
(1748-1750), which starts a periodic timer for that runtime (3178-3179) without closing the old dialog. Closing that
dialog subsequently calls _dismissFinishedTimer (3366-3367), which unconditionally replaces the new running runtime with
TimerRuntime.idle() (1824-1827) but leaves timerInterval and seconds intact. tick immediately returns for idle status
(3193), while Start refuses a non-null interval (3696): the panel remains Running/Pause with a frozen positive
countdown, and the repeated timer is lost. Separately, both notification Dismiss and Repeat bypass
_stopMobileRingtone/stopNotification, so the old alarm continues until its timeout, reconfirming #51. Repair: identify
the dialog by finished run/revision, retire it and stop completion audio on either external transition, and ignore
results from a superseded dialog; do not route an obsolete modal's null result into dismissal of the current run. This
ordered sequence does not require a concurrent interleaving.

### U08 — [MEDIUM] Starting the next timer leaves the previous desktop completion sound playing

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3338-3340`  
**Review origin:** TimerCompletion #2; corroborated by AudioSpeechUsage #3

Source-traced; medium severity; new relative to the prior audit. Preconditions: a non-Android platform with completion
audio enabled and working. Actions: let the timer finish, then select Repeat Same Timer, a finished-dialog preset, or
valid custom minutes before the ten-second completion sound expires; optionally immediately use the app-bar audio-off
control. Expected: accepting the next timer stops the previous completion alarm, and Audio OFF silences all audio.
Actual: _completeTimerRun uses _audioService.playNotification(... stopAfter: const Duration(seconds: 10))
(lib/main.dart:3323-3330), but the selected-duration branch only calls _stopMobileRingtone and _startTimerFromMinutes
(3362-3373). _startTimerFromMinutes also only stops the mobile ringtone (3338-3340), which is a no-op on desktop
(1794-1797). Thus the old completion sound continues over the new countdown; _setSpeechMaster(false) likewise stops
TTS/background/mobile ringtone but not notification playback (1807-1811), so Audio OFF does not silence it either. Close
without selecting another timer does correctly call stopNotification via _dismissFinishedTimer (1822-1823). Repair:
stop/invalidate notification playback as part of the shared completion-audio teardown before every restart, and include
that player in the master-mute teardown. AudioService already supplies a revision-protected stopNotification
implementation (lib/services/audio_service.dart:127-138). No platform reproduction is claimed.

**Parent qualification:** The same notification player is missing from Master Audio OFF teardown. One retained defect covers both restart and mute journeys, rather than counting the player twice.

### U09 — [MEDIUM] Restored Repeat Same Timer starts 25 minutes instead of the finished duration

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#30)  
**Primary source anchor:** `lib/main.dart:3168-3175`  
**Review origin:** TimerCompletion #3; corroborated by TimerFlow #1, PresetChains #4, HistoryTaggingUsage #3

Source-traced; medium severity; new relative to the prior audit. Preconditions: persistent runtime is finished, with a
duration other than 25 minutes, and a fresh MainScreen is loading it. Actions: open the application with that pending
finished runtime, then select Repeat Same Timer. Expected: repeat the persisted duration. Actual:
_lastFinishedTimerDurationSeconds initializes to 25 * 60 (lib/main.dart:754), and _applyTimerRuntime restores only
_activeTimerDurationSeconds = next.durationSeconds (3171), not the last-finished duration. It then presents the
completion dialog for restored finished status (3185-3187). Both dialogs calculate their Repeat result from
_lastFinishedTimerDurationSeconds (3435-3442, 3616-3620), so a persisted one-minute or ten-minute completed timer
repeats for 25 minutes. The notification Repeat consumer instead uses runtime.durationSeconds (250-258), making the two
supported repeat surfaces disagree. The existing in-memory 25-minute fallback also survives adoption of an expired
persisted running runtime, which is converted to finished at 3154-3163. Repair: populate the repeat duration from the
finished runtime when adopting/restoring it, preferably have the dialog use the captured finished runtime itself. This
finding explicitly requires a fresh/restoring State; it does not assume that OS Back destroys State.

### U10 — [MEDIUM] Repeat Same Timer rounds an adjusted one-second timer up to one minute

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3435-3442`  
**Review origin:** TimerCompletion #4

Source-traced; medium severity; new relative to the prior audit. Actions: tap the visible one-minute preset, press the
visible minus control while it runs, let the resulting one-second timer finish, then select Repeat Same Timer in either
completion dialog. Expected: repeat the completed timer's stored duration, consistently with notification Repeat.
Actual: the minus control calls addTimeToRunningTimer(-60) (lib/widgets/timer_panel.dart:212); both remaining time and
duration clamp to one second, with _activeTimerDurationSeconds = duration (lib/main.dart:3797-3807). Completion captures
that one-second duration (3274-3276). Both dialog repeat handlers use '(_lastFinishedTimerDurationSeconds ~/
60).clamp(1, 720)' (3435-3439, 3616-3619) and pass the result to a minutes-only start helper, so Repeat Same Timer
starts 60 seconds, whereas notification Repeat faithfully starts runtime.durationSeconds, one second (250-258).
Pausing/resuming a timer with less than a minute remaining is not by itself evidence of this defect: startTimer normally
retains the original duration when resuming (3709-3713). Repair: distinguish a repeat action carrying exact
durationSeconds from preset/custom actions carrying whole minutes, and restart the former without integer division or a
one-minute minimum.

### U11 — [MEDIUM] Retired timer runs can still announce Timer finished

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2946-2952`  
**Review origin:** TimerCompletion #5

Source-traced; medium severity; new relative to the prior audit. Preconditions: audio and timer speech enabled, working
speech output, and a clock/timer/stopwatch/goal announcement fired within ten seconds before completion. Ordered
actions: let the timer finish, then close its completion dialog or start a replacement timer before the announcement gap
expires. Expected: retiring the completed run cancels its pending completion speech; the replacement timer must not
announce that it has already finished. Actual: completion calls speakTimerMessage('Timer finished')
(lib/main.dart:3306-3312), which enqueues an announcement behind the ten-second gap (2779-2795). Unlike clock and
stopwatch announcements, speakTimerMessage supplies no isStillValid predicate (2938-2952). Neither _dismissFinishedTimer
(1820-1831) nor _startTimerFromMinutes (3337-3351) invalidates the speech generation or removes this pending
announcement. After the user has closed or replaced the timer, the scheduled onFire still executes 'speak(text, voice:
timerVoice)' (2951), producing stale completion speech, and any already-speaking completion message is likewise not
stopped by those actions. A reachable way to establish the gap is to enable clock speech shortly before timer
completion: the Clock control routes to speakClock immediately (3881-3894). Repair: associate completion speech with the
captured finished run/revision and check validity before firing, then cancel its queued/active speech on
dismissal/restart without cancelling unrelated clock announcements. The specified action-before-gap ordering is
deterministic, not a conjectured race.

## Speaking-clock controls and scheduling

### U12 — [MEDIUM] Quotes On produces no quotes when Sound is Off

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2839-2843`  
**Review origin:** ClockUsage #1

Severity: medium; confidence: source-traced; prior audit relation: new. Preconditions: master audio on and no active
night mute. User steps: (1) open Clock; (2) turn Sound, Noise and Quotes off; (3) turn only Quotes on; (4) wait through
the selected announcement interval. Expected: the independently enabled Quotes control produces quotes while spoken time
remains disabled. Actual: no quote ever executes, although Quotes displays On and its category/delay controls remain
usable. The visible controls are independent in lib/widgets/clock_panel.dart:161-190; onMotivationChanged sets
motivationOn and optionally clockOn/startClock in lib/main.dart:3913-3921, but both startClock and the scheduled
callback call speakClock only under `if (clockSpeakTime)` (2819, 2839), speakClock additionally requires `clockOn &&
clockSpeakTime` (2882), and the only quote enqueue is inside that function (2899-2909). The same failure occurs when
Sound is disabled while Quotes and Noise remain enabled: ambient audio continues, but quotes disappear. Repair
direction: give the scheduled clock batch separate time and quote branches, with quote validity controlled by
clockOn/motivationOn rather than clockSpeakTime; alternatively, explicitly prevent and explain the unsupported
combination instead of presenting Quotes as independently enabled.

**Parent qualification:** The concrete flaw is an allowed enabled-but-silent control combination. Either support independent quotes or explain/enforce their dependency on Sound; a new quote-only feature is not silently assumed.

### U13 — [MEDIUM] Turning Quotes/Sound off does not retire already-delayed clock items

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2566-2573`  
**Review origin:** ClockUsage #2

Severity: medium; confidence: source-traced; prior audit relation: new. Preconditions: master audio on; Sound and Quotes
on; choose a long quote delay such as 30 or 60 seconds. User steps: (1) allow a clock announcement to enqueue its
delayed quote; (2) after the time finishes, turn Quotes off during the delay; (3) optionally turn Sound off too.
Expected: disabled Quotes must not begin speaking a not-yet-started quote, and disabled Sound must suppress
not-yet-started time repeats. Actual: the quote still speaks after its delay; queued time repeats also continue after
Sound is disabled. `drainQueue` removes the item before waiting (`final item = speechQueue.removeFirst(); ... await ...
item.delayMs`, lib/main.dart:2566-2569), then only checks mounted, generation and master/night mute (2570-2573), not
clockOn, clockSpeakTime or motivationOn. The Clock callbacks only update and persist booleans (3881-3894, 3913-3921),
neither removing obsolete items nor changing `_speechGeneration`; the pre-enqueue `isStillValid` check at 2882 cannot
protect already queued or popped items. Playback ultimately forwards that item to `_speechService.speakItem`
(2601-2609), confirming it is not dropped downstream. Repair direction: validate clock-item type against the latest
toggles after every asynchronous wait and immediately before playback; remove pending affected items when a feature is
disabled without cancelling unrelated modules or permitted quote-only audio.

### U14 — [MEDIUM] Delayed clock speech announces the old minute

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#57)  
**Primary source anchor:** `lib/main.dart:2883-2892`  
**Review origin:** ClockUsage #3

Severity: medium; confidence: source-traced; prior audit relation: extends prior audit #57, which identifies the related
pre-gap voice/post-gap quote-language mismatch but not stale spoken wall time. Preconditions: master audio on; another
reachable timer/stopwatch/goal announcement has just consumed the shared announcement slot near the end of a minute.
User steps: (1) run a speaking countdown and wait for its remaining-time announcement near 12:00:58; (2) enable Clock
Sound at 12:00:59, or let its scheduled deadline occur then; (3) listen after the enforced gap. Expected: a clock
announcement beginning at approximately 12:01:08 should announce 12:01. Actual: it announces 12:00, because
`speakClock(timeToWords())` evaluates wall time at request creation (lib/main.dart:2819, 2839, 3892), `_speakAfterGap`
serializes the request and waits until ten seconds after the previous slot (2775-2794), and `onFire` constructs each
`SpeechItem(text, ...)` from the captured original string (2883-2896). Timer speech is reachable through the timer
controls and tick -> speakTimerMessage path (3965-3987, 3192-3222); no playback-side time regeneration exists. Long
quote/queue waits can stale this snapshot further. Repair direction: generate current clock text at the latest valid
execution point, with a coherent language/voice snapshot for that batch, rather than passing a precomputed wall-time
string through delayed scheduling.

### U15 — [MEDIUM] Changing the interval leaves announcements from the old schedule pending

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2848-2853`  
**Review origin:** ClockUsage #4

Severity: medium; confidence: source-traced; prior audit relation: new. Preconditions: Clock Sound on and a clock
announcement waiting in the shared ten-second gap. User steps: (1) after another module speaks, let a clock interval
fire or enable Clock Sound so its request waits; (2) before the gap finishes, change Announce interval; (3) optionally
select another interval again. Expected: replacing the schedule retires announcements from the superseded schedule, with
at most the latest immediate announcement and then the newly selected interval. Actual: each pending request survives
the restart and produces another announcement roughly ten seconds apart, even if the latest selected interval is 30 or
60 minutes. The interval callback invokes `startClock()` (lib/main.dart:3859-3865); startClock calls stopClock and
requests immediate speech (2816-2821), but stopClock cancels only clockTimer and its deadline (2848-2853). Requests
already chained into `_announcementTail` remain live because `_speechGeneration` is unchanged and their only feature
guard is `clockOn && clockSpeakTime` (2775-2794, 2882). `speechQueue.removeWhere` in onFire cannot remove a request
still waiting outside speechQueue (2885). Repair direction: introduce clock-schedule-specific validity/versioning that
stop/restart advances, and check it in the delayed request before enqueueing; preserve unrelated modules' requests.

## Stopwatch and lap journeys

### U16 — [MEDIUM] Fullscreen stopwatch Reset retains old lap history and numbering

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3097-3106`  
**Review origin:** StopwatchUsage #1; corroborated by FocusDriveUsage #2

NEW; medium; source-traced. Preconditions: the current stopwatch session has at least one recorded lap. User journey:
Stopwatch → Start → Lap → tap the elapsed display to enter fullscreen → Reset → close fullscreen → Start → Lap.
Expected: Reset starts a new stopwatch session with no previous laps and the first subsequent lap numbered 1. Actual:
elapsed time becomes zero, but all old lap rows and the old count remain; the next lap continues numbering and mixes the
old run's elapsed values with the new run. The actual fullscreen Reset control dispatches `widget.onStopwatchReset`
(lib/widgets/fullscreen_focus_view.dart:424-493), wired directly as `onStopwatchReset: resetStopwatch`
(lib/main.dart:1676-1678). `resetStopwatch()` clears elapsed/runtime/announcement state but never `_lapCount` or
`_lapTimes` (lib/main.dart:3097-3113); only the ordinary tab's wrapper executes `_lapCount = 0; _lapTimes = [];`
(lib/main.dart:4098-4103). Lap insertion remains `_lapTimes.insert(0, 'Lap $_lapCount  $stopwatchElapsedValue')`
(lib/main.dart:4071-4075). Repair: make lap clearing part of the shared reset transition and pass that same handler on
every reset surface. Relation to prior audit: new, separate from #20 parsing and #21 list truncation.

### U17 — [MEDIUM] Restored stopwatch elapsed time survives but its laps disappear

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:4068-4075`  
**Review origin:** StopwatchUsage #2

NEW; medium; source-traced. Preconditions: a running or paused stopwatch session has recorded laps, its runtime writes
have completed, and the process is later recreated without using the explicit Exit action. User journey: Stopwatch →
Start → record two laps → optionally Pause → background the app → reopen after process recreation. Expected: the
restored session retains its elapsed time and associated lap history/count. Actual: elapsed time and running/paused
state are restored, but every lap is lost and numbering begins again at 1 if the user resumes and records another lap.
`_lapCount = 0` and `_lapTimes = []` are only parent-State fields (lib/main.dart:4068-4075); recording a lap does not
save anything. `StopwatchRuntime.toJson()` contains only `'isRunning'`, `'accumulatedMs'`, `'startedAtEpochMs'`, and
`'revision'` (lib/models/timer_runtime.dart:174-179), and TimerRuntimeStore saves exactly that JSON
(lib/services/timer_runtime_store.dart:71-86). Bootstrap calls `_restoreStopwatchRuntime()` (lib/main.dart:1915-1916),
whose `_applyStopwatchRuntime()` restores elapsed/running state only (lib/main.dart:3040-3063), leaving new-State lap
defaults untouched. Switching tabs or backgrounding without destroying the State does retain the laps, making the same
continuing session inconsistent across process recreation. Repair: persist typed lap records and count/session identity
atomically with the stopwatch runtime, restore them with that runtime, and clear both on Reset/Exit. Relation to prior
audit: new persistence loss, not the existing oldest-20 display issue.

### U18 — [MEDIUM] Drive Speak now is silent for a paused stopwatch or automatic Speech Off

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3006-3013`  
**Review origin:** StopwatchUsage #3; corroborated by FocusDriveUsage #1

NEW; medium; source-traced. Preconditions: Linux Drive Mode is reachable from the visible Desktop controls menu, master
Audio is on, and night mute is not active. User journey: select Stopwatch → Desktop controls → Drive Mode —
compact/fullscreen → Start Stopwatch → Pause Stopwatch → tap the enabled Speak now button. Expected: announce the paused
stopwatch's elapsed time without resuming it; the same explicit request should also work when automatic stopwatch Speech
is Off. Actual: no speech is enqueued. The visible button is always enabled and invokes `widget.onSpeakNow(_mode)`
(lib/widgets/drive_mode_view.dart:322-327); Drive Mode's stopwatch branch calls `speakStopwatchElapsedNow()`
(lib/main.dart:1548-1555), which reuses `_speakStopwatchMessage()` (lib/main.dart:3115-3117). That helper applies the
automatic-announcement validity guard `isStillValid: () => stopwatchInterval != null && stopwatchSpeakOn`
(lib/main.dart:3006-3013). Pause sets `stopwatchInterval = null` (lib/main.dart:3091-3092), so `_speakAfterGap` returns
before `onFire()` when it checks validity (lib/main.dart:2785-2794). This fails regardless of whether the ten-second gap
requires waiting. Repair: separate explicit elapsed speech from automatic periodic announcements; explicit requests
should honor master/night audio policy but not require the stopwatch to be running or automatic Speech to be enabled.
Relation to prior audit: new silent-control failure, distinct from #59 speech-language behavior.

### U19 — [MEDIUM] Reset → Start allows old stopwatch announcements into the new run

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3097-3106`  
**Review origin:** StopwatchUsage #4

NEW; medium; source-traced conditional sequence, not a device reproduction. Preconditions: master Audio and stopwatch
Speech are on, and a stopwatch periodic announcement is waiting behind the shared ten-second announcement gap—for
example, a clock/timer announcement fired shortly before the stopwatch reaches its selected 15-second boundary. User
journey: run the stopwatch until that elapsed announcement is queued → Reset → immediately Start the new run before the
queued announcement's gap expires. Expected: the old run's pending elapsed announcement is discarded; speech describes
only the current session. Actual: the old message, e.g. 'Elapsed 15 seconds', is emitted while the new stopwatch is only
a few seconds old. `_tickStopwatch` constructs the old text and `_speakStopwatchMessage` captures it through `onFire: ()
=> speak(text)` (lib/main.dart:3013,3031-3036). `_speakAfterGap` retains that callback across
`Future<void>.delayed(...)` and only checks global `_speechGeneration`, mute, and `isStillValid`
(lib/main.dart:2775-2794). `resetStopwatch()` neither increments a stopwatch session generation nor cancels pending
stopwatch announcements (lib/main.dart:3097-3113); after Start, the guard `stopwatchInterval != null &&
stopwatchSpeakOn` becomes true again, so an old run's message passes. Likewise, changing Speak delay while an
old-boundary announcement is queued does not invalidate it: the callback updates the delay and
`_lastStopwatchAutoAnnouncedSecond` only (lib/main.dart:4126-4133). Repair: capture a stopwatch-session/announcement
generation and reject callbacks from previous resets or announcement reconfigurations; use a dedicated generation rather
than cancelling unrelated clock/timer announcements globally. Relation to prior audit: new cross-run/cross-setting queue
inconsistency, not its architecture discussion of multiple tickers.

## Sleep mode and effective audio muting

### U20 — [MEDIUM] Quiet-hours rows retain old times after the user changes them

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#46)  
**Primary source anchor:** `lib/main.dart:1177-1182`  
**Review origin:** NightMuteUsage #1; corroborated by SettingsBackupUsage #6

Severity: medium; source-traced; extends prior audit #46 (Settings route mixes live provider values with snapshotted
props), specifically its unreported sleep-control consequence. Preconditions: Settings remains open with sleep mode
enabled. Steps: tap Starts at or Ends at, select a different time, and return to the settings page. Expected: the row
displays the selected time. Actual: persistence and the audio predicate immediately use the new minutes, but the row
continues displaying the previous time until Settings is closed and reopened. main.dart:1177-1182 computes
`sleepStartLabel`/`sleepEndLabel` when constructing the pushed route; settings_panel.dart:968,976 displays
`widget.sleepStartLabel`/`widget.sleepEndLabel`. The picker writes `sleepStartMinutes = selected.hour * 60 +
selected.minute` and `_lsSave()` at main.dart:1029-1034, with equivalent end-time code at 1049-1054, while the settings
rebuild at settings_panel.dart:535 watches the provider but never derives these labels from it. Repair: format the rows
from the live `s.sleepStartMinutes` and `s.sleepEndMinutes` rather than route-construction snapshots.

### U21 — [MEDIUM] Automatic sleep treats active in-app use as inactivity

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2693-2698`  
**Review origin:** NightMuteUsage #2

Severity: medium; source-traced; new relative to the prior audit. Preconditions: current time is inside the configured
range and master audio is on. Steps: enable sleep in Automatic mode (or switch enabled sleep from Manual to Automatic),
then keep the app foregrounded and operate tabs, stopwatch lap controls, or timer controls for more than five minutes
without an OS lifecycle transition. Expected: activity prevents automatic mute, matching help_panel.dart:248, `after 5
minutes inactivity during sleep range, mute auto-activates`. Actual: enabling/changing mode calls
`_startNightIdleTimerIfNeeded()` at main.dart:1262-1263,1277-1279; its unconditional five-minute callback sets
`autoNightMuteActive = true` and stops audio at 2693-2698 despite ongoing use. All references to the night timer show
only settings and lifecycle hooks; actual tab selection at 4298-4309, stopwatch lap handling at 4071-4076, and
timer-control wiring at 3973-3984 neither reset the timer nor clear the active flag. Conversely, a resumed foreground
app cancels its idle timer at 2724-2726 and never arms another for subsequent foreground inactivity. Repair: track
genuine interaction and last-activity time, and evaluate/rearm the automatic deadline from that state rather than
treating lifecycle changes and settings edits as the complete activity contract.

### U22 — [MEDIUM] Automatic sleep does not arm when quiet hours begin while backgrounded

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2685-2690`  
**Review origin:** NightMuteUsage #3

Severity: medium; source-traced; new relative to the prior audit. Preconditions: Automatic sleep is enabled with master
audio and a recurring clock announcement or running long timer enabled, and the Dart state remains alive. Steps: leave
the app before Starts at; remain away through the window start and for at least five more minutes. Expected: automatic
mute engages during the configured window once inactivity qualifies. Actual: the background lifecycle events call
`_startNightIdleTimerIfNeeded()`, but it returns on `!_isNightTime()` at main.dart:2687-2690 and schedules nothing for
the start boundary. No subsequent clock, timer, stopwatch, reminder, display tick, or foreground-health callback arms
the night timer; `_isAudioMuted()` returns the unchanged false `autoNightMuteActive` in Automatic mode at 2753-2765.
Recurring announcements and completion alarms consequently remain permitted throughout the sleep range unless another
qualifying lifecycle/settings event occurs. The same missing scheduling appears when editing a window from outside the
current time to include it without re-enabling/changing mode: the picker only saves and clears queued speech. Repair:
schedule the next start/deadline transition and recompute it on window changes, using tracked activity to determine when
mute becomes due.

### U23 — [MEDIUM] Enabling Manual sleep does not stop an already-playing utterance

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1255-1265`  
**Review origin:** NightMuteUsage #4

Severity: medium; source-traced; new relative to the prior audit. Preconditions: a clock announcement, motivation quote,
or voice test is already being spoken and the current time falls inside the selected quiet range. Steps: open Settings
and enable Manual sleep, switch active sleep to Manual, or change Starts at/Ends at so that the current time becomes
covered. Expected: speech is muted in the effective range, as stated at help_panel.dart:247. Actual: the relevant
handlers only execute `if (_isAudioMuted()) speechQueue.clear()` (main.dart:1265,1281,1032-1034,1052-1054). The active
item has already been removed from the queue at 2565-2566 and handed to the asynchronous playback service at 2598-2607,
so clearing the queue does not stop it; there is no mid-play predicate polling. `_cancelPendingSpeech()` at 2643-2650
provides the needed generation invalidation and `_stopTts()` call and is already used for automatic activation at 2695,
but is absent from these manual transitions. Repair: when a settings/window change transitions into effective mute,
cancel pending and active playback rather than only clearing queued items; reconcile the other gated players
consistently.

### U24 — [MEDIUM] An old automatic-mute deadline can stop audio after quiet hours end

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2693-2698`  
**Review origin:** NightMuteUsage #5

Severity: medium; source-traced; new relative to the prior audit. Preconditions: Automatic sleep and master audio are
enabled, with ambient timer/clock audio playing. Steps: background the app less than five minutes before Ends at, then
remain away until the five-minute deadline. Expected: the expired sleep window does not mute audio. Actual: the timer
was eligible when armed but its callback at main.dart:2693-2698 unconditionally sets the automatic flag, cancels speech,
pauses ambient audio, stops notification playback, and stops the mobile ringtone after the range has ended.
`_isAudioMuted()` would return false and clear the flag at 2758-2760, but the timer does not call that predicate or
recheck `_isNightTime()` before its destructive actions. Changing the range while a deadline is armed, including setting
equal endpoints, can likewise leave this obsolete deadline active because picker handlers at 1029-1054 do not
cancel/rearm it. Repair: revalidate mounted state, enabled/mode/window/activity eligibility at expiration and
invalidate/recompute pending night deadlines whenever the time range changes.

### U25 — [MEDIUM] Ambient audio stays paused after sleep mute ends

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2722-2727`  
**Review origin:** NightMuteUsage #6; corroborated by ClockUsage #5

Severity: medium; source-traced; new relative to the prior audit. Preconditions: a long timer is running with ambient
sound enabled, master audio is on, and automatic sleep has activated and paused that sound. Steps: resume the app while
the timer is still running, or leave it running through Ends at; alternatively start a timer during Manual sleep and
disable sleep while it runs. Expected: the enabled ambient sound resumes once audio is no longer muted, without
requiring another timer/sound toggle. Actual: automatic activation calls `_audioService.stopBackground()` at
main.dart:2696; AudioService.stopBackground at audio_service.dart:55-62 pauses the player and sets its internal playing
flag false. Resume clears `autoNightMuteActive` at 2724 but never calls `_applyAudioSettings()`; importantly, the resume
dispatch skips `_restoreTimerRuntime()` when the timer interval exists and its status is running at 2743-2746, so that
indirect reconciliation also does not occur. Window expiry only clears the flag inside `_isAudioMuted()` at 2758-2760,
and disabling sleep at 1258-1266 likewise performs no ambient reconciliation. Timer ticks and clock/stopwatch speech can
now proceed, but they do not restart the ambient player. Repair: centralize effective-mute transitions and call
`_applyAudioSettings()` when returning to an audible state, including resume, settings changes, and scheduled window
expiry.

## Voice, engine and volume controls

### U26 — [MEDIUM] English Rotate voices selection is discarded and keeps using one voice

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1333-1335`  
**Review origin:** AudioSpeechUsage #1

Severity: medium. Preconditions: at least two available English voices, Master Audio on, quiet-hours mute inactive. User
steps: Settings → Language list → English; Preferred voice → 'Rotate voices (Different each time)'; press Test voice
several times after each sample finishes. Expected: successive announcements select different English voices, as
settings_panel.dart:605-611 explicitly promises. Actual: the callback maps '__rotate__' to null with `if (val == null ||
val == '__auto__' || val == '__rotate__') { favoriteVoiceName = null; ... }` (main.dart:1333-1335). The consuming
dispatcher in voice_session_manager.dart:79-91 rotates Malayalam unconditionally but rotates English only under `else if
(favoriteVoiceName == '__rotate__')`; null instead returns the cached preferred voice. Thus the visible selection never
reaches the English rotation branch, while the label continues to claim rotation. Call path: Settings picker →
onFavoriteVoiceChanged → settings provider/save → _testSpeech → _resolveVoiceForNewAnnouncement →
resolveVoiceForAnnouncement → cached fallback. Confidence: source-traced, no device reproduction. Prior-audit relation:
new. Repair direction: preserve the rotation sentinel, or consistently define null as rotation for English as well as
Malayalam; keep any automatic single-voice selection distinct if it remains supported.

### U27 — [MEDIUM] Voice/language changes leave old delayed announcements alive

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#57)  
**Primary source anchor:** `lib/main.dart:1289-1292`  
**Review origin:** AudioSpeechUsage #4

Severity: medium. Preconditions: Master Audio on, English selected, clock and timer speech enabled, and a timer
announcement waiting behind the ten-second announcement gap. User steps: arrange a clock announcement shortly before a
timer minute boundary; after that boundary, open Settings and select Malayalam before the delayed timer message fires.
Expected: changing language cancels the old pending message, consistent with this callback explicitly clearing queued
speech and stopping TTS, or rebuilds its text and voice coherently in the new language. Actual: the callback calls
`speechQueue.clear(); unawaited(_stopTts());` (main.dart:1290-1292) but does not increment `_speechGeneration`. The
message lives in `_announcementTail`, not speechQueue: _speakAfterGap captures that generation and validates only
generation/mute/optional module validity before invoking onFire (2768-2795). speakTimerMessage already captured the
English text and timerVoice (2938-2952), so its closure survives the settings change; speak then derives Malayalam from
current settings while retaining that old English voice/text (2652-2662), and drainQueue passes the current cached
Malayalam decision to speakItem (2598-2609). The queued announcement therefore crosses the language switch with stale
content/configuration. Changing a pinned favorite during the same gap likewise leaves the captured old timer/clock voice
intact because onFavoriteVoiceChanged only resets the session cache (1330-1346). Confidence: source-traced after
accounting for the actual queue clear, service stop and application-generation guards. Prior-audit relation: extends
prior audit §57, supplying the surviving-tail mechanism and reachable timer journey rather than assuming the queue clear
is ineffective for every kind of work. Repair direction: invalidate the application announcement generation when
language/voice configuration changes and cancel any already-dequeued delayed item, or resolve text, language and voice
atomically at execution time.

### U28 — [MEDIUM] Timer Speech Off does not suppress a pending timer announcement

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2946-2952`  
**Review origin:** AudioSpeechUsage #5

Severity: medium. Preconditions: Master Audio on, a running timer with Speech on, and a timer announcement scheduled
during the ten-second gap after another module's announcement. User steps: allow a clock announcement; let the timer
cross an enabled minute-announcement boundary within ten seconds; turn the Timer panel's Speech toggle off before the
timer message fires. Expected: no new timer speech begins after that module has been muted, while other modules remain
unaffected. Actual: TimerPanel exposes this action at timer_panel.dart:349-353, but onTimerSpeakOnChanged only saves
`timerSpeakOn = val ?? true` (main.dart:4007-4012); it neither cancels this pending operation nor invalidates its
generation. The original tick guarded scheduling with timerSpeakOn (3215-3224), but speakTimerMessage supplies no
isStillValid callback: its delayed onFire is simply `() => speak(text, voice: timerVoice)` (2946-2952). _speakAfterGap
therefore permits it through (2786-2795), and speak/drainQueue check global mute, not timerSpeakOn (2652-2662,
2554-2572), so the old message starts after the switch visibly reads off. In contrast, clock and stopwatch scheduling
already provide module-validity checks (2882, 3012), showing this is a missing execution guard rather than a requirement
to mute every module globally. Confidence: source-traced, no runtime reproduction. Prior-audit relation: new. Repair
direction: carry timer-module permission to execution and cancel only timer-originated pending work; if finish
announcements need validity beyond a running timer, retain that distinction rather than using timerInterval alone as the
guard.

### U29 — [MEDIUM] System TTS only / Sherpa only can be bypassed by Malayalam asset clips

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/speech_service.dart:1273-1278`  
**Review origin:** AudioSpeechUsage #6

Severity: medium. Preconditions: Malayalam selected, Master Audio on, and bundled test clip playback succeeds. User
steps: Settings → Speech engine → System TTS only; press Test voice; optionally repeat with Sherpa-ONNX only. Expected:
the sample exercises the selected engine, as the visible labels 'System TTS only' and 'Sherpa-ONNX only' promise
(settings_panel.dart:537-546); the desktop model card also explicitly says 'System-only mode bypasses offline models'
(346-348). Actual: _testSpeech emits a Malayalam test phrase (main.dart:2383-2391), resolveAudioClips maps it to the
bundled per-voice test.mp3 (malayalam_tts_service.dart:368-375), and speakItem dispatches that asset before examining
either strict mode: `if (useMalayalamNuance) { ... _playAssetClips(...) ... return; }` (speech_service.dart:1273-1285).
Therefore neither selected backend is used for the test; supported Malayalam clock/timer phrases likewise bypass strict
selection. This is not a complaint about intentionally shared quote recordings or the deliberate silent behavior of an
unavailable strict Sherpa backend: it is a reachable engine-selection branch bypass. Confidence: source-traced; the
per-voice test assets exist, but playback was not executed. Prior-audit relation: new. Repair direction: honor strict
engine modes in the dispatch ordering before considering the prerecorded-asset backend, keeping asset-first behavior
only for a mode that actually permits it.

### U30 — [MEDIUM] Linux system-fallback speech ignores the speech-volume and boost controls

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/speech_service.dart:1311-1315`  
**Review origin:** AudioSpeechUsage #7

Severity: medium. Preconditions: Linux, English selected, System TTS only, and a fallback backend successfully producing
speech. User steps: set Speech volume to Very Low and press Test voice; set it to Very High and test again; toggle Boost
TTS Volume and repeat. Expected: those supported controls change the sample/announcement volume. Actual: speakItem
calculates `ttsVolume` from both controls (speech_service.dart:1269-1272), but its Linux fallback call passes only text
and useMalayalamNuance (1311-1315). _speakOnLinuxFallback takes no volume parameter and builds `espeak-ng -v <voice>
<text>` or `spd-say -w [-l <voice>] <text>` with no amplitude/volume option (844-854). The controls are saved and
reflected by the settings provider, yet their values cannot reach this backend at all, so this entire supported engine
path uses backend-default volume regardless of the selected speech level or boost. Ambient volume is separately handled
by AudioService and cannot correct it. Confidence: source-traced conditional on fallback playback, not an
auditory/device comparison. Prior-audit relation: new. Repair direction: pass the effective speech volume through the
fallback interface and map it to each backend's supported volume/amplitude control, or play synthesized output through
the already volume-aware player.

### U31 — [MEDIUM] Speech-only boost leaves shared Android media volume at maximum after speech

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/speech_service.dart:1358-1359`  
**Review origin:** AudioSpeechUsage #8

Severity: medium. Preconditions: Android with device media volume below maximum, background noise playing, and English
system TTS available. User steps: Settings → enable Boost TTS Volume; press Test voice; wait for the sample to finish;
disable the boost. Expected: the control's subtitle, 'Maximum volume for speech announcements only'
(settings_panel.dart:698-703), leaves background audio and subsequent unboosted media at their prior device volume.
Actual: speakItem calls `_setMediaVolumeToMax()` before speaking (speech_service.dart:1358-1359). The consuming native
channel handles this with `audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, max, 0)` (MainActivity.kt:76-78),
which modifies the shared Android media stream, including ambient audio. No caller reads the previous media-volume ratio
or invokes the available setMediaVolumeRatio handler; the only production volume-channel invocation is
setMediaVolumeToMax. Neither speech completion nor onMaximumSpeechVolumeChanged restores it, so background audio is
boosted too and the device remains at maximum even after disabling this setting. Confidence: source-traced; exact
perceived loudness depends on device audio routing and was not exercised. Prior-audit relation: new. Repair direction:
constrain the gain to the speech player where possible; if temporary stream maximization is retained, capture and
restore the prior level in a completion/cancellation/error-safe scope without overwriting volume changes the user makes
during speech.

**Parent qualification:** The source proves an un-restored shared-stream change, not that every device has identical perceived loudness. Respect user changes made during playback when designing any restoration.

## Settings backup/restore actions

### U32 — [MEDIUM] Restored enabled clock settings do not start or reschedule the clock

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1487-1495`  
**Review origin:** SettingsBackupUsage #1

Preconditions: a valid backup contains clockOn=true and clockSpeakTime=true, while the current clock is stopped with
_nextClockAt=null. Journey: open Settings → Restore settings → select that backup → confirm Restore → return to Clock
and wait for the imported interval. Expected: the restored enabled clock starts its announcement schedule; actual: the
provider and controls show enabled settings but no periodic announcement is scheduled until a separate start-triggering
action or application restart. Exact path: settings_panel.dart:1002-1021 dispatches onRestoreSettings →
main.dart:1443-1477 → _applyRestoredSettings:1487-1495, which calls replace, language/session reset, audio, goal
reminder, save and foreground reconciliation but never startClock or _scheduleNextClockAnnouncement. Only startClock
assigns the new deadline (`_nextClockAt = DateTime.now().add(Duration(minutes: clockIntervalMins));`,
main.dart:2816-2822); the resume scheduler cannot repair a missing deadline (`if (due == null || !clockOn) return;`,
2825-2828). Restoring a shorter interval while the clock is already active also leaves its old next deadline in place,
unlike the normal interval control that calls startClock (3860-3865). Repair: compare previous/restored clock settings
and explicitly start, stop, or reschedule the clock as appropriate; do not claim a reload without performing one.
Confidence: source-traced. Prior audit relation: new; prior_audit_reference: null.

### U33 — [MEDIUM] Restoring Master Audio Off allows in-flight speech to finish

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1487-1495`  
**Review origin:** SettingsBackupUsage #2

Preconditions: a valid backup has speechMasterOn=false, and a speech item is still playing when restore is confirmed.
Journey: with timer/clock speech active, open Settings → Restore settings → pick the muted backup → confirm. Expected:
Master Audio becomes off and currently playing speech stops, as it does when using the visible Master Audio switch;
actual: the setting becomes false and ambient audio stops, but the current speech playback is allowed to finish.
_applyRestoredSettings (main.dart:1487-1495) replaces settings and calls only _applyAudioSettings for audio; its muted
branch is `unawaited(_audioService.stopBackground()); ... return;` (2289-2295), not a speech stop. The speech player is
separately owned by SpeechService/FlutterTts (drainQueue, 2598-2608), and subsequent mute guards prevent future queue
processing rather than interrupting the already awaited speakItem. Contrast the normal switch path `_setSpeechMaster`:
`_cancelPendingSpeech(); await _stopTts();` (1800-1811), which invalidates speech generation, clears queued work and
stops playback. Repair: make restoration an awaited settings transition that invokes the same cancellation/stop effects
when Master Audio changes to off (and when restored language invalidates existing speech). Confidence: source-traced
conditional on speech remaining active at confirmation, not a device reproduction. Prior audit relation: new;
prior_audit_reference: null.

### U34 — [MEDIUM] Restored Android engine selection is displayed but not rebound

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1487-1495`  
**Review origin:** SettingsBackupUsage #3

Preconditions: Android has installed engines A and B, the live FlutterTts instance is initialized using A, and a valid
backup selects B with English speech. Journey: open Settings → restore the B backup and confirm → tap Test voice.
Expected: the displayed restored engine B handles the sample; actual: the setting displays B while the initialized
instance continues speaking through A until a later explicit engine selection or restart. Restore only calls
`ref.read(settingsProvider.notifier).replace(normalized);` and resets language/session (main.dart:1487-1495); it never
executes the normal engine control's setSpeechEngine/_initTts(forceRebind:true) sequence (1313-1328). Test voice
(2383-2391) → speak → drainQueue → _ensureTtsReady, whose `if (_ttsReady && !forceRebind) return true;` (2502-2504)
bypasses engine initialization. Consuming-side SpeechService.speakItem (1260-1373) uses the mode for auto/system/sherpa
routing but does not call setEngine for an Android package ID; that operation resides in setSpeechEngine (1387-1402).
Repair: await a forced TTS rebind when restore changes speechEngineMode, refresh the available voices and cancel
obsolete speech before declaring restoration complete. Confidence: source-traced. Prior audit relation: new;
prior_audit_reference: null.

### U35 — [MEDIUM] Two backups in the same minute silently overwrite the first file

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/settings_service.dart:247-250`  
**Review origin:** SettingsBackupUsage #4

Preconditions: the same writable destination folder is selected for two backups within one calendar minute. Journey:
Settings → Backup settings → choose folder → Done → change a preference → Backup settings → choose the same folder
before the minute changes. Expected: both revisions remain available, or an overwrite is explicitly confirmed; actual:
the second operation silently truncates and replaces the first backup and shows Backup Saved again. SettingsService
constructs time with only hours and minutes (`'${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2,
'0')}'`, settings_service.dart:247-248), reuses `SolasFlow_Settings_${date}_$time.json` (249), and calls `await
file.writeAsString(contents, flush: true);` (250) without an existence check or overwrite confirmation. This can destroy
the very pre-change backup the user intended to preserve before editing. Repair: choose a collision-resistant filename
and avoid overwriting an existing file without consent, including for repeated/concurrent requests. Confidence:
source-traced. Prior audit relation: new; prior_audit_reference: null.

### U36 — [MEDIUM] Backup/import failure is silently treated as user cancellation

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/settings_service.dart:252-254`  
**Review origin:** SettingsBackupUsage #5

Preconditions: the user chooses an invalid JSON file (malformed JSON or a non-object such as []), an unreadable backup,
or a destination where writing fails. Journey: open Settings → Restore settings → select the invalid file, or Backup
settings → select the failing destination. Expected: an actionable failure message, with cancellation remaining silent;
actual: both handlers silently return exactly as if the user cancelled, so no Restore failed/Backup failed feedback
appears and a failed folder export offers no Copy JSON fallback. `importFromJson` returns null on parse/non-object
failure (settings_service.dart:226-234), importFromFile returns null on read failure (258-270), and exportToUserFolder
catches all export exceptions and returns null (252-254). Main's consumers interpret null as cancellation (`if (filePath
== null) return;`, main.dart:1381; `if (imported == null) return;`, 1447), so their outer catch/snackbar paths cannot
receive these failures. Copy JSON is only constructed after a successful file path (1383-1426), not as a fallback from
failed file saving. Repair: reserve null for actual selector cancellation and propagate validation/I/O failures to the
UI; retain the serialized document and expose an explicit clipboard alternative when folder saving fails. Confidence:
source-traced for invalid JSON; I/O triggering conditions are conditional failure risks, not injected failures. Prior
audit relation: new; prior_audit_reference: null.

**Parent qualification:** Malformed JSON and non-object input have deterministic null-return paths. Filesystem-failure consequences are conditional; no I/O fault was injected.

### U37 — [MEDIUM] Export all settings omits the selected local desktop model

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/settings_service.dart:220-223`  
**Review origin:** SettingsBackupUsage #7

Preconditions: Linux offline speech is enabled and a trusted local model folder is available for import. Journey: with
built-in English selected, use Backup settings → import a custom English model through Local offline model → restore the
earlier backup and confirm → tap Test English. Expected under the visible promises 'Export all settings as JSON'
(settings_panel.dart:990-996) and 'replace all current settings' (main.dart:1455-1457): the earlier built-in model
selection is restored; actual: the newly imported custom model remains selected and handles the sample, even on the same
installation where all its files remain available. Import persists this supported user preference separately as
`desktop_tts_model_$language` (desktop_tts_controller.dart:231-235) and assigns `_selected[language] = imported`
(238-239). SettingsService exports only AppSettings.toJson (220-223), whose complete field list
(app_settings.dart:317-363) contains no model selection, and restore only replaces AppSettings (main.dart:1487-1495).
The consuming speech dispatch explicitly prefers the unchanged imported model: `final imported =
_desktopOffline.selected(language); if (imported != null) return imported;` (speech_service.dart:259-261). This finding
does not request shipping model binaries in JSON: the same-machine built-in/custom selection already fails to
round-trip. Repair: back up and reconcile the model selection as an explicit settings value with availability
validation, or explicitly scope the backup/restore UI to exclude local model selections rather than promising all
settings. Confidence: source-traced. Prior audit relation: new; prior_audit_reference: null.

**Parent qualification:** This is a same-installation selection round-trip defect against the visible all-settings promise. It does not demand embedding model binaries into JSON.

## Fullscreen, native navigation and shortcuts

### U38 — [MEDIUM] Closing a timer alert also closes unrelated Clock/Stopwatch focus

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3365-3370`  
**Review origin:** FocusDriveUsage #3

New finding; medium severity; source-traced. Preconditions: a countdown is running independently of the selected focus
module. Journey: start a timer, switch to Clock or Stopwatch, enter that module's focus by tapping its display (these
callbacks explicitly pass clock/moduleC at lib/main.dart:3835-3843 and 4085-4093), wait for the timer to finish, then
press 'Close timer' or the completion dialog's close icon/Back. Expected: dismiss the finished timer and return to the
clock/stopwatch focus that was interrupted; actual: both the completion dialog and the unrelated focus route close,
returning to the normal tab and running focus cleanup. `_completeTimerRun` opens the completion dialog
(lib/main.dart:3330-3331); `_showTimerFinishedDialog` chooses its variant using only `_fullscreenFocusOpen`, and after
the null result calls `if (_fullscreenFocusOpen) { await rootNavigator.maybePop(); }` (3354-3370), without checking
which module owns that focus. The fullscreen dialog's 'Close timer' returns null (3669-3673). Track the active focus
module/route and restrict timer-specific focus exit to timer focus; closing an alert over clock/stopwatch focus should
only dismiss that timer alert. No corresponding journey is covered in the prior audit.

### U39 — [MEDIUM] Widget mode requests are acknowledged but the existing focus shows the wrong module

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1610-1618`  
**Review origin:** FocusDriveUsage #4; corroborated by AndroidExternalUsage observation #2

New finding; medium severity; source-traced with the explicit precondition that the Android activity/process remains
alive. Journey: enter Timer or Stopwatch focus, press Home without closing it, then tap the actual 'Focus Mode' button
on the Live Realtime Clock home-screen widget. Expected: the supported native clock-focus action presents clock focus;
actual: the existing timer/stopwatch focus remains visible, with that module's controls, while only the hidden root tab
changes to Clock. The visible native producer binds `btn_fullscreen_clock` to `open_fullscreen_clock_direct`
(android/app/src/main/kotlin/com/atherpulse/solasflow/LiveClockWidget.kt:55-57); singleTop/new-intent handling queues
the action and invokes `widgetActionsAvailable` (AndroidManifest.xml:37; MainActivity.kt:95-105). Dart drains and
acknowledges it (lib/main.dart:2120-2132), dispatches the explicit `specificMode: FullscreenFocusMode.clock` request
(2219-2227), but `_openFullscreenFocus` immediately returns at `if (_fullscreenFocusOpen) return;` (1617), discarding
that requested mode. The existing view assigns `_mode = widget.initialMode` only in initState
(lib/widgets/fullscreen_focus_view.dart:105-108), so no consumer updates the visible mode. Keep the no-duplicate-route
guard, but update/replace the existing focus presentation for an explicit different-mode request before acknowledging
the action. This is a new wrong-mode journey, not the prior audit #33 orientation/default ownership issue.

**Parent qualification:** The inverse journey also fails: Clock focus → Home → timer preset starts the timer behind the unchanged Clock focus because _startPresetFromWidget skips focus navigation while a focus route is open.

### U40 — [MEDIUM] Launcher Start 25m does not replace a running timer

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1063-1085,3695-3729`  
**Review origin:** AndroidExternalUsage #1

NEW, medium, launcher Start 25m while a different timer is running: quick_actions_android's QuickActions.java:168-179
creates ACTION_RUN with the shortcut extra and QuickActionsPlugin.java:89-113 forwards it to `_initQuickActions` at
main.dart:1107-1109, but `_handleQuickAction` at 1066-1073 only assigns `seconds = 25 * 60` and calls `startTimer`,
whose `if (timerInterval != null) return` at 3696 leaves the old `_timerRuntime`, deadline, and prefs intact, and the
next tick at 3197-3216 restores the old countdown instead of starting the advertised 25 minutes; paused Start 25m can
also retain the former larger duration because main.dart:3709-3713 preserves `_activeTimerDurationSeconds` for paused
runtimes, making a subsequently completed 25-minute countdown repeat the former duration through notification Repeat at
250-258; repair by using the explicit timer-replacement transition already used by presets, synchronizing duration,
remaining, deadline, chain state, and persistence rather than overwriting display fields then calling a guarded resume
routine.

**Parent qualification:** The Android reviewer reported baseline observations outside its patch-oriented findings array. The parent verified the actual handlers/native queue rather than treating its overall_correctness field as an app verdict.

### U41 — [MEDIUM] Cold-start queued widget taps bypass the real three-second confirmation window

**Evidence level:** Interleaving risk [INFERENCE], with source-traced consequences  
**Relation to first audit:** new  
**Primary source anchor:** `android/app/src/main/kotlin/com/atherpulse/solasflow/MainActivity.kt:108-130; lib/main.dart:1728-1734,2146-2179`  
**Review origin:** AndroidExternalUsage #4

NEW, medium, delayed cold-start confirmation: with bootstrap held behind the first-run permission request at
main.dart:1930 and 868-883, capture two Audio widget taps more than three seconds apart before completing
initialization; MainActivity.kt:111-117 stores only ID/action, not an arrival time, and `_handleWidgetAction` at
main.dart:2146-2179 starts its three-second Timer while draining, so the two old queued taps are processed consecutively
and confirm an audio toggle despite their real separation exceeding the confirmation window; repair by preserving native
arrival time and enforcing expiry against that time instead of queue-processing time, while retaining the serialized
acknowledgement protocol.

**Parent qualification:** The Android reviewer reported baseline observations outside its patch-oriented findings array. The parent verified the actual handlers/native queue rather than treating its overall_correctness field as an app verdict.

## Tagging and history visibility

### U42 — [MEDIUM] Enabling Tagging mid-run records none of the enabled portion

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:4045-4051`  
**Review origin:** HistoryTaggingUsage #1

NEW; medium; source-traced. Preconditions: tagging is off and a timer is running. Journey: tap a 5-minute preset, let it
run for 1 minute, enable Tagging, leave it enabled until completion, then open Time Utilization. Expected: enabling
recording should record at least the remaining enabled portion of the running timer. Actual: no session is written at
all. The visible Tagging control is wired at lib/widgets/timer_panel.dart:383-388; its handler here only sets `taggingOn
= val` and runs `if (val) _refreshTodaySummary()`. The start marker is created exclusively at timer start (`if
(taggingOn) _sessionStartTime ??= DateTime.now();`, lib/main.dart:3729, or widget-start line 2061), and the completion
consumer requires `taggingOn && _sessionStartTime != null` at lib/main.dart:3303-3305. Because enabling tagging never
arms the marker, neither completion nor Pause logs the enabled portion. Repair: make the off-to-on transition initialize
an active recording segment and its remaining-time baseline when a timer is already running; compute that segment's
elapsed duration rather than subsequently crediting the whole configured timer.

### U43 — [MEDIUM] Reset with Tagging Off leaves stale session provenance for the next run

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:3761-3770`  
**Review origin:** HistoryTaggingUsage #2

NEW; medium; source-traced. Preconditions: retain the same app state across the journey. Steps: at 23:50 enable Tagging
and start a 5-minute timer; at 23:51 disable Tagging and press Reset; after midnight at 00:10 re-enable Tagging and
start a 1-minute preset; complete it and inspect the dashboard. Expected: the new timer's record begins at 00:10 and
belongs entirely to the new day, regardless of the policy for discarding the earlier disabled session. Actual: the new
60-second record retains the old 23:50 start and is prorated across both dates, approximately 29 seconds yesterday and
31 seconds today. `resetTimer()` calls `stopTimer()`, whose logging/marker clearing is skipped when `taggingOn` is false
(lib/main.dart:3736-3742); reset clears runtime/duration but never `_sessionStartTime` (lines 3761-3777). The next start
uses `_sessionStartTime ??= DateTime.now()` (3729), so `_logCurrentSession` persists the stale start (1994-2001). The
consuming daily aggregation explicitly prorates with `return (durationSeconds * overlapMs / wallMs).round();`
(lib/models/session_log.dart:43-52). The same leak occurs when changing presets after disabling tagging. Repair: close
or discard the current recording segment explicitly on disable/reset/preset replacement, and always create fresh
provenance for a genuinely new run.

### U44 — [MEDIUM] Dashboard stays stale when a timer logs while the route remains open

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/widgets/dashboard_screen.dart:21-31`  
**Review origin:** HistoryTaggingUsage #5

EXTENDS prior audit #26 with a successful-storage journey rather than a speculative load failure; medium; source-traced.
Preconditions: tagging enabled, no earlier history required. Steps: start a 1-minute timer, immediately open Time
Utilization and allow its initial load to finish; remain there until the timer finishes; choose Close timer in the
completion dialog. Expected: the underlying dashboard displays the newly recorded minute. Actual: it remains on `No
sessions logged yet` (or the old totals when history exists) until the user leaves and reopens the dashboard. Opening
the route does not pause the main timer (lib/main.dart:4060-4063); completion logs through `_logCurrentSession`
(3303-3305), but that refresh updates only main-screen `_todaySummary` (1993-2022). This dashboard's `_load()` is called
solely in `initState()` (21-25), and `_summaries` is otherwise never reloaded/subscribed. Closing the finish dialog
dismisses the timer without replacing the dashboard route (3354-3374), so there is no new initialization. Repair:
refresh from session-log changes or route visibility after the completion dialog, rather than requiring navigation away
from the dashboard to expose a successfully saved session.

**Parent qualification:** This is a successful-storage refresh failure, distinct from the prior audit #26 load-error spinner. It is classified new, not a reconfirmation of that failure.

### U45 — [MEDIUM] Timer today summary keeps yesterday totals after midnight

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:2012-2021`  
**Review origin:** HistoryTaggingUsage #6

NEW; medium; source-traced. Preconditions: tagging enabled and at least one logged session on the current date. Journey:
complete a 5-minute study timer before midnight, close the finished dialog, keep the app open through midnight without
another log or Tagging toggle, then inspect the Timer tab's Time Utilization preview and open the dashboard. Expected:
the preview represents the new day's totals, consistent with the freshly opened dashboard. Actual: the timer preview
continues to show the previous day's `Study 5m`, while the dashboard correctly groups that record under Yesterday.
`_refreshTodaySummary` queries `getDailySummary(DateTime.now())` once and caches only the rendered text
(lib/main.dart:2007-2022); its only call sites are bootstrap (1914), logging (2003), and enabling Tagging (4051). The
display ticker continues rebuilding clock/timer text (1859-1881), but never invalidates this date-scoped cache, and
resume handling likewise does not refresh it (2738-2750). Repair: retain the date associated with the cached summary and
refresh when the local calendar date changes, including on resume; rebuilding the widget alone does not recompute the
query.

## Desktop speech and model recovery

### U46 — [MEDIUM] Master mute/Exit cannot cancel the active Linux fallback speech subprocess

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/speech_service.dart:717-719`  
**Review origin:** DesktopRecoveryUsage #1; corroborated by AudioSpeechUsage #2

New relative to APP_AUDIT_2026-10-11.md; source-traced missing cancellation, with continued audible playback after
process exit a platform-dependent [INFERENCE]. Preconditions: Linux, an available external speech backend such as
espeak-ng, and Speech engine set to System TTS only. Steps: start a speech sample or announcement, then press Exit or
close the window with Keep running when closed disabled while that backend is running. Expected: the exit cleanup stops
ongoing speech before quitting; actual: `_runExternal` assigns only `process = child`, never `_externalSpeechProcess =
child`, so `stopDesktopSpeech()` executes `_externalSpeechProcess?.kill()` against a field that remains null. The
generation check at speech_service.dart:719 only catches cancellation during Process.start; cancellation after startup
cannot terminate the running subprocess. The reachable path is Settings engine/test callbacks → main.dart:2383-2391 →
drainQueue:2600-2609 → speakItem:1320-1324 → _speakOnLinuxFallback:843-859 → _runExternal:713-743; Exit/window-close
cleanup reaches _stopTts and disposeDesktopSpeech through main.dart:1688-1718 and desktop_service.dart:71-75. Retain the
spawned Process in the cancellation-owned field immediately after startup, preserve the existing generation check, and
clear that same process in finally.

**Parent qualification:** The subprocess reference is never populated, which is source-traced. Continued audible speech after app process exit is platform-dependent [INFERENCE]; no backend was launched.

### U47 — [MEDIUM] Cancel at completed-download verification can still install Kokoro

**Evidence level:** Interleaving risk [INFERENCE], with source-traced consequences  
**Relation to first audit:** new  
**Primary source anchor:** `lib/services/speech_service.dart:509-511`  
**Review origin:** DesktopRecoveryUsage #2

New relative to APP_AUDIT_2026-10-11.md; [INFERENCE] for the triggering interleaving, with the resulting state
transition established by source. Preconditions: an accepted Kokoro download whose response body has finished but whose
sink-close, size-check, SHA-256 process, or final rename is still pending. Steps: remain in Settings and press the
still-visible Cancel button at 100% progress. Expected: cancellation prevents installation and ends in cancelled status;
actual: `cancelKokoroVoiceDownload` sets `_kokoroCancelRequested = true` and closes the HttpClient, but the completed
response is no longer doing network work, and neither `_downloadToFile` nor the successful installer path checks that
flag again. The phase remains downloading throughout `_downloadToFile`'s hash verification
(speech_service.dart:174-190), making Cancel available under settings_panel.dart:412-432; after that future resolves,
execution unconditionally changes to verifying, installs the model, and publishes ready at speech_service.dart:556-629.
The cancellation flag is interpreted only in the catch branch at 631-637, which does not run when those local operations
succeed. Check cancellation before publishing/returning the downloaded archive and before crossing into installation, or
move to a non-cancellable verification phase before the network stream has fully completed; do not leave an enabled
cancellation action that cannot affect the operation.

### U48 — [MEDIUM] Kokoro becomes Ready but its voices stay unavailable until Settings reopens

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (#46)  
**Primary source anchor:** `lib/main.dart:1200-1200`  
**Review origin:** DesktopRecoveryUsage #3

Extends prior audit §46 with a precise supported download-to-selection journey; source-traced. Preconditions: Kokoro is
not installed when Settings opens. Steps: open Settings, download or retry Kokoro, wait for its live card to say Ready,
select English in Language list, and open Preferred voice without leaving Settings. Expected: the four newly installed
Kokoro choices are available immediately; actual: the picker continues to offer only the old English voices until
Settings is closed and reopened. `_openSettings` captures `final settingsVoices = voices` at main.dart:1141 and passes
that captured list here, while download completion replaces the main screen's `voices` with a new list at
main.dart:1846-1855. The download card watches a ValueListenable (settings_panel.dart:733-737), but the language
filtering and Preferred voice options are built from `widget.voices` (settings_panel.dart:552-602 and 776-787), so even
a provider-driven rebuild after changing language still reads the pre-download list. The engine runtime/detail props at
main.dart:1187-1188 similarly remain stale after testing the new backend. Expose the current voice list and runtime
status through a provider/notifier observed by the Settings route rather than capturing them at route creation.

## Ordinary navigation and Help instructions

### U49 — [MEDIUM] Landscape removes the only ordinary tab navigation on mobile

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/main.dart:1833-1837; lib/main.dart:4292-4332; lib/main.dart:4220-4224; lib/main.dart:4240-4268`  
**Review origin:** Parent

Preconditions: Android/iOS main screen in landscape, outside fullscreen focus; no desktop-only Drive menu.

User steps:
1. Open the Timer tab.
2. Rotate the ordinary app screen to landscape.
3. Try to switch to Clock or Stopwatch without rotating the device back.

Expected: Clock, Timer and Stopwatch remain reachable from ordinary navigation in either orientation.

Actual: The root removes BottomNavBar in landscape and supplies no replacement tab chooser, navigation rail, drawer or
horizontal paging.

Code path: initState allows unrestricted orientations. OrientationBuilder sets bottomNavigationBar to null except in
portrait. The menu button opens Settings; Drive mode entries are gated to Linux. The ordinary tab callback resides only
in the removed navigation bar.

Repair direction: Keep a compact tab chooser in landscape or provide an equivalent mobile navigation rail/menu.

### U50 — [MEDIUM] Help sends users to an Accessibility Service that does not exist

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/widgets/help_panel.dart:262-269; android/app/src/main/AndroidManifest.xml:24-32,57-94; lib/main.dart:1347-1350`  
**Review origin:** Parent

Preconditions: User tries to recover background operation after reboot using built-in Help.

User steps:
1. Open Settings → Help / Working.
2. Read Tips after reboot.
3. Try to enable the app Accessibility Service as instructed.

Expected: Recovery instructions identify a real app/system control relevant to the shipped background implementation.

Actual: Help instructs enabling Accessibility Service for auto-restart, but no app AccessibilityService, binding
permission, settings action or feature is declared or implemented.

Code path: Settings opens the live Help route. Help text explicitly promises an Accessibility Service; the manifest
declares a foreground service and widgets instead, and exact-symbol search across lib and Android source found no such
integration.

Repair direction: Replace the instruction with the actual notification/battery/background-recovery steps; do not add an
unrelated Accessibility Service.

### U51 — [LOW] Help advertises a timer slider absent from Timer Setup

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** extends (APP_AUDIT_2026-10-11.md #89 (dead required panel parameters))  
**Primary source anchor:** `lib/widgets/help_panel.dart:232-239; lib/widgets/timer_panel.dart:312-343,603-644; lib/main.dart:3979-3983`  
**Review origin:** Parent

Preconditions: User follows Timer Setup FAQ to set a duration.

User steps:
1. Open Settings → Help.
2. Read “Set minutes with slider or quick presets”.
3. Return to Timer and look for the duration slider.

Expected: The advertised slider is present, or instructions describe the supported custom-minute dialog.

Actual: Timer Setup builds presets plus a Custom dialog; the duration-slider callback is supplied but never read by
TimerPanel, so the advertised input does not exist.

Code path: Help promises a duration slider. TimerPanel instead constructs PresetGrid and a validated Custom dialog. The
unused onSliderChanged prop is not a reachable duration editor.

Repair direction: Describe preset taps and Custom → Minutes in Help; do not invent another duration input unless
requested.

### U52 — [LOW] Invalid Custom timer input makes Set silently do nothing

**Evidence level:** Source-traced; platform/preconditions as specified below  
**Relation to first audit:** new  
**Primary source anchor:** `lib/widgets/timer_panel.dart:614-637; lib/main.dart:3402-3411`  
**Review origin:** Parent

Preconditions: Timer tab → Custom minute dialog.

User steps:
1. Open Custom.
2. Enter 0, 721, empty text or non-integer input.
3. Press Set.

Expected: An inline validation message explains the supported 1–720-minute integer range and why no timer was set.

Actual: The callback only pops for a valid integer; invalid input has no else branch, error message or visible state
update, leaving an apparently unresponsive Set button.

Code path: The main Custom dialog calls int.tryParse and guards 1<=parsed<=720 without feedback. The timer-finished
custom dialog already sets an inputError for invalid input, so the same user action has inconsistent error semantics.

Repair direction: Keep the dialog open and show a validation message using the existing finished-dialog pattern.

## Earlier usage defects reconfirmed, not counted again

These remain in the first audit. The second pass checked reachable consumers or explicitly treated them as known rather than inflating the new list:

| First-audit reference | Journey / existing consequence |
|---|---|
| #01 | Select a foreign/empty JSON object as settings backup → confirm Restore: absent recognized fields become defaults. |
| #03 | Restore/adopt a timer after process loss: session start provenance is not persisted, so completion can lack a history record. |
| #04 | Pause a tagged timer then resume/complete: elapsed pause record plus full-duration completion overcounts active time. |
| #05 | Complete a chain: only the final segment duration is logged for the whole chain interval. |
| #06 / #08 | Imported out-of-slider brightness and old assets/-prefixed ambient-sound values remain inconsistently normalized. |
| #20 / #21 | Lap labels cannot be parsed as durations, and the current list projection shows the oldest 20 entries. |
| #46 | Settings voice/options/status snapshots can become stale; U20/U48 and related live-label/model-ready journeys make the consequences concrete. |
| #55 / #57 | English-mode Malayalam catalog speech and pre-gap voice/post-gap language mismatches remain source-traced. |

The first audit's concrete chain-accounting numeric example should not be reused uncritically: current `chainPresets` are Pomodoro `[25,5,25,5,25,5,25,15]` (130 minutes total, last segment 15), Sprint `[50,10,50,10]` (120 total, last 10), and Quick `[15,3,15,3,15,3]` (54 total, last 3), at `lib/main.dart:795-798`. The retained defect is final-segment-only logging; it does not mean all chain segments are study time.

## Corrections and rejected suspicions

- **Earlier reboot claim narrowed:** first-audit #50's blanket “auto-started at every device boot” consequence is too broad. The resolved `flutter_foreground_task` 9.2.1 `RebootReceiver.kt:29-45` returns when `stopWithTask` applies or the service was correctly stopped; auto-run also requires stored options and OS permission to start. The new chain-recovery finding is conditional on task continuation/restart, not an assertion that every idle/stopped app restarts at boot.
- **Actual notification affordances:** current notification buttons are Audio/Open/Exit or Repeat/Dismiss/Open (`ForegroundNotificationState.buttons`, lines 50-66). Legacy pause/resume handlers are not evidence of reachable notification pause/resume buttons.
- **Actual widgets:** current native widgets emit presets, global audio/clock-focus actions and app opening; legacy per-module/ResumeLast/widget start-stop handler cases have no producer in those widgets. Launcher Resume Last is a distinct shortcut. Help's descriptions should not be mistaken for a real native control inventory.
- Native queue UUID acknowledgement preserves later arrivals and normal warm widget actions execute serially. Rapid ordinary preset taps leaving the last preset active is not automatically a defect. The retained confirmation flaw specifically concerns queue processing time versus arrival time during delayed startup.
- Denying notification permission was not proven to destroy a timer or permanently block bootstrap. Permission-request failure and a timer loss must not be conflated.
- Ordinary Android Back may intentionally background a timer app. No finding assumes Back destroys `MainScreen`.
- Immediate preset/custom timer starts are implemented behavior, not an invented two-tap requirement. Custom Cancel and restore-confirmation Cancel leave the active timer/settings unchanged as traced.
- Positive-remainder timer/stopwatch pause/resume generally preserves elapsed/remaining data. Stopwatch fractions are calculated from real runtime milliseconds; fullscreen omission of fractions is deliberate.
- Active tag switching attributing the current unlogged interval to the latest tag was not separately flagged without an immutable/split-at-switch contract. Enable/disable/reset provenance failures are distinct and retained.
- Successful session writes are serialized, and session reads await the shared write tail. An unawaited `logSession` call alone does not prove the immediate main summary is stale. The retained dashboard flaw is lack of subsequent reload/subscription.
- Quiet-hour range predicates handle midnight-spanning and same-day ranges with inclusive start/exclusive end. Equal endpoints explicitly disable the range; no undocumented all-day contract was invented.
- Device UI locale versus configured speech language, intentional shared Malayalam recordings, documented window-manager hints, captured custom-model import language and absence of a whole-chain Repeat button are not defects by themselves.
- Code validation, staging and guarded replacement make several local-model import/recovery suspicions unfounded. No claimed checksum omission or fabricated missing audio assets were retained.
- Architecture size, dead code, generated-file policy, CI/build/package hygiene and unsupported wished-for controls were outside this second pass unless an existing user action demonstrably failed.

## Original suggested repair order (audit baseline)

1. Bind timer completion/dialog/speech results to the owning run/revision and retire obsolete work before adopting replacement timers.
2. Share durable chain-stage advancement across UI ticking, foreground task and expired-runtime restoration; preserve chain configuration and completed-cycle position.
3. Make mute, language/engine changes, restore and quiet-hour transitions apply their actual playback/scheduling side effects coherently.
4. Put stopwatch laps and session provenance into the same start/reset/restore transitions as their associated runtime; refresh history surfaces when records/date change.
5. Repair backup filename/error/selection contracts and the live Settings labels/options.
6. Resolve navigation requests into existing focus routes; retain ordinary tab access in landscape and correct the built-in Help instructions.

## Verification boundary

All new journeys are code-only. No sound, device-volume mutation, screenshot, layout rendering, modal interaction, systemd operation, real backup I/O, download/import or background/reboot behavior was exercised. These are evidence-backed source findings with explicit conditions, not UI-run or test-suite results.

## Repair tracking — started

Implemented in source, pending a runnable application-level scenario:

| Finding | Repair |
|---|---|
| U01 / U07 | Generation-guarded completion work and run/revision-bound dialogs; newer local or externally adopted timers invalidate old completion results and retire the stale modal instead of dismissing the new runtime. |
| U04 / U06 | A shared expired-runtime transition now advances the next chain segment in both foreground restoration and background reconciliation; final chain completion persists index zero. |
| U35 | Backup names include subsecond uniqueness and file creation is exclusive, so an existing backup is never silently overwritten. |
| U36 | Settings import rejects incomplete/unrelated JSON and propagates parse/read errors; export propagates write failures and offers clipboard JSON fallback. |

Also addressed first-audit findings 01–02: imports no longer turn arbitrary JSON objects into default settings, and a settings snapshot that loaded successfully remains usable when write-back fails.

**Verification so far:** `dart analyze lib/main.dart lib/services/settings_service.dart` — no issues. No runtime journey was exercised: the Linux device is detected but this session has neither `DISPLAY` nor `WAYLAND_DISPLAY`; the repository explicitly prohibits running tests unless requested. These source changes still need runtime verification on an available desktop/device. Other audited findings remain open; this table is not a claim that the audit backlog is complete.

### Milestone 2 — timer sessions, laps and history

| Finding | Repair |
|---|---|
| U03 | Restored timer duration now populates the timer preset value, so Reset → Start uses the restored minutes. |
| U16 / U17 | Stopwatch laps belong to the persisted stopwatch runtime; both ordinary and fullscreen Reset clear them, while stop/resume/restore preserve them. |
| U42 / U43 | Enabling Tagging mid-run captures the then-current remaining time; disabling/resetting clears the session marker and logs only the tagged interval. |
| U44 / U45 | Session writes publish a change revision that refreshes an open dashboard; dashboard also refreshes periodically and handles load errors. The timer’s today summary refreshes on local-day rollover and app resume. |

Also addressed first-audit findings **03–05**: foreground-task completion logs tagged segments, timer runs carry their segment-start remaining seconds across persistence, pause/resume logs only the active interval, and each chain segment is recorded separately. Session IDs deduplicate a foreground/background completion of the same runtime revision. First-audit **26** now shows a bounded history-load error instead of an indefinite spinner.

`dart analyze lib/main.dart lib/models/timer_runtime.dart lib/models/session_log.dart lib/services/session_log_service.dart lib/services/timer_runtime_store.dart lib/widgets/dashboard_screen.dart` reported no issues. Runtime smoke remains unavailable: no display session; tests remain prohibited unless requested.

### Milestone 3–5 — audio, restore and interaction repairs

| Finding | Repair |
|---|---|
| U08/U13/U15/U21–U25/U28/U31 | Notification playback teardown, per-module delayed speech validity, clock schedule generations, sleep-window boundary rechecks/audio restoration, timer-speech suppression and speech-only TTS gain. |
| U32–U34/U37 | Restore applies clock and mute effects and rebinds Android TTS; backup UI explicitly excludes local desktop offline-model selections and states restore preserves them. |
| U18/U19/U38/U39 | Explicit Drive stopwatch speech works while paused/automatic speech is off; stopwatch generations invalidate stale session announcements; existing focus routes update module mode and timer dismissal pops only timer focus. |
| U40/U41/U49–U52 | Start 25m uses the replacement transition; native confirmations use arrival-time expiration; tab navigation stays reachable in landscape; Help and Custom timer validation reflect actual controls. |

`dart analyze lib/main.dart lib/models/speech_item.dart lib/widgets/fullscreen_focus_view.dart lib/widgets/timer_panel.dart lib/widgets/help_panel.dart` reported no issues. App runtime/UI and Android/Kotlin builds remain unavailable/unrun; all other audit findings remain open.
