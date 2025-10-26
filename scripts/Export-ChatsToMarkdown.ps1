Param(
    [string]$ChatsDir = "documentation/chats",
    [string]$OutputFile = "documentation/generative-ai.md"
)

# Resolve repository root as the parent of the scripts directory
$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $scriptDir
Push-Location $repoRoot | Out-Null
try {
    # Normalize and resolve paths
    if (-not [System.IO.Path]::IsPathRooted($ChatsDir)) { $ChatsDir = Join-Path -Path $repoRoot -ChildPath $ChatsDir }
    if (-not [System.IO.Path]::IsPathRooted($OutputFile)) { $OutputFile = Join-Path -Path $repoRoot -ChildPath $OutputFile }

    if (-not (Test-Path -LiteralPath $ChatsDir -PathType Container)) {
        throw "Chats directory not found: $ChatsDir"
    }

    $chatFiles = Get-ChildItem -Path $ChatsDir -Filter 'chat*.json' -File |
        Sort-Object { [int]($_.BaseName -replace '[^0-9]', '') }

    if (-not $chatFiles) {
        throw "No chat JSON files found in $ChatsDir"
    }

    # Start fresh output (use ASCII hyphen to avoid encoding issues in some shells)
    "# Generative AI - All Conversations`r`n" | Out-File -FilePath $OutputFile -Encoding utf8

    $convIndex = 1
    foreach ($file in $chatFiles) {
        $jsonRaw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
        $chat = $jsonRaw | ConvertFrom-Json

    $model = $chat.responderUsername
    "`r`n## Conversation $convIndex`r`n`r`nDate: `r`n`r`nModel: $model`r`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8

        $turnIndex = 1
        foreach ($req in $chat.requests) {
            # Prompt (verbatim)
            $promptText = $req.message.text
            "`r`nPrompt (Turn $turnIndex):`r`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
            @"
```
$promptText
```
"@ | Out-File -FilePath $OutputFile -Append -Encoding utf8

            # Response (verbatim, concatenated in order of segments without injection)
            $respSegments = @()
            if ($req.response) {
                foreach ($r in $req.response) {
                    if ($null -ne $r.PSObject.Properties['value']) {
                        $respSegments += [string]$r.value
                    }
                }
            }
            $respText = ($respSegments -join '')
            "`r`nAI response (Turn $turnIndex):`r`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
            @"
```
$respText
```
"@ | Out-File -FilePath $OutputFile -Append -Encoding utf8

            $turnIndex++
        }

        # Notes section per conversation
    "`r`nNotes (optional):`r`n`r`n---" | Out-File -FilePath $OutputFile -Append -Encoding utf8
        $convIndex++
    }

    # Append reflection and checklist templates
    @"

## Reflection - How AI helped and what I learned

Write a short reflection addressing the following:

- Which tasks you used AI for (e.g., creating docs, generating code snippets, debugging, writing commands).
- How AI improved your workflow or saved time.
- Any limitations or inaccuracies you noticed and how you verified/fixed them.
- Key learnings from using AI for this milestone.

Minimum 200 words. Missing this reflection = 0 points.

---

## Checklist (student use)

- [ ] All prompts pasted (verbatim)
- [ ] All responses pasted (verbatim)
- [ ] Reflection written (>=200 words)
- [ ] File included in milestone submission

---

## Instructor notes

(Leave this empty for the grader or add any extra context.)
"@ | Out-File -FilePath $OutputFile -Append -Encoding utf8
}
finally {
    Pop-Location | Out-Null
}
