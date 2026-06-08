# MimicXI launcher news feed

The launcher pulls live news from a JSON file on this web server.
Point your launcher's `NEWS_URL` setting at the URL where this site
serves **news.json**.

If the site is served by Flask (Option A in `INTEGRATION.md`), the
URL is:

```
http://your-server.example.com/site/news.json
```

If you serve `site/` from any other static host, it's just:

```
https://yourdomain.com/news.json
```

## Editing news

Edit `site/news.json` directly. It's a plain JSON array — each entry
becomes one card in the launcher.

```json
[
  {
    "date":  "MAY 24",
    "tag":   "PATCH",
    "color": "gold",
    "title": "v1.2.5 — Something changed",
    "body":  "Details here."
  }
]
```

### Fields

| Field   | Notes |
|---------|-------|
| `date`  | Short date string. Free-form — `MAY 24`, `2026-05-24`, `Today`, whatever you want shown. |
| `tag`   | Short uppercase label (`PATCH`, `EVENT`, `NEWS`, `SERVER`, etc). |
| `color` | One of `"gold"`, `"crimson"`, `"teal"`, `"green"`. Controls the tag colour in the launcher. |
| `title` | Headline. |
| `body`  | One or two sentences of detail. Plain text. |

Order matters — newest first. The launcher renders entries in array
order. Keep the file short (last 5–10 items is plenty) so it loads
fast.

### Tips

- Validate the JSON before you commit. A trailing comma will break the
  feed for every player. Paste it into <https://jsonlint.com> if in doubt.
- Cache: the launcher fetches this every time it opens, so changes go
  live the moment you save the file. No deploy step needed if Flask
  serves it.
- The website's home page also reads this file (`#news` section) so
  patch notes appear on the web at the same time as in the launcher —
  one source of truth.
