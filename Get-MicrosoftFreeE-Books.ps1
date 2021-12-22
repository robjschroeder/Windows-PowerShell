# this assumes you are in the folder you want to save to and the text file is here as well
$dir = Set-Location -Path "C:\users\username\downloads\Microsoft E-books"
$booklist = Get-Content "MSFTFreeEbooks.txt"
$destination = Get-Location
foreach ($url in $booklist)
{
    if ($url.StartsWith("http"))
    {
        $result = Invoke-WebRequest -Uri $url -OutFile $destination\temp.tmp -PassThru
        if ($result.statuscode -eq "200")
        {
            $filename = join-path $destination (Split-Path -leaf ($result.BaseResponse.ResponseUri))
            Write-Host $filename
            Rename-Item $destination\temp.tmp $filename
        }
    }
}