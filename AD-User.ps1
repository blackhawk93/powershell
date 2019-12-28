Import-Module ActiveDirectory

# This script will help you in adding a user to active directory 
# Certain tasks are automated such as default password and users home directory creation
# The script will only run under as an admnistrator or the user should be in the domain admins group
# Certain options and folder paths will need to be edited for your environment


function Add-User{

    $exit = ""
    $test = $null
   

    Try {

        while ($exit -ne 'q'){

            # Getting the user details via input from admin. You can add more options of your choosing

            echo "**********  ACTIVE DIRECTORY COMMANDLINE SERVICE  **********`n`n"
            echo "-----  Here you can add users at ease  -----`n`n`n"
            $firstname = Read-Host -Prompt "Enter users first name: "
            $lastname = Read-Host -Prompt "Enter users last name: "
            $emailaddress = Read-Host -Prompt "Enter E-mail Address: "
            $mobile = Read-Host -Prompt "Enter mobile number: "
            
            # Setting up a static password rather than typing new passwords for each user
            # We will make the user to change the password at logon time

            $password = "P@ssw0rd"
            $loop = 2
    
            while ($loop -ne 1){

                try{

                    # Where to store the user account in active directory
                    # This is the location of the OU you need to add the user to
                    # Method to get the location: 
                    # Open Active Directory Users and Computers --> view --> Enable Advanced Features
                    # Then right-click the relevant OU and select properties
                    # Select Attribute Editor tab and scroll down to where is says distinguishedName
                    # Copy the value as this is the OU Path
                    # $OUPath = "OU=somename,DC=domainname,DC=com"


                    #But for now we will be storing the OU Path automatically according to user supplied OU

                    $OU = Read-Host -Prompt "`nWhich OU do you want to add the user to? Press L to list all available OU's"
                    

                    if ($OU -ieq "L"){

                        echo "`nPlease select your OU from below: `n"

                        Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A           # Lets display all the available OU's to select from

                        $OU = Read-Host -Prompt "`nWhich OU ? "          # Get the user to enter their prefered OU

                        Get-ADOrganizationalUnit -Filter "Name -like '$OU'" | ft DistinguishedName -A -hide -outvariable test
                
                        if ($test -ne $null){

                            # Here we are Getting the DistinguishedName of the OU and storing the output to a file as an Array
                    
                            Get-ADOrganizationalUnit -Filter "Name -like '$OU'" | ft DistinguishedName -A -hide -outvariable test > "C:\Windows\Temp\OUPath.txt"           
                            $loop = 1

                        }
                
                        else {
                    
                            echo "`nYou have entered a OU that doesn't exist. Please re-Enter`n"
                    
                        }


                    }

                    else {

                        Get-ADOrganizationalUnit -Filter "Name -like '$OU'" | ft DistinguishedName -A -hide -outvariable test
                
                        if ($test -ne $null){

                            # Here we are Getting the DistinguishedName of the OU and storing the output to a file as an Array
                    
                            Get-ADOrganizationalUnit -Filter "Name -like '$OU'" | ft DistinguishedName -A -hide -outvariable test > "C:\Windows\Temp\OUPath.txt"    
                            $loop = 1

                        }
                
                        else {
                    
                            echo "`nYou have entered a OU that doesn't exist. Please re-Enter"                    
                            
                        }
                
                
                    }

                }

                Catch {
    
                    echo "An error has occured. Please try again "
    
                }
            }

               

                $OUPath = Get-Content -Path "C:\Windows\Temp\OUPath.txt" | Out-String          # We need to read the file as a String and store its contents in a variable
   
                $OUPath = $OUPath.Trim()          # Here we are trimming the contents for the white spaces which are in the file

                $securePassword = ConvertTo-SecureString $password -AsPlainText -Force          # Convert the password as a secure string (Encryption)

                # Below is the command for adding the user to Active Directory

                New-ADUser -Name "$firstname $lastname" -GivenName $firstname -Surname $lastname -UserPrincipalName "$firstname.$lastname" -Path $OUPath -AccountPassword $securePassword -ChangePasswordAtLogon $true -EmailAddress $emailaddress -MobilePhone $mobile -HomeDirectory "\\DC01\share\$firstname $lastname" -HomeDrive "Z:" -Enabled $true
                
                # Here we are creating the users home directory. Edit this according to your environment
                
                New-Item -Path "\\DC01\share\" -Name "$firstname $lastname" -ItemType Directory
                
                $Acl = Get-Acl "\\DC01\share\$firstname $lastname"         

                $AR = New-Object System.Security.AccessControl.FileSystemAccessRule("$firstname $lastname", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

                $Acl.SetAccessRule($AR) 

                Set-Acl "\\DC01\share\$firstname $lastname" $Acl          # We are assigning the permissions to the relavent home directory
                
                Remove-Item -Path "C:\Windows\Temp\OUPath.txt"   # Once we are done we no longer need to store this file therefore it is been deleted.

                echo "`nUser $firstname $lastname has been added successfully`n"

                $exit = Read-Host -Prompt "`nPress Enter to add another user or 'q' to exit: " 

        }

    }

    Catch {


        echo "`nAn Error has Occured. Please re-enter`n"
        Add-User
        

    }
    
    echo "`n**********  Thank you for using Active Directory Commandline Service  **********`n"

}

Add-User




