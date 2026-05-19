<?php
require_once __DIR__ . '/controller/AuthController.php';
$error = '';
$success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $controller = new AuthController();
    $error = $controller->registerPatient($_POST);
    if ($error === '') {
        $success = 'Registration successful. You can log in now.';
    }
}
include __DIR__ . '/view/auth/register.php';
?>
