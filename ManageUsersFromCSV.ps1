
#Import-Module Kell hozzá, hogy Get-Help-el elérhető legyen
#Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.
#VsCode esetén a helyes ékezetek megjelenítéséhez UTF-8 BOM a helyes beállítás

   


    
Function ManageUsersFromCsv {

<#

.DESCRIPTION
Felhasználók csoportos létrehozása, ill. törlése CSV fájlból

.SYNOPSIS
Felhasználók csoportos létrehozása, ill. törlése egy külső (users.csv) fájlból vett adatok alapján, Csoport elnevézs hozzáfúzése a Description értékhez

.NOTES
-Paraméter megadása nélkül is kétrehozásra kerülnek a felhasználk, ez esetben jelszó nélkül
-Import-Module Kell hozzá, hogy Get-Help-el elérhető legyen
-Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.
-VsCode esetén a helyes ékezetek megjelenítéséhez UTF-8 BOM a helyes beállítás
-Segítség a jelszó kipróbáláshoz ha a pw kapcsolót is használjuk. PL. CMD -> runas /user:minta1 regedit




.PARAMETER pw
- Értéke lehet a csv  -> Felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

.PARAMETER prompt
- Értéke lehet a prompt  -> Felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

.PARAMETER cmd
- Értéke lehet a del -> Felhasználók törlése a users.csv fájl alapján  -<


.EXAMPLE
 ManageUsersFromCSV -> Felhasználók létrehozása a  users.csv fájlból jelszó nélkül <- 

 .EXAMPLE
 ManageUsersFromCSV -pw csv -> Felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

 .EXAMPLE
 ManageUsersFromCSV -pw prompt -> Felhasználók létrehozás a users.csv fájl adatai alapján jelszó bekérésével <- 

 .EXAMPLE
 ManageUsersFromCSV -cmd del -> Felhasználók törlése a users.csv fájl alapján <- 

#>
	

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
                $Groups = $_.Group

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
                
                 #Organization hozzáfűzése

                #Saját verzió

                #$Description_update = $Groups + " " + $Descriptions;
                #Write-Host $Description_update
                #Set-LocalUser -Name $Names -Description $Description_update
                
                #Switch verzió

                $DescriptionUpdate = $Groups

                Switch($DescriptionUpdate) {
                    "FO" {
                        $DescriptionUpdate ="Front Office"
                    }
                    "BO" {
                        $DescriptionUpdate ="Back Office"
                    }
                    "GY" {
                        $DescriptionUpdate ="Gyártás"
                    }
                    "GOD" {
                        $DescriptionUpdate ="... Bryan ..."
                    }
                }
               
                $Descriptions = $DescriptionUpdate + " " + $Descriptions;
                Set-LocalUser -Name $Names -Description $Descriptions
            
            }
        
    

        }    
        


END { 
   


}

}

