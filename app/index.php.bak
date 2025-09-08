<?php
$dbHost = getenv('DB_HOST') ?: '127.0.0.1';
$dbName = getenv('DB_NAME') ?: 'appdb';
$dbUser = getenv('DB_USER') ?: 'appuser';
$dbPass = getenv('DB_PASS') ?: 'apppass';

$appTitle = getenv('APP_TITLE') ?: "DefaultApp";

echo "<h1>Hello</h1>";
echo "<p>App title from ENV: " . htmlspecialchars($appTitle) . "</p>";

// Try to connect to DB
try {
    $dsn = "mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4";
    $pdo = new PDO($dsn, $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    echo "<h2>Events</h2>";
    echo "<table border='1' cellpadding='5'><tr><th>ID</th><th>Title</th><th>Starts</th><th>Ends</th></tr>";

    $stmt = $pdo->query("SELECT id, title, starts_at, ends_at FROM events ORDER BY starts_at");
    foreach ($stmt as $row) {
        echo "<tr>";
        echo "<td>" . htmlspecialchars($row['id']) . "</td>";
        echo "<td>" . htmlspecialchars($row['title']) . "</td>";
        echo "<td>" . htmlspecialchars($row['starts_at']) . "</td>";
        echo "<td>" . htmlspecialchars($row['ends_at']) . "</td>";
        echo "</tr>";
    }
    echo "</table>";

} catch (Exception $e) {
    echo "<p style='color:red'>DB connection failed: " . htmlspecialchars($e->getMessage()) . "</p>";
}
?>
