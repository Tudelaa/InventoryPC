# InventoryPC

This script generates a full inventory from your Windows device including:

- HOSTNAME
- OS
- RAM
- SERIAL NUMBER
- DEVICE MODEL
- MICROPROCESSOR
- WINDOWS LICENSE -KMS OR OEM-
- SSID AND PASSWORD -If device is in English or Spanish-
- IP ADDRESS
- WIFI HARDWARE
- USER
- S.M.A.R.T HD STATUS
- MB/S WRITE IN HD
- TOTAL SIZE AND FREE SPACE IN ALL VOLUMES

  
Furthermore, Results of full inventory will be displayed in interactive table.

<img width="802" alt="image" src="https://github.com/Tudelaa/InventoryPC/assets/108870102/531857e3-dcd1-4fa8-8b7c-5aa34ce41f7f">

or in your CMD if you use the switch -Output "CMD"

<img width="1017" height="477" alt="image" src="https://github.com/user-attachments/assets/e902dea8-b8de-4741-88fd-b6d844310f99" />

# Version History

Version 1.20  11/2025

- Added the function Get-Diskmeasures to get the writte HD results in MB/S
- Added the function Get-WifiHardware to check if Wifi Hardware exist and get the brand and model
- Added the parameter -Output "table" to get the data in interactive table -by default- or -Output "CMD" if you want to see the info directly in your console
- Fixed some old lines of code

Version 1.10 

- Get some extra values from get-computerinfo instead of "systeminfo"
- added Microprocessor info
- added kind license activation -KMS or OEM-
- added S.M.A.R.T physical disk values


# how to run InventoryPC?

Open a Powershell console -make sure that you can run scripts not signed-

<img width="1505" alt="image" src="https://github.com/user-attachments/assets/90274064-49f2-4c31-a36d-cd54ce644df4" />

then navigate to folder where you have downloaded the file inventoryPC.ps1

![image](https://github.com/user-attachments/assets/569ece35-fdca-410d-a1e9-3197a3d5607e)

in case that security warning appears, press "Run once"

![image](https://github.com/user-attachments/assets/3f67185c-bc9b-48d8-b1f6-672fa83ec29f)

after several seconds, PCinventory will show a full inventory from your PC in a friendly table

![image](https://github.com/user-attachments/assets/1059c095-1a49-490a-b309-91cda2727a33)



