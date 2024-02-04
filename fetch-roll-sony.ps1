param(
  [Alias("b")]
  # 备份路径
  [string]$backupPath = ".\"
)
# 获取所有盘符
$drives = Get-PSDrive -PSProvider FileSystem
# 遍历每个盘符
foreach ($drive in $drives) {
  # 寻找索尼相机卡，拼接文件路径
  $file = Join-Path -Path $drive.Root -ChildPath "/PRIVATE/SONY/SONYCARD.IND"
  # 判断文件是否存在
  if (Test-Path -Path $file) {
    # 底片盘路径
    $rollDrives.Add($drive.Root)
  }
}
# 检查是否找到了相机卡
if (-not $rollDrives -or ($rollDrives.count -eq 0)) {
  # 输出错误信息
  Write-Output "Camara roll drive is not found."
  timeout /t -1
}
else {
  foreach ($rollDrive in $rollDrives) {
    # 复制新文件
    doCopy($rollDrive, $backupPath)
  }
  doArchive
}
function doCopy {
  param (
    $src,
    $dest
  )
  robocopy $src $dest /e /xo /copy:dat 
}
function doArchive {
  $videoFolderPath = "$backupPath\PRIVATE\"
  # 检查视频目录是否存在
  if (((Test-Path -Path $videoFolderPath))) {
    $videoFolder = Get-Item "$videoFolderPath"
    $dateString = $date.ToString("yyMMddHHmm")
    if ((-not (Test-Path -Path ($videoFolderPath.TrimEnd('\') + "-" + $dateString)))) {
      $newName = "PRIVATE-" + $dateString
      Write-Output "Video directory is found. Archiving."
      Write-Output "Video directory archive time: "$dateString
      # 归档视频目录
      Rename-Item -LiteralPath $videoFolder -NewName $newName
    } 
  }
  else {
    # 目录不存在，跳过
    Write-Output "The video directory does not exist. Archive skipping."
  }
  timeout /t -1
}
