Set-Location C:\bc-replay

$Env:Username='Playwright'
$Env:Password='Workshop4you!'

npx replay `
    -Tests '.\C:\bc-replay\recordings\demo 1\*.yml' `
    -StartAddress https://d365bc25/BC/ `
    -Authentication UserPassword `
    -UserNameKey 'Username' `
    -PasswordKey 'Password' `
    -ResultDir .\results

npx playwright show-report results\playwright-report