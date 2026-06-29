-- Client Desk — Phase 14 migration (run once, after 013).
-- Office holidays / closure dates per workspace. Used purely to power a soft
-- "that day is a holiday" warning when scheduling a task due date, a calendar
-- event, or a request's target date. It does not block anything.
--
-- Note on numbering: 012 was a one-time production data fix (cancel orphaned
-- accepted requests) that was run directly on the live DB and never committed,
-- and 013 is the timeline migration. 014 is the next free number.
--
-- Safe to re-run: CREATE TABLE IF NOT EXISTS.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS holidays (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  workspace_id  BIGINT UNSIGNED NOT NULL,
  holiday_date  DATE NOT NULL,
  label         VARCHAR(120) NOT NULL DEFAULT '',
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_holiday (workspace_id, holiday_date),
  KEY k_holidays_ws (workspace_id),
  CONSTRAINT fk_holidays_ws FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
