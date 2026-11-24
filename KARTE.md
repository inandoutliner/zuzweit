# Inhaltskarte

Automatisch erzeugt mit `werkstatt/werkzeuge/karte.py`. Stand: 

Vorgehen: Abschnitt hier finden → `grep -n "<Titel>" index.html` → nur diesen Bereich lesen.

## `index.html` – Zu zweit 1001
888 Zeilen, 56 KB.

**Bedien-Bereiche (HTML)**

- 221: `<section>` welcome – Willkommen
- 267: `<nav>` events – Anlässe
- 269: `<section>` hero – Aktueller Anlass
- 307: `<dialog>` dItem – Aufgabe bearbeiten
- 321: `<dialog>` dEv – Anlass
- 334: `<dialog>` dSet – Einstellungen
- 357: `<dialog>` dShare – Link teilen
- 607: `<section>` ${label}

**Abschnitte im Code** (Suchbegriff = Titel)

| Zeile | Abschnitt | Funktionen |
|---|---|---|
| 19–52 | Farben und Schriften |  |
| 52–68 | Kopf |  |
| 68–81 | Anlässe |  |
| 81–102 | Bühne: der aktuelle Anlass |  |
| 102–110 | Filter |  |
| 110–150 | Liste |  |
| 150–168 | Eingabe unten |  |
| 168–185 | Knöpfe, Felder |  |
| 185–198 | Blätter (Dialoge von unten) |  |
| 198–371 | Willkommen |  |
| 371–393 | Grundlagen | $, esc, uid, nowIso, makeCode, sha |
| 393–414 | Datum | todayStr, dayDiff, fmtDate, fmtStamp, countText |
| 414–442 | Zustand | other, nameOf, initial, saveLocal, liveEvents, liveTasks, evById, tasksOf, sortedEvents, nextEvent, ensureCur |
| 442–467 | lokale Änderungen | putTask, putEvent, addTasks |
| 467–479 | Server (Supabase-Funktionen) | rpc |
| 479–528 | Abgleich | pendingCount, syncSoon, sync, applyServer, setStatus |
| 528–545 | Live-Signal: „ich habe etwas geändert“ (Supabase Realtime Broadcast) | loadRealtime, ping |
| 545–637 | Zeichnen | avatar, whoLabel, isNew, render, renderEvents, renderHero, renderList, row, renderComposer, cycle |
| 637–706 | Bedienung | stampOn, grow, toast |
| 706–743 | Blatt: Aufgabe | segHtml, bindSeg, segVal, openItem |
| 743–769 | Blatt: Anlass | openEvent |
| 769–802 | Blatt: Einstellungen | shareLink, shareTo, copy |
| 802–888 | Start: Link lesen, anlegen, beitreten | parseLink, keepHash, openList, start, askWho, markSeen |
