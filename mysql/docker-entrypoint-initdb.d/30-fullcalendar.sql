-- Users table
CREATE TABLE IF NOT EXISTS users (
  user_id    INT AUTO_INCREMENT PRIMARY KEY,
  user_mail  VARCHAR(255) NOT NULL
);

-- Day offs table
CREATE TABLE IF NOT EXISTS day_offs (
  day_off_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  date_occur   DATE NOT NULL,
  day_off_type INT NOT NULL DEFAULT 1,
  comment      VARCHAR(255) DEFAULT '',
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Seed demo users
INSERT INTO users (user_mail) VALUES
  ('alice@example.com'),
  ('bob@example.com');

-- Seed demo events
INSERT INTO day_offs (user_id, date_occur, day_off_type, comment) VALUES
  (1, CURDATE(),                   2, ' PTO'),
  (2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 5, ' Sick'),
  (1, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, ' Conf');
