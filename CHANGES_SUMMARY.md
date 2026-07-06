# Changes Summary — July 6, 2026

All changes from `general_notes_modifications.md`, applied to both the **solution** sessions (`sessions/`) and the **empty student** versions (`downloads/api_workshop_empty/`, zip rebuilt). Site re-rendered to `_site/`.

## Session 1 — JSON Fundamentals & Request/Response

| # | Note | Change Made | Where |
|---|------|-------------|-------|
| 1 | Restaurant analogy needs a gif/animation in Part 1 | Built an **interactive restaurant-analogy animation** (Client 🙋 → Waiter 🤵 → Kitchen 👨‍🍳 → Fridge 🧊) with **Back / Next / Play–Pause / Restart** controls — it steps and pauses, per the "recreate animation in steps" general note. Embedded directly in the page (no GIF file needed) | `sessions/01_...qmd` Part 1 |
| 2 | Client makes a request in this example | Step 2 of the animation is literally "You **make a request**", and the written analogy now says "You (the client) **make a request** — you place your order... the client makes the request; nothing happens until you order" | Part 1 |
| 3 | Part 3 requests too complicated (URL + API key) | Simplified to one idea: **"a request is written as a URL."** API key reduced to a one-sentence aside ("like a library card — our API doesn't need one"), explicitly deferred to Session 2 | Part 3 |
| 4 | Explain the response slowly: GIF first → text → fill-in-the-blanks | Part 4 restructured as **Watch First** (GIF) → **Now in Words** (numbered, slow walk-through) → **three quick fill-in-the-blank checks** before any harder question | Part 4 |
| 5 | During Break section | Added: answer questions + "Did you finish?" self-checklist + stretch task | End of session |

## Session 2 — CRUD, HTTP Methods & URL Anatomy

| # | Note | Change Made | Where |
|---|------|-------------|-------|
| 6 | Parts 5–7 overwhelming; may need to be cut / made optional | Parts 5–7 (Under the Hood, dummy-server hands-on, error handling) moved to a clearly labeled **"Optional — After the Workshop"** appendix with a "Read this later, not today" warning. Live session now ends after URL Anatomy. *(Your note had both "cut out" and "optional (no)" — I kept the content as an after-class appendix so nothing is lost; delete the appendix if you truly want it gone.)* | End of session |
| 7 | (Follow-on from Session 3 change) | URL-anatomy example switched from OpenWeather (`appid=YOUR_KEY`) to the **Open-Meteo URL used in Session 3** — no key. Added a brief "What About API Keys?" concept callout | Part 4 |
| 8 | Q8 keep but move to end of Session 3, letters not bullets | Removed from Session 2; now **Session 3 Q10**, options lettered a)–e), answer given as `b → e → d → c → a` | Session 3, Part 7 |
| 9 | During Break section | Added (questions + did-you-finish + write-your-own-URL stretch task) | End of live portion |

## Session 3 — Weather API (largest rewrite)

| # | Note | Change Made | Where |
|---|------|-------------|-------|
| 10 | Change weather API to the free one: `request("https://api.open-meteo.com/v1/forecast")` | Entire session rebuilt on **Open-Meteo**. That exact endpoint is introduced verbatim in Part 1. Geocoding uses `https://geocoding-api.open-meteo.com/v1/search` | Whole session |
| 11 | Erase saving API key / client / secret; mention concepts briefly | All `.Renviron` / `dotenv` / key setup **removed**. One "What About API Keys, Clients & Secrets?" callout keeps the concept alive and points to the Practice Labs for the real thing | Part 1 |
| 12 | Show the URL-with-query in the web browser returning data | New **Part 2: "See It in the Browser First"** — paste the full query URL, see raw JSON, tie every piece back to Sessions 1–2, then change coordinates and reload | Part 2 |
| 13 | ETV Cycle notes to make the process easy to see | New **Part 3: "The ETV Cycle"** — Extract → Transform → Visualize table mapped to the exact functions; every later code block is labeled with its ETV step. A `<!-- TODO(Immanuel) -->` marker is in the qmd where you can link your actual **ETV Cycle 4 notes** | Part 3 + throughout |
| 14 | No named functions — use map + anonymous functions | The `geocode()` and `prev_weather()` named functions are gone. Multi-city work uses `pmap(\(city, latitude, longitude) {...})` and `map(\(nm) {...})` + `bind_rows()`, with a "Reading the map pattern" callout explaining `\( )` as a "nameless recipe" | Parts 5–6 |
| 15 | During Break section | Added (questions + did-you-finish + add-a-4th-city stretch task) | End of session |

## Session 4 — Historical Weather & Visualization

| # | Note | Change Made | Where |
|---|------|-------------|-------|
| 16 | Session 3 changes inherently change Session 4 | Rebuilt on the **Open-Meteo archive endpoint** (`archive-api.open-meteo.com/v1/archive`). One request returns a whole date range — the per-day `for` loop, `lubridate` date math, and the sf/rnaturalearth map section are all gone. Browser-first demo kept | Whole session |
| 17 | Simple visualizations: Boston vs SLO summer + winter, 2 more questions | **Part 3** — same `pmap` recipe run twice: July 2025 summer plot and January 2026 winter plot (only `start_date`/`end_date` change). Added **Q4 (summer visual check)**, **Q5 (winter visual check)**, plus Q6 fill-in-the-blank | Part 3 |
| 18 | Explorative: audience creates their own query from provided options | **Part 4: "Explore — Build Your Own Query"** — pick-one-from-each-column menu (5 cities w/ coordinates + hometown-via-geocoding, 5 daily variables, 4 date ranges), fill-in-the-blank template, worked example (Seattle spring winds), two-city bonus | Part 4 |
| 19 | During Break: + resources for after the class | Break section now includes an **after-workshop resources list**: Practice Labs, Session 2 optional appendix, Open-Meteo docs, httr2 site, R4DS iteration chapter, JSONPlaceholder | End of session |

## General Notes [REALLY IMPORTANT]

| # | Note | Change Made | Where |
|---|------|-------------|-------|
| 20 | Empty version reflects all changes / created without answers | All four student versions **regenerated from the new solutions** (46 answer/solution callouts stripped; content, code scaffolds, and the interactive animation kept). Zip rebuilt | `downloads/api_workshop_empty/` + zip |
| 21 | Meg's schedule for learning the material | Added a schedule table **stub** (dates marked `___` for you to fill) | Instructor Guide, top |
| 22 | What am I assuming you know before this course | New **"What We Assume You Already Know"** section (know / don't-need-to-know lists + R4DS refresher pointer) | Session 0 |
| 23 | Survey audience: R experience + how they'll use this to teach Data/STAT | New **"Quick Survey"** section (3 questions) | Session 0 |
| 24 | Online vs Positron (text) vs Positron (visual) | Survey question 3 asks exactly this (a/b/c); delivery-mode decision noted in Instructor Guide | Session 0 + Instructor Guide |
| 25 | Answer the questions inadvertently in my own notes | Every question is now answerable from the text/animation immediately above it (recorded as a design standard in the Instructor Guide) | All sessions |
| 26 | List of all questions by session and part | New **Question Bank** page — every question, its type, part, and answer key, plus the MC letter distribution. Added to navbar under **Instructor ▸ Question Bank** | `sessions/supplemental/question_bank.qmd` |
| 27 | Image/GIF first → words second → questions third | Every part with a visual now follows **Watch First → Now in Words → questions** | Sessions 1–2 (and browser-first in 3–4) |
| 28 | Keep highlighting the purpose (request → format → analyze) in every part of S1–S2 | One-sentence goal defined in a "🎯 The One Goal" callout at the top of S1–S4, and a short **"🎯 Goal Check"** callout in **every part** of Sessions 1 and 2 (and at key moments in 3–4) tying that part back to the goal | Sessions 1–4 |
| 29 | Videos: two per session | 8-video production plan table (concept video + walkthrough video per session) | Instructor Guide |
| 30 | Recreate animation in steps, able to pause (really important) | Done for the restaurant analogy (stepper with Back/Next/Play-Pause). The five remaining GIFs are listed in the Instructor Guide as candidates to convert to the same stepper pattern | Session 1 + Instructor Guide |
| 31 | Images-only version to narrate over | Logged as planned work in the Instructor Guide (not yet built) | Instructor Guide |
| 32 | Questions: heavier 1–2-word fill-in-the-blank | FIB is now the primary type: **19 FIB** across the workshop (S1 alone has 9) | All sessions |
| 33 | All questions have 5 options | Every MC question has exactly **five options a)–e)** | All sessions |
| 34 | Make choices more obvious | Distractors rewritten to be clearly wrong (e.g., "It draws the plots", "R is not installed correctly") | All sessions |
| 35 | Correct answer not always b) | MC answers deliberately spread — S1: d,c,e,a,c,e,b · S2: d,a,e,b,c,a,d · S3: c,e,d,b · S4: a,e,c | All sessions |
| 36 | Limit open-ended; make them straightforward | Open-ended cut from ~14 to **3** (one short-answer URL dissection, one bonus in the optional appendix, one teaching-reflection discussion) | All sessions |
| 37 | Don't assume functions before they're introduced | e.g., S1's old visual check that used `resp_body_json()` before it was taught is now a plain "named list" FIB; S3 introduces each function before questioning it; recorded as a design standard | All sessions + Instructor Guide |

## Also Updated (consequences of the above)

| File | Change |
|------|--------|
| `index.qmd` | Package list (`dotenv`/`lubridate` → `purrr`/`tibble`), API renamed to "Open-Meteo (free — no API key required)" |
| `sessions/00_Getting_Started.qmd` | Install list updated; "OpenWeather API key" checklist item replaced with "API key — not needed!" |
| `_quarto.yml` | Navbar: "Instructor" menu now holds Instructor Guide + Question Bank |
| `sessions/supplemental/instructor_guide.qmd` | New "Core Workshop — Production & Delivery Checklist" section; Lab 3 setup note fixed (students no longer arrive with an OpenWeather key) |
| `downloads/api_workshop_empty.zip` | Rebuilt from the regenerated student files |
| `_site/` | Full `quarto render` completed successfully |

## Open Items for You

1. **Fill in Meg's schedule dates** in the Instructor Guide stub.
2. **Link your ETV Cycle 4 notes** at the `<!-- TODO(Immanuel) -->` marker in Session 3, Part 3.
3. **Session 2 Parts 5–7:** kept as an "Optional — After the Workshop" appendix per one reading of your note ("(no)" was ambiguous) — delete the appendix if you wanted them fully cut.
4. **Record the 8 videos** per the plan table; **build the images-only narration decks** when ready.
5. The site was rendered but **not committed/pushed** — run your usual `git add … && git commit && git push` (per `README_ME_ONLY.md`) when you're happy with it.
