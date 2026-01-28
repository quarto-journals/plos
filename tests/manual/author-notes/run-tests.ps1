#!/usr/bin/env pwsh
# Test runner for PLOS author notes conditional rendering

$ErrorActionPreference = "Continue"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PLOS Author Notes Test Suite" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Copy _extensions to tests directory
Write-Host "Setting up test environment..." -ForegroundColor Yellow
$sourceExt = "../../../_extensions"
$destExt = "_extensions"

if (Test-Path $destExt) {
    Remove-Item -Recurse -Force $destExt
}
Copy-Item -Recurse $sourceExt $destExt
Write-Host "  ✓ Extension copied to tests directory`n" -ForegroundColor Green

$tests = @(
    "test-no-notes",
    "test-equal-contributor",
    "test-deceased",
    "test-group",
    "test-current-address-single",
    "test-current-address-multiple",
    "test-current-address-duplicate",
    "test-custom-text"
)

$results = @()

foreach ($test in $tests) {
    Write-Host "Running: $test.qmd" -ForegroundColor Yellow

    # Render the document
    $output = quarto render "$test.qmd" 2>&1
    $renderSuccess = $LASTEXITCODE -eq 0

    if ($renderSuccess) {
        Write-Host "  ✓ Rendered successfully" -ForegroundColor Green

        # Extract author notes section from TEX file
        $texFile = "$test.tex"
        if (Test-Path $texFile) {
            Write-Host "`n  Author notes section:" -ForegroundColor Cyan
            $content = Get-Content $texFile -Raw

            # Extract the section between "Insert additional author notes" and "\end{flushleft}"
            if ($content -match '(?s)Insert additional author notes.*?Remove or comment out.*?\n(.*?)\n\s*% Use the asterisk') {
                $notesSection = $matches[1].Trim()
                if ($notesSection) {
                    $notesLines = $notesSection -split "`n"
                    foreach ($line in $notesLines) {
                        if ($line.Trim() -and -not ($line.Trim().StartsWith("%"))) {
                            Write-Host "    $line" -ForegroundColor White
                        }
                    }
                } else {
                    Write-Host "    (No notes rendered)" -ForegroundColor Gray
                }
            } else {
                Write-Host "    (Could not extract notes section)" -ForegroundColor Red
            }

            # Check for author superscripts
            if ($content -match 'Insert author names.*?\n(.*?)\n\\\\') {
                $authorLine = $matches[1].Trim()
                Write-Host "`n  Author line:" -ForegroundColor Cyan
                Write-Host "    $authorLine" -ForegroundColor White
            }
        }

        $results += [PSCustomObject]@{
            Test = $test
            Status = "PASS"
            PDF = Test-Path "$test.pdf"
        }
    } else {
        Write-Host "  ✗ Render failed" -ForegroundColor Red
        $results += [PSCustomObject]@{
            Test = $test
            Status = "FAIL"
            PDF = $false
        }
    }

    Write-Host ""
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$results | Format-Table -AutoSize

$passCount = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$totalCount = $results.Count

Write-Host "`nPassed: $passCount / $totalCount" -ForegroundColor $(if ($passCount -eq $totalCount) { "Green" } else { "Yellow" })

# Cleanup
Write-Host "`nCleaning up..." -ForegroundColor Yellow
if (Test-Path $destExt) {
    Remove-Item -Recurse -Force $destExt
    Write-Host "  ✓ Removed temporary extension copy" -ForegroundColor Green
}
