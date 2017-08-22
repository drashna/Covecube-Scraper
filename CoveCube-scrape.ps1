param([boolean] $Verbose = $False, [string] $DownloadFolder= "C:\Users\Public\Downloads\StableBit")

#
# If you wish to run thins from the Task Scheduler, you want to use the following command: 
# powershell -Command "& C:\path\to\Covecube-scrape.ps1 -Verbose $False -DownloadFolder 'D:\Path\To\Download\' "
#

$Products = ,@{Name = "StableBit Scanner for Windows"; SKU = "ScannerWindows"; BetaURI = "http://dl.covecube.com/ScannerWindows/beta/download/"; ReleaseURI = "http://dl.covecube.com/ScannerWindows/release/download/"}
$Products += ,@{Name = "StableBit Scanner for Windows Home Server v1"; SKU = "ScannerWhs1"; BetaURI = "http://dl.covecube.com/ScannerWhs1/beta/download/"; ReleaseURI = "http://dl.covecube.com/ScannerWhs1/release/download/"}
$Products += ,@{Name = "StableBit Scanner for Windows Server Essentials"; SKU = "ScannerWhs2"; BetaURI = "http://dl.covecube.com/ScannerWhs2/beta/download/"; ReleaseURI = "http://dl.covecube.com/ScannerWhs2/release/download/"}
$Products += ,@{Name = "StableBit DrivePool for Windows Home Server 2011"; SKU = "DrivePoolWhs2"; BetaURI = "http://dl.covecube.com/DrivePool/beta/download/"; ReleaseURI = "http://dl.covecube.com/DrivePool/release/download/"}
$Products += ,@{Name = "StableBit DrivePool for Windows"; SKU = "DrivePoolWindows"; BetaURI = "http://dl.covecube.com/DrivePoolWindows/beta/download/"; ReleaseURI = "http://dl.covecube.com/DrivePoolWindows/release/download/"}
$Products += ,@{Name = "StableBit CloudDrive for Windows"; SKU = "CloudDriveWindows"; BetaURI = "http://dl.covecube.com/CloudDriveWindows/beta/download/"; ReleaseURI = "http://dl.covecube.com/CloudDriveWindows/release/download/"}
$Products += ,@{Name = "WSS Troubleshooter"; SKU = "WssUtil"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/WssTroubleshoot/Release/download/"}
$Products += ,@{Name = "SSD Optimizer Balancer Plugin"; SKU = "Balancers\SSD Optimizer"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/DrivePoolBalancingPlugins/SsdOptimizer/"}
$Products += ,@{Name = "Ordered File Placement Balancer Plugin"; SKU = "Balancers\Ordered File Placement"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/DrivePoolBalancingPlugins/OrderedFilePlacement/"}
$Products += ,@{Name = "Disk Space Equalizer Balancer Plugin"; SKU = "Balancers\Disk Space Equalizer"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/DrivePoolBalancingPlugins/DiskSpaceEqualizer/"}
$Products += ,@{Name = "Achive Optimizer Balancer Plugin"; SKU = "Balancers\Archive Optimizer"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/DrivePoolBalancingPlugins/ArchiveOptimizer/"}
$Products += ,@{Name = "DirectIO Test"; SKU = "DirectIO Test"; BetaURI = ""; ReleaseURI = "http://dl.covecube.com/DirectIoTest/"}

$DownloadFolder = $DownloadFolder.TrimEnd("\") + "\"

Write-Host ( "Downloading files to " + $DownloadFolder ) 

function DownloadFiles([PSObject] $Links, [System.Object] $ThisProduct, [boolean] $Release, [boolean] $ManagedInstaller = $False)
{
    $Folder = $DownloadFolder + $ThisProduct.SKU + "\"
    if ( $ManagedInstaller -eq $true ) {
        $ManageText = "Managed_Deployment/"
        $Folder += "Managed Deployment\"
    }
    If ( $(Test-Path $Folder) -eq $False) {
        New-Item $Folder -ItemType Directory
    }

	foreach ($Link in $Links )
	{
		if ( $Link.href -notlike "*.exe" -and $Link.href -notlike "*.wssx" -and $Link.href -notlike "*.msi" -and $Link.href -notlike "*.txt" -and $Link.href -notlike "*.sha") {
			continue
		}
        if ($ManagedInstaller -eq $true -and $Link.href -notlike "*.msi" ) {
            continue
        }
        if ($Release) { $URIheader = $ThisProduct.ReleaseURI }
        else { $URIheader = $ThisProduct.BetaURI }

		$FileURI = $URIHeader + $ManageText + $Link.innerText
        $Outputfile = $Folder + $Link.innerText
		$FileExists = Test-Path $Outputfile
    	
    	If ( ( $FileExists -eq $false ) -or ( $Link.href -like "*.txt" -and ( ( $Release -eq $true -and $ThisProduct.BetaURI -eq "") -or ( $Release -eq $false ) ) ) ) {
			Write-Host ("[Downloaded] " + $Outputfile) -ForegroundColor Green
            Invoke-WebRequest -uri $FileURI -OutFile $Outputfile
		} elseif ($Verbose -eq $True) { 
            Write-Host ("[Skipped] " + $FileURI) -ForegroundColor DarkRed
        }
	}
    If ($Product.SKU -like "*Windows" -and $ManagedInstaller -eq $False) {
        DownloadFiles -Links $( Invoke-WebRequest -uri ( $URIHeader + "Managed_Deployment/" ) ).Links -ThisProduct $ThisProduct -Release $Release -ManagedInstaller $True
    }
    return;
}



foreach ($Product in $Products)
{
    Write-Host ("Downloads for " + $Product.Name + ":") -ForegroundColor Red
    If ($Product.ReleaseURI -ne "") {
        DownloadFiles -Links $(Invoke-WebRequest -uri $Product.ReleaseURI).Links -ThisProduct $Product -Release $True
    }
    If ($Product.BetaURI -ne "") {
        DownloadFiles -Links $(Invoke-WebRequest -uri $Product.BetaURI).Links -ThisProduct $Product -Release $False
    }
}

return $true;