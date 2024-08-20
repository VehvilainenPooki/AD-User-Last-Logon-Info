# AD-User-Last-Logon-Info
Terminaali työkalu, jolla voi tarkistaa organisaation kaikilta domain controllereilta käyttäjän viimeisimmän kirjautumisajan.

## Käyttönotto
Työkalu vaatii, että AD on käytössä organisaatiossa.
1. Avaa tiedosto sovelluksella, jossa voit muokata sitä. Esim. Notepad tai PowerShell ISE.
2. Laita organisaation domain kohtaan:
``` PowerShell
$domain = "<laita domain tähän>"
```
Esim.
``` PowerShell
$domain = "organisaatio-123"
```
4. Tallenna tiedosto
5. Nyt voit suorittaa tiedoston PowerShellillä

Jos työkalu ei toimi oikein, tarkista, että laitteesi PowerShell execution Policy on järkevä.

Jos domain controllerit eivät valikoidu oikein tai haluat valita manuaalisesti mistä etsitään, voit vaihtaa koodista `#Haetaan DomainControllerit` kohdan koodin. kommentti blokin sisällä oleva koodi lukee listan domain controllereita, jotka voit listata kohtaan `$domaincontrollers = @(Lista tähän)`.

```PowerShell
#Haetaan DomainControllerit
$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$domaincontrollers = $myforest.Sites | % { $_.Servers } | Select Name
$RealUserLastLogon = $null
$LastusedDC = $null
$domainsuffix = "*."+$domain

<# Käytä tätä, jos haluat määrätä manuaalisesti miltä domain controllereilta etsitään.

$domaincontrollers = @("DomainController1","DomainController2","DomainController3")
$RealUserLastLogon = $null
$LastusedDC = $null
$domainsuffix = "*."+$domain
#>
```
