$ErrorActionPreference = 'Stop'

function New-RGB {
    param([int]$R, [int]$G, [int]$B)
    return ($R + ($G * 256) + ($B * 65536))
}

# Theme colors
$PRIMARY = New-RGB 31 58 95      # #1F3A5F
$SECONDARY = New-RGB 77 163 255  # #4DA3FF
$ACCENT = New-RGB 245 166 35     # #F5A623
$BG_LIGHT = New-RGB 245 247 250
$WHITE = New-RGB 255 255 255
$TEXT_DARK = New-RGB 30 42 54
$MUTED_BORDER = New-RGB 216 226 236

# Common constants
$msoTrue = -1
$msoFalse = 0
$msoTextOrientationHorizontal = 1
$ppLayoutBlank = 12
$ppAlignLeft = 1
$ppAlignCenter = 2
$ppAlignRight = 3

$msoShapeRectangle = 1
$msoShapeRoundedRectangle = 5
$msoShapeOval = 9
$msoShapeRightArrow = 33
$msoShapeDownArrow = 36

function Add-Textbox {
    param(
        $Slide,
        [float]$Left,
        [float]$Top,
        [float]$Width,
        [float]$Height,
        [string]$Text,
        [string]$FontName = 'Calibri',
        [int]$FontSize = 20,
        [bool]$Bold = $false,
        [int]$Color = 0,
        [int]$Align = 1
    )

    $box = $Slide.Shapes.AddTextbox($msoTextOrientationHorizontal, $Left, $Top, $Width, $Height)
    $range = $box.TextFrame.TextRange
    $range.Text = $Text
    $range.Font.Name = $FontName
    $range.Font.Size = $FontSize
    $range.Font.Bold = $(if ($Bold) { $msoTrue } else { $msoFalse })
    $range.Font.Color.RGB = $Color
    $range.ParagraphFormat.Alignment = $Align
    return $box
}

function Add-Bullets {
    param(
        $Slide,
        [float]$Left,
        [float]$Top,
        [float]$Width,
        [float]$Height,
        [string[]]$Items,
        [int]$FontSize = 18,
        [int]$Color = 0
    )

    $text = ($Items | ForEach-Object { "- $_" }) -join "`r`n"
    $box = Add-Textbox -Slide $Slide -Left $Left -Top $Top -Width $Width -Height $Height -Text $text -FontName 'Calibri' -FontSize $FontSize -Bold $false -Color $Color -Align $ppAlignLeft
    $box.TextFrame.TextRange.ParagraphFormat.SpaceAfter = 8
    return $box
}

function Add-RoundedCard {
    param(
        $Slide,
        [float]$Left,
        [float]$Top,
        [float]$Width,
        [float]$Height,
        [int]$LineColor
    )

    $card = $Slide.Shapes.AddShape($msoShapeRoundedRectangle, $Left, $Top, $Width, $Height)
    $card.Fill.ForeColor.RGB = $WHITE
    $card.Line.ForeColor.RGB = $LineColor
    $card.Line.Weight = 1.5
    return $card
}

function Add-Header {
    param($Slide, [string]$Title, [int]$SlideNo)

    $band = $Slide.Shapes.AddShape($msoShapeRectangle, 0, 0, 960, 44)
    $band.Fill.ForeColor.RGB = $BG_LIGHT
    $band.Line.Visible = $msoFalse

    $line = $Slide.Shapes.AddShape($msoShapeRectangle, 0, 42, 960, 3)
    $line.Fill.ForeColor.RGB = $SECONDARY
    $line.Line.Visible = $msoFalse

    Add-Textbox -Slide $Slide -Left 40 -Top 8 -Width 760 -Height 30 -Text $Title -FontName 'Poppins' -FontSize 24 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
    Add-Textbox -Slide $Slide -Left 885 -Top 10 -Width 55 -Height 20 -Text ("{0}/10" -f $SlideNo) -FontName 'Calibri' -FontSize 12 -Bold $true -Color $PRIMARY -Align $ppAlignRight | Out-Null
}

$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = $msoTrue

$presentation = $ppt.Presentations.Add()
$presentation.PageSetup.SlideWidth = 960
$presentation.PageSetup.SlideHeight = 540

# Slide 1 - Title Slide
$slide = $presentation.Slides.Add(1, $ppLayoutBlank)

$leftPanel = $slide.Shapes.AddShape($msoShapeRectangle, 0, 0, 300, 540)
$leftPanel.Fill.ForeColor.RGB = $PRIMARY
$leftPanel.Line.Visible = $msoFalse

$accentStrip = $slide.Shapes.AddShape($msoShapeRectangle, 0, 493, 300, 47)
$accentStrip.Fill.ForeColor.RGB = $ACCENT
$accentStrip.Line.Visible = $msoFalse

Add-Textbox -Slide $slide -Left 35 -Top 95 -Width 230 -Height 210 -Text "Auction`r`nManagement`r`nSystem" -FontName 'Poppins' -FontSize 46 -Bold $true -Color $WHITE -Align $ppAlignLeft | Out-Null
Add-Textbox -Slide $slide -Left 340 -Top 74 -Width 560 -Height 38 -Text "Software Engineering Project Presentation" -FontName 'Montserrat' -FontSize 23 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null

$today = Get-Date -Format 'MMMM dd, yyyy'
Add-Bullets -Slide $slide -Left 350 -Top 145 -Width 520 -Height 190 -Items @(
    'Presenter: [Your Name]',
    'Course: [Course Name / Code]',
    'Institution: [Institution Name]',
    "Date: $today"
) -FontSize 18 -Color $TEXT_DARK | Out-Null

# Gavel icon (shape composition)
$handle = $slide.Shapes.AddShape($msoShapeRoundedRectangle, 730, 312, 150, 14)
$handle.Fill.ForeColor.RGB = $PRIMARY
$handle.Line.Visible = $msoFalse
$handle.Rotation = -25

$head1 = $slide.Shapes.AddShape($msoShapeRectangle, 670, 264, 86, 28)
$head1.Fill.ForeColor.RGB = $ACCENT
$head1.Line.Visible = $msoFalse
$head1.Rotation = -25

$head2 = $slide.Shapes.AddShape($msoShapeRectangle, 722, 238, 86, 28)
$head2.Fill.ForeColor.RGB = $ACCENT
$head2.Line.Visible = $msoFalse
$head2.Rotation = -25

$base = $slide.Shapes.AddShape($msoShapeRoundedRectangle, 665, 370, 190, 18)
$base.Fill.ForeColor.RGB = $SECONDARY
$base.Line.Visible = $msoFalse

# Slide 2 - Introduction
$slide = $presentation.Slides.Add(2, $ppLayoutBlank)
Add-Header -Slide $slide -Title '2. Introduction' -SlideNo 2

Add-Bullets -Slide $slide -Left 55 -Top 78 -Width 485 -Height 275 -Items @(
    'An Auction Management System is a web-based platform for conducting online auctions.',
    'Sellers can list auction items with details, reserve prices, and timelines.',
    'Buyers can place competitive bids online from any location.',
    'The platform improves transparency, automation, and operational efficiency.'
) -FontSize 17 -Color $TEXT_DARK | Out-Null

$card = Add-RoundedCard -Slide $slide -Left 575 -Top 90 -Width 330 -Height 95 -LineColor $MUTED_BORDER
$badge = $slide.Shapes.AddShape($msoShapeOval, 590, 106, 34, 34)
$badge.Fill.ForeColor.RGB = $PRIMARY
$badge.Line.Visible = $msoFalse
Add-Textbox -Slide $slide -Left 590 -Top 112 -Width 34 -Height 18 -Text 'TR' -FontName 'Montserrat' -FontSize 11 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 99 -Width 255 -Height 20 -Text 'Transparent Process' -FontName 'Poppins' -FontSize 14 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 121 -Width 255 -Height 40 -Text 'Bids are visible and traceable during each auction.' -FontName 'Calibri' -FontSize 12 -Bold $false -Color $TEXT_DARK -Align $ppAlignLeft | Out-Null

$card = Add-RoundedCard -Slide $slide -Left 575 -Top 198 -Width 330 -Height 95 -LineColor $MUTED_BORDER
$badge = $slide.Shapes.AddShape($msoShapeOval, 590, 214, 34, 34)
$badge.Fill.ForeColor.RGB = $SECONDARY
$badge.Line.Visible = $msoFalse
Add-Textbox -Slide $slide -Left 590 -Top 220 -Width 34 -Height 18 -Text 'AU' -FontName 'Montserrat' -FontSize 11 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 207 -Width 255 -Height 20 -Text 'Automated Operations' -FontName 'Poppins' -FontSize 14 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 229 -Width 255 -Height 40 -Text 'Timer control, bid updates, and winner selection are automatic.' -FontName 'Calibri' -FontSize 12 -Bold $false -Color $TEXT_DARK -Align $ppAlignLeft | Out-Null

$card = Add-RoundedCard -Slide $slide -Left 575 -Top 306 -Width 330 -Height 95 -LineColor $MUTED_BORDER
$badge = $slide.Shapes.AddShape($msoShapeOval, 590, 322, 34, 34)
$badge.Fill.ForeColor.RGB = $ACCENT
$badge.Line.Visible = $msoFalse
Add-Textbox -Slide $slide -Left 590 -Top 328 -Width 34 -Height 18 -Text 'EF' -FontName 'Montserrat' -FontSize 11 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 315 -Width 255 -Height 20 -Text 'Higher Efficiency' -FontName 'Poppins' -FontSize 14 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
Add-Textbox -Slide $slide -Left 632 -Top 337 -Width 255 -Height 40 -Text 'Less manual effort and better scalability for many auctions.' -FontName 'Calibri' -FontSize 12 -Bold $false -Color $TEXT_DARK -Align $ppAlignLeft | Out-Null

# Slide 3 - Problem Statement
$slide = $presentation.Slides.Add(3, $ppLayoutBlank)
Add-Header -Slide $slide -Title '3. Problem Statement' -SlideNo 3

$box = Add-RoundedCard -Slide $slide -Left 55 -Top 90 -Width 850 -Height 310 -LineColor $MUTED_BORDER
Add-Bullets -Slide $slide -Left 80 -Top 120 -Width 795 -Height 220 -Items @(
    'Traditional auctions require physical presence, reducing participation and reach.',
    'Managing bidders and bid records manually is difficult and error-prone.',
    'Manual handling often causes delays, inconsistency, and data inaccuracies.',
    'Limited transparency can reduce trust among buyers, sellers, and organizers.'
) -FontSize 18 -Color $TEXT_DARK | Out-Null

$codes = @('PH', 'MG', 'ER', 'TR')
for ($i = 0; $i -lt $codes.Count; $i++) {
    $circle = $slide.Shapes.AddShape($msoShapeOval, (85 + ($i * 125)), 412, 36, 36)
    $circle.Fill.ForeColor.RGB = $(if (($i % 2) -eq 0) { $ACCENT } else { $SECONDARY })
    $circle.Line.Visible = $msoFalse
    Add-Textbox -Slide $slide -Left (85 + ($i * 125)) -Top 421 -Width 36 -Height 14 -Text $codes[$i] -FontName 'Montserrat' -FontSize 10 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null
}

# Slide 4 - Objectives
$slide = $presentation.Slides.Add(4, $ppLayoutBlank)
Add-Header -Slide $slide -Title '4. Objectives' -SlideNo 4

$objectives = @(
    'Develop a secure and reliable auction platform.',
    'Enable user registration and authenticated login.',
    'Allow sellers to list and manage auction items.',
    'Enable buyers to place bids with real-time updates.',
    'Automatically declare the highest bidder as winner.'
)

$y = 88
for ($i = 0; $i -lt $objectives.Count; $i++) {
    $row = Add-RoundedCard -Slide $slide -Left 70 -Top $y -Width 820 -Height 56 -LineColor $MUTED_BORDER

    $badge = $slide.Shapes.AddShape($msoShapeOval, 84, ($y + 10), 34, 34)
    $badge.Fill.ForeColor.RGB = $(if ((($i + 1) % 2) -eq 0) { $SECONDARY } else { $PRIMARY })
    $badge.Line.Visible = $msoFalse
    Add-Textbox -Slide $slide -Left 84 -Top ($y + 18) -Width 34 -Height 12 -Text ($i + 1) -FontName 'Montserrat' -FontSize 11 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null

    Add-Textbox -Slide $slide -Left 128 -Top ($y + 16) -Width 730 -Height 24 -Text $objectives[$i] -FontName 'Calibri' -FontSize 17 -Bold $false -Color $TEXT_DARK -Align $ppAlignLeft | Out-Null
    $y += 67
}

# Slide 5 - System Requirements
$slide = $presentation.Slides.Add(5, $ppLayoutBlank)
Add-Header -Slide $slide -Title '5. System Requirements' -SlideNo 5

$left = Add-RoundedCard -Slide $slide -Left 45 -Top 80 -Width 420 -Height 390 -LineColor $SECONDARY
$right = Add-RoundedCard -Slide $slide -Left 495 -Top 80 -Width 420 -Height 390 -LineColor $ACCENT

Add-Textbox -Slide $slide -Left 70 -Top 98 -Width 370 -Height 24 -Text 'Functional Requirements' -FontName 'Poppins' -FontSize 19 -Bold $true -Color $PRIMARY -Align $ppAlignCenter | Out-Null
Add-Textbox -Slide $slide -Left 520 -Top 98 -Width 370 -Height 24 -Text 'Non-Functional Requirements' -FontName 'Poppins' -FontSize 19 -Bold $true -Color $PRIMARY -Align $ppAlignCenter | Out-Null

Add-Bullets -Slide $slide -Left 68 -Top 135 -Width 370 -Height 315 -Items @(
    'User registration and account creation',
    'Secure login with authentication',
    'Item listing and update by sellers',
    'Real-time bid placement by buyers',
    'Auction timer for start and end control'
) -FontSize 15 -Color $TEXT_DARK | Out-Null

Add-Bullets -Slide $slide -Left 518 -Top 135 -Width 370 -Height 315 -Items @(
    'Strong security and privacy controls',
    'Reliable operation with low downtime',
    'Fast response time during peak traffic',
    'User-friendly and intuitive interface',
    'Scalability for future expansion'
) -FontSize 15 -Color $TEXT_DARK | Out-Null

# Slide 6 - System Architecture
$slide = $presentation.Slides.Add(6, $ppLayoutBlank)
Add-Header -Slide $slide -Title '6. System Architecture' -SlideNo 6

Add-Bullets -Slide $slide -Left 40 -Top 56 -Width 880 -Height 24 -Items @('Main components: User Interface, Backend Server, Auction Management, Bidding System, Database, and Payment Module.') -FontSize 13 -Color $TEXT_DARK | Out-Null

function Add-ArchBox {
    param($Slide, [string]$Text, [float]$Left, [float]$Top, [int]$BorderColor)
    $b = Add-RoundedCard -Slide $Slide -Left $Left -Top $Top -Width 140 -Height 66 -LineColor $BorderColor
    Add-Textbox -Slide $Slide -Left ($Left + 8) -Top ($Top + 12) -Width 124 -Height 42 -Text $Text -FontName 'Calibri' -FontSize 12 -Bold $true -Color $TEXT_DARK -Align $ppAlignCenter | Out-Null
}

Add-ArchBox -Slide $slide -Text 'User Interface`n(Frontend)' -Left 55 -Top 120 -BorderColor $PRIMARY
Add-ArchBox -Slide $slide -Text 'Backend`nServer' -Left 220 -Top 120 -BorderColor $SECONDARY
Add-ArchBox -Slide $slide -Text 'Auction`nManagement' -Left 385 -Top 120 -BorderColor $PRIMARY
Add-ArchBox -Slide $slide -Text 'Bidding`nSystem' -Left 550 -Top 120 -BorderColor $SECONDARY
Add-ArchBox -Slide $slide -Text 'Database' -Left 325 -Top 255 -BorderColor $PRIMARY
Add-ArchBox -Slide $slide -Text 'Payment`nModule' -Left 500 -Top 255 -BorderColor $ACCENT

for ($x = 200; $x -le 530; $x += 165) {
    $arr = $slide.Shapes.AddShape($msoShapeRightArrow, $x, 142, 18, 16)
    $arr.Fill.ForeColor.RGB = $SECONDARY
    $arr.Line.Visible = $msoFalse
}

$d1 = $slide.Shapes.AddShape($msoShapeDownArrow, 450, 192, 16, 28)
$d1.Fill.ForeColor.RGB = $SECONDARY
$d1.Line.Visible = $msoFalse

$d2 = $slide.Shapes.AddShape($msoShapeDownArrow, 615, 192, 16, 28)
$d2.Fill.ForeColor.RGB = $SECONDARY
$d2.Line.Visible = $msoFalse

# Slide 7 - Use Case Diagram
$slide = $presentation.Slides.Add(7, $ppLayoutBlank)
Add-Header -Slide $slide -Title '7. Use Case Diagram' -SlideNo 7

$boundary = Add-RoundedCard -Slide $slide -Left 250 -Top 85 -Width 520 -Height 375 -LineColor $SECONDARY
$boundary.Fill.ForeColor.RGB = (New-RGB 249 251 255)
Add-Textbox -Slide $slide -Left 270 -Top 95 -Width 480 -Height 22 -Text 'Auction Management System' -FontName 'Poppins' -FontSize 15 -Bold $true -Color $PRIMARY -Align $ppAlignCenter | Out-Null

$actors = @(
    @{ Name = 'Admin'; Top = 145 },
    @{ Name = 'Seller'; Top = 225 },
    @{ Name = 'Buyer'; Top = 305 }
)

foreach ($actor in $actors) {
    $a = Add-RoundedCard -Slide $slide -Left 55 -Top $actor.Top -Width 130 -Height 42 -LineColor $PRIMARY
    Add-Textbox -Slide $slide -Left 55 -Top ($actor.Top + 10) -Width 130 -Height 20 -Text $actor.Name -FontName 'Calibri' -FontSize 14 -Bold $true -Color $PRIMARY -Align $ppAlignCenter | Out-Null
}

$useCases = @(
    @{ Name = 'Register'; Left = 285; Top = 145 },
    @{ Name = 'Login'; Left = 530; Top = 145 },
    @{ Name = 'List Item'; Left = 285; Top = 225 },
    @{ Name = 'Place Bid'; Left = 530; Top = 225 },
    @{ Name = 'Manage Auctions'; Left = 285; Top = 305 },
    @{ Name = 'Declare Winner'; Left = 530; Top = 305 }
)

foreach ($uc in $useCases) {
    $oval = $slide.Shapes.AddShape($msoShapeOval, $uc.Left, $uc.Top, 190, 44)
    $oval.Fill.ForeColor.RGB = $WHITE
    $oval.Line.ForeColor.RGB = $SECONDARY
    Add-Textbox -Slide $slide -Left $uc.Left -Top ($uc.Top + 12) -Width 190 -Height 20 -Text $uc.Name -FontName 'Calibri' -FontSize 12 -Bold $true -Color $TEXT_DARK -Align $ppAlignCenter | Out-Null
}

$line1 = $slide.Shapes.AddLine(185, 166, 285, 166)
$line1.Line.ForeColor.RGB = $PRIMARY
$line2 = $slide.Shapes.AddLine(185, 246, 285, 246)
$line2.Line.ForeColor.RGB = $PRIMARY
$line3 = $slide.Shapes.AddLine(185, 326, 285, 326)
$line3.Line.ForeColor.RGB = $PRIMARY

# Slide 8 - System Workflow
$slide = $presentation.Slides.Add(8, $ppLayoutBlank)
Add-Header -Slide $slide -Title '8. System Workflow' -SlideNo 8

$steps = @(
    '1. User`nRegistration',
    '2. Login',
    '3. Seller`nLists Item',
    '4. Auction`nBegins',
    '5. Buyers`nPlace Bids',
    '6. Highest Bid`nUpdated',
    '7. Auction`nEnds',
    '8. Winner`nDeclared'
)

$x = 34
for ($i = 0; $i -lt $steps.Count; $i++) {
    $box = Add-RoundedCard -Slide $slide -Left $x -Top 178 -Width 98 -Height 78 -LineColor $(if (($i % 2) -eq 0) { $PRIMARY } else { $SECONDARY })
    Add-Textbox -Slide $slide -Left ($x + 4) -Top 198 -Width 90 -Height 40 -Text $steps[$i] -FontName 'Calibri' -FontSize 10 -Bold $true -Color $TEXT_DARK -Align $ppAlignCenter | Out-Null

    if ($i -lt ($steps.Count - 1)) {
        $arr = $slide.Shapes.AddShape($msoShapeRightArrow, ($x + 101), 208, 14, 12)
        $arr.Fill.ForeColor.RGB = $SECONDARY
        $arr.Line.Visible = $msoFalse
    }

    $x += 116
}

Add-Textbox -Slide $slide -Left 60 -Top 300 -Width 840 -Height 42 -Text 'The workflow ensures fairness and automation from user onboarding to winner declaration.' -FontName 'Calibri' -FontSize 15 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null

# Slide 9 - Advantages
$slide = $presentation.Slides.Add(9, $ppLayoutBlank)
Add-Header -Slide $slide -Title '9. Advantages' -SlideNo 9

$advantages = @(
    @{ T = 'Easy Access'; D = 'Users can join auctions from anywhere.'; C = $PRIMARY; L = 55;  Top = 90 },
    @{ T = 'Transparent Bidding'; D = 'Real-time bid visibility builds trust.'; C = $SECONDARY; L = 335; Top = 90 },
    @{ T = 'Reduced Manual Work'; D = 'Automation lowers administrative effort.'; C = $ACCENT; L = 615; Top = 90 },
    @{ T = 'Time Efficient'; D = 'Fast updates speed up auction cycles.'; C = $PRIMARY; L = 195; Top = 270 },
    @{ T = 'Better Management'; D = 'Centralized records improve tracking.'; C = $SECONDARY; L = 475; Top = 270 }
)

foreach ($a in $advantages) {
    $card = Add-RoundedCard -Slide $slide -Left $a.L -Top $a.Top -Width 245 -Height 145 -LineColor $a.C
    $dot = $slide.Shapes.AddShape($msoShapeOval, ($a.L + 12), ($a.Top + 12), 18, 18)
    $dot.Fill.ForeColor.RGB = $a.C
    $dot.Line.Visible = $msoFalse

    Add-Textbox -Slide $slide -Left ($a.L + 38) -Top ($a.Top + 10) -Width 190 -Height 20 -Text $a.T -FontName 'Poppins' -FontSize 13 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
    Add-Textbox -Slide $slide -Left ($a.L + 14) -Top ($a.Top + 42) -Width 215 -Height 76 -Text $a.D -FontName 'Calibri' -FontSize 12 -Bold $false -Color $TEXT_DARK -Align $ppAlignLeft | Out-Null
}

# Slide 10 - Conclusion and Future Scope
$slide = $presentation.Slides.Add(10, $ppLayoutBlank)
Add-Header -Slide $slide -Title '10. Conclusion and Future Scope' -SlideNo 10

$left = Add-RoundedCard -Slide $slide -Left 55 -Top 85 -Width 405 -Height 355 -LineColor $SECONDARY
$right = Add-RoundedCard -Slide $slide -Left 500 -Top 85 -Width 405 -Height 355 -LineColor $ACCENT

Add-Textbox -Slide $slide -Left 78 -Top 104 -Width 360 -Height 22 -Text 'Conclusion' -FontName 'Poppins' -FontSize 18 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
Add-Bullets -Slide $slide -Left 75 -Top 138 -Width 360 -Height 250 -Items @(
    'The platform modernizes auctions through a structured SDLC implementation.',
    'It improves transparency, efficiency, and trust among participants.',
    'Automated bidding and winner declaration reduce manual errors.'
) -FontSize 14 -Color $TEXT_DARK | Out-Null

Add-Textbox -Slide $slide -Left 523 -Top 104 -Width 360 -Height 22 -Text 'Future Scope' -FontName 'Poppins' -FontSize 18 -Bold $true -Color $PRIMARY -Align $ppAlignLeft | Out-Null
Add-Bullets -Slide $slide -Left 520 -Top 138 -Width 360 -Height 250 -Items @(
    'Develop a full-featured mobile application.',
    'Add AI-based fraud detection capabilities.',
    'Integrate real-time push notifications.',
    'Explore blockchain-based secure auctions.'
) -FontSize 14 -Color $TEXT_DARK | Out-Null

$thanks = $slide.Shapes.AddShape($msoShapeRoundedRectangle, 395, 462, 170, 34)
$thanks.Fill.ForeColor.RGB = $PRIMARY
$thanks.Line.Visible = $msoFalse
Add-Textbox -Slide $slide -Left 395 -Top 469 -Width 170 -Height 20 -Text 'Thank You' -FontName 'Poppins' -FontSize 18 -Bold $true -Color $WHITE -Align $ppAlignCenter | Out-Null

$outputFile = Join-Path (Get-Location) 'Auction_Management_System_SDLC_Presentation.pptx'
if (Test-Path $outputFile) {
    Remove-Item $outputFile -Force
}

$presentation.SaveAs($outputFile)
$presentation.Close()
$ppt.Quit()

[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($presentation)
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($ppt)

Write-Output "Created: $outputFile"
