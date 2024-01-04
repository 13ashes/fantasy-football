function copyToDispatchTransactions() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sourceSheet = ss.getActiveSheet();
  var dispatchSheet = ss.getSheetByName("Dispatch Transactions");

  // Fetch all data from the source sheet.
  var data = sourceSheet.getDataRange().getValues();

  Logger.log("Starting to process " + data.length + " rows from source sheet.");

  var rowsCopied = 0; // Keep track of how many rows were copied.

  // Loop over each row and check for the criteria.
  for(var i = 0; i < data.length; i++) {
    var row = data[i];

    // Logging the current row's transaction_type_id and LOCATION/BUILDING for clarity.
    Logger.log("Processing row " + (i+1) + ". Transaction Type ID: " + row[3] + ", Location: " + row[9]);

    // Check if transaction_type_id = -1 and LOCATION/BUILDING = Dispatch.
    if(row[3] === -1 && row[9] === "Dispatch") {
      // Create the row for the dispatchSheet.
      var newRow = [
        "",          // Placeholder for column 1 (array formula).
        "",          // Placeholder for column 2 (array formula).
        row[1],      // Data from source Column B.
        "",          // Placeholder for column 4 (array formula).
        "",          // Placeholder for column 5 (array formula).
        row[5],      // Data from source Column F.
        row[6],      // Data from source Column G.
        "IN",       // Fixed value for Transaction Type.
        row[8],      // Data from source Column I.
        row[10]      // Data from source Column K.
      ];

      // Append the new row to the dispatch sheet.
      dispatchSheet.appendRow(newRow);
      rowsCopied++;

      Logger.log("Row " + (i+1) + " meets criteria. Copied to Dispatch Transactions sheet.");
    } else {
      Logger.log("Row " + (i+1) + " does not meet criteria. Skipping.");
    }
  }

  // Log for completion.
  Logger.log(rowsCopied + " rows copied to Dispatch transactions sheet.");
}
