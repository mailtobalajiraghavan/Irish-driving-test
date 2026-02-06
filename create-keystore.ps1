$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$keystore = "keystore/upload-keystore-new.jks"
$alias = "upload"
$storepass = "IrishDrivingTest2026!"
$keypass = "UploadKey2026!"
$dname = "CN=Irish Driving Test, OU=Antigravity, O=Antigravity, L=Dublin, ST=Leinster, C=IE"

& $keytool -genkey -v -keystore $keystore -keyalg RSA -keysize 2048 -validity 10000 -alias $alias -storepass $storepass -keypass $keypass -dname $dname

Write-Host "Keystore created successfully at: $keystore"
Write-Host "Store Password: $storepass"
Write-Host "Key Password: $keypass"
Write-Host "Alias: $alias"
