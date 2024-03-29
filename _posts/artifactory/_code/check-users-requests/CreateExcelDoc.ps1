[CmdletBinding()]
Param(
    [parameter(Mandatory=$True,Position=0)]
    [alias("I")]
    $InputFiles,
    [parameter(Mandatory=$False,Position=1)]
    [alias("O")]
    [String]$OutputFile = ""
)

# This scrip creates an Excel Spreadsheet from formatted "username" files that are generated by script "FormatLogs.sh"
# It checks Active Directiory for account actions, like "LastLogonDate".
#
# e.g.
#  .\CreateExcelDoc.ps1 -InputFiles (Get-ChildItem -Path "C:\temp\_output_formatted" -Filter "*.log" | ?{ !$_.PSIsContainer }) -OutputFile "Artifactory_Access_Users.xlsx"
#

$script:Path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$script:ModulePath = $(Join-Path -Path "$script:Path" -ChildPath ".\modules")

if (!([string]::IsNullOrEmpty($OutputFile))) {
  if (!([System.IO.Path]::IsPathRooted("$OutputFile"))) {
    $OutputFile = $(Join-Path -Path $(Get-Location) -ChildPath $([System.IO.Path]::GetFileName("$OutputFile")))
  }
}

function Release-Ref ($ref) {
  ([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
}

function Insert-ADDetails(
  [parameter(Mandatory=$True)]
  [System.__ComObject]$worksheet,
  [parameter(Mandatory=$True)]
  [String]$identity)
{
  $xlShiftDown = [Microsoft.Office.Interop.Excel.XlInsertShiftDirection]::xlShiftDown

  $props = @("AccountExpirationDate", "Created", "LastBadPasswordAttempt", "LastLogonDate", "Modified", "PasswordLastSet", "whenChanged", "Enabled")
  $userADProps = Get-ADUser -identity "$identity" -Properties $props

  if ($userADProps -ne $null) {
    foreach ($prop in $props) {
      $propValue = $userADProps.("$prop")
      $propDate = "{0:dd/MM/yyyy}" -f ($propValue)
      $propTime = "{0:HH:mm:ss}" -f ($propValue)
      $propAdAction = "AD ACTION"

      if (!([string]::IsNullOrEmpty($propValue))) {
        $eRow = $worksheet.cells.item(2,1).entireRow
        $active = $eRow.activate()
        $active = $eRow.insert($xlShiftDown)

        $rowColor = 37
        if ("$prop" -eq "Enabled") {
          $propDate = " " # NOTE: Space is used so this row is placed at the top after sorting.
          $propTime = " " # NOTE: Space is used so this row is placed at the top after sorting.
          if ($propValue -eq $False) {
            $rowColor = 3
            $prop = "Disabled"
            $worksheet.Tab.ColorIndex = 3
          } else {
            $rowColor = 4
          }
        }

        $columnMax = ($worksheet.usedRange.columns).count
        for($column = 1 ; $column -le $columnMax ; $column ++) {
          $worksheet.cells.item(2,$column).Interior.ColorIndex = $rowColor
        }

        $worksheet.Cells.Item(2,1) = ($propDate)
        $worksheet.Cells.Item(2,2) = ($propTime)
        $worksheet.Cells.Item(2,3) = $propAdAction
        $worksheet.Cells.Item(2,4) = "$prop"
      }
    }
  }
}

function Sort-Feild(
  [parameter(Mandatory=$True)]
  [System.__ComObject]$worksheet)
{
  $xlYes = 1
  $xlNo = 2

  $xlSortOnValues = $xlSortNormal = 0
  $xlTopToBottom = $xlSummaryBelow = 1

  $xlAscending = 1
  $xlDescending = 2

  $worksheet.sort.sortFields.clear()

  $usedRange = $worksheet.UsedRange

  [void]$worksheet.sort.sortFields.add($worksheet.Range("A1"), $xlSortOnValues, $xlDescending, $xlSortNormal)
  $worksheet.sort.setRange($worksheet.UsedRange)
  $worksheet.sort.header = $xlYes
  $worksheet.sort.orientation = $xlTopToBottom
  $worksheet.sort.apply()

  [void]$worksheet.Range("A1").Select()
}

function Add-worksheet(
  [parameter(Mandatory=$True)]
  [System.__ComObject]$worksheets,
  [parameter(Mandatory=$True)]
  [String]$file)
{
  $name = [System.IO.Path]::GetFileNameWithoutExtension("$file")

  $worksheet = $worksheets.add([System.Reflection.Missing]::Value,$worksheets.Item($worksheets.count))
  $worksheet.Name = "$name"

  $TxtConnector = ("TEXT;$file")
  $CellRef = $worksheet.Range("A1")

  $Connector = $worksheet.QueryTables.add($TxtConnector,$CellRef)
  $worksheet.QueryTables.item("$($Connector.name)").TextFileTabDelimiter = $True
  $worksheet.QueryTables.item("$($Connector.name)").TextFileParseType = 1
  [void]$worksheet.QueryTables.item("$($Connector.name)").Refresh()
  $worksheet.QueryTables.item("$($Connector.name)").delete()

  Insert-ADDetails -worksheet $worksheet `
                   -identity "$name"

  $excel.Rows.Item(1).Font.Bold = $true
  [void]$excel.Cells.EntireColumn.AutoFilter()
  [void]$worksheet.UsedRange.EntireColumn.AutoFit()

  $worksheet.Activate();
  $worksheet.Application.ActiveWindow.SplitRow = 1;
  $worksheet.Application.ActiveWindow.FreezePanes = $True;

  Sort-Feild -worksheet $worksheet

  $a = Release-Ref($worksheet)
}

function Main
{
  $excel = New-Object -ComObject excel.application
  $excel.visible = ([string]::IsNullOrEmpty($OutputFile))
  $excel.DisplayAlerts = $False

  $workbooks = $excel.Workbooks.Add()
  $worksheets = $workbooks.worksheets

  while ($workbooks.sheets.count -gt 1) {
    $worksheets.Item($workbooks.sheets.count).delete()
  }

  foreach ($file in $InputFiles) {
    Write-Host "$($file.FullName)"
    Add-worksheet -worksheets $worksheets `
                  -file "$($file.FullName)"
  }

  $worksheets.Item(1).delete()
  $worksheets.Item(1).Select()

  if (!([string]::IsNullOrEmpty($OutputFile))) {
    $xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault

    $workbooks.SaveAs("$OutputFile", $xlFixedFormat)
    $excel.Quit()
  }

  $a = Release-Ref($workbooks)
  $a = Release-Ref($excel)
  $excel = $null

  [System.GC]::Collect()
  [System.GC]::WaitForPendingFinalizers()
}

Main
