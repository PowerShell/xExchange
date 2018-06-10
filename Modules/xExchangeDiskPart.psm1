#Adds the array of commands to a single temp file, and has disk part execute the temp file
function Start-ExchDscDiskpart
{
    [CmdletBinding()]
    [OutputType([System.String])]
    Param
    (
        [Parameter()]
        [Array]
        $Commands,
        
        [Parameter()]
        [System.Boolean]
        $ShowOutput, 
        
        [Parameter()]
        $VerbosePreference
    )

    $tempFile = [System.IO.Path]::GetTempFileName()

    foreach ($Com in $Commands)
    {
        $CMDLine = $CMDLine + $Com + ', '
        Add-Content -Path $tempFile -Value $Com
    }

    $outPut = DiskPart /s $tempFile

    if ($ShowOutput)
    {
        Write-Verbose -Message "Executed Diskpart commands: $(StringArrayToCommaSeparatedString -Array $Commands). Result:"
        Write-Verbose -Message "$($outPut)"
    }

    Remove-Item -Path $tempFile

    return $outPut
}

#Uses diskpart to obtain information on the disks and volumes that already exist on the system
function Get-ExchDscDiskInfo
{
    [Hashtable]$global:DiskToVolumeMap = @{}
    [Hashtable]$global:VolumeToMountPointMap = @{}
    [Hashtable]$global:DiskSizeMap = @{}
    [int[]]$diskNums = @()

    $diskList = Start-ExchDscDiskpart -Commands 'List Disk' -ShowOutput $false
    $foundDisks = $false

    #First parse out the list of disks
    foreach ($line in $diskList)
    {
        if ($foundDisks -eq $true)
        {
            if ($line.Contains('Disk '))
            {
                #First find the disk number
                $startIndex = '  Disk '.Length
                $endIndex = '  --------  '.Length
                $diskNumStr = $line.Substring($startIndex, $endIndex - $startIndex).Trim()

                if ($diskNumStr.Length -gt 0)
                {
                    $diskNum = [int]::Parse($diskNumStr)
                    $diskNums += $diskNum
                }

                #Now find the disk size
                $startIndex = '  --------  -------------  '.Length
                $endIndex = '  --------  -------------  -------  '.Length
                $diskSize = $line.Substring($startIndex, $endIndex - $startIndex).Trim()

                if ($diskSize.Length -gt 0 -and $null -ne $diskNum)
                {
                    $DiskSizeMap.Add($diskNum, $diskSize)
                }
            }
        }
        elseif ($line.Contains('--------  -------------  -------  -------  ---  ---')) #Scroll forward until we find the where the list of disks starts
        {
            $foundDisks = $true
        }
    }

    #Now get info on the disks
    foreach ($diskNum in $diskNums)
    {
        $diskDetails = Start-ExchDscDiskpart -Commands "Select Disk $($diskNum)",'Detail Disk' -ShowOutput $false

        $foundVolumes = $false

        for ($i = 0; $i -lt $diskDetails.Count; $i++)
        {
            $line = $diskDetails[$i]

            if ($foundVolumes -eq $true)
            {
                if ($line.StartsWith('  Volume '))
                {
                    #First find the volume number
                    $volStart = '  Volume '.Length
                    $volEnd = '  ----------  '.Length
                    $volStr = $line.Substring($volStart, $volEnd - $volStart).Trim()

                    if ($volStr.Length -gt 0)
                    {
                        $volNum = [int]::Parse($volStr)

                        AddObjectToMapOfObjectArrays -Map $DiskToVolumeMap -Key $diskNum -Value $volNum

                        #Now parse out the drive letter if it's set
                        $letterStart = '  ----------  '.Length
                        $letterEnd = $line.IndexOf('  ----------  ---  ') + '  ----------  ---  '.Length
                        $letter = $line.Substring($letterStart, $letterEnd - $letterStart).Trim()

                        if ($letter.Length -eq 1)
                        {
                            AddObjectToMapOfObjectArrays -Map $VolumeToMountPointMap -Key $volNum -Value $letter
                        }

                        #Now find all the mount points
                        do
                        {
                            $line = $diskDetails[++$i]

                            if ($null -eq $line -or $line.StartsWith('  Volume ') -or $line.Trim().Length -eq 0) #We've hit the next volume, or the end of all info
                            {
                                $i-- #Move $i back one as we may have overrun the start of the next volume info
                                break
                            }
                            else
                            {
                                $mountPoint = $line.Trim()

                                AddObjectToMapOfObjectArrays -Map $VolumeToMountPointMap -Key $volNum -Value $mountPoint
                            }

                        } while ($i -lt $diskDetails.Count)

                    }
                }
            }
            elseif ($line.Contains('There are no volumes.'))
            {
                [System.String[]]$emptyArray = @()
                $DiskToVolumeMap[$diskNum] = $emptyArray

                break
            }
            elseif ($line.Contains('----------  ---  -----------  -----  ----------  -------  ---------  --------'))
            {
                $foundVolumes = $true
            }
        }
    }
}

function StringArrayToCommaSeparatedString
{
    param([System.String[]]$Array)

    $string = ''

    if ($null -ne $Array -and $Array.Count -gt 0)
    {
        $string = $Array[0]

        for ($i = 1; $i -lt $Array.Count; $i++)
        {
            $string += ",$($Array[$i])"
        }
    }

    return $string
}

#Takes a hashtable, and adds the given key and value.
function AddObjectToMapOfObjectArrays
{
    Param([Hashtable]$Map, $Key, $Value)

    if ($Map.ContainsKey($Key))
    {
        $Map[$Key] += $Value
    }
    else
    {
        [object[]]$Array = $Value
        $Map[$Key] = $Array
    }
}

<#
    Checks whether the mount point specified in the given path already exists as a mount point
    Returns the volume number if it does exist, else -1
#>
function MountPointExists
{
    param([System.String]$Path)

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($value in $global:VolumeToMountPointMap[$key])
        {
            #Make sure both paths end with the same character
            if (($value.EndsWith('\')) -eq $false)
            {
                $value += '\'
            }

            if (($Path.EndsWith('\')) -eq $false)
            {
                $Path += '\'
            }

            #Do the comparison
            if ($value -like $Path)
            {
                return $key
            }
        }
    }

    return -1
}

#Creates mount points for any Exchange Volumes we are missing
function Add-ExchDscMissingVolumes
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR','GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL',

        [Parameter()]
        [System.Int32]
        $CurrentVolCount,

        [Parameter()]
        [System.Int32]
        $RequiredVolCount
    )

    for ($i = $CurrentVolCount; $i -lt $RequiredVolCount; $i++)
    {
        if ($i -ne $CurrentVolCount) #Need to update disk info if we've gone through the loop already
        {
            Get-ExchDscDiskInfo
        }

        $firstDisk = Find-ExchDscFirstAvailableDisk -MinDiskSize $MinDiskSize

        if ($firstDisk -ne -1)
        {
            $firstVolume = Find-ExchDscFirstAvailableVolume -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix

            if ($firstVolume -ne -1)
            {
                $volPath = Join-Path -Path "$($AutoDagVolumesRootFolderPath)" -ChildPath "$($VolumePrefix)$($firstVolume)"

                Initialize-ExchDscMountPoint -DiskNumber $firstDisk -Folder $volPath -FileSystem $FileSystem -UnitSize $UnitSize -PartitioningScheme $PartitioningScheme -Label "$($VolumePrefix)$($firstVolume)"
            }
            else
            {
                throw 'Unable to find a free volume number to use when naming the volume folder'
            }
        }
        else
        {
            throw 'No available disks to assign an Exchange Volume mount point to'
        }
    }
}

#Looks for databases that have never had a mount point created, and gives them a mount point
function Add-ExchDscMissingDatabases
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR','GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    for ($i = 0; $i -lt $DiskToDBMap.Count; $i++)
    {
        if ($i -gt 0) #Need to refresh current disk info
        {
            Get-ExchDscDiskInfo
        }

        [System.String[]]$dbsNeedingMountPoints = @()

        [System.String[]]$allDBsRequestedForDisk = $DiskToDBMap[$i].Split(',')

        for ($j = 0; $j -lt $allDBsRequestedForDisk.Count; $j++)
        {
            $current = $allDBsRequestedForDisk[$j]

            $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($current)"

            #We only want to touch datases who have never had a mount point created. After that, AutoReseed will handle it.
            if ((Test-Path -Path "$($path)") -eq $false)
            {
                $dbsNeedingMountPoints += $current
            }
            else #Since the folder already exists, need to check and error if the mount point doesn't
            {
                if ((MountPointExists -Path $path) -eq -1)
                {
                    throw "Database '$($current)' already has a folder on disk at '$($path)', but does not have a mount point. This must be manually corrected for xAutoMountPoint to proceed."
                }
            }
        }

        if ($dbsNeedingMountPoints.Count -eq $allDBsRequestedForDisk.Count) #No DB mount points for this disk have been created yet
        {
            $targetVolume = Get-ExchDscVolume -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -DBsPerDisk $allDBsRequestedForDisk.Count -VolumePrefix $VolumePrefix
        }
        elseif ($dbsNeedingMountPoints.Count -gt 0) #We just need to create some mount points
        {
            $existingDB = ''

            #Find a DB that's already had its mount point created
            foreach ($db in $allDBsRequestedForDisk)
            {
                if (($dbsNeedingMountPoints.Contains($db) -eq $false))
                {
                    $existingDB = $db
                    break
                }
            }

            if ($existingDB -ne '')
            {
                $targetVolume = Get-ExchDscVolume -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -ExistingDB $existingDB -DBsPerDisk $allDBsRequestedForDisk.Count -DBsToCreate $dbsNeedingMountPoints.Count -VolumePrefix $VolumePrefix
            }
        }
        else #All DB's requested for this disk are good. Just continue on in the loop
        {
            continue
        }

        if ($null -ne $targetVolume)
        {
            if ($targetVolume -ne -1)
            {
                foreach ($db in $dbsNeedingMountPoints)
                {
                    $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($db)"

                    Add-ExchDscMountPoint -VolumeNumber $targetVolume -Folder $path

                    if ($CreateSubfolders -eq $true)
                    {
                        $dbFolder = Join-Path -Path "$($path)" -ChildPath "$($db).db"
                        $logFolder = Join-Path -Path "$($path)" -ChildPath "$($db).log"

                        if ((Test-Path -LiteralPath "$($dbFolder)") -eq $false)
                        {
                            mkdir -Path "$($dbFolder)"
                        }

                        if ((Test-Path -LiteralPath "$($logFolder)") -eq $false)
                        {
                            mkdir -Path "$($logFolder)"
                        }
                    }
                }
            }
            else
            {
                throw "Unable to find a volume to place mount points for the following databases: '$($dbsNeedingMountPoints)'"
            }
        }
    }
}

#Builds a map of the DBs that already exist on disk
function Get-ExchDscDatabaseMap
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath
    )

    #Get the DB path to a point where we know there will be a trailing \
    $dbpath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath ''

    #Will be the return value for DiskToDBMap
    [System.String[]]$dbMap = @()

    #Loop through all existing mount points and figure out which ones are for DB's
    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        [System.String]$mountPoints = ''

        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbpath))
            {
                $startIndex = $dbpath.Length
                $endIndex = $mountPoint.IndexOf('\', $startIndex)
                $dbName = $mountPoint.Substring($startIndex, $endIndex - $startIndex)

                if ($mountPoints -eq '')
                {
                    $mountPoints = $dbName
                }
                else
                {
                    $mountPoints += ",$($dbName)"
                }
            }
        }

        if ($mountPoints.Length -gt 0)
        {
            $dbMap += $mountPoints
        }
    }

    return $dbMap
}

<#
    Looks for a volume where an Exchange Volume or Database mount point can be added.
    If ExistingDB is not specified, looks for a spare volume that has no mount points yet.
    If ExistingDB is specified, finds the volume number where that DB exists, only if
    there is room to create the requested database mount points.
#>
function Get-ExchDscVolume
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $ExistingDB = '', 
        
        [Parameter()]
        [Uint32]
        $DBsPerDisk, 

        [Parameter()]
        [Uint32]
        $DBsToCreate, 
        
        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL')

    $targetVol = -1 #Our return variable

    [object[]]$keysSorted = Get-ExchDscSortedVolumeKeys -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix
    
    #Loop through every volume
    foreach ($key in $keysSorted)
    {
        [int]$intKey = $key

        #Get mount points for this volume
        [System.String[]]$mountPoints = $global:VolumeToMountPointMap[$intKey]

        $hasExVol = $false #Whether any ExVol mount points exist on this disk
        $hasExDb = $false #Whether any ExDB mount points exist on this disk
        $hasExistingDB = $false #Whether $ExistingDB exists as a mount point on this disk

        #Inspect each individual mount point
        foreach($mountPoint in $mountPoints)
        {
            if ($mountPoint.StartsWith($AutoDagVolumesRootFolderPath))
            {
                $hasExVol = $true
            }
            elseif ($mountPoint.StartsWith($AutoDagDatabasesRootFolderPath))
            {
                $hasExDb = $true

                $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($ExistingDB)"

                if ($mountPoint.StartsWith($path))
                {
                    $hasExistingDB = $true
                }
            }
        }

        if ($ExistingDB -eq '')
        {
            if ($hasExVol -eq $true -and $hasExDb -eq $false)
            {
                $targetVol = $intKey
                break
            }
        }
        else
        {
            if ($hasExVol -eq $true -and $hasExistingDB -eq $true)
            {
                if (($mountPoints.Count + $DBsToCreate) -le ($DBsPerDisk + 1))
                {
                    $targetVol = $intKey
                }

                break
            }
        }
    }

    return $targetVol
}

function Get-ExchDscSortedVolumeKeys
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL')

    [System.String[]]$sortedKeys = @() #The return value

    [System.String]$pathBeforeVolumeNumber = Join-Path -Path $AutoDagVolumesRootFolderPath -ChildPath $VolumePrefix

    #First extract the actual volume number as an Int from the volume path, then add it to a new hashtable with the same key value
    [Hashtable]$tempVolumeToMountPointMap = @{}

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        $volPath = ''

        #Loop through each mount point on this volume and find the EXVOL mount point
        foreach ($value in $VolumeToMountPointMap[$key])
        {
            if ($value.StartsWith($pathBeforeVolumeNumber))
            {
                $volPath = $value
                break
            }
        }

        if ($volPath.StartsWith($pathBeforeVolumeNumber))
        {
            if ($volPath.EndsWith('\') -or $volPath.EndsWith('/'))
            {
                [System.String]$exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length - 1))
            }
            else
            {
                [System.String]$exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length))
            }
            
            [int]$exVolNumber = [int]::Parse($exVolNumberStr)
            $tempVolumeToMountPointMap.Add($key, $exVolNumber)
        }
    }

    #Now go through the volume numbers, and add the keys to the return array in sorted value order
    while ($tempVolumeToMountPointMap.Count -gt 0)
    {
        [object[]]$keys = $tempVolumeToMountPointMap.Keys
        [int]$lowestKey = $keys[0]
        [int]$lowestValue = $tempVolumeToMountPointMap[$keys[0]]

        for ($i = 1; $i -lt $tempVolumeToMountPointMap.Count; $i++)
        {
            [int]$currentValue = $tempVolumeToMountPointMap[$keys[$i]]

            if ($currentValue -lt $lowestValue)
            {
                $lowestKey = $keys[$i]
                $lowestValue = $currentValue
            }
        }

        $sortedKeys += $lowestKey
        $tempVolumeToMountPointMap.Remove($lowestKey)
    }

    return $sortedKeys
}

#Finds the lowest disk number that doesn't have any volumes associated, and is larger than the requested size
function Find-ExchDscFirstAvailableDisk
{
    param
    (
        [Parameter()]
        [System.String]
        $MinDiskSize = ''
    )

    $diskNum = -1

    foreach ($key in $global:DiskToVolumeMap.Keys)
    {
        if ($global:DiskToVolumeMap[$key].Count -eq 0 -and ($key -lt $diskNum -or $diskNum -eq -1))
        {
            if ($MinDiskSize -ne '')
            {
                [Uint64]$minSize = 0 + $MinDiskSize.Replace(' ', '')
                [Uint64]$actualSize = 0 + $global:DiskSizeMap[$key].Replace(' ', '')

                if ($actualSize -gt $minSize)
                {
                    $diskNum = $key
                }
            }
            else
            {
                $diskNum = $key
            }
        }
    }

    return $diskNum
}

<#
    Looks in the volumes root folder and finds the first number we can give to a volume folder
    based off of what folders have already been created
#>
function Find-ExchDscFirstAvailableVolume
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $VolumePrefix
    )

    if((Test-Path -LiteralPath "$($AutoDagVolumesRootFolderPath)") -eq $false) #If the ExVol folder doesn't already exist, then we can start with 1
    {
        return 1
    }

    $currentFolders = Get-ChildItem -LiteralPath "$($AutoDagVolumesRootFolderPath)" | Where-Object {$_.GetType().Name -eq 'DirectoryInfo'} | Sort-Object

    for ($i = 1; $i -lt 999; $i++)
    {
        $existing = $null
        $existing = $currentFolders | Where-Object {$_.Name -eq "$($VolumePrefix)$($i)"}

        if ($null -eq $existing)
        {
            return $i
        }
    }

    return -1
}

#Counts and returns the number of DB's in the disk to db map
function Get-ExchDscDatabaseCount
{
    param
    (
        [Parameter()]
        [System.String[]]
        $DiskToDBMap
    )

    $count = 0

    foreach ($value in $DiskToDBMap)
    {
        $count += $value.Split(',').Count
    }

    return $count
}

#Checks if a database already has a mountpoint created
function Test-ExchDscDatabaseMountPoint
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath, 
        
        [Parameter()]
        [System.String]
        $Database
    )

    $dbPath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($Database)"

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbPath))
            {
                return $true
            }
        }
    }

    return $false
}

#Gets the count of in use mount points matching the given critera
function Get-ExchDscInUseMountPointCount
{
    param
    (
        [Parameter()]
        [System.String]
        $RootFolder
    )

    $count = 0

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($RootFolder))
            {
                $count++
            }
        }
    }

    return $count
}

<#
    Checks all volumes, and sees if any of them have ExchangeVolume mount points 
    that show up before other (like ExchangeDatabase) mount points.
    If so, it returns the volume number. If not, it returns -1
#>
function Get-ExchDscVolumeMountPoint
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath
    )

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        $values = $global:VolumeToMountPointMap[$key]

        if ($null -ne $values)
        {
            for ($i = 0; $i -lt $values.Count; $i++)
            {
                if ($values[$i].StartsWith($AutoDagVolumesRootFolderPath) -eq $true -and $i -lt ($values.Count - 1))
                {
                    return $key
                }
            }
        }
    }

    return -1
}

<#
    For volumes that have multiple mount points including an ExchangeVolume mount point,
    sends removes and re-adds the ExchangeVolume mount point so that
    it is at the end of the list of mount points
#>
function Set-ExchDscVolumeMountPoint
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath, 
        
        [Parameter()]
        [System.Int32]
        $VolumeNumber
    )

    $values = $global:VolumeToMountPointMap[$VolumeNumber]

    foreach ($folderName in $values)
    {
        if ($folderName.StartsWith($AutoDagVolumesRootFolderPath))
        {
            if ($folderName.EndsWith('\'))
            {
                $folderName = $folderName.Substring(0, $folderName.Length - 1)
            }

            Start-ExchDscDiskpart -Commands "select volume $($VolumeNumber)","remove mount=`"$($folderName)`"","assign mount=`"$($folderName)`"" -VerbosePreference $VerbosePreference | Out-Null
            break
        }
    }
}

#Takes an empty disk, initalizes and formats it, and gives it an ExchangeVolume mount point
function Initialize-ExchDscMountPoint
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Int32]
        $DiskNumber, 
        
        [Parameter()]
        [System.String]
        $Folder, 
        
        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS', 
        
        [Parameter()]
        [System.String]
        $UnitSize, 
        
        [Parameter()]
        [System.String]
        $PartitioningScheme, 
        
        [Parameter()]
        [System.String]
        $Label
    )
    
    #Initialize the disk and put in MBR format
    Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'clean' -VerbosePreference $VerbosePreference | Out-Null
    Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'online disk' -VerbosePreference $VerbosePreference | Out-Null
    Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'attributes disk clear readonly','convert MBR' -VerbosePreference $VerbosePreference | Out-Null
    Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'offline disk' -VerbosePreference $VerbosePreference | Out-Null
 
    #Online the disk
    Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'attributes disk clear readonly','online disk' -VerbosePreference $VerbosePreference | Out-Null

    #Convert to GPT if requested
    if ($PartitioningScheme -eq 'GPT')
    {
        Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)",'convert GPT noerr' -VerbosePreference $VerbosePreference | Out-Null
    }

    #Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        mkdir -Path "$($Folder)" | Out-Null
    }    

    #Create the partition and format the drive
    if ($FileSystem -eq 'NTFS')
    {
        $formatString = "Format FS=$($FileSystem) UNIT=$($UnitSize) Label=$($Label) QUICK"

        Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)","create partition primary","$($formatString)","assign mount=`"$($Folder)`"" -VerbosePreference $VerbosePreference | Out-Null
    }
    else #if ($FileSystem -eq "REFS")
    {
        Start-ExchDscDiskpart -Commands "select disk $($DiskNumber)","create partition primary" -VerbosePreference $VerbosePreference | Out-Null
        
        if ($UnitSize.ToLower().EndsWith('k'))
        {
            $UnitSizeBytes = [UInt64]::Parse($UnitSize.Substring(0, $UnitSize.Length - 1)) * 1024
        }
        else
        {
            $UnitSizeBytes = $UnitSize
        }

        Write-Verbose -Message 'Sleeping for 15 seconds after partition creation.'

        Start-Sleep -Seconds 15

        Get-Partition -DiskNumber $DiskNumber -PartitionNumber 2| Format-Volume -AllocationUnitSize $UnitSizeBytes -FileSystem REFS -NewFileSystemLabel $Label -SetIntegrityStreams:$false -Confirm:$false
        Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 2 -AccessPath $Folder -PassThru | Set-Partition -NoDefaultDriveLetter $true
    }
}

#Adds a mount point to an existing volume
function Add-ExchDscMountPoint
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Int32]
        $VolumeNumber, 
        
        [Parameter()]
        [System.String]
        $Folder
    )

    #Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        mkdir -Path "$($Folder)" | Out-Null
    }

    Start-ExchDscDiskpart -Commands "select volume $($VolumeNumber)","assign mount=`"$($Folder)`"" -VerbosePreference $VerbosePreference | Out-Null
}

Export-ModuleMember -Function *