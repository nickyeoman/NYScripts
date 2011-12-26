<?php
/**
* SHA1 for command line
* v1.0
* Last Updated Dec 25, 2011
* 
* Description:
* Used to reset a sha1 in a database to recover a password
* I also use it to generate strong passwords
**/

$username = strtolower($argv[1]);
$password = $argv[2];
$salt = $argv[3];
$varname = sha1($username . $password . $salt);
echo $varname;
?>
