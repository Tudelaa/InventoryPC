<# inventoryPC 1.20

.SYNOPSIS

This script generates a full inventory from your computer device.


.DESCRIPTION

This script generate a full inventory from your computer device including:

- HOSTNAME
- OS 
- RAM
- SERIAL NUMBER
- MODEL
- MICROPROCESSOR
- WINDOWS LICENSE
- SSID AND PASSWORD
- IP ADDRESS
- WIFI HARDWARE
- USER
- S.M.A.R.T HD Status
- MB/S SPEED WRITE IN HD
- TOTAL SIZE AND FREE SPACE IN ALL VOLUMES 

Written: Antonio Tudela 

.PARAMETER

-Output

use -Output "table" to get the data in a graphical table or -Output "CMD" if you want to see the data directly in yout console


.VERSION HISTORY

# Version 1.20

# Added the function Get-Diskmeasures to get the writte HD results in MB/s
# Added the function Get-WifiHardware to check if Wifi Hardware exist without check the drivers
# fixed the function Get-WiFi_SSID_Password
# fixed some issues in code and added some new functions substitute lineal code to do itmore "friendly"


# Version 1.10
# get some extra values from get-computerinfo instead of systeminfo.
# added microprocessor info
# added kind license activation -OEM or KMS-
# added S.M.A.R.T physical disk values
#>



Param(

       [String]$Output="table"  # use -Output "table" to get the data in a graphical table or "CMD" if you want to see the data directly in yout console
       
       
     )



function Get-Diskmeasures { 

                           <#
                            .SYNOPSIS
                            Returns MB/s from your HD
                            .DESCRIPTION
                            This function create a file size 500MB in your computer to measure the time that needs to write in your HD and return this data in MB/S in variable $Measure
                            .PARAMETER Yes
                            $Driver = Disk you want to measure
                            $Path = Where you want to create the temp file with 500MB size
 
                            .EXAMPLE
                            PS> Get-Diskmeasures -Drive c:\ -Path c:\hola
                            #>
 
                            
                           param (
                           
                           $Drive="c:", 
                           $Path=$env:TEMP
                           
                                  )

                           $size = 524288000
                           $path3 = $env:TEMP + "\testfile.tmp"
                           $content = New-Object byte[] $size
                           (New-Object System.Random).NextBytes($content)
                           $Get_Time= measure-command { [System.IO.File]::WriteAllBytes($path3, $content)}
                           $SizeMB = $size/1MB
                           $MBS = $sizeMB/$get_time.Seconds
                           Remove-Item -Path $path3
                           $Measure = [String]$MBS + "Mb/s"
                           return $Measure
 
                           
                           

 
                          }



function Get-WifiHardware { 

                           <#
                            .SYNOPSIS
                            Returns the WiFi brand/manufacture and model without check the drivers
                        
                            .DESCRIPTION
                            This function WiFi check the brand/manufacture and model using Get-CimInstance
 
                            .PARAMETER NO
 
                            #>
                           
                           [int]$counter = 0
                           $wifiAdapters = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true -and $_.NetConnectionID -like "*Wi-Fi*" }
 
                           if ($wifiAdapters) {
     
    

                                        
                                                $Manufacture_Model = "Model: $($wifiAdapters.Name)"


                                               } 

                            else {
                   
                                     $Manufacture_Model = "No Wi-Fi hardware detected."
                                 }
 
 
                            return $Manufacture_Model

                          }



function Get-WindowsLicense {


                            <#

                            .SYNOPSIS
                            Returns if your Windows device has OEM or KMS license
                        
                            .DESCRIPTION
                            This function runs get-wmiObject to get the SoftwareLicenseService and check if this one returns OEM,KMS or UNKNOWN with friendly msg
 
                            .PARAMETER NO
 
                            #>
                             

                            $licenseKMS_or_OEM = get-wmiObject -query "select * from SoftwareLicensingService"

                            if ($licenseKMS_or_OEM.SubscriptionEdition -eq "UNKNOWN") { 

                                                          
                                                           
                                                          #Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name License -Value $licenseKMS_or_OEM.SubscriptionEdition
                                                          $Windows_License = "I cannot determine if it is an OEM or KMS license"
                                                          return $Windows_License

                                                          }

                                                          elseif ($null -ne $licenseKMS_or_OEM.OA3XOriginalProductKey) { 

                                                              #Add-Member -InputObject $systeminfo NoteProperty -Name OEMLicense $licenseKMS_or_OEM.OA3XOriginalProductKey 
                                                              $Windows_License = "You have OEM license: $($licenseKMS_or_OEM.OA3XOriginalProductKey)"
                                                              return $Windows_License


                                                              } 

                                                           elseif ($null -ne $licenseKMS_or_OEM.DiscoveredKeyManagementServiceMachineName) { 

                                                               # Add-Member -InputObject $systeminfo NoteProperty -Name KMS_Server_License $licenseKMS_or_OEM.DiscoveredKeyManagementServiceMachineName
                                                               $Windows_License = "You have KMS license: $($licenseKMS_or_OEM.DiscoveredKeyManagementServiceMachineName)"
                                                               return $Windows_License 

                                                              } 
                
                             
                             }




function Get-WiFi_SSID_Password {

                            <#
                            .SYNOPSIS
                            
                            get full wifi values with Netsh CMD command in case that service was enbaled and Returns SSID and Password if you have WiFi service enabled
                        
                            .DESCRIPTION
                            get full wifi values with Netsh CMD command in case that service was enbaled and Returns SSID and Password if you have WiFi service enabled
 
                            .PARAMETER No
 
                            #>
                               
                     

                                $wifiservice = (Get-Service -Name WlanSvc).Status

                                
                                
                                
                                if ($wifiservice -eq "Stopped")  { 
                                
                                                                   $NOSSID = "WiFi NOT DETECTED"
                                                                   $PASSWORD = "Wifi NOT DETECTED"

                                                                   return [PSCustomObject]@{

                                                                                            SSID = $NOSSID
                                                                                            PASSWORD = $PASSWORD
                                                                                            }
                                                                              
                                                                  } elseif ($wifiservice -ne "Stopped") { 

                                                                                                        $wifi = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)} | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} 
                                
                                                                                                        if ($null -ne $wifi.PROFILE_NAME -or $null -ne $wifi.PASSWORD) { 

                                                               #Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name SSID $wifi.PROFILE_NAME
                                                               #Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name Password $wifi.PASSWORD
                                                              
                                                                                                                                                                         return [PSCustomObject]@{

                                                                                                                                                                         SSID = $wifi.PROFILE_NAME
                                                                                                                                                                         PASSWORD = $wifi.PASSWORD
  
   
  
                                                                                                                                                                                                 }

                                                                                                                                                                         } 
                                                                                 
                                                                                                         } 
                            
                                                                      
                                                                    
                                                      
                                                                 
                                }        







# get different variables to make inventory with some cmd-lets commands

$values = Get-ComputerInfo
$net_values = Get-NetIPConfiguration
$Wifi_Values = Get-WiFi_SSID_Password

# make systeminfo new object where we will save all inventory info


$systeminfo = [PSCustomObject]@{


  hostname= $values.CsName 
  OS= $values.OsName
  RAM = $values.OsTotalVisibleMemorySize/(1024*1024)
  Serial_Number = $values.BiosSeralNumber
  Model = $values.CsModel
  Microprocessor = $values.CsProcessors.Name
  Windows_License = Get-WindowsLicense
  ipaddress = $net_values.IPv4Address.IPAddress
  WifiHardware = Get-WifiHardware
  user = $env:USERNAME
  SSID = $Wifi_Values.SSID
  PASSWORD = $Wifi_Values.PASSWORD
  
   
  
}



                            
# get the S.M.A.R.T values from physical disks

$physicaldisk = Get-PhysicalDisk
[int]$counter = 0

foreach ($pd in $physicaldisk) {

                                $Disk_name = "Physical Disk " + [string]$counter
                                Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $Disk_name $pd.FriendlyName                  
                                $status = "S.M.A.R.T Status Physical Disk" +  [string]$counter
                                Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $status $pd.HealthStatus

                                }
                                                               


$disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID,FreeSpace,Size


[int]$cont = 0



foreach ($disk2 in $disk.DeviceID) { 

                                   $mbs_in_partition= Get-Diskmeasures -Drive $disk2
                                   $labeldisk = "Drive" + [string]$cont
                                   $DiskSpeed = "Write speed MB/S in " + $disk2
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $labeldisk -Value $disk2
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $DiskSpeed -Value $mbs_in_partition
                                   [int]$cont++

                                    }


[int]$cont = 0

foreach ($totalsize in $disk.Size) { 

                                   
                                   $size_in_GB = "Total_Size_in_GB in Drive " + [string]$cont 
                                   [int64]$diskGB = [int64]$totalsize / 1073741824
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $size_in_GB -Value $diskGB
                                   [int]$cont++

                                    }


[int]$cont = 0

foreach ($totalfree in $disk.FreeSpace) { 

                                   
                                   
                                   $Free_in_GB = "Total_Freespace_GB in Drive " + [string]$cont
                                   [int64]$freeGB = [int64]$totalfree /1073741824
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $Free_in_GB -Value $freeGB
                                   [int]$cont++

                                    }



if($output -eq "table") { 


                        $systeminfo | Out-GridView -Title "ComputerInfo"
 
                        } 

elseif($Output -eq "CMD") { 


                        $systeminfo 
 
                        } 




