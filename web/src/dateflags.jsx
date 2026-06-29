// Soft scheduling warnings: flags a date that lands on a weekend (worked out
// from the date itself) or on an office holiday (passed in from /holidays).
// Purely advisory — callers still let the user save.

const WEEKDAY = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

// dateStr: 'YYYY-MM-DD'. holidays: [{ day, label }]. Returns { type, text } | null.
// Holiday takes precedence over weekend (a holiday that lands on a weekend shows
// the holiday).
export function dateWarning(dateStr, holidays) {
  if (!dateStr) return null;
  const d = new Date(dateStr + 'T00:00:00');
  if (Number.isNaN(d.getTime())) return null;

  const hit = (holidays || []).find((h) => h.day === dateStr);
  if (hit) {
    const name = (hit.label || '').trim() || 'a holiday';
    return { type: 'holiday', text: `Heads up — ${name} is marked as a holiday; the office is closed that day.` };
  }

  const dow = d.getDay();
  if (dow === 0 || dow === 6) {
    return { type: 'weekend', text: `Heads up — that's a ${WEEKDAY[dow]}, and weekends aren't usual work days.` };
  }
  return null;
}

// Inline note rendered under a date field. Renders nothing for a normal weekday.
export function DateWarn({ date, holidays }) {
  const w = dateWarning(date, holidays);
  if (!w) return null;
  return (
    <p className={'date-warn ' + w.type} role="status">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M10.3 3.6 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.6a2 2 0 0 0-3.4 0z" /><path d="M12 9v4" /><path d="M12 17h.01" />
      </svg>
      <span>{w.text}</span>
    </p>
  );
}
