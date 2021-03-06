$wc = new-object net.webclient
#Downloads zip for who_is_active 10.0 from sqlblog.com
$wc.DownloadFile("http://sqlblog.com/files/folders/29675/download.aspx", "c:\temp\WhoIsActive.zip")
 
#UnZips the file to C:\Temp
$shellApplication = new-object -com shell.application
            $zipPackage = $shellApplication.NameSpace("c:\temp\WhoIsActive.zip")
            $destinationFolder = $shellApplication.NameSpace("c:\temp\")
            $file = $zipPackage.Items() | SELECT Name
            $destinationFolder.CopyHere($zipPackage.Items())
$DeployFile = $(resolve-path "c:\temp\$($file.Name)").path

# Loops through Registered SQL Severs and applys WhoIsActive
foreach ($RegisteredSQLs in dir -recurse SQLSERVER:\SQLRegistration\'Database Engine Server Group'\Development\ | where {$_.Mode -ne "d"} ) 
{ 
"Deploying to "+ $RegisteredSQLs.ServerName;
invoke-sqlcmd -InputFile $DeployFile -ServerInstance $RegisteredSQLs.ServerName -database master `
}
