#Import-Module Kell hozz�, hogy Get-Help-el el�rhet? legyen
#Hasznos a -force kapcol� ha friss�tett�k, hogy bet�ltse a v�ltoztat�sokat is.
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
                    #Write-Host $Fullnames
                    
                    if ($FullNames -eq "") {
                        
                        #Ha nincs teljes n�v, kieg�sz�t�s
                        $Fullnames = "Automat: $Names"
                        $Descriptions = "Hi�nyos adat"
                    }

                New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames -NoPassword
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
