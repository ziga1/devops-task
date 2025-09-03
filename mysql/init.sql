-- Simple calendar/events example
CREATE TABLE IF NOT EXISTS events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  starts_at DATETIME NOT NULL,
  ends_at   DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example seed data
INSERT INTO events (title, starts_at, ends_at)
VALUES
  ('Team meeting',      '2025-09-02 09:00:00', '2025-09-02 10:00:00'),
  ('Doctor appointment','2025-09-03 14:30:00', '2025-09-03 15:00:00');
