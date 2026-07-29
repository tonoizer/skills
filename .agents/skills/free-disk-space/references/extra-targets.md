# Extra reclaim targets and gotchas

Use these after the core survey in `SKILL.md`. Report sizes first. Only clear
what the skill marks as safe-tier, or ask before touching keepers.

## High-yield developer extras

| Target | Typical path / command | Tier |
| --- | --- | --- |
| Docker / Colima / OrbStack | `docker system df`; prune only after confirming (`docker system prune`, unused images). Volumes often hold real data — ask. | Ask |
| Xcode beyond DerivedData | `~/Library/Developer/Xcode/iOS DeviceSupport`, `Archives`, `watchOS DeviceSupport`, CoreSimulator devices via `xcrun simctl delete unavailable` | Ask (unavailable sims often OK) |
| Android / emulator | `~/.android/avd`, SDK system images under `~/Library/Android/sdk` | Ask |
| Rust / Go / JVM | `cargo clean` in projects; `go clean -cache -modcache` (modcache needs redownload); Gradle `~/.gradle/caches` | Safe via tool CLI when regenerable |
| Bun / Yarn / uv / pip | `bun pm cache rm`, `yarn cache clean`, `uv cache clean`, `pip cache purge` | Safe via tool CLI |
| Next.js / Vite / Turborepo | `.next/`, `dist/`, `.turbo/`, `.cache/` inside projects | Safe regenerable build dirs |
| CocoaPods / SPM | `~/Library/Caches/CocoaPods`, SPM checkouts under DerivedData | Prefer tool cleanup; ask if unsure |
| Gradle / Maven | `~/.gradle/caches`, `~/.m2/repository` | Ask (re-download cost) |

## AI / model weights

Common large dirs: `~/.ollama`, `~/.cache/huggingface`, `~/.cache/whisper`,
`~/.cache/torch`, ComfyUI / Stable Diffusion model folders, local LLM GGUF
dirs. **Always ask** — these are expensive to redownload and are not
"build artifacts."

## Editor and agent caches

- Cursor / VS Code: report extension and cached data sizes under
  `~/Library/Application Support/Cursor` and `Code`; do not wipe without
  naming the app and accepting login/state loss.
- Claude / Codex / agent skill caches: report only unless the user asks.
- Language servers and indexers (rust-analyzer, clangd): usually regenerable;
  prefer their own clear commands when known.

## System and backup gotchas

- **Local Time Machine snapshots**: `tmutil listlocalsnapshots /` then ask
  before `tmutil deletelocalsnapshots <date>`. Can free a lot; not Trash-based.
- **iOS backups**: `~/Library/Application Support/MobileSync/Backup` — ask.
- **Mail / Messages attachments**: leave alone unless the user names them.
- **iCloud Optimize Mac Storage**: deleting local copies may only evict
  placeholders; confirm before mass deletes in Desktop/Documents.
- **Purgeable space**: macOS may show more free after emptying Trash and a
  short wait; re-check `df -h /System/Volumes/Data`.

## Offload reminders

- Prefer offloading named project media folders (exports, screen recordings),
  not entire `~/Movies` or `~/Pictures`.
- After `rsync -a` + size verify + trash + symlink, open one file through the
  symlink before declaring success.
- If the external volume uses a different filesystem (exFAT), warn about
  permissions, resource forks, and broken symlinks when the drive is unmounted.

## Commands worth preferring over raw deletes

```bash
brew cleanup --prune=all
pnpm store prune
npm cache clean --force
yarn cache clean
bun pm cache rm
go clean -cache
cargo cache -a   # if cargo-cache is installed; else cargo clean per project
pip cache purge
uv cache clean
xcrun simctl delete unavailable
docker system df
```
