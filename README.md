# StayAwake Menubar

A lightweight macOS menubar app that keeps your Mac from sleeping — a simple free alternative to paid tools like Amphetamine or KeepingYouAwake.

A ☕ icon in the menubar, click it and pick how long the Mac should stay awake. No background processes, no bloat.

## Features

- Prevents system (idle) sleep; the display still sleeps normally by default
- Hold **Option (⌥)** while picking a duration to also keep the display awake
- Duration options: 15 min / 30 min / 1h / 2h / 4h / until manually turned off
- Zero configuration, no external dependencies
- Negligible resource usage (idle process ≈ 0% CPU)

## Requirements

- macOS 13 (Ventura) or newer
- Xcode 14+ (to build from source)

## Usage

- Click the ☕ icon in the menubar.
- Pick a sleep-prevention duration. By default, only system sleep is blocked — the display still dims/sleeps on its own schedule.
- Hold **Option** while clicking a duration to also block display sleep (a small "⌥" appears next to each option while Option is held, as a hint). The active status will then show "(display won't sleep)".
- The icon fills in (☕ → filled cup) while the block is active.
- Click again and choose "Turn off" to end it early.

Quitting the app (⌘Q or "Quit" in the menu) automatically releases the active sleep assertion.

> **Note:** the "⌥" hint next to each option relies on SwiftUI refreshing an already-open native `NSMenu`, which isn't fully reliable across macOS versions. The Option-key behavior itself (checked at click time) always works correctly even if the hint doesn't visually update in real time — worst case, just close and reopen the menu to see it.

## How it works

The app uses the system `IOPMAssertionCreateWithName` API (IOKit) — the same mechanism the built-in macOS `caffeinate` command relies on. By default it creates a `kIOPMAssertionTypePreventUserIdleSystemSleep` assertion (system stays awake, display can still sleep); holding Option switches to `kIOPMAssertionTypeNoDisplaySleep` (blocks display sleep too). The assertion is tied to the app's process, so quitting it (even via crash or Force Quit) instantly releases the sleep block.
