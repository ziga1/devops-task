<?php
header('Content-Type: application/json; charset=utf-8');

// FullCalendar calls ?start=YYYY-MM-DD&end=YYYY-MM-DD
if (!isset($_GET['start'], $_GET['end'])) {
  echo json_encode([]);
  exit;
}

require __DIR__ . '/config.php';
$db = pdo_conn();

$sql = "
  SELECT d.day_off_id, d.user_id, d.date_occur, d.day_off_type, d.comment,
         u.user_mail
  FROM day_offs d
  LEFT JOIN users u ON u.user_id = d.user_id
  WHERE d.date_occur BETWEEN ? AND ?
  ORDER BY d.date_occur
";

$start = date('Y-m-d', strtotime($_GET['start']));
$end   = date('Y-m-d', strtotime($_GET['end']));

$rows = getSet($db, $sql, [$start, $end]);

$colors = [
  1 => '#9B26AF', 2 => '#2095F2', 3 => '#009587',
  4 => '#FE5621', 5 => '#5CB85C', 6 => '#FEEA3A',
  7 => '#785447', 8 => '#5F7C8A', 9 => '#212121'
];

$events = [];
foreach ($rows as $r) {
  $color = $colors[(int)$r['day_off_type']] ?? '#212121';
  $events[] = [
    'id'     => (int)$r['day_off_id'],
    'title'  => ($r['user_mail'] ?? '') . ($r['comment'] ?? ''),
    'color'  => $color,
    'allDay' => true,
    'start'  => date('c', strtotime($r['date_occur'] . ' 00:00:00')),
  ];
}

echo json_encode($events, JSON_UNESCAPED_UNICODE);
