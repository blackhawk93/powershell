$profiles = (netsh wlan show profiles) -match '\s{1,}:\s' -replace '.*:\s' , ''

ForEach($i in $profiles){

    $passwords = (netsh wlan show profiles $i key=clear |findstr "Key Content") -replace '.*:\s', ''
    echo "SSID: $i"
    echo "Password: $passwords `n"
    
}