$OGLocation = "C:\ArchiveMoverTestSRC"
$TargetLocation = "C:\ArchiveMoverTestDST"
$ErrorLocation = "F:\errors.txt" 
$folders = get-childitem $OGLocation -Directory | Select-Object -ExpandProperty Name
$numberofDays = -30
$todayDate = Get-Date

Foreach ($folder in $folders) {
    $TargetEntityPath = Join-Path $TargetLocation -ChildPath $folder
    $OGEntityLocation = Join-Path $OGLocation -ChildPath $folder
    $archives = get-childitem $OGEntityLocation -Directory
    Foreach ($archive in $archives) {
        $dateString = $archive.name.Split("_")[0]
        $archiveDate = [datetime]::ParseExact($dateString, 'yyyyMMdd', $null)
        $OGFilePath = Join-Path $OGEntityLocation -ChildPath $archive
        $finalPath = Join-Path $TargetEntityPath -ChildPath $archive
        if ($archiveDate -lt $todayDate.AddDays($numberofDays)){
            New-Item -ItemType directory -Path $finalPath
            Get-ChildItem -Path $OGFilePath | Move-Item -Destination $finalPath
            $itemCount = Get-ChildItem -Path $OGFilePath | Measure-Object
            if ($itemCount.Count -eq 0){
                Remove-Item -Path $OGFilePath -Recurse
            }
            if (!$?) {
                "Error on $($archive.name)" | out-file $ErrorLocation -append 
            }
        }
    }
}
