# release.ps1 — 一键发版（本机跑，不需要额外 CI 授权）
#
# 用法：
#   .\scripts\release.ps1                 # 用 package.json 的版本号
#   .\scripts\release.ps1 -Version 1.2.0  # 指定版本（会先改 package.json 再提交）
#   .\scripts\release.ps1 -DryRun         # 只打包不上传
#
# 做的事：语法自检 → npm pack → 打 tag → 推 tag → 建/更新 Release 并上传 tgz

param(
  [string]$Version,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$pkg = Get-Content "./package.json" -Raw | ConvertFrom-Json
$name = $pkg.name
$ver  = if ($Version) { $Version } else { $pkg.version }
$tag  = "v$ver"

Write-Host "== $name $tag ==" -ForegroundColor Cyan

# 1) 版本号对齐
if ($Version -and $pkg.version -ne $Version) {
  $pkg.version = $Version
  ($pkg | ConvertTo-Json -Depth 20) + "`n" | Set-Content "./package.json" -NoNewline
  Write-Host "  package.json version -> $Version"
}

# 2) JS 语法自检
$js = Get-ChildItem -Recurse -File -Include *.js,*.mjs,*.cjs | Where-Object { $_.FullName -notmatch "\(node_modules|.git)\" }
foreach ($f in $js) { node --check $f.FullName; if ($LASTEXITCODE -ne 0) { throw "syntax error: $($f.FullName)" } }
Write-Host "  语法自检通过：$($js.Count) 个文件"

# 3) 打包
Get-ChildItem ./*.tgz -EA SilentlyContinue | Remove-Item -Force
npm pack --ignore-scripts   # dist 已预编译，跳过 prepare 钩子（避免 tsc 缺失报错）
$tgz = Get-ChildItem ./*.tgz | Select-Object -First 1
Write-Host "  打包完成：$($tgz.Name)  $($tgz.Length) B"

if ($DryRun) { Write-Host "  -DryRun：跳过 git tag / 上传"; return }

# 4) 提交版本号（若有改动）
if ((git status --porcelain)) {
  git add -A
  git -c user.name=azure5100 -c user.email=710782721@qq.com commit -m "chore(release): $tag"
}

# 5) 打 tag 并推送
if (-not (git tag -l $tag)) { git tag $tag }
git push origin main
git push origin $tag

# 6) 建或更新 Release
$repo = (git remote get-url origin) -replace "^.*github\.com[:/]", "" -replace "\.git$", ""
$exists = gh release view $tag --repo $repo 2>$null
if ($exists) {
  gh release upload $tag $tgz.FullName --repo $repo --clobber
  Write-Host "  已更新 Release $tag 的资产"
} else {
  gh release create $tag $tgz.FullName --repo $repo --title "$name $tag" --generate-notes
  Write-Host "  已创建 Release $tag"
}

Write-Host "完成：https://github.com/$repo/releases/tag/$tag" -ForegroundColor Green
