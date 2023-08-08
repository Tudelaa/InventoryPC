# inventoryPC 1.0

# this script generate a full inventory from your server with hostname, IP, Operating system, RAM, system model, SSID, Password 
# and all the drives that you have including full size and free size.

# Written: Antonio Tudela 

# get some values from systeminfo and other cmd commands.

$hostname1 = systeminfo | Select-String "Host Name:"
$hostname2 = $hostname1.ToString().Split(":")[1].Trim()

$osname1= systeminfo | Select-String "OS Name:"
$osname2 = $osname1.ToString().Split(":")[1].Trim()

$memory1 = systeminfo | select-String "Total Physical Memory:"
$memory2 = $memory1.ToString().Split(":")[1].Trim()
 
$serialnumber = Get-WMIObject win32_bios | Select SerialNumber
$serialnumber2 = $serialnumber.SerialNumber

$systemmodel1 = systeminfo | select-String "System Model"
$systemmodel2 = $systemmodel1.ToString().Split(":")[1].Trim()

$ipaddress = ipconfig | select-string "IPv4 Address" 
$ipaddress2 = $ipaddress.ToString().Split(":")[1].Trim()  

$user = whoami 

$wifi = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)} | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} 


# avoid problem with ipconfig if you have 2 different IP´s selecting the DNS A register

if ($ipaddress2 -eq $null) { 

                          $ipaddress3 = Resolve-DnsName hostname | Select-Object IPAddress 
                          $ipaddress4 = $ipaddress3.IPAddress

                          
                          } 


                          

$disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID,FreeSpace,Size

# changing value from Size and FreeSpace from KB to GB

$systeminfo = New-Object PSobject

Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name Hostname -Value $hostname2

if ($ipaddress2 -eq $null) { 

                            Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name IP -Value $ipaddress4

                            } 

                      
                      else  { 

                            Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name IP -Value $ipaddress2
                            
                            }       

Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name User -Value $user
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name OS -Value $osname2
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name RAM -Value $memory2
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name Serial_Number $serialnumber2
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name Model $systemmodel2
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name SSID $wifi.PROFILE_NAME
Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name Password $wifi.PASSWORD


[int]$cont = 0

foreach ($disk2 in $disk.DeviceID) { 

                                   
                                   $labeldisk = "Drive" + [string]$cont
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $labeldisk -Value $disk2
                                   [int]$cont++

                                    }


[int]$cont = 0

foreach ($totalsize in $disk.Size) { 

                                   
                                   $size_in_GB = "Total_Size_in_GB_disk" + [string]$cont 
                                   [int64]$diskGB = [int64]$totalsize / 1073741824
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $size_in_GB -Value $diskGB
                                   [int]$cont++

                                    }


[int]$cont = 0

foreach ($totalfree in $disk.FreeSpace) { 

                                   
                                   
                                   $Free_in_GB = "Total_Freespace_GB_disk" + [string]$cont
                                   [int64]$freeGB = [int64]$totalfree /1073741824
                                   Add-Member -InputObject $systeminfo -MemberType NoteProperty -Name $Free_in_GB -Value $freeGB
                                   [int]$cont++

                                    }





$systeminfo | Out-GridView -Title "ComputerInfo"
 



