<?php
require_once __DIR__ . '/../../includes/auth-check.php';
require_login('admin');
require_once __DIR__ . '/../../model/UserModel.php';
$data = request_data();
$model = new UserModel();
$ok = $model->toggleStatus((int)($data['user_id'] ?? 0));
json_response(['success' => $ok, 'message' => $ok ? 'User status changed.' : 'Status change failed.']);
?>
