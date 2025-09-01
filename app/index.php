<?php
// Read ENV variable APP_TITLE (with fallback if not set)
$appTitle = getenv('APP_TITLE') ?: "DefaultApp";

echo "<h1>Hello</h1>";
echo "<p>App title from ENV: " . htmlspecialchars($appTitle) . "</p>";
?>
