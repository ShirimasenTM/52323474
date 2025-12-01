
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

