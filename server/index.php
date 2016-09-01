<?php
//$link = mysql_connect('mysql.4s2.ru', "u602543626_admin", "7651523252");
$link = mysql_connect('localhost', "root", "7651523252");
if (!$link)
    echo "ERROR ".mysql_errno()." ".mysql_error()."\n";
//else
//    echo "Success";
mysql_select_db("u602543626_db", $link) or die("Fail to select DB");

$q = mysql_query('SELECT * FROM users WHERE soc_id=\'$_GET["id"]\'');
if (mysql_num_rows($q) == 0)
{
    //mysql_query('INSERT INTO users (last_login) VALUES ("2016-03-11")');
    echo "Add";
}




$user['a'] = 123;
echo json_encode($user);
?>