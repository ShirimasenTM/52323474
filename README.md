
League of Legends — Notes site

How to use the Items image picker

How to attach images to Items (current)

- The image dropdown selectors were removed and the in-page attach feature has been removed per request.
- If you want a different workflow you can:

	- Manually add or replace images inside the `ikons/` folder and edit `index.html` to change the `src` path on each item image.
	- Reintroduce an in-page selection or persistence behaviour — I can add a gallery UI or an automatic local manifest generator on demand.
Browser compatibility and notes
 - No in-page attach/persistence feature is currently being used.

Troubleshooting


If you'd like, I can add an optional small script that auto-generates `ikons/images.json` from the directory contents (a node script), or add a simple UI to clear persisted attachments.

## Champion data (Data Dragon) — scripts & usage

This repository now includes a copy of Riot's Data Dragon champion dataset: `championstats.json` (currently v15.23.1) — it's saved in a human-readable, pretty-printed format.

You can fetch the latest champion JSON from Riot and format it using the included PowerShell scripts in the `scripts/` folder:

- scripts/fetch_and_format_championstats.ps1 — fetches the latest Data Dragon version, downloads `champion.json`, and formats it in-place (creates a backup). Use `-Force` to overwrite existing file.
- scripts/format_championstats.ps1 — formats an existing `championstats.json` file and (optionally) creates a `.bak` backup.

Examples (PowerShell):

1) Download latest Data Dragon champion.json and format:
	powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\fetch_and_format_championstats.ps1 -Force

2) Pretty-print the existing file (create .bak backup):
	powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\format_championstats.ps1 -Path .\championstats.json -MakeBackup

If you'd like, I can also add a GitHub Action to auto-fetch & format the file whenever a new patch is released.

