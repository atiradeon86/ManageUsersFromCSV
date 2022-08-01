#Import-Module Kell hozzá, hogy Get-Help-el elérhető legyen
#Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.
Function CreateUsersFromCsv {
	

[CmdletBinding()]
param (

   
)

BEGIN { 
     #DataSOurce
     $csvFile = "users.csv"
      
}
PROCESS {  

        #Csv Import     
        #$data = Import-Csv $csvFile
       
       #Import and execute commands with pipeline
       Import-Csv $csvFile |ForEach-Object{

                $FullNames = $_.FullName
                $Descriptions = $_.Description
                $Names = $_.Name
                if ($Names -ne "") {
                    New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames -NoPassword
                    #Write-Host $Fullnames
                
                }
                #Remove Command
                #Remove-LocalUser -Name $Names

       }
        
}        
END { 
    #Debug ShowData
    #$Names;
    #$FullNames;
    #$Descriptions
}
}
