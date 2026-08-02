Here is the dir: `/Users/immanuelwilliams/Documents/projects/project-155-api-mini-course/animations`

Create click through version with next, play, pause back of each animation of each witihin a new dir

Let the play button be default to be slow

Make sure the arrows are clean and make it make sure they are clean

Make sure it is clean and nice, give a different color scheme that is visually appealing and easy on the eyes. 
---

## 2026-08-02 — GIF regeneration needed

`animations/interactive/url_breakdown.html` was reworked for consistent URL terminology
(critique: "keep the URL terminology consistent across the website, animation, and activity"):

- The address is now broken into **three pieces — Protocol / Base URL / Endpoint** —
  instead of one lumped "Base URL" (matches the Session 2 stepper, table, and glossary).
- Example URL switched from `api.example.com/data?q=city&appid=API_KEY` to the real
  workshop URL `https://api.open-meteo.com/v1/forecast?latitude=…` (no API key,
  consistent with "Open-Meteo needs no key" messaging).
- Final step now says: protocol/base URL rarely change — focus on the endpoint + query.

→ **`animations/gifs/url_breakdown.gif` is now out of date** and must be re-recorded from
the updated interactive version for the attendee downloads zip.

Note: Session 2 Part 1 now uses a new inline CRUD stepper (in the .qmd itself, replacing
`sessions/images/crud-operations.jpeg`). If attendee versions swap steppers for GIFs, a
CRUD GIF would need to be recorded too.
