function copyToDispatchTransactions() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sourceSheet = ss.getActiveSheet();
  var dispatchSheet = ss.getSheetByName("Dispatch Transactions");

  // Fetch all data from the source sheet.
  var data = sourceSheet.getDataRange().getValues();
  var dispatchData = dispatchSheet.getDataRange().getValues();

  Logger.log("Starting to process " + data.length + " rows from source sheet.");

  var rowsCopied = 0;
  var rowsUpdated = 0;

  for(var i = 0; i < data.length; i++) {
    var row = data[i];

    // Logging the current row's transaction_type_id and LOCATION/BUILDING for clarity.
    Logger.log("Processing row " + (i+1) + ". Transaction Type ID: " + row[3] + ", Location: " + row[9]);

    // Check if transaction_type_id = -1 and LOCATION/BUILDING = Dispatch.
    if(row[3] === -1 && row[9] === "Dispatch") {
      var newRow = [
        "", "", row[1], "", "", row[5], row[6], "IN", row[8], row[10]
      ];

      // Check if primary_key is already present in the dispatchSheet.
      var existingRowIdx = dispatchData.findIndex(existingRow => existingRow[1] === row[1]);

      if(existingRowIdx === -1) {
        // If not found, append a new row.
        dispatchSheet.appendRow(newRow);
        rowsCopied++;
        Logger.log("Row " + (i+1) + " copied to Dispatch Transactions sheet.");
      } else {
        // If found, update the existing row.
        dispatchSheet.getRange(existingRowIdx + 1, 1, 1, newRow.length).setValues([newRow]);
        rowsUpdated++;
        Logger.log("Row " + (i+1) + " updated in Dispatch Transactions sheet.");
      }
    } else {
      Logger.log("Row " + (i+1) + " does not meet criteria. Skipping.");
    }
  }

  Logger.log(rowsCopied + " rows copied to Dispatch transactions sheet.");
  Logger.log(rowsUpdated + " rows updated in Dispatch transactions sheet.");
}
