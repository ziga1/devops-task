<?php
// If caller didn't pass start/end, pick a default window so smoke tests pass.
if (!isset($_GET['start']) || !isset($_GET['end'])) {
  $_GET['start'] = date('Y-m-d', strtotime('-7 days'));
  $_GET['end']   = date('Y-m-d', strtotime('+30 days'));
}
require __DIR__ . '/get_events.php';
