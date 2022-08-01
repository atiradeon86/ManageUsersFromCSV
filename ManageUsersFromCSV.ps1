Function ManageUsersFromCsv {
    
<#

.DESCRIPTION
Helyi felhasználók csoportos létrehozása, ill. törlése CSV fájlból

.SYNOPSIS
Helyi felhasználók csoportos létrehozása, ill. törlése egy külső (users.csv) fájlból vett adatok alapján, Csoport elnevézs hozzáfúzése a Description értékhez

.NOTES
-Import-Module Kell hozzá, hogy elérhető legyen (Import-Module -force .\ManageUsersFromCSV.ps1)
-Users.csv fájl szükséges
-Hasznos a -force kapcoló ha frissítettük, hogy betöltse a változtatásokat is.

-Paraméter megadása nélkül is létrehozásra kerülnek a felhasználók, ez esetben jelszó nélkül

-VsCode esetén a helyes ékezetek megjelenítéséhez UTF-8 BOM a helyes beállítás
-Segítség a jelszó kipróbáláshoz ha a pw kapcssolót is használjuk. PL. CMD -> runas /user:minta1 regedit


.PARAMETER pw csv
- Értéke lehet a csv  -> Helyi felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

.PARAMETER pw prompt
- Értéke lehet a prompt  -> Helyi felhasználók létrehozása a users.csv fájl alapján, jelszó manuális bevitelével <- 

.PARAMETER NeverExpire
- Értéke lehet a NeverExpire  -> A jelszó nem jár le <- 

.PARAMETER cmd del
- Értéke lehet a del -> Helyi felhasználók törlése a users.csv fájl alapján  -<

.PARAMETER cmd CreateDemoCsv
- Létrehoz egy Demo.csv fájlt az aktuális adatok alapján

.EXAMPLE
 ManageUsersFromCSV -cmd CreateDemoCsv -> Létrehoz az aktuiális adatok alapján egy Demo.csv fájlt. Értelme igazából nem sok, mert nyilván a meglévőt nem akarjuk importálni, az élesben használtat pedig nem fogjuk törölni <- 

.EXAMPLE
 ManageUsersFromCSV -> Helyi felhasználók létrehozása a  users.csv fájlból jelszó nélkül <- 

 .EXAMPLE
 ManageUsersFromCSV -pw csv -> Helyi felhasználók létrehozása a users.csv fájlban lévő jelszavakkal <- 

 .EXAMPLE
 ManageUsersFromCSV -pw prompt -> Helyi felhasználók létrehozás a users.csv fájl adatai alapján jelszó bekérésével <- 

 .EXAMPLE
 ManageUsersFromCSV -cmd del -> Helyi felhasználók törlése a users.csv fájl alapján <- 

 .EXAMPLE
 ManageUsersFromCSV -pw csv -NeverExpire $true -> Helyi felhasználók létrehozás a users.csv fájl adatai alapján - A jelszó nem jár le attribútummal <- 

 .EXAMPLE
 ManageUsersFromCSV -pw prompt -NeverExpire $true -> Helyi felhasználók létrehozás a users.csv fájl adatai alapján - A jelszó nem jár le attribútummal <- 
#>
	

[CmdletBinding()]
param (

    [Parameter(Mandatory=$false,
    HelpMessage="pw -> csv, prompt, no ")] 
    [string]$pw,

    [Parameter(Mandatory=$false,
    HelpMessage="Del ")] 
    [string]$cmd,

    [Parameter(Mandatory=$false,
    HelpMessage="1")] 
    [bool]$NeverExpire = $false
   
)

BEGIN { 

     #DataSOurce
     $csvFile = "users.csv"
      
}

PROCESS {  
       
       #Esetleges hibaüzenetek, figyelmeztetések elrejtése - > tudom nem szép, lehet hibakezelést is de itt nem volt feladat
       $ErrorActionPreference = "SilentlyContinue"
       #Importálás, és parancsok végrehajtása a kívánt logika szerint
       Import-Csv $csvFile | ForEach-Object {

                #Adatok
                $FullNames = $_.FullName
                $Descriptions = $_.Description
                $Names = $_.Name
                $Groups = $_.ObjectClass

                #A jelszó paraméter működéséhez szükséges a sima string konvertálása
                $Passwords = $_.Password
                $SecurePasswords  = ConvertTo-SecureString -String $Passwords -AsPlainText -Force

                ## Ha törölni akarunk
                if ($cmd -eq "del") {
                    Remove-LocalUser -Name $Names
                    Write-Host "Törölt felhasználó: $Names"
                } 

                elseif ($cmd -eq "CreateDemoCsv") {
                    $file ="Demo.csv"
                    if (-not (Get-Item $file)) {
                        Get-LocalUser | Export-CSV Demo.csv
                    }
                    
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

                            #Adatok módosítása ha -PasswordNeverExpires értéke true
                            if ($NeverExpire -EQ $true ) {
                                Set-LocalUser -Name $Names -PasswordNeverExpires $true
                            }
                            
                        } 

                        #Ha bekérjük a felhasználók adatait
                        elseif ($pw -eq "prompt") {
                            #Jelszó Bekérése
                            Write-Host "$Names Password:"
                            $SecurePassword = Read-Host -AsSecureString
                            New-LocalUser -Name $Names -Description $Descriptions -FullName $Fullnames  -Password $SecurePassword

                            #Adatok módosítása ha -PasswordNeverExpires értéke true
                            if ($NeverExpire -EQ $true ) {
                                Set-LocalUser -Name $Names -PasswordNeverExpires $true
                            }

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
    #Get-LocalUser | példák | html kimenet demo

    Get-LocalUser | Where-Object -Property Enabled -NE $false | Select-Object Name,Sid,Enabled

    Get-LocalUser | Where-Object -Property Enabled -EQ $true | Sort-Object -Property Name,Sid | Select-Object Name,Enabled,Description -Last 2 |FL

    Get-LocalUser | Where-Object -Property Enabled -NE $false | Sort-Object -Property Name,Sid | Select-Object -Last 1 |FL

    Get-LocalUser | Where-Object -Property Enabled -EQ $true | Select-Object Name,Description | Sort-Object -Property Name -Descending | Format-List |FL

    Get-LocalUser | Select-Object Name,Enabled | Where-Object -Property Name -like 'minta*'  | Format-Table 

    Get-LocalUser | Where-Object -Property Description -like '*hiányos*' | Select-Object name,enabled | Sort-Object -Property Name -Descending |FL

    Get-LocalUser | Where-Object -Property Description -like '*Front*' | Select-Object name,enabled,sid ,Description | Sort-Object -Property Description |  ConvertTo-Html | Out-File -FilePath Front-Office.html           
}

}

