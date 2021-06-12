# Settings

```
The VSCode settings.json file usually lives: %appdata%\Code\User\settings.json
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
