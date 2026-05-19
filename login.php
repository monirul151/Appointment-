<?php
require_once __DIR__ . '/controller/AuthController.php';
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $controller = new AuthController();
    $error = $controller->login($_POST['email'] ?? '', $_POST['password'] ?? '');
}
include __DIR__ . '/view/auth/login.php';
?>
