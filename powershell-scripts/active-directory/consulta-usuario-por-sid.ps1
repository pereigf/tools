$SID = "S-1-5-21-4143994516-4084414367-4262529727-70599"
Get-ADObject -IncludeDeletedObjects -Filter * -Properties * | where{$_.objectSid -eq $SID}