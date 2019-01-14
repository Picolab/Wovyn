function doPost(e) {
  recordReading(e.parameter);
}

function recordReading(data) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(data.tabName);
  if (!sheet) {
    sheet = ss.insertSheet(data.tabName,ss.getSheets().length,{template:ss.getSheetByName('day')});
  }
  sheet.appendRow([data.timestamp,data.temperature]);
}