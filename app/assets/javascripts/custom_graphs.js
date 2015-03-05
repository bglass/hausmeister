heating_circuits_graph = function(canvasname, width, height, setpoint_s, actual_s, valve_s) {


  function draw() {
    var ctx = document.getElementById(canvasname).getContext('2d');

    setpoint = JSON.parse(setpoint_s);
    actual   = JSON.parse(actual_s);
    valve    = JSON.parse(valve_s);

    ctx.canvas.width  = width;
    ctx.canvas.height = 1000; // height;

    // ctx.strokeStyle = "#cc3";
    // ctx.beginPath();
    // ctx.rect(0,0,width,height);
    // ctx.stroke();


    // width, height

    n        = valve.length;
    k        = 50;
    r        = k/10;

    kx       = width / (n+2)

    cv       = height/2/100    // (0..100)
    ct       = height/2/10     // (15..25)
    ot       = -15


    // ylabel
    ctx.setTransform( 1, 0, 0, 1, 1.2*kx, -height/5 );
    ctx.fillText("1", -.5*kx, height/2);
    ctx.fillText("1/2", -.6*kx, height*.75);
    ctx.fillText("0", -.5*kx, height);
    ctx.fillText("25 °C", n*kx, height/2);
    ctx.fillText("20 °C", n*kx, height*.75);
    ctx.fillText("15 °C", n*kx, height);

    ctx.setTransform( 1, 0, 0, -1, 1.5*kx, 0.75*height );

    // grid
    ctx.strokeStyle = "#ddd";
    ctx.lineWidth   = 1;
    for (var i=0; i<3; i++){
      ctx.beginPath();
      ctx.moveTo( -.25*kx, i*height/4);
      ctx.lineTo( (n-.75)*kx,i*height/4);
      ctx.stroke();
    }


    // xticks
    // yticks


    // xlabel

    // vlines
    ctx.strokeStyle = "#ddd";
    ctx.lineWidth   = 2;
    for (var i=0; i<n; i++){
      ctx.beginPath();
      // ctx.moveTo(i*k,0);
      // ctx.lineTo(i*k,k);
      ctx.moveTo(i*kx,0);
      ctx.lineTo(i*kx,height/2);
      ctx.stroke();
    }
    // setpoint_trends
    // temperature_trends


    // valves
    ctx.strokeStyle = "#222";
    ctx.lineWidth   = 2;
    for (var i=0; i<n; i++){
      ctx.beginPath();
      ctx.moveTo(i*kx,     valve[i]*cv+r  );
      ctx.lineTo(i*kx + r, valve[i]*cv    );
      ctx.lineTo(i*kx,     valve[i]*cv-r  );
      ctx.lineTo(i*kx - r, valve[i]*cv    );
      ctx.closePath();
      ctx.stroke();
    }

    rt = r*.8
    // setpoints
    ctx.fillStyle = "#22f";
    ctx.lineWidth   = 2;
    rr = 2*rt;
    rrr = 3*rt;
    for (var i=0; i<n; i++){

      ctx.beginPath();
      ctx.moveTo(i*kx,        (setpoint[i]+ot)*ct     );
      ctx.lineTo(i*kx - rrr,  (setpoint[i]+ot)*ct - rr   );
      ctx.lineTo(i*kx - rrr,  (setpoint[i]+ot)*ct + rr   );
      ctx.fill();
    }

    // temperatures
    ctx.fillStyle = "#f22";
    ctx.lineWidth   = 2;
    for (var i=0; i<n; i++){

      ctx.beginPath();
      ctx.moveTo(i*kx,        (actual[i]+ot)*ct     );
      ctx.lineTo(i*kx + rrr,  (actual[i]+ot)*ct - rr   );
      ctx.lineTo(i*kx + rrr,  (actual[i]+ot)*ct + rr   );
      ctx.fill();
    }

  }

  draw();
}


temperature_graph = function(canvasname, width, height, setpoint_s, actual_s, valve_s) {

  function xx(x) {
    var kx = width/50;
    return 30+kx*x;
  }

  function yy(y) {
    var ky = height/50;
    return 250-ky*y;
  }

  function bar(ctx,x,y1,y2,r) {

    y = yy(y2);
    h = yy(y2) - yy(y1);

    if (h < 0) {
      ctx.fillStyle="#FF0000";
    } else {
      ctx.fillStyle="#0000FF";
    }


    ctx.fillRect( xx(x)-r, y, 2*r, h );
  }

  function viereck(ctx,x1,y1,x2,y2,x3,y3,x4,y4) {

    if (y3 > y2) {
      ctx.fillStyle="#FF0000";
    } else {
      ctx.fillStyle="#0000FF";
    }


    ctx.beginPath();
    ctx.moveTo(xx(x1),yy(y1));
    ctx.lineTo(xx(x2),yy(y2));
    ctx.lineTo(xx(x3),yy(y3));
    ctx.lineTo(xx(x4),yy(y4));

    ctx.fill();

  }



  function draw() {
    var ctx = document.getElementById(canvasname).getContext('2d');

    setpoint = JSON.parse(setpoint_s);
    actual   = JSON.parse(actual_s);
    valve    = JSON.parse(valve_s);

    ctx.canvas.width  = width;
    ctx.canvas.height = 1000; // height;

    ctx.strokeStyle = "#cc3";
    ctx.beginPath();
    ctx.rect(0,0,width,height);
    ctx.stroke();


    // width, height

    n        = valve.length;
    k        = 50;
    r        = k/10;

    kx       = width / (n+2)

    cv       = height/2/100    // (0..100)
    ct       = height/2/10     // (15..25)
    ot       = -15


    ctx.transform( 1, 0, 0, -1, 1.5*kx, 0.75*height );

    // grid
    ctx.strokeStyle = "#ddd";
    ctx.lineWidth   = 1;
    for (var i=0; i<3; i++){
      ctx.beginPath();
      ctx.moveTo( -.25*kx, i*height/4);
      ctx.lineTo( (n-.75)*kx,i*height/4);
      ctx.stroke();
    }


    // xticks
    // yticks
    // ylabel



    // xlabel

    // vlines
    ctx.strokeStyle = "#ddd";
    ctx.lineWidth   = 5;
    for (var i=0; i<n; i++){
      ctx.beginPath();
      // ctx.moveTo(i*k,0);
      // ctx.lineTo(i*k,k);
      ctx.moveTo(i*kx,0);
      ctx.lineTo(i*kx,height/2);
      ctx.stroke();
    }
    // setpoint_trends
    // temperature_trends


    // valves
    ctx.strokeStyle = "#222";
    ctx.lineWidth   = 2;
    for (var i=0; i<n; i++){
      ctx.beginPath();
      ctx.moveTo(i*kx,     valve[i]*cv+r  );
      ctx.lineTo(i*kx + r, valve[i]*cv    );
      ctx.lineTo(i*kx,     valve[i]*cv-r  );
      ctx.lineTo(i*kx - r, valve[i]*cv    );
      ctx.closePath();
      ctx.stroke();
    }

    rt = r*.8
    // setpoints
    ctx.fillStyle = "#22f";
    ctx.lineWidth   = 2;
    rr = 2*rt;
    rrr = 3*rt;
    for (var i=0; i<n; i++){

      ctx.beginPath();
      ctx.moveTo(i*kx,        (setpoint[i]+ot)*ct     );
      ctx.lineTo(i*kx - rrr,  (setpoint[i]+ot)*ct - rr   );
      ctx.lineTo(i*kx - rrr,  (setpoint[i]+ot)*ct + rr   );
      ctx.fill();
    }

    // temperatures
    ctx.fillStyle = "#f22";
    ctx.lineWidth   = 2;
    for (var i=0; i<n; i++){

      ctx.beginPath();
      ctx.moveTo(i*kx,        (actual[i]+ot)*ct     );
      ctx.lineTo(i*kx + rrr,  (actual[i]+ot)*ct - rr   );
      ctx.lineTo(i*kx + rrr,  (actual[i]+ot)*ct + rr   );
      ctx.fill();
    }









    ctx.transform(1,0,0,-100/height,0,height);







    ctx.beginPath();
    var index;
    var points = [10,10,10,16,16,10,10,21,21,21,10,10];
    for (index = 0; index<points.length; index++) {
      ctx.lineTo(xx(index),yy(points[index]));
    };
    ctx.stroke();

    ctx.beginPath();
    ctx.stroke();
    var value, i0, i1, lastval;
    value = (Math.random()-.5)*10 + points[index];
    for (index = 1; index<points.length; index++) {
      lastval = value;
      value = (Math.random()-.5)*10 + points[index];
      // bar(ctx,index,value,points[index],10);
      i0 = index-1;
      i1 = index;
      viereck(ctx, i0, points[i0], i1, points[i1], i1, value, i0, lastval);
    };
    ctx.stroke();

  }

  draw();

}
