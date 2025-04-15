# Download YouTube Videos & MP3s

A PowerShell script that downloads the highest quality YouTube videos and MP3s.

---

## 📁 Repo Contents

- `Download Youtube Videos & MP3s.ps1` – The main PowerShell script  
- `Download Youtube Videos & MP3s.ico` – Custom icon used for the executable  
- `Download Youtube Videos & MP3s.exe` – Compiled version of the script via Win-PS2EXE  

---

## ⚙️ What the Script Does

1. **Checks if 7-Zip is installed** – Required to unzip FFMPEG  
2. **Checks if yt-dlp is installed** – Handles all YouTube downloading  
3. **Checks if FFMPEG is installed** – Used for video and audio conversion  
4. **Installs any missing tools automatically**
5. **Prompts you for a YouTube video link**
6. **Gives you several download options:**
   - `V` – Video and audio (MP4)  
   - `A` – Audio only (MP3)  
   - `S` – Video only (MP4)  
   - `C` – Convert a local video/audio file (MP4) to MP3  
7. **Downloads the highest quality video first, then audio** using `yt-dlp`
8. **Combines and converts the downloaded files** to MP4 or MP3 using `FFMPEG`
9. **Saves your downloaded files to the user's Desktop**
10. **Asks if you want to download another video** once complete

---

## ✅ Requirements (installed automatically if missing)

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)  
- [FFmpeg](https://ffmpeg.org/)  
- [7-Zip](https://www.7-zip.org/)

---

## 💡 Tip

You can right-click the `.ps1` file and choose **"Run with PowerShell"**, or use the included `.exe` if you prefer a double-clickable app experience.
