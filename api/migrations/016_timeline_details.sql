-- Client Desk — Phase 16 migration (run once, after 015).
-- Meeting notes on timeline NOTES: an optional longer free-text block attached to
-- a timeline entry, collapsed by default in the UI. Stored as a nullable TEXT
-- column on the existing timeline_entries table (only notes use it; reminders
-- and merged task markers ignore it). Internal-only, same as the rest of the
-- timeline. Written to be safe to re-run: the column is only added if absent.

SET NAMES utf8mb4;

SET @col := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'timeline_entries'
    AND COLUMN_NAME = 'details'
);
SET @ddl := IF(@col = 0,
  'ALTER TABLE timeline_entries ADD COLUMN details TEXT NULL AFTER body',
  'DO 0'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
