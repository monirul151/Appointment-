<?php
require_once __DIR__ . '/../config/database.php';

class AdminModel {
    private $conn;

    public function __construct() {
        $db = new DBConnection();
        $this->conn = $db->connect();
    }

    public function addSpecialization($name, $description) {
        $stmt = $this->conn->prepare('INSERT INTO specializations (name, description) VALUES (?, ?)');
        $stmt->bind_param('ss', $name, $description);
        return $stmt->execute();
    }

    public function updateSpecialization($id, $name, $description) {
        $stmt = $this->conn->prepare('UPDATE specializations SET name = ?, description = ? WHERE id = ?');
        $stmt->bind_param('ssi', $name, $description, $id);
        return $stmt->execute();
    }

    public function deleteSpecialization($id) {
        $stmt = $this->conn->prepare('DELETE FROM specializations WHERE id = ?');
        $stmt->bind_param('i', $id);
        return $stmt->execute();
    }

    public function settings() {
        $stmt = $this->conn->prepare('SELECT setting_key, setting_value FROM settings');
        $stmt->execute();
        $rows = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        $data = [];
        foreach ($rows as $row) {
            $data[$row['setting_key']] = $row['setting_value'];
        }
        return $data;
    }

    public function saveSetting($key, $value) {
        $stmt = $this->conn->prepare('INSERT INTO settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)');
        $stmt->bind_param('ss', $key, $value);
        return $stmt->execute();
    }
}
?>
