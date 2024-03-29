# AD-User-Last-Logon-Info
Terminaali työkalu, jolla voi tarkistaa organisaation kaikilta domain controllereilta käyttäjän viimeisimmän kirjautumisajan.

## Käyttönotto
Työkalu vaatii, että AD on käytössä organisaatiossa.
1. Avaa tiedosto Powrshell ISE tms.
2. Laita organisaation domain kohtaan:
``` Powershell
$domain = "<laita domain tähän>"
```
Esim.
``` Powershell
$domain = "organisaatio-123"
```
4. Tallenna tiedosto
5. Nyt voit suorittaa tiedoston PowerShellillä

Jos työkalu ei toimi oikein, tarkista, että laitteesi PowerShell execution Policy on järkevä.

Jos domain controllerit eivät valikoidu oikein tai haluat valita itse mistä etsitään, voit vaihtaa koodista `#Haetaan DomainControllerit` kohdan sen alla olevaan listasta luettavaan koodiin.

```PowerShell
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
```
