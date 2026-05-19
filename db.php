<?php
// db.php

class DBConnection {
    private $host = 'localhost';
    private $username = 'root';
    private $password = '';
    private $db_name = 'hospital_db';   

    public function connect() {
        $conn = new mysqli($this->host, $this->username, $this->password, $this->db_name);
        
        if ($conn->connect_error) {
            die("Connection unsuccessful: " . $conn->connect_error);
        }
        
        $conn->set_charset("utf8mb4");
        return $conn;
    }
}
?>