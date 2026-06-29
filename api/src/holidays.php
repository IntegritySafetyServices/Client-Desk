<?php
// Office holidays / closure dates (per workspace).
//
// These power a soft scheduling warning only — the front-end flags a date that
// falls on a holiday (or a weekend, which it works out from the date itself) so
// whoever's scheduling can reconsider. Nothing here blocks saving.
//
// Listing is open to any team member (everyone needs the warnings); adding and
// removing dates is admin-only. Weekends are NOT stored here — Saturdays and
// Sundays are detected client-side from the date.

function holiday_row(array $r): array {
    return [
        'id'    => (int)$r['id'],
        'day'   => $r['holiday_date'],   // 'YYYY-MM-DD'
        'label' => $r['label'],
    ];
}

// GET /holidays — every team member can read the list.
function holidays_list(array $user): void {
    $wid = user_workspace_id($user);
    $s = db()->prepare(
        'SELECT id, holiday_date, label FROM holidays
         WHERE workspace_id = ? ORDER BY holiday_date'
    );
    $s->execute([$wid]);
    json_out(['holidays' => array_map('holiday_row', $s->fetchAll())]);
}

// Accepts only a strict YYYY-MM-DD and confirms it's a real calendar date.
function valid_date(string $d): bool {
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $d)) return false;
    [$y, $m, $day] = array_map('intval', explode('-', $d));
    return checkdate($m, $day, $y);
}

// POST /holidays  { day: 'YYYY-MM-DD', label?: string }  — admin only.
// Re-adding an existing date just updates its label (idempotent).
function holidays_create(array $user): void {
    require_csrf();
    $wid = require_admin($user);
    $b = body();
    $day = str_field($b, 'day');
    $label = str_field($b, 'label');
    if (!valid_date($day)) json_out(['error' => 'A valid date is required'], 422);
    if (mb_strlen($label) > 120) $label = mb_substr($label, 0, 120);

    $s = db()->prepare(
        'INSERT INTO holidays (workspace_id, holiday_date, label) VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE label = VALUES(label)'
    );
    $s->execute([$wid, $day, $label]);

    $g = db()->prepare('SELECT id, holiday_date, label FROM holidays WHERE workspace_id = ? AND holiday_date = ?');
    $g->execute([$wid, $day]);
    $row = $g->fetch();
    json_out(['holiday' => $row ? holiday_row($row) : null], 201);
}

// DELETE /holidays/{id} — admin only, scoped to the caller's workspace.
function holidays_delete(array $user, int $id): void {
    require_csrf();
    $wid = require_admin($user);
    $s = db()->prepare('DELETE FROM holidays WHERE id = ? AND workspace_id = ?');
    $s->execute([$id, $wid]);
    json_out(['ok' => true]);
}
