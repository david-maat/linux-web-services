<?php
$servername = getenv('MYSQL_HOST');
$username = getenv('MYSQL_USER');
$password = getenv('MYSQL_PASSWORD');
$dbname = getenv('MYSQL_DATABASE');

// Get container hostname
$hostname = gethostname();

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT name FROM users LIMIT 1";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    // Output data of each row
    $row = $result->fetch_assoc();
    echo "<h1>" . $row['name'] . " has reached Milestone 1!!</h1>";
    echo "<h2>Served by container: " . $hostname . "</h2>";
} else {
    echo "No records found.";
}

$conn->close();
?>


