Function Prompt {
	Begin {
		$PathSep = [IO.Path]::DirectorySeparatorChar
		$TimeStamp = (Get-Date -Format 'yyyyMMddHHmmsszz').ToString()
	}

	Process {
		if (-Not $env:SetWindowTitle) {
			Set-WindowTitle
			$env:SetWindowTitle = $true
		}
		$CurrentPath = $executionContext.SessionState.Path.CurrentLocation.Path

		if ($env:AdminContext) {
			# Add admin to command prompt
			Write-Host '[' -NoNewline -ForegroundColor White
			Write-Host 'Admin' -NoNewline -ForegroundColor Red
			Write-Host '] ' -NoNewline -ForegroundColor White
		}

		Write-Host "$TimeStamp " -NoNewline
		if ($pwd.Provider.Name -ne 'FileSystem') {
			# Add Provider type to prompt if its not filesystem.
			Write-Host '[' -NoNewline -ForegroundColor White
			Write-Host $pwd.Provider.Name -NoNewline -ForegroundColor Green
			Write-Host '] ' -NoNewline -ForegroundColor White
		}
		if ($CurrentPath.Split("$PathSep").count -lt 4) {
			$OutputPath = "$CurrentPath>"
		} else {
			if (($CurrentPath.StartsWith('\\')) -and (($CurrentPath.Split('\')).count -ge 6)) {
				$OutputPath = ("\\$($CurrentPath.Split('\')[2])\...\$($CurrentPath.Split('\')[-2])\$($CurrentPath.Split('\')[-1])>")
			} else {
				$OutputPath = "$($CurrentPath.Split("$PathSep")[0])$PathSep...$PathSep$($CurrentPath.Split("$PathSep")[-2])$PathSep$($CurrentPath.Split("$PathSep")[-1])>"
			}
		}
	}

	End { "$OutputPath" }
}

Function Set-WindowTitle {
	Begin {
		if (-Not $IsLinux) {
			$AdminCheck = [Security.Principal.WindowsPrincipal]::New(
				[Security.Principal.WindowsIdentity]::GetCurrent()
			).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
		}
		$WindowTitle = ''
	}

	Process {
		# Build WindowTitle
		if ($AdminCheck) {
			# Don't start in System32 by default.
			if ($executionContext.SessionState.Path.CurrentLocation.Path -ieq 'C:\Windows\System32') {
				Set-Location ~
			}
			$Env:AdminContext = $True
			$WindowTitle = '[Admin] '
			# Add admin to command prompt since it was missed on first startup.
		}

		# Add PSEdition to WindowTitle
		$WindowTitle += Switch ($PSVersionTable.PSEdition) {
			'Core' { 'PWSH' }
			'Desktop' { 'PS' }
			Default {}
		}

		# Add PSVersion number and current provider to WindowTitle
		$WindowTitle += " v$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)" # Done this way for win PS compat.
		$WindowTitle += " [$($pwd.Provider.Name)]"

		# Update window title
		Try {
			$Host.Ui.RawUi.WindowTitle = "$WindowTitle"
		} Catch {
			# Do Nothing.
		}
	}
	End {}
}

Function Set-GitSettings {
	ssh-agent -k | Out-Null
	$Output = (ssh-agent -s)

	$Env:SSH_AUTH_SOCK = $Output[0].Split('=')[1].split(';')[0]
	$Env:SSH_AGENT_PID = $Output[1].Split('=')[1].split(';')[0]
	$Env:GPG_TTY = tty

	ssh-add ~/.ssh/id_ed25519
}
