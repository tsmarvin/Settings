# Settings
1. The VSCode_settings.json file usually lives:
	- Windows Default: `%appdata%\Code\User\settings.json`
	- Portable: `{PortableVSCodeRoot}\data\user-data\User\settings.json`
2. The VSCode_keybindings.json file usually lives:
	- Windows Default: `%appdata%\Code\User\keybindings.json`
	- Portable: `{PortableVSCodeRoot}\data\user-data\User\keybindings.json`
3. My WindowsTerminal_settings.json file currently lives:
	- `%localappdata%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

<br>

# Profile
- Profile Paths:
```
Terminal Profile:
  $PROFILE.CurrentUserAllHosts
  $PROFILE.CurrentUserCurrentHost
  $PROFILE.AllUsersCurrentHost
  $PROFILE.AllUsersAllHosts

VSCode:
  ~/.config/powershell/Microsoft.VSCode_profile.ps1
```

- Dynamically find which profile paths exist:
```
$Profiles = @($PROFILE
	| Get-Member -MemberType NoteProperty
	| Select-Object -ExpandProperty Name
	| ForEach-Object { $Profile.$_ }
), '~/.config/powershell/Microsoft.VSCode_profile.ps1'
Foreach ($Path in $Profiles) { Get-Item $Path -ErrorAction Ignore }
```
