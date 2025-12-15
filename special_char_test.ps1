try {
    # Password has Uppercase, Lowercase, Digit, but NO Special Char
    $response = Invoke-RestMethod -Uri "http://localhost:5262/api/Auth/register" -Method Post -ContentType "application/json" -Body '{"email": "debug_user_08@test.com", "password": "Password123", "userName": "debuguser08"}' -ErrorAction Stop
    Write-Host "Success:"
    $response
} catch {
    Write-Host "Error Message:" $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        Write-Host "Body:"
        Write-Host $reader.ReadToEnd()
    }
}
