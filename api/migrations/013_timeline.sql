-- Client Desk — Phase 13 migration (run once, after 011).
-- Client timeline: manual reminders + notes attached to a client. Tasks are NOT
-- copied here; they're merged onto the timeline at read time from the tasks table.
-- Written to be safe to re-run.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS timeline_entries (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  workspace_id BIGINT UNSIGNED NOT NULL,
  client_id    BIGINT UNSIGNED NOT NULL,
  author_id    BIGINT UNSIGNED NULL,                 -- creator; SET NULL on user delete
  kind         ENUM('reminder','note') NOT NULL,
  body         TEXT NOT NULL,
  entry_date   DATE NOT NULL,                         -- reminder due date OR note record date
  done_at      DATETIME NULL,                         -- reminders only: when completed
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY k_tl_client (client_id),
  KEY k_tl_due (workspace_id, kind, done_at, entry_date),
  CONSTRAINT fk_tl_ws     FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE CASCADE,
  CONSTRAINT fk_tl_client FOREIGN KEY (client_id)    REFERENCES clients(id)    ON DELETE CASCADE,
  CONSTRAINT fk_tl_author FOREIGN KEY (author_id)    REFERENCES users(id)      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
