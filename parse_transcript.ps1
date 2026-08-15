$transcriptPath = "C:\Users\BCOC2020\.gemini\antigravity-ide\brain\bce7cdd0-d4ea-4428-b323-48bc26453203\.system_generated\logs\transcript_full.jsonl"
$outputPath = "c:\Users\Public\Documents\Foundations of Faith\믿음의기초_모바일.html"

# Read transcript and extract view_file output
$viewFileOutput = ""
foreach ($line in [System.IO.File]::ReadLines($transcriptPath)) {
    if ($line -match '"type":"TOOL_RESPONSE"' -and $line -match '"name":"default_api:view_file"') {
        $json = $line | ConvertFrom-Json
        $viewFileOutput = $json.content
        break
    }
}

if ([string]::IsNullOrEmpty($viewFileOutput)) {
    Write-Host "Could not find view_file output in transcript."
    exit 1
}

# Extract OCR text
$lines = $viewFileOutput -split "`n"
$extractedText = @()
$inOcr = $false

foreach ($line in $lines) {
    if ($line -match "==Start of OCR for page") {
        $inOcr = $true
        continue
    }
    if ($line -match "==End of OCR for page") {
        $inOcr = $false
        continue
    }
    if ($inOcr) {
        $extractedText += $line.Trim()
    }
}

# Combine and process text
$fullText = $extractedText -join " "

# Remove page numbers like "1", "2" that might be joined
# But actually, the text is joined with spaces. 
# A better way is to process line by line to preserve paragraph breaks, but the OCR might have broken lines.
$processedLines = @()
$currentParagraph = ""

foreach ($line in $extractedText) {
    if ($line -match '^\d+$') {
        continue # Skip page numbers
    }
    if ($line -eq "") {
        if ($currentParagraph -ne "") {
            $processedLines += $currentParagraph
            $currentParagraph = ""
        }
    } else {
        $currentParagraph += $line + " "
    }
}
if ($currentParagraph -ne "") {
    $processedLines += $currentParagraph
}

# Generate HTML
$html = @"
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>믿음의 기초</title>
<style>
    body {
        font-family: 'Malgun Gothic', sans-serif;
        font-size: 24px; /* Large font */
        font-weight: bold; /* Bold text */
        line-height: 1.6;
        padding: 20px;
        background-color: #f9f9f9;
        color: #333;
    }
    h1 {
        text-align: center;
        font-size: 36px;
        margin-bottom: 30px;
        color: #222;
    }
    h2 {
        font-size: 30px;
        color: #0056b3;
        margin-top: 40px;
        padding-bottom: 10px;
        border-bottom: 2px solid #ccc;
    }
    h3 {
        font-size: 26px;
        color: #007bff;
        margin-top: 30px;
    }
    p {
        margin-bottom: 20px;
        text-align: justify;
    }
    .toc {
        background-color: #fff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        margin-bottom: 40px;
    }
    .toc h2 {
        margin-top: 0;
        border-bottom: none;
    }
    .toc ul {
        list-style-type: none;
        padding-left: 0;
    }
    .toc li {
        margin-bottom: 15px;
    }
    .toc a {
        text-decoration: none;
        color: #0056b3;
        display: block;
        padding: 10px;
        background-color: #e9ecef;
        border-radius: 5px;
    }
    .toc a:hover {
        background-color: #cce5ff;
    }
    .home-btn {
        display: block;
        width: 120px;
        text-align: center;
        margin: 30px auto;
        padding: 15px;
        background-color: #007bff;
        color: #fff;
        text-decoration: none;
        border-radius: 8px;
        font-size: 20px;
    }
    .home-btn:hover {
        background-color: #0056b3;
    }
    .content-block {
        background-color: #fff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        margin-bottom: 30px;
    }
</style>
</head>
<body>

<h1 id="toc">믿음의 기초</h1>
<div class="toc">
    <h2>차례 (Table of Contents)</h2>
    <ul>
"@

# Define chapters for TOC and content splitting
$chapters = @(
    "1. 하나님 찾기",
    "2. 예수님 알기",
    "3. 하나님의 말씀",
    "4. 세상의 지혜 또는 하나님의 지혜",
    "5. 죄",
    "6. 십자가",
    "7. 믿음을 통해 은혜로 구원받기",
    "8. 회개",
    "9. 예수님과 연합하는 세례",
    "10. 제자의 삶",
    "11. 성령의 사역",
    "12. 교회",
    "#보충자료",
    "1. 성경의 신뢰성",
    "2. 예수님의 실존 증거",
    "3. 예수님의 성품",
    "4. 예수님의 부활",
    "5. 예수님의 십자가 처형 보고서",
    "6. 예배",
    "7. 성찬",
    "8. 헌금",
    "9. 성화, 성숙의 길, 제자훈련",
    "#FAQ"
)

$chapterIds = @{}
$i = 1
foreach ($chap in $chapters) {
    $id = "chap_$i"
    $chapterIds[$chap] = $id
    $html += "<li><a href='#$id'>$chap</a></li>`n"
    $i++
}

$html += @"
    </ul>
</div>
<div class="content-block">
"@

$currentChapter = ""

foreach ($para in $processedLines) {
    $isChapterTitle = $false
    
    foreach ($chap in $chapters) {
        if ($para.StartsWith($chap) -and $para.Length -lt ($chap.Length + 20)) {
            if ($currentChapter -ne "") {
                $html += "<a href='#toc' class='home-btn'>처음으로</a>`n</div>`n<div class='content-block'>`n"
            }
            $currentChapter = $chap
            $id = $chapterIds[$chap]
            $html += "<h2 id='$id'>$para</h2>`n"
            $isChapterTitle = $true
            break
        }
    }
    
    if (-not $isChapterTitle) {
        # Break long paragraphs into semantic blocks (split by sentences)
        if ($para.Length -gt 200) {
            # split by '. '
            $sentences = $para -split "\. "
            $newPara = ""
            $count = 0
            foreach ($sentence in $sentences) {
                $newPara += $sentence
                if (-not $sentence.EndsWith(".")) {
                    $newPara += ". "
                }
                $count++
                if ($count -ge 3) { # Group 3 sentences
                    $html += "<p>$newPara</p>`n"
                    $newPara = ""
                    $count = 0
                }
            }
            if ($newPara.Trim() -ne "") {
                $html += "<p>$newPara</p>`n"
            }
        } else {
            $html += "<p>$para</p>`n"
        }
    }
}

$html += "<a href='#toc' class='home-btn'>처음으로</a>`n</div>`n</body>`n</html>"

[System.IO.File]::WriteAllText($outputPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "Successfully generated HTML at $outputPath"
