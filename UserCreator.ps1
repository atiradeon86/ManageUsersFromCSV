#Import-Module Kell hozzá, hogy Get-Help-el elérhető legyen
#Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.
#VsCode esetén a helyes ékezetek megjelenítéséhez UTF-8 BOM a helyes beállítás

    #Csv Import példa     
    #$data = Import-Csv $csvFile

    #Létrehozás alapból jelszó nélkül: CreateUsersFromCSV
    #Létrehozás CSV fájlban lévő jelszavakkal: CreateUsersFromCSV -pw csv
    #Létrehozás jelszó bekérésével: CreateUsersFromCSV -pw prompt
    #A csv fájl alapján a felhasználók törlése: CreateUsersFromCSV -cmd del

Function CreateUsersFromCsv {
	

[CmdletBinding()]
param (

    [Parameter(Mandatory=$false,
    HelpMessage="pw -> csv, prompt, no ")] 
    [string]$pw,

    [Parameter(Mandatory=$false,
    HelpMessage="Del ")] 
    [string]$cmd
   
)

BEGIN { 

     #DataSOurce
     $csvFile = "users.csv"
      
}

PROCESS {  
       
       #Importálás, és parancsok végrehajtása a kívánt logika szerint
       Import-Csv $csvFile | ForEach-Object {

                #Adatok
                $FullNames = $_.FullName
                $Descriptions = $_.Description
                $Names = $_.Name

                #A jelszó paraméter működéséhez szükséges a sima string konvertálása
                $Passwords = $_.Password
                $SecurePasswords  = ConvertTo-SecureString -String $Passwords -AsPlainText -Force

                if ($cmd -eq "del") {
                    Remove-LocalUser -Name $Names
                    Write-Host "Törölt felhasználó: $Names"
                } else {
                    #Ha a felhasználónév nem üres
                    if ($Names -ne "") {
                        
                        #Ha nincs teljes név, kiegészítés
                        if ($FullNames -eq "") {     
                            
                            $Fullnames = "Automat: $Names"
                            $Descriptions = "Hiányos adat"
                        }

                        #Ha csv fájlból importáljuk a jelszavakat 
                        if ($pw -eq "csv") {  
                            New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames -Password $SecurePasswords
                        } 
                        #Ha bekérjük a felhasználók adatait
                        elseif ($pw -eq "prompt") {
                            #Jelszó Bekérése
                            Write-Host "$Names Password:"
                            $SecurePassword = Read-Host -AsSecureString
                            New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames  -Password $SecurePassword

                        }  else {
                            #Ha nem adunk meg beállítást, alapból jelszó nélkül hozzuk létre
                            New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames -NoPassword
                        }
                    }
                }
                
       }
        
}     

END { 

}

}
