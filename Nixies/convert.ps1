param($height)
$inkscape = "C:\Program files\Inkscape\Inkscape.exe"
$magick = "C:\Program Files\ImageMagick-7.0.10-Q16\magick.exe"

$destination = Join-Path $(Get-Location) $height
New-Item -Path $destination -ItemType Directory -Force | Out-Null

$all = New-Object System.Collections.ArrayList
Get-ChildItem -Filter "*.svg" | Foreach-Object {
    $name_png = $([io.path]::ChangeExtension($_.Name, 'png' ))
    $name_bmp = $([io.path]::ChangeExtension($_.Name, 'bmp' ))

    # Keep track of all the .pngs
    $all.Add($name_png) | Out-Null

    # Invoke Inkscape on the .svg to produce a .png. Must wait for it to finsh.
    Start-Process -Wait -FilePath $inkscape @('-z', '-b #3b1c55',  '-y 1.0', "-h $height", "-e $name_png", "$($_.FullName)")

    # Invoke ImageMagick to conver the .png to a ver. 3 .bmp file.
    & $magick @('convert', $([io.path]::ChangeExtension($_.Name, 'png' )), "BMP3:$name_bmp")
    Move-Item -Destination $destination -Path $name_bmp -Force
}

# Convert all the .pngs into an animated .gif.
Write-Output 'All items: ' $all
& $magick convert -delay 50 $all -loop 0 "loop_$height.gif"
