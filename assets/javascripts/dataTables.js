$("#make_table").live("click", function(){
  var data = [
    ["", "Kia", "Nissan", "Toyota", "Honda"],
    ["2008", 10, 11, 12, 13],
    ["2009", 20, 11, 14, 13],
    ["2010", 30, 15, 12, 13]
  ];
  $("#journey").handsontable({
    data: data,
    startRows: 6,
    startCols: 8
  });
});

