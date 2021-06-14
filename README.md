# Settings

```
The VSCode_settings.json file usually lives: %appdata%\Code\User\settings.json
The WindowsTerminal_settings.json file currently lives: %localappdata%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

<br>

# Profile

<p>

Profile Paths:
```
$PROFILE.CurrentUserAllHosts
$PROFILE.CurrentUserCurrentHost
$PROFILE.AllUsersCurrentHost
$PROFILE.AllUsersAllHosts
Linux VSCode: ~/.config/powershell/Microsoft.VSCode_profile.ps1
```

Quickly find which profile paths exist:
```
Foreach ($Path in (
		$PROFILE.CurrentUserAllHosts,
		$PROFILE.CurrentUserCurrentHost,
		$PROFILE.AllUsersCurrentHost,
		$PROFILE.AllUsersAllHosts,
		'~/.config/powershell/Microsoft.VSCode_profile.ps1'
	)
){ Get-Item $Path -ErrorAction Ignore }
```
</p>
