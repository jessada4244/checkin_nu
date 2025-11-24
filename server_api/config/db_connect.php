<?php
header("Access-Control-Allow-Origin: *"); // อนุญาตให้ Flutter Web/App เข้าถึงได้
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

$servername = "localhost";
$username = "root"; // Default ของ XAMPP/MAMP
$password = ""; // MAMP ใช้ "root", XAMPP ใช้ "" (ค่าว่าง)
$dbname = "checkin_classroom";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    // echo "Connected successfully"; 
} catch(PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $e->getMessage()]);
    exit();
}
?>