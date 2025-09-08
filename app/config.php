<?php
// config.php — ENV-driven MySQL (PDO)
function pdo_conn(): PDO {
  $host = getenv('DB_HOST') ?: 'devdb';
  $db   = getenv('DB_NAME') ?: 'appdb';
  $user = getenv('DB_USER') ?: 'appuser';
  $pass = getenv('DB_PASS') ?: 'apppass';

  $dsn = "mysql:host={$host};dbname={$db};charset=utf8mb4";
  $pdo = new PDO($dsn, $user, $pass, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  ]);
  return $pdo;
}

function getSet(PDO $db, string $sql, array $params = []) {
  $st = $db->prepare($sql);
  $st->execute($params);
  return $st->fetchAll();
}

function execSQL(PDO $db, string $sql, array $params = []) {
  $st = $db->prepare($sql);
  $st->execute($params);
  return $st->rowCount();
}
