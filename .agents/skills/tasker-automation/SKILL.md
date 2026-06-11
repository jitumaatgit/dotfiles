---
name: tasker-automation
description: Generate valid Tasker XML (Profiles, Tasks, Projects) from natural language requests, including custom Widget v2 layouts, variable arrays, and structured data access. Use when user asks for Tasker automation, profiles, tasks, projects, widgets, or custom Android automation XML.
---

# Tasker Automation

Generate Tasker XML from natural language. The AI infers whether to create a **Profile** (triggered automatically), **Standalone Task** (manual trigger), or **Project** (multi-component).

## Quick Start

1. User makes a request (e.g. "When I get home, turn on wifi")
2. Determine entity type (Profile / Task / Project)
3. Select components from REFERENCE.md catalogs
4. Build XML following the structure descriptions
5. Output: explanatory sentence + XML code block

## Entity Selection

- **Profile**: Automation triggered by conditions/events/states/times/apps/location
- **Standalone Task**: Manual sequence (shortcut, tile, widget button)
- **Project**: Multiple profiles + named tasks, state tracking + manual actions, widget calling separate tasks

## Key References

See [REFERENCE.md](REFERENCE.md) for:

| Section | Content |
|---------|---------|
| 1 | Event Context Catalog (all available event trigger codes) |
| 2 | State Context Catalog (all available state trigger codes) |
| 3 | Action Catalog (all available action codes) |
| 4 | Tasker XML Schema Definition |
| 5-7 | Structure descriptions for Profile, Standalone Task, Project |
| 8 | Complete XML examples |
| 9 | Clarification JSON Schema (for asking user follow-up questions) |
| 10 | Tasker Input Dialog Types Catalog |
| 11 | Built-in Variable Catalog |
| 12 | Variable Arrays & Structured Variable access syntax |
| 13 | Example success scenarios (complete XML patterns) |
| 14 | Example clarification scenarios |
| 15 | Widget v2 Custom Layout JSON Schema |
| 16 | Widget v2 Custom Layout JSON Examples |
| 17 | Pattern matching rules & operator codes |
| 18 | Command System |
| 19 | Handling modification requests |

## Critical Rules

- **No plugins**: Refuse requests requiring AutoApps, AutoNotification, Join, etc.
- **No hallucination**: Only use `code` values from provided catalogs
- **XML types**: `"a"` field in catalog is sole determinant of XML tag type
- **1-based arrays**: Tasker arrays start at index 1, not 0
- **Widget colors**: Only use Material You names listed in REFERENCE.md section 15's `colorString` enum, or hex codes
- **Widget interaction**: Prefer Task Calling with Variables over Command System
- **State inversion**: Use `<pin>true</pin>` for inverted states (not by modifying parameters)
- **Int variables**: Use `<var>` tag for variables in `<Int>` arguments, `val` attribute for literals
- **Exit Task required**: For State profiles with `flags=40`, manually restore settings in Exit Task
- **Early returns**: Use `If` → `Flash` → `Stop` for precondition checks
