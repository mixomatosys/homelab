$domain=Read-Host "Enter the domain to import and link GPOs"
klist purge > $Null
$DN=$(Get-addomain -server $domain).distinguishedname
$path ='[INSERT PATH TO OU]'

# list of gpos backed up in folder
$gpos=$(Get-ChildItem $path).name
foreach ($GPO in $gpos)
{
    #check if GPO exists - if not create/import it
    write-host "Checking $GPO in $domain"
    $GPOExists=Get-GPO -Name "$gpo" -domain $domain
    if ($GPOExists)
    {
        #link policy?
        write-host "$GPO Exists - Linking to ou=t0,ou=vzdas,$DN"
        $GPOExists| New-GPLink -target "[INSERT OU],$DN"  -Domain $domain
        #Get-GPO -Name $gpo -domain $domain | New-GPLink -target "[INSERT OU],$DN"  -Domain $domain
    }
    Else
    {
        write-host "$GPO did not exist - importing from $path\$gpo"
        # gpo didnt exist - create GPO and import from backup
        Import-GPO -CreateIfNeeded -BackupGpoName "$gpo" -TargetName "$gpo"  -Path "$path\$gpo"  -Domain $domain
        write-host "Linking $gpo to [INSERTOU]$DN"
        Get-GPO -Name "$gpo" -domain $domain | New-GPLink -target "[INSERT OU]$DN" -Domain $domain
     }
}
