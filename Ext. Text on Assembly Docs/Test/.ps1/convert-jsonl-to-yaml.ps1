# Converts all .jsonl files in the .resources folder to .yaml files in the desired format

Import-Module powershell-yaml

$resourcePath = ".resources"
Get-ChildItem -Path $resourcePath -Filter *.jsonl | ForEach-Object {
    $jsonlPath = $_.FullName
    $yamlPath = [System.IO.Path]::ChangeExtension($jsonlPath, ".yaml")
    $tests = @()

    # Each line in the .jsonl file is a separate test case
    Get-Content $jsonlPath | ForEach-Object {
        $jsonObj = $_ | ConvertFrom-Json
        $tests += $jsonObj
    }

    # Create a hashtable with the 'tests' key
    $yamlObj = @{ tests = $tests }

    # Convert to YAML and save
    $yamlObj | ConvertTo-Yaml | Set-Content $yamlPath
}