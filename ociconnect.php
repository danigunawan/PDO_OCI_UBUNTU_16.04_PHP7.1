<?php
        $db = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SID=opc)))" ;

        if($c = OCILogon("yourusernamedb", "yourpasswordb", $db))
        {
            echo "Successfully connected to Oracle.\n";
            OCILogoff($c);
        }
        else
        {
            $err = OCIError();
            echo "Connection failed." . $err[text];
        }
?>