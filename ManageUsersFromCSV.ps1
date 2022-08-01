Function ManageUsersFromCsv {

<#

.DESCRIPTION
Helyi felhasználók csoportos létrehozása, ill. törlése CSV fájlból

.SYNOPSIS
Helyi felhasználók csoportos létrehozása, ill. törlése egy külső (users.csv) fájlból vett adatok alapján, Csoport elnevézs hozzáfúzése a Description értékhez

.NOTES
-Import-Module Kell hozzá, hogy elérhető legyen (Import-Module -force .\ManageUsersFromCSV.ps1)
-Users.scv fájl szükséges
-Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.

-Paraméter megadása nélkül is létrehozásra kerülnek a felhasználók, ez esetben jelszó nélkül

-VsCode esetén a helyes ékezetek megjelenítéséhez UTF-8 BOM a helyes beállítás
-Segítség a jelszó kipróbáláshoz ha a pw kapcsolót is használjuk. PL. CMD -> runas /user:minta1 regedit


.PARAMETER pw
- Értéke lehet a csv  -> Helyi felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

.PARAMETER prompt
- Értéke lehet a prompt  -> Helyi felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

.PARAMETER cmd
- Értéke lehet a del -> Helyi felhasználók törlése a users.csv fájl alapján  -<


.EXAMPLE
 ManageUsersFromCSV -> Helyi felhasználók létrehozása a  users.csv fájlból jelszó nélkül <- 

 .EXAMPLE
 ManageUsersFromCSV -pw csv -> Helyi felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

 .EXAMPLE
 ManageUsersFromCSV -pw prompt -> Helyi felhasználók létrehozás a users.csv fájl adatai alapján jelszó bekérésével <- 

 .EXAMPLE
 ManageUsersFromCSV -cmd del -> Helyi felhasználók törlése a users.csv fájl alapján <- 

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

                ## Ha törölni akarunk
                if ($cmd -eq "del") {
                    Remove-LocalUser -Name $Names
                    Write-Host "Törölt felhasználó: $Names"
                } 

                #Egyébként
                else {

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

                        }  
                         #Ha nem adunk meg beállítást, alapból jelszó nélkül hozzuk létre
                        else {
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

