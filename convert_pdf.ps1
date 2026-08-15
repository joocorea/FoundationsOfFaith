$word = New-Object -ComObject Word.Application
$word.Visible = $false
$pdfPath = "c:\Users\Public\Documents\Foundations of Faith\믿음의기초.pdf"
$htmlPath = "c:\Users\Public\Documents\Foundations of Faith\믿음의기초_raw.html"

Write-Host "Opening PDF in Word..."
$doc = $word.Documents.Open($pdfPath, $false, $true)

Write-Host "Saving as HTML..."
# wdFormatHTML = 8, wdFormatFilteredHTML = 10
$saveFormat = [int]10
$doc.SaveAs([ref]$htmlPath, [ref]$saveFormat)

$doc.Close([ref]$false)
$word.Quit()
Write-Host "Done."
