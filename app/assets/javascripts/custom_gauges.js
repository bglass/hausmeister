cv_pressure_gauge = function(canvas,size) {

  var gauge = new Gauge({
    renderTo : canvas,
    width : size,
    height : size,
    glow : false,
    units : 'bar',
    title : "CV Pressure",
    minValue : 0,
    maxValue : 3,
    valueFormat : { "int" : 1, "dec" : 1 },
    majorTicks : ['0', '0.5', '1', '1.5', '2', '2.5', '3'],
    minorTicks : 5,
    // strokeTicks : true,
    highlights : [{ from : 1.5, to : 2,  color : '#8f8' }],
    colors : {
      needle : { start : '#c00', end : '#f00' },
      lcdback    : "#eee",
      lcdtext    : "#000" }
  });
  gauge.onready = function() {
    setInterval( function() {
      gauge.setValue( Math.random() * 3);
    }, 1000);
  };
  gauge.draw();
}
