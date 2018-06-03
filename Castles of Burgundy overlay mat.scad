
THICKNESS = 1.2;

TOTAL_HEX_EDGE_WITH = 27;
HEX_EDGE = 1.6;
HEX_WIDTH = TOTAL_HEX_EDGE_WITH - HEX_EDGE;  // The size to allow for the hex

HEXi_r = HEX_WIDTH/2;
HEXi_R = HEXi_r/cos(30);
HEXo_r = HEX_WIDTH/2 + HEX_EDGE;
HEXo_R = HEXo_r/cos(30);

SIDE_STEP = HEXo_r*2 - HEX_EDGE;
UP_STEP = HEXo_R*(cos(60))+HEXo_R-HEX_EDGE*cos(30);

EDGE_TO_HEX = 15;
TOP_TO_HEX = 19;

EDGE_TO_CENTRE = EDGE_TO_HEX + SIDE_STEP * 3.5;

CUBE_WIDTH = EDGE_TO_CENTRE + SIDE_STEP * 3.5;

TOTAL_HEIGHT = 211; // Height of the actual player mat
HALF_HEIGHT = TOTAL_HEIGHT/2;

DIE_AREA_DIA = 30;
DIE_AREA_TO_EDGE = 10;

DIE_WIDTH = 15;
DIE_CORNER_RADIUS = 1;

BOARD_THICKNESS = 0.6; // Actual thickness of mat: 0.33mm;
BORDER_OVERHANG = 2;

difference() {
    union() {
        translate([0, , 0]) cube([EDGE_TO_CENTRE, HALF_HEIGHT, THICKNESS]);
        linear_extrude(THICKNESS) polygon(points=[[-SIDE_STEP * 1.5, UP_STEP * 3 + HEXo_R],
    [0, HALF_HEIGHT],
    [0,0]]);
        
        linear_extrude(THICKNESS) polygon(points=[[-SIDE_STEP * 1.5, -(UP_STEP * 3 + HEXo_R)],
    [0, -HALF_HEIGHT],
    [EDGE_TO_CENTRE, -HALF_HEIGHT],
    [EDGE_TO_CENTRE, 0],
    [EDGE_TO_CENTRE-5, 0],
    [EDGE_TO_CENTRE-5, -HALF_HEIGHT+5],
    [0, -HALF_HEIGHT+5],
    [0, 0],]);
       
         linear_extrude(THICKNESS) polygon(points=[
        [SIDE_STEP * 1.5, -(UP_STEP * 3 + HEXo_R)],
    [SIDE_STEP * 3, -HALF_HEIGHT],
    [0, -HALF_HEIGHT+5],
    [0, 0],]);
    }
    
    hexes();
    
    translate([EDGE_TO_CENTRE-DIE_AREA_TO_EDGE-DIE_AREA_DIA/2, HALF_HEIGHT-DIE_AREA_TO_EDGE-DIE_AREA_DIA/2, -0.1]) {
        translate([-DIE_WIDTH/2, DIE_WIDTH/2, 0]) roundCornersCube(DIE_WIDTH, DIE_WIDTH, THICKNESS*4, DIE_CORNER_RADIUS);
        translate([DIE_WIDTH/2, -DIE_WIDTH/2, 0]) roundCornersCube(DIE_WIDTH, DIE_WIDTH, THICKNESS*4, DIE_CORNER_RADIUS);
        cylinder(d=DIE_WIDTH, h=THICKNESS*4);
    }
}
hexes(dogrid=true);

translate([EDGE_TO_CENTRE-50+BORDER_OVERHANG, HALF_HEIGHT, -BOARD_THICKNESS]) cube([50, BORDER_OVERHANG, THICKNESS + BOARD_THICKNESS]);
translate([EDGE_TO_CENTRE, HALF_HEIGHT-50+BORDER_OVERHANG, -BOARD_THICKNESS]) cube([BORDER_OVERHANG, 50, THICKNESS + BOARD_THICKNESS]);
translate([EDGE_TO_CENTRE-50+BORDER_OVERHANG, -HALF_HEIGHT-BORDER_OVERHANG, -BOARD_THICKNESS]) cube([50, BORDER_OVERHANG, THICKNESS + BOARD_THICKNESS]);
translate([EDGE_TO_CENTRE, -HALF_HEIGHT-BORDER_OVERHANG, -BOARD_THICKNESS]) cube([BORDER_OVERHANG, 50, THICKNESS + BOARD_THICKNESS]);

echo("Height", HALF_HEIGHT*2 + BORDER_OVERHANG*2);
echo("Width", EDGE_TO_CENTRE + SIDE_STEP * 3.5);

module hexes(dogrid=false) {
    for(y = [-3 : 3]) {
        count = 7 - abs(y);
        translate([-SIDE_STEP * (count-1) / 2, UP_STEP * y, 0]) hexline(count, dogrid);
    }
}

module hexline(count, dogrid) {
    for(x = [0:count-1]) {
        translate([x * SIDE_STEP, 0, 0]) {
            if (dogrid) {
                hexgrid();
            } else {
                hex();
            }
        }
    }
}

module hex() {
    translate([0, 0, -THICKNESS/2]) linear_extrude(THICKNESS*2) hexploygon(HEXi_r, HEXi_R);
}

module hexgrid() {
    difference() {
        linear_extrude(THICKNESS) hexploygon(HEXo_r, HEXo_R);
        translate([0, 0, -THICKNESS/2]) linear_extrude(THICKNESS*2) hexploygon(HEXi_r, HEXi_R);
    }
}

module hexploygon(r, R) {
    polygon(points=[[-r, -R/2],[-r, R/2],[0, R],[r, R/2],
        [r, -R/2], [0, -R],[-r, -R/2],]);
}

// From: https://www.thingiverse.com/thing:8812/#files
module createMeniscus(h,radius) // This module creates the shape that needs to be substracted from a cube to make its corners rounded.
difference(){        //This shape is basicly the difference between a quarter of cylinder and a cube
   translate([radius/2+0.1,radius/2+0.1,0]){
      cube([radius+0.2,radius+0.1,h+0.2],center=true);         // All that 0.x numbers are to avoid "ghost boundaries" when substracting
   }

   cylinder(h=h+0.2,r=radius,$fn = 25,center=true);
}


module roundCornersCube(x,y,z,r)  // Now we just substract the shape we have created in the four corners
    difference(){
       cube([x,y,z], center=true);

    translate([x/2-r,y/2-r]){  // We move to the first corner (x,y)
          rotate(0){  
             createMeniscus(z,r); // And substract the meniscus
          }
       }
       translate([-x/2+r,y/2-r]){ // To the second corner (-x,y)
          rotate(90){
             createMeniscus(z,r); // But this time we have to rotate the meniscus 90 deg
          }
       }
          translate([-x/2+r,-y/2+r]){ // ... 
          rotate(180){
             createMeniscus(z,r);
          }
       }
          translate([x/2-r,-y/2+r]){
          rotate(270){
             createMeniscus(z,r);
          }
       }
}