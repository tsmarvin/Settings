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
		$OutputPath = if ($CurrentPath.Split("$PathSep").count -lt 4) {
			"$CurrentPath>"
		} elseif ($CurrentPath.StartsWith('\\') -and ($CurrentPath.Split('\').count -ge 6)) {
			$PathSplit = $CurrentPath.Split('\')
			"\\$($PathSplit[2])\...\$($PathSplit[-2])\$($PathSplit[-1])>"
		} else {
			$PathSplit = $CurrentPath.Split($PathSep)
			"$($PathSplit[0])$PathSep...$PathSep$($PathSplit[-2])$PathSep$($PathSplit[-1])>"
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
		}

		# Add PSVersion number and current provider to WindowTitle
		$PSVersion = $PSVersionTable.PSVersion
		$WindowTitle += " v$($PSVersion.Major).$($PSVersion.Minor).$($PSVersion.Patch)"
		$WindowTitle += " [$($pwd.Provider.Name)]"
	}

	End {
		Try {
			# Attempt to update window title
			$Host.Ui.RawUi.WindowTitle = "$WindowTitle"
		} Catch {}
	}
}

Function Set-GitSettings {
	[CmdletBinding()]
	param ()

	begin {
		$GithubSSHKeyDefault = '~/.ssh/id_ed25519'
		Try { ssh-agent -k | Out-Null } Catch {}
	}

	process {
		$Output = (ssh-agent -s)
		$Env:SSH_AUTH_SOCK = $Output[0].Split('=')[1].split(';')[0]
		$Env:SSH_AGENT_PID = $Output[1].Split('=')[1].split(';')[0]
		$Env:GPG_TTY = tty

		$SSH = if (Test-Path $GithubSSHKeyDefault -PathType Leaf) {
			$GithubSSHKeyDefault
		} else {
			$Keys = Get-ChildItem -Path '~/.ssh/' -File | Where-Object {
				($_.Extension -ine '.pub') -and
				($_.name -ine 'known_hosts')
			}
			if ($Keys) {
				$Index = 0
				$KeyList = Foreach ($Key in $Keys) {
					[PSCustomObject]@{
						Number = $Index
						Path   = $Key.FullName
					}
					++$Index
				}
				$PromptAnswer = Read-Host -Prompt (
					"Enter the number corresponding to the ssh key to use.`n" +
					($KeyList | Format-Table | Out-String)
				)
				$Keys[$PromptAnswer].FullName
			} else {
				$PSCmdlet.WriteError('No SSH Keys found.')
			}
		}
	}

	end { ssh-add $SSH }
}
