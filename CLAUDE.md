# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What RAEED is

A private mobile + web platform connecting three roles around each enrolled child: **parents**, **educators (mo'atirin)**, and **executives (moshrifin)**. See [README.md](./README.md) for the full role and release description.

- **MVP**: categories (فئات) / groups / weekly sessions, presence confirmation + attendance with instant absence alerts, homework tracking, session materials, safeguarded messaging + targeted announcements, private Memories Wall (photos/videos), executive dashboard + audit logs.
- **V1**: camps and events, enrollment, fees.

## Project status

No code yet — stack, architecture, and directory layout are undecided. When this changes, update this file with:
- the actual tech stack (mobile framework, web framework, backend, database)
- how to install dependencies, run the app, run tests, and lint
- the real directory layout

Do not assume a stack; ask or check for existing config files before scaffolding.

## Domain notes to keep in mind

- **Safeguarding is central**: this app handles data about children. Any feature touching messaging, media (Memories Wall), or personal data should default to the most private/restrictive option, and access should be scoped by role and by the specific child/group relationship — never assume broad visibility.
- **Role-based access is the core model**: parents should only ever see their own child's data; educators should only see their own group(s); executives have the oversight view (dashboard, audit logs) but actions should still be traceable per user.
- **Attendance alerts are latency-sensitive**: absence alerts are meant to be instant — keep this in mind for any notification/queue design.
- **Arabic terms are part of the domain vocabulary** (فئات = categories, mo'atirin = educators, moshrifin = executives). Keep them consistent across code, docs, and UI strings rather than inventing new translations.

## Working conventions

- Keep MVP and V1 scope separate — don't pull V1 features (camps/events, enrollment, fees) into MVP work unless asked.
- Prefer small, reviewable changes; confirm architecture/stack decisions with the user before committing to them, since none exist yet.
