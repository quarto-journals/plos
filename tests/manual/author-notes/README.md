# Author Notes Conditional Rendering Tests

## Overview

This test suite verifies the conditional rendering of author notes in the PLOS template, ensuring that note symbols and explanations only appear when at least one author has the corresponding attribute.

**Related:** [Issue #16](https://github.com/quarto-journals/plos/issues/16)

## Purpose

The PLOS template supports four types of author notes:
- `\Yinyang` Equal Contribution
- `\textcurrency` Current Address
- `\dag` Deceased
- `\textpilcrow` Group/Consortium

Previously, all four note types were rendered unconditionally. This test suite ensures that each note only appears when an author has the corresponding attribute.

## Prerequisites

- [Quarto](https://quarto.org) installed
- PowerShell (pwsh) for running the test script
- LaTeX distribution (for PDF rendering)

## Running the Tests

From this directory, run:

```powershell
pwsh ./run-tests.ps1
```

The script will:
1. Copy the `_extensions` directory to this location (temporary)
2. Render all 8 test documents
3. Extract and display author notes sections from LaTeX output
4. Verify PDF generation
5. Clean up temporary files
6. Display summary report

## Test Cases

### Test 1: No Special Attributes
**File:** `test-no-notes.qmd`
**Purpose:** Verify that NO author notes render when authors have no special attributes
**Expected:** Empty author notes section, only affiliation numbers in author list

### Test 2: Only Equal Contributor
**File:** `test-equal-contributor.qmd`
**Purpose:** Verify conditional rendering of equal contributor note
**Expected:** ONLY `\Yinyang These authors contributed equally to this work.`

### Test 3: Only Deceased
**File:** `test-deceased.qmd`
**Purpose:** Verify conditional rendering of deceased note
**Expected:** ONLY `\dag Deceased`

### Test 4: Only Group/Consortium
**File:** `test-group.qmd`
**Purpose:** Verify conditional rendering of group note
**Expected:** ONLY `\textpilcrow Membership list can be found in the Acknowledgments section.`

### Test 5: Single Current Address
**File:** `test-current-address-single.qmd`
**Purpose:** Verify single current address renders with NO letter suffix
**Expected:** `\textcurrency Current Address: ...` (no 'a', 'b', 'c')

### Test 6: Multiple Current Addresses
**File:** `test-current-address-multiple.qmd`
**Purpose:** Verify multiple addresses get letter suffixes (a, b, c)
**Expected:**
```latex
\textcurrency a Current Address: Department X, ...
\textcurrency b Current Address: Department Y, ...
\textcurrency c Current Address: Department Z, ...
```

### Test 7: Duplicate Current Address
**File:** `test-current-address-duplicate.qmd`
**Purpose:** Verify deduplication - identical addresses share the same symbol
**Expected:** Two unique addresses in notes, authors with same address share symbol

### Test 8: Custom Author Notes Text
**File:** `test-custom-text.qmd`
**Purpose:** Verify custom text from `author-notes` metadata overrides defaults
**Expected:** Custom text appears instead of default messages

## Implementation Details

The conditional rendering is implemented via:

1. **Lua Filter** (`_extensions/plos/filter.lua`):
   - Detects which author attributes are present
   - Sets metadata flags (`has-equal-contributor`, `has-deceased`, etc.)
   - Handles current address deduplication and symbol assignment

2. **Template** (`_extensions/plos/partials/before-body.tex`):
   - Wraps each note type in `$if(has-*)$` conditionals
   - Only renders notes when flag is true

3. **Author Partial** (`_extensions/plos/partials/_authors.tex`):
   - Adds appropriate symbols to author names based on attributes

## Current Address Symbol Assignment

The current address feature uses special symbol assignment logic:

- **1 address:** Symbol is `\textcurrency` (no suffix)
- **2+ addresses:** All get letter suffixes: `\textcurrency a`, `\textcurrency b`, `\textcurrency c`
- **Deduplication:** Authors with identical address text share the same symbol

## Expected Results

All 8 tests should PASS:

```
Test                           Status  PDF
----                           ------  ---
test-no-notes                  PASS    True
test-equal-contributor         PASS    True
test-deceased                  PASS    True
test-group                     PASS    True
test-current-address-single    PASS    True
test-current-address-multiple  PASS    True
test-current-address-duplicate PASS    True
test-custom-text               PASS    True

Passed: 8 / 8
```

## Test Script Details

The `run-tests.ps1` script:

- **Copies extension:** Temporarily copies `_extensions` to allow rendering from test directory
- **Renders documents:** Uses `quarto render` on each test file
- **Extracts sections:** Parses LaTeX output to show author notes
- **Verifies PDFs:** Confirms successful PDF generation
- **Cleans up:** Removes temporary extension copy and generated files (via .gitignore)

## Directory Structure

```
tests/manual/author-notes/
├── .gitignore              # Excludes generated PDFs and LaTeX files
├── README.md               # This file
├── run-tests.ps1           # Test runner script
├── test-no-notes.qmd       # Test: No special attributes
├── test-equal-contributor.qmd   # Test: Equal contributor
├── test-deceased.qmd       # Test: Deceased author
├── test-group.qmd          # Test: Group/consortium
├── test-current-address-single.qmd      # Test: Single current address
├── test-current-address-multiple.qmd    # Test: Multiple current addresses
├── test-current-address-duplicate.qmd   # Test: Duplicate current addresses
└── test-custom-text.qmd    # Test: Custom author notes text
```

## Notes

- These tests are excluded from `quarto use template` via `.quartoignore`
- Generated PDFs and LaTeX files are excluded from git via `.gitignore`
- The `_extensions` directory is temporarily copied during test runs
