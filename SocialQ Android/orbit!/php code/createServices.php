<?php

/*
 * Following code will get single product details
 * A product is identified by product id (pid)
 */
$comments = "Comments: ";
$category = 'Services';
$response = array();
if (isset($_POST['username'])&&isset($_POST['title'])&&isset($_POST['cost'])&&isset($_POST['notes'])&&isset($_POST['school'])) {
    $username = $_POST['username'];
    $cost = $_POST['cost'];
    $school = $_POST['school'];
    $notes = $_POST['notes'];
    $title = $_POST['title'];

    // include db connect class
    require_once __DIR__ . '/db_connect.php';
    try{
        // connecting to db
        $con = new DB_CONNECT();
        $db = $con->connect();
        $checkAct = $db->prepare("SELECT * FROM service WHERE username = :username AND title = :title AND price = :cost AND notes = :notes AND school = :school");
        $checkAct->bindParam(":username", $username);
        $checkAct->bindParam(":cost", $cost);
        $checkAct->bindParam(":school", $school);
        $checkAct->bindParam(":notes", $notes);
        $checkAct->bindParam(":title", $title);
        $checkAct->execute();
        if ($checkAct->rowCount() > 0) {
            // successfully inserted into database
            $responses["success"] = 0;
            $responses["message"] = "This post already exists, you can not create an exactly the same one";
            // echoing JSON response
            echo json_encode($responses);
        }
        else{
            $result = $db->prepare("INSERT INTO service(title, price, notes, comments, username, school) VALUES(:title, :cost, :notes, :comments, :username, :school)");
            // binding parameters for mysql insertion
            $result->bindParam(":username", $username);
            $result->bindParam(":title", $title);
            $result->bindParam(":school", $school);
            $result->bindParam(":cost", $cost);
            $result->bindParam(":notes", $notes);
            $result->bindParam(":comments", $comments);
            // mysql inserting a new row with prepared and binded statements
            $result->execute();
            if (!empty($result)) {
                // check for empty result
                if ($result->rowCount() > 0) {
                    // successfully inserted into database
                    // echoing JSON response
                    $result = $db->prepare("INSERT INTO allposts(category, price, notes, comments, username, title, school) VALUES(:category, :cost, :notes, :comments, :username, :title, :school)");
                    // binding parameters for mysql insertion
                    $result->bindParam(":category", $category);
                    $result->bindParam(":username", $username);
                    $result->bindParam(":cost", $cost);
                    $result->bindParam(":school", $school);
                    $result->bindParam(":title", $title);
                    $result->bindParam(":comments", $comments);
                    $result->bindParam(":notes", $notes);
                    // mysql inserting a new row with prepared and binded statements
                    $result->execute();
                    if (!empty($result)) {
                        // check for empty result
                        if ($result->rowCount() > 0) {
                            // successfully inserted into database
                            $response["success"] = 1;
                            $response["message"] = "post successfully created";
                            // echoing JSON response
                            echo json_encode($response);
                        }
                        else{
                            $response["success"] = 0;
                            $response["message"] = "Oops! An error occurred.";
                            
                            // echoing JSON response
                            echo json_encode($response);
                        }
                    }
                    else {
                        // failed to insert row
                        $response["success"] = 0;
                        $response["message"] = "Oops! An error occurred.";
                        
                        // echoing JSON response
                        echo json_encode($response);
                    }
                }
                else{
                    $response["success"] = 0;
                    $response["message"] = "Oops! An error occurred.";
                    
                    // echoing JSON response
                    echo json_encode($response);
                }
            }
            else {
                // failed to insert row
                $response["success"] = 0;
                $response["message"] = "Oops! An error occurred.";
                
                // echoing JSON response
                echo json_encode($response);
            }
        } 
    }
    catch (PDOException $e){
        print "Sorry, a database error occurred. Please try again later.\n";
        print $e->getMessage();
    }
} else {
    // required field is missing
    $response["success"] = 0;
    $response["message"] = "Required field(s) is missing";
    // echoing JSON response
    echo json_encode($response);
}
?>