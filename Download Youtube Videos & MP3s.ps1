# Define paths and URLs
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
$sevenZipUrl = "https://www.7-zip.org/a/7z2408-x64.exe"
$sevenZipTempPath = [System.IO.Path]::GetTempFileName() + ".exe"

$ytDlpPath = "C:\Program Files (x86)\yt-dlp\yt-dlp.exe"
$ytDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"

$ffmpegPath = "C:\Program Files (x86)\FFmpeg\bin\ffmpeg.exe"
$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$ffmpegExtractPath = "C:\Program Files (x86)\FFmpeg"

function Install-SevenZip {
    Write-Host "7-Zip not found. Installing..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipTempPath
    Start-Process -FilePath $sevenZipTempPath -ArgumentList "/S" -Wait
    Remove-Item -Path $sevenZipTempPath -Force
    if (Test-Path $sevenZipPath) {
        Write-Host "7-Zip installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "7-Zip installation failed." -ForegroundColor Red
    }
}

function Install-YtDlp {
    Write-Host "yt-dlp not found. Installing..." -ForegroundColor Yellow
    $ytDlpTempPath = [System.IO.Path]::GetTempFileName()
    Invoke-WebRequest -Uri $ytDlpUrl -OutFile $ytDlpTempPath
    New-Item -Path "C:\Program Files (x86)\yt-dlp" -ItemType Directory -Force
    Move-Item -Path $ytDlpTempPath -Destination $ytDlpPath
    if (Test-Path $ytDlpPath) {
        Write-Host "yt-dlp installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "yt-dlp installation failed." -ForegroundColor Red
    }
}

function Install-Ffmpeg {
    Write-Host "FFmpeg not found. Installing..." -ForegroundColor Yellow
    $ffmpegZipTempPath = [System.IO.Path]::GetTempFileName() + ".zip"
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $ffmpegZipTempPath
    Write-Host "Extracting FFmpeg..." -ForegroundColor Yellow
    
    New-Item -Path $ffmpegExtractPath -ItemType Directory -Force
    Expand-Archive -Path $ffmpegZipTempPath -DestinationPath $ffmpegExtractPath -Force

    $extractedFolder = Get-ChildItem -Path $ffmpegExtractPath -Directory | Select-Object -First 1
    if ($extractedFolder) {
        Get-ChildItem -Path $extractedFolder.FullName -Recurse | Move-Item -Destination $ffmpegExtractPath -Force
        Remove-Item -Path $extractedFolder.FullName -Recurse -Force
    }

    Remove-Item -Path $ffmpegZipTempPath -Force
    if (Test-Path $ffmpegPath) {
        Write-Host "FFmpeg installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "FFmpeg installation failed." -ForegroundColor Red
    }
}

# Install any missing components
if (-not (Test-Path $sevenZipPath)) { Install-SevenZip }
else { Write-Host "7-Zip is already installed." -ForegroundColor Green }

if (-not (Test-Path $ytDlpPath)) { Install-YtDlp }
else { Write-Host "yt-dlp is already installed." -ForegroundColor Green }

if (-not (Test-Path $ffmpegPath)) { Install-Ffmpeg }
else { Write-Host "FFmpeg is already installed." -ForegroundColor Green }

Write-Host "All installation tasks completed." -ForegroundColor Cyan
Start-Sleep -Seconds 2

# Global counters
$global:successCount = 0
$global:failureCount = 0
$desktopPath = [Environment]::GetFolderPath('Desktop')

# Function: Download video with audio
function Download-YouTubeVideoWithAudio {
    param ([string]$VideoUrl)
    $outputPath = "$env:USERPROFILE\Desktop\%(title)s.%(ext)s"
    $ffmpegQuotedPath = "`"$ffmpegPath`""
    Write-Host "Downloading video with audio..." -ForegroundColor Cyan
    $result = & $ytDlpPath $VideoUrl -f "bestvideo+bestaudio/best" --merge-output-format mp4 --ffmpeg-location $ffmpegQuotedPath -o $outputPath --newline 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -eq 0) {
        $global:successCount++
    } else {
        $global:failureCount++
        Write-Host "Error: $result" -ForegroundColor Yellow
    }
}

# Function: Download audio only
function Download-YouTubeAudio {
    param ([string]$VideoUrl)
    $outputPath = "$env:USERPROFILE\Desktop\%(title)s.%(ext)s"
    $ffmpegQuotedPath = "`"$ffmpegPath`""
    Write-Host "Downloading audio only..." -ForegroundColor Cyan
    $result = & $ytDlpPath $VideoUrl -x --audio-format mp3 --ffmpeg-location $ffmpegQuotedPath -o $outputPath --newline 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -eq 0) {
        $global:successCount++
    } else {
        $global:failureCount++
        Write-Host "Error: $result" -ForegroundColor Yellow
    }
}

# Function: Download video only (no audio)
function Download-YouTubeVideoOnly {
    param ([string]$VideoUrl)
    $outputPath = "$env:USERPROFILE\Desktop\%(title)s.%(ext)s"
    $ffmpegQuotedPath = "`"$ffmpegPath`""
    Write-Host "Downloading video only..." -ForegroundColor Cyan
    $result = & $ytDlpPath $VideoUrl -f "bestvideo[ext=mp4]" --ffmpeg-location $ffmpegQuotedPath -o $outputPath --newline 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -eq 0) {
        $global:successCount++
    } else {
        $global:failureCount++
        Write-Host "Error: $result" -ForegroundColor Yellow
    }
}

# Function: Convert MP4 to MP3
function Convert-Mp4ToMp3 {
    param ([string]$mp4FilePath)
    if (-not (Test-Path $mp4FilePath)) {
        Write-Host "File not found: $mp4FilePath" -ForegroundColor Red
        return
    }
    $mp3FilePath = [System.IO.Path]::ChangeExtension($mp4FilePath, ".mp3")
    Write-Host "Converting to MP3..." -ForegroundColor Cyan
    $result = & $ffmpegPath -i $mp4FilePath -q:a 0 -map a $mp3FilePath 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "MP3 saved to $mp3FilePath" -ForegroundColor Green
    } else {
        Write-Host "Conversion failed." -ForegroundColor Red
    }
}

# Main loop
do {
    Clear-Host
    Write-Host "Select download/conversion type:" -ForegroundColor Cyan
	Write-Host "[V] Video + Audio (MP4)"
	Write-Host "[A] Audio only (MP3)"
	Write-Host "[S] Video only (no audio)"
	Write-Host "[C] Convert existing MP4 to MP3"
	$downloadType = Read-Host "Enter your choice (V, A, S, or C)"
	
    $input = Read-Host "Enter a YouTube URL or MP4 path"
    $input = $input.Trim('"')

    switch ($downloadType.ToUpper()) {
        'V' { Download-YouTubeVideoWithAudio -VideoUrl $input }
        'A' { Download-YouTubeAudio -VideoUrl $input }
        'S' { Download-YouTubeVideoOnly -VideoUrl $input }
        'C' { Convert-Mp4ToMp3 -mp4FilePath $input }
        default {
            Write-Host "Invalid option. Use 'V', 'A', 'S', or 'C'." -ForegroundColor Red
        }
    }

    Write-Host "`nWould you like to process another? (Y/N)" -ForegroundColor Yellow -NoNewLine
    $retry = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
} while ($retry -eq 'Y' -or $retry -eq 'y')

Write-Host "`nAll done! Successes: $global:successCount | Failures: $global:failureCount" -ForegroundColor Cyan
