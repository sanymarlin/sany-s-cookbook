param(
    [string]$RecipeFileName,         # HTML file name (e.g., "new-recipe.html")
    [string]$Language,              # Language ("fr" or "en")
    [string]$DisplayTitle = $null   # Optional: Display title (if different from file name without extension)
)

# Constants
$IndexFilePath = "C:\Users\Sany Marlin\Proton Drive\My files\Documents\cookbooks\Sany's Cookbook\index.html"
$RecipesFolderPath = "C:\Users\Sany Marlin\Proton Drive\My files\Documents\cookbooks\Sany's Cookbook\Recipes"

# Ensure the Recipe File Name Ends with .html
if (-not ($RecipeFileName -like "*.html")) {
    $RecipeFileName += ".html"
}

# Validate Input
if (-not (Test-Path $IndexFilePath)) {
    Write-Error "Index file not found at $IndexFilePath"
    exit 1
}

if (-not (Test-Path "$RecipesFolderPath\$RecipeFileName")) {
    Write-Error "Recipe file not found in the Recipes folder"
    exit 1
}

# Generate Display Title if not provided
if (-not $DisplayTitle) {
    $DisplayTitle = [System.IO.Path]::GetFileNameWithoutExtension($RecipeFileName) -replace "-", " "
}

# Determine Target Section Based on Language
if ($Language -eq "fr") {
    $SectionTag = "french-recipes"
} elseif ($Language -eq "en") {
    $SectionTag = "english-recipes"
} else {
    Write-Error "Invalid language specified. Use 'fr' for French or 'en' for English."
    exit 1
}

# Read the HTML File with UTF-8 Encoding
$IndexContent = Get-Content -Path $IndexFilePath -Raw -Encoding UTF8

# Locate the Target Section
$SectionStart = $IndexContent.IndexOf("<div class=`"recipe-list $SectionTag`">")
if ($SectionStart -eq -1) {
    Write-Error "Target section for language '$Language' not found in the index.html file."
    exit 1
}

$UlStart = $IndexContent.IndexOf("<ul>", $SectionStart)
$UlEnd = $IndexContent.IndexOf("</ul>", $UlStart)
if ($UlStart -eq -1 -or $UlEnd -eq -1) {
    Write-Error "Could not find the <ul> tags in the target section."
    exit 1
}

# Extract Current Recipes
$UlContent = $IndexContent.Substring($UlStart + 4, $UlEnd - $UlStart - 4).Trim()
$CurrentRecipes = @()

if ($UlContent) {
    $CurrentRecipes = $UlContent -split "`n" | ForEach-Object {
        $_.Trim()
    }
}

# Add New Recipe
$NewRecipeTag = "<li><a href=`"Recipes/$RecipeFileName`">$DisplayTitle</a></li>"
$CurrentRecipes += $NewRecipeTag

# Sort Recipes Alphabetically by Display Title
$SortedRecipes = $CurrentRecipes | Sort-Object {
    if ($_ -match ">(.*?)</a>") {
        $Matches[1]
    } else {
        $_
    }
}

# Reconstruct the <ul> Section
$UpdatedUlContent = "<ul>`n    " + ($SortedRecipes -join "`n    ") + "`n</ul>"

# Replace the <ul> Section in the Original Content
$UpdatedContent = $IndexContent.Substring(0, $UlStart + 4) + "`n    " + $UpdatedUlContent + "`n" + $IndexContent.Substring($UlEnd)

# Save the Updated File with UTF-8 Encoding
Set-Content -Path $IndexFilePath -Value $UpdatedContent -Encoding UTF8

Write-Output "Successfully added recipe '$DisplayTitle' to the $Language section in alphabetical order."
