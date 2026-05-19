<?php
require_once __DIR__ . '/../../includes/auth-check.php';
require_login('admin');
require_once __DIR__ . '/../../model/UserModel.php';
$data = request_data();
$model = new UserModel();
$ok = $model->deleteUser((int)($data['user_id'] ?? 0));
json_response(['success' => $ok, 'message' => $ok ? 'User deleted.' : 'Delete failed.']);
?>
