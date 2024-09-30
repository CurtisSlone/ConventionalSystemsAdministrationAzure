New-Item -Name "C:\index.html"

@"
<!DOCTYPE html>
<html>
<head>
    <title>My Basic HTML Page</title>
</head>
<body>
    <h1>Welcome to my website!</h1>
    <p>This is a basic HTML page created using PowerShell.</p>
</body>
</html>
"@ | Out-File -FilePath "C:\index.html"
