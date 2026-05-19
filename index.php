<?php
require_once __DIR__ . '/includes/functions.php';
if (!isset($_SESSION['user'])) {
    redirect_to('login.php');
}
$role = $_SESSION['user']['role'];
if ($role === 'doctor') redirect_to('view/doctor/dashboard.php');
if ($role === 'patient') redirect_to('view/patient/dashboard.php');
if ($role === 'receptionist') redirect_to('view/receptionist/dashboard.php');
if ($role === 'admin') redirect_to('view/admin/dashboard.php');
redirect_to('login.php');
?>
