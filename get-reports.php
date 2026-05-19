<?php
require_once __DIR__ . '/../../includes/auth-check.php';
require_login('admin');
require_once __DIR__ . '/../../model/ReportModel.php';
$model = new ReportModel();
json_response(['success' => true, 'revenue' => $model->revenueReport(), 'volume' => $model->appointmentVolumeReport()]);
?>
