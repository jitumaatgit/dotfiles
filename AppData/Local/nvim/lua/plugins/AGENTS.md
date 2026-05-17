## Non-obvious Learnings

### Wiki-link reference update bug (`extend-mini-files.lua`)

`update_obsidian_refs` builds `old_forms` and `new_forms` as flattened arrays of 6 forms each (from `get_ref_forms`). Position-wise replacement means `old_forms[i]` → `new_forms[i]`. When moving a file without renaming, `old_id == new_id` but `old_rel_noext != new_rel_noext`. For root notes, `old_id == old_rel_noext`, so the third group matches the same links as the first group. On the second pass, `[[Note|label]]` gets degraded to `[[path/Note|label]]`. Fix: use `new_id` (basename) for the third group instead of `new_rel_noext`.

### `get_ref_forms` generates 6 link variants

`get_ref_forms(ref)` returns: `[[ref]]`, `[[ref|`, `[[ref\\|`, `[[ref#`, `](ref)`, `](ref#`. The `\\|` form handles escaped pipes in wiki link titles (e.g., titles containing literal `|` characters).
