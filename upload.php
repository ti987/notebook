<?php
// Initialize the session
session_start();
 
// Check if the user is logged in, if not then redirect him to login page
if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true){
    header("location: auth/login.php");
    exit;
}

$errors = false;
   if(isset($_FILES['image'])){
      $file_name = $_FILES['image']['name'];
      $file_size = $_FILES['image']['size'];
      $file_tmp = $_FILES['image']['tmp_name'];
      $file_type = $_FILES['image']['type'];
      $file_ext=strtolower(end(explode('.',$_FILES['image']['name'])));
      
      $expensions= array("jpeg","jpg","png", "svg", "docx", "xls", "xlsm", "tbz", "tgz");
      
      if(in_array($file_ext,$expensions)=== false){
         $errors="extension not allowed, please choose a SVG, JPEG, or PNG file.";
      }
      
      if($errors == false) {
         move_uploaded_file($file_tmp,"images/".$file_name);
         echo '<head>';
         echo '<meta http-equiv="refresh" content="7" url="index.php" />';
         echo '</head>';
         echo "Success";
      }else{
         print_r($errors);
      }
   }
?>
<html>
   <body>
      
      <form action = "" method = "POST" enctype = "multipart/form-data">
         <input type = "file" name = "image" />
         <input type = "submit"/>
            
         <ul>
            <li>Sent file: <?php echo $_FILES['image']['name'];  ?>
            <li>File size: <?php echo $_FILES['image']['size'];  ?>
            <li>File type: <?php echo $_FILES['image']['type'] ?>
         </ul>
            
      </form>

     <a href="./index.php" class="menu_button" ><button> Home </button></a>

   </body>
</html>
