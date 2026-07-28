# API Workshop — Planning Notes (MAA MathFest 2026)

---

## General Notes

- This is a **mini-workshop for MAA MathFest 2026**, structured like a class — asking questions throughout and reviewing answers to reinforce each concept.
- Some questions are done **together as a group**; others are done **individually**, depending on time.
- The workshop grew from a six-month web development course. The original goal was to learn web dev, but the experience also introduced data engineering, databases, servers, and extracting online data. This workshop covers a practical subset of that learning.
- Participants should know **basic R, functions, pipes, and some dplyr/tidyverse**.
- Participants work through a `.qmd` file in **Positron** (or RStudio). Demonstrations are done primarily in Positron.
- The API used is **Open-Meteo**, which **does not require an API key** — simplifies setup significantly.
- **Meg** is the workshop assistant. Participants can ask either of us for help.
- Include the **MAA MathFest 2026 Evaluation/Survey** in the slides:
  - <https://docs.google.com/forms/d/e/1FAIpQLSd2JNOT09AWYlI-5S8q4QyMTYsV0GKn0AV7R921rexumXgHuw/viewform?usp=dialog>

---

## Potential Changes

### Reorganization

1. **Session 2 is too long.** Trim content so it fits comfortably in one hour. Move overflow material into Session 3 or cut concepts that can be referenced rather than taught live.

2. **Better organize Sessions 3 and 4.** The current split (setup/geocoding vs. historical/visualization) needs rethinking to create a smoother flow across Day 2.

3. **Pre-build functions for participants instead of live-building complex functions during the session.** Provide working functions (e.g., `geocode()`, `prev_weather()`) as ready-to-use tools. Participants call them, inspect outputs, and learn the logic by reading — not by typing out 40-line functions in real time. Reserve function-building as a **take-home exercise** so they can practice at their own pace.
While highlighting major concepts for the API workflow, the focus should be on **using functions** rather than **building functions** during the workshop. There should still be a request or two that participants build themselves, but the majority of the functions should be pre-built.



4. **Create blank/empty versions of each QMD.** Each session needs two versions:
   - **Answer key version** — full code and solutions (for Meg and reference).
   - **Blank version** — key elements removed for participants to fill in during the session (variable names, function arguments, URL components, status code checks, etc.).

This already exists for all the sessions, but needs to be double-checked for completeness and consistency. Everything should be fill in blank nothing from scratch. The goal is to have participants **fill in the blanks** rather than write code from scratch.



DONE I do

6. **Add a Session 0 (Opening) block** — the 30-minute pre-session setup and welcome. This is not a full session, but needs a slide or outline in the materials.

7. **Give Meg the answer-key solutions** — either as a single packet or as four separate packets (one per session) so she can assist participants effectively.

---

## Day of Tasks

- [ ] **Arrive 30 minutes early** to help participants open files and resolve setup issues.
- [ ] **Welcome and introduction:**
  - Introduce yourself and the purpose of the workshop.
  - Explain that participants will learn the fundamentals of APIs and how they can be used in statistics and data science courses.
- [ ] **Share background:**
  - This workshop grew from a six-month web development course.
  - Originally wanted to learn web dev, but the experience also introduced data engineering, databases, servers, and extracting online data.
  - This workshop covers a practical subset of that learning.
- [ ] **Outline the workshop structure for participants:**
  - *Today (Day 1):* Understand API requests and responses. Examine responses first. Learn how to parse responses in R. Begin creating requests.
  - *Tomorrow (Day 2):* Apply these skills using a weather API. Discuss classroom applications.
- [ ] **Set expectations:**
  - Participants should know basic R, functions, pipes, and some dplyr/tidyverse.
  - Open the provided `.qmd` file in Positron or RStudio.
  - Demonstrations will be done primarily in Positron.
- [ ] **Introduce Meg** as the workshop assistant. Encourage participants to ask either of you for help.
- [ ] **Confirm API access:**
  - We will use Open-Meteo, which does not require an API key.
- [ ] **Remind about the evaluation survey** (display link on slide):
  - <https://docs.google.com/forms/d/e/1FAIpQLSd2JNOT09AWYlI-5S8q4QyMTYsV0GKn0AV7R921rexumXgHuw/viewform?usp=dialog>
- [ ] **Give Meg the answer-key packets** (four separate packets, one per session).
- [ ] **Transition into Session 1:**
  - *"Let's begin by examining what happens when an application communicates with an API."*