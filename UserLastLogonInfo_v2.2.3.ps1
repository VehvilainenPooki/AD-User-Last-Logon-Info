##### Author: Pooki Vehviläinen
##################
#--------Config
##################
#####

$domain = "<laita domain tähän>"

#####
##################
#--------Main
##################
#####

import-module activedirectory -ErrorAction Stop

cls
'Get_User_Logon_info_v2.2.3.ps1' 
'Date format dd/MM/yyyy HH:mm:ss'
''

"The domain is " + $domain

#Haetaan DomainControllerit
$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$domaincontrollers = $myforest.Sites | % { $_.Servers } | Select Name
$RealUserLastLogon = $null
$LastusedDC = $null
$domainsuffix = "*."+$domain

<# Käytä tätä, jos haluat määrätä miltä domain controllereilta etsitään.

$domaincontrollers = @("DomainController1","DomainController2","DomainController3")
$RealUserLastLogon = $null
$LastusedDC = $null
$domainsuffix = "*."+$domain
#>



#######
#Main loop
#######
''
"Give User AccountName (`"exit`" Closes window)"

while ($true) {

    $samaccountname = Read-Host ">"

    #
    if ($samaccountname -eq "exit") {
        exit 
    }
    if ($samaccountname -eq "cls") {
        cls
        continue 
    }
    if ($samaccountname -eq "Olen omena!") {
        Write-Host "      _         ,..`n ,--._\\_.--, (-00)`n; #         _:(  -)`n:          (_____/ `n:            :     `n '.___..___.'      `n" -ForegroundColor Red
        continue
    }

    try {
        #Käyttäjän tiedon haku domain Controllereilta käyttäjätunnuksella
        $RealUserLastLogon = $null
        
        foreach ($DomainController in $DomainControllers) {

	        if ($DomainController -like $domainsuffix ) {

                try {
		            $UserLastlogon = Get-ADUser -Identity $samaccountname -Properties LastLogon -Server $DomainController -ErrorAction Stop
                }  Catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException]{
                    #Ohitetaan, koska on mahdollista, että domain controllerille ei ole tietoa käyttäjästä.

                } Catch [Microsoft.ActiveDirectory.Management.Commands.GetADUser] {

                    #Domain controlleriin ei saada yhteyttä.
                    Write-Host -NoNewline "Ei yhteyttä: "
                } Catch {
                    raise
                }

                Write-Host $DomainController
                
		        if ($RealUserLastLogon -le [DateTime]::FromFileTime($UserLastlogon.LastLogon)) {

			        $RealUserLastLogon = [DateTime]::FromFileTime($UserLastlogon.LastLogon)
			        $LastusedDC =  $DomainController
		        }

	        }

        }

        #Tarkistetaan löytyikö käyttäjä
        if ($UserLastlogon -eq $null) {
            Write-Host "`nUser account not found.`n"<#$_#>
        } else  {

            #Datan formationti
            $RealUserLastLogon = $RealUserLastLogon.ToString("dd'/'MM'/'yyyy HH:mm:ss")

            if ($RealUserLastLogon -eq "01/01/1601 02:00:00") {
                $RealUserLastLogon = "New account"
            }


            $password = get-aduser -Identity $samaccountname -Properties PasswordLastSet
            $password = $password | Select -ExpandProperty PasswordLastSet
            if ($password -ne $null) {
                $password = $password.ToString("dd'/'MM'/'yyyy HH:mm:ss")
            }


            $AccountExpired = Get-ADUser -Identity $samaccountname -Properties accountExpirationDate
            $AccountExpired = $AccountExpired | Select -ExpandProperty accountExpirationDate
            if ($AccountExpired -ne $null) {
                $AccountExpired = $AccountExpired.ToString("dd'/'MM'/'yyyy HH:mm:ss")
            }


            $passwordEB = get-aduser -Identity $samaccountname -Properties PasswordExpired
            $passwordEB = $passwordEB | Select -ExpandProperty PasswordExpired
        

            $passwordB = get-aduser -Identity $samaccountname -Properties Passwordneverexpires
            $passwordB = $passwordB | Select -ExpandProperty Passwordneverexpires

            if (!$passwordB) {
                $PSTime = Get-ADUser -Identity $samaccountname –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" 
                $PSTime = $PSTime | Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
                $PSTime = $PSTime | Select -ExpandProperty "ExpiryDate"
                $PSTime = $PSTime.ToString("dd'/'MM'/'yyyy HH:mm:ss")
                if ($PSTime -eq "01/01/1601 02:00:00") {
                    $PSTime = ""
                }
            } else {
                $PSTime = ""
            }


            #Taulukon luonti
            $table = new-object psobject -Property @{
                name = "$samaccountname "
                LastLogon = "$RealUserLastLogon "
                PasswordLastSet = "$password "
                PasswordExpiryDate = "$PSTime "
                accountExpirationDate = "$AccountExpired "
                PwExpired = $passwordEB
                PwNeverExpires = $passwordB

            }

            #Taulukon kirjoitus
            $e = [char]27
            $table | fl Name, LastLogon, PasswordLastSet, @{
                Label = "PasswordExpiryDate"
                Expression = {
                    if ($_.PasswordExpiryDate -eq $null) {
                        ""
                    } else {
                        $color = 0
                        $date = Get-Date
                        $comp =  $_.PasswordExpiryDate
                        $dcomp = Get-Date $comp
                        if ($date -gt $dcomp) {
                            $color = 31

                        } elseif ($date -gt $dcomp.AddDays(-14)) {
                            $color = 93
                        }
                        "$e[${color}m$($comp)${e}[0m"

                    }
                }

            }, @{
                Label = "accountExpirationDate"
                Expression = {
                    if ($_.accountExpirationDate -eq $null) {
                        ""
                    } else {
                        $color = 0
                        $date = Get-Date
                        $comp =  $_.accountExpirationDate
                        $dcomp = Get-Date $comp
                        if ($date -gt $dcomp) {
                            $color = 31

                        } elseif ($date -gt $dcomp.AddDays(-14)) {
                            $color = 93
                        }
                        "$e[${color}m$($comp)${e}[0m"

                    }
                }

            }, @{
                Label = "PwExpired"
                Expression = {

                    $color = 0
                    if ($_.PwExpired) {
                        $color = 7
                    }

                   "$e[${color}m$($_.PwExpired)${e}[0m"
                }

             }, @{
                Label = "PwNeverExpires"
                Expression = {

                    $color = 0
                    if ($_.PwNeverExpires) {
                        $color = 7
                    }

                   "$e[${color}m$($_.PwNeverExpires)${e}[0m"
                }
            }

        }

    } Catch {
    Write-Host -ForegroundColor Red "Jotain meni pieleen: \n"
    $_.Exception.GetType()
    $_
    }

}
