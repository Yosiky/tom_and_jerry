
`include "hvsync_generator.v"
`include "sprite_rotation.v"

/*
Tank game.

minefield - Displays the minefield.
playfield - Displays the playfield maze.
tank_game_top - Runs the tank game, using two tank_controller
  modules.
*/

module playfield(hpos, vpos, playfield_gfx);
  
  input [8:0] hpos;
  input [8:0] vpos;
  output playfield_gfx;
  
  reg [31:0] maze [0:27];
  
  wire [4:0] x = hpos[7:3];
  wire [4:0] y = vpos[7:3] - 2;
  
  assign playfield_gfx = maze[y][x];
  
  initial begin/*{w:32,h:28,bpw:32}*/
    maze[0]  = 32'b11111111111111111111111111111111;   //upside
    maze[1]  = 32'b10000000001000000001000000100001;
    maze[2]  = 32'b10000000001000000001000000100001;
    maze[3]  = 32'b10000000000000000001000100000001;
    maze[4]  = 32'b11111110000000001000000100000001;
    maze[5]  = 32'b10000010001000001000000100000001;
    maze[6]  = 32'b10000010001000001111111111100001;
    maze[7]  = 32'b10011110000001111000000000100001;
    maze[8]  = 32'b10000010000000001000000000111001;
    maze[9]  = 32'b10000011100000001000010000100001;
    maze[10] = 32'b10000000000000001110010000100001;
    maze[11] = 32'b10000000000111000010010000000001;
    maze[12] = 32'b11111000000001000000010000000001;
    maze[13] = 32'b10001000000000000000010001111111;
    maze[14] = 32'b10001000000000000000010000000001;
    maze[15] = 32'b10001111100011100011110000000001;
    maze[16] = 32'b10000000000000100000100000000001;
    maze[17] = 32'b10000000000000100000100000000001;
    maze[18] = 32'b10001000000000100000111000000001;
    maze[19] = 32'b10001111000000100000100001000001;
    maze[20] = 32'b10000001000000000011100001000001;
    maze[21] = 32'b10000001000000000000000001000001;
    maze[22] = 32'b10000001000000000000000001000001;
    maze[23] = 32'b11110001111111111000011111000111;
    maze[24] = 32'b10000000000000000000000100000001;
    maze[25] = 32'b10000000000000000000000100000001;
    maze[26] = 32'b10000000000000000000000100000001;
    maze[27] = 32'b11111111111111111111111111111111;    //downside
  end
  
endmodule


module mouse_bitmap(x, y, playfield_gfx);
  
  input [3:0] x;
  input [3:0] y;
  output playfield_gfx;
  
  reg [10:0] maze [0:10];
  
  assign playfield_gfx = maze[y][x];
  
  initial begin/*{w:32,h:28,bpw:32}*/
    maze[0]   = 'b00000000000;
    maze[1]   = 'b00110001100;
    maze[2]   = 'b01001010010;
    maze[3]   = 'b01001010010;
    maze[4]   = 'b00111111100;
    maze[5]   = 'b00100000100;
    maze[6]   = 'b00101010100;
    maze[7]   = 'b00100000100;
    maze[8]   = 'b00010001000;
    maze[9]   = 'b00001110000;
    maze[10]  = 'b00000000000;
  end
  
endmodule

module cat_bitmap(x, y, playfield_gfx);
  
  input [3:0] x;
  input [3:0] y;
  output playfield_gfx;
  
  reg [10:0] maze [0:14];
  
  assign playfield_gfx = maze[x][y];
  
  initial begin/*{w:32,h:28,bpw:32}*/
    maze[0]   = 'b0000000000;
    maze[1]   = 'b0011111110;
    maze[2]   = 'b0100000100;
    maze[3]   = 'b1000001000;
    maze[4]   = 'b1000010000;
    maze[5]   = 'b1001010000;
    maze[6]   = 'b1000001000;
    maze[7]   = 'b1010001000;
    maze[8]   = 'b1000010000;
    maze[9]   = 'b1001010000;
    maze[10]  = 'b1000001000;
    maze[11]  = 'b1000001000;
    maze[12]  = 'b0100000100;
    maze[13]  = 'b0011111110;
    maze[14]  = 'b0000000000;

  end
  
endmodule

module tank_game_top(clk, reset, hsync, vsync, rgb, switches_p1, switches_p2);

  input clk, reset;
  input [7:0] switches_p1;
  input [7:0] switches_p2;
  
  output hsync, vsync;
  output [2:0] rgb;
  
  wire display_on;
  
  wire [8:0] hpos;
  wire [8:0] vpos;
  
  wire [8:0] mouse_posx;
  wire [8:0] mouse_posy;
  wire mouse_gfx;
  
  wire [8:0] dmouse_x = hpos - mouse_posx;
  wire [8:0] dmouse_y = vpos - mouse_posy;
  wire [7:0] mouse_flag;
  
  wire [8:0] cat_posx;
  wire [8:0] cat_posy;
  wire cat_gfx;
  
  wire [8:0] dcat_x = hpos - cat_posx;
  wire [8:0] dcat_y = vpos - cat_posy;
  wire [7:0] cat_flag;
  
  wire mine_gfx;
  wire flag_reset;
  
  // video sync generator  
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(0),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );
  
  playfield map(.hpos(hpos), 
                .vpos(vpos), 
                .playfield_gfx(mine_gfx));
  
  playfield mouse_and_border_left_up(.hpos(mouse_posx - 1), 
                .vpos(mouse_posy), 
                .playfield_gfx(mouse_flag[0]));
  playfield mouse_and_border_left_down(.hpos(mouse_posx - 1), 
                 .vpos(mouse_posy + 8), 
                .playfield_gfx(mouse_flag[1]));
  
  playfield mouse_and_border_right_up(.hpos(mouse_posx + 10), 
                .vpos(mouse_posy), 
                .playfield_gfx(mouse_flag[2]));
  playfield mouse_and_border_right_down(.hpos(mouse_posx + 10), 
                 .vpos(mouse_posy + 8), 
                .playfield_gfx(mouse_flag[3]));
  
  playfield mouse_and_border_up_left(.hpos(mouse_posx), 
                                     .vpos(mouse_posy - 1), 
                .playfield_gfx(mouse_flag[4]));
  playfield mouse_and_border_up_rigth(.hpos(mouse_posx + 9), 
                                      .vpos(mouse_posy - 1), 
                 .playfield_gfx(mouse_flag[5]));
  
  playfield mouse_and_border_down_left(.hpos(mouse_posx), 
                                       .vpos(mouse_posy + 9), 
                .playfield_gfx(mouse_flag[6]));
  playfield mouse_and_border_down_rigth(.hpos(mouse_posx + 9), 
                                        .vpos(mouse_posy + 9), 
                 .playfield_gfx(mouse_flag[7]));
  
  
  mouse_bitmap mouse_sprite(.x(dmouse_x <= 10 ? dmouse_x[3:0] : 0),
                            .y(dmouse_y <= 11 ? dmouse_y[3:0] : 0),
                            .playfield_gfx(mouse_gfx));
  //cat
  playfield cat_and_border_left_up(.hpos(cat_posx - 1), 
                .vpos(cat_posy), 
                .playfield_gfx(cat_flag[0]));
  playfield cat_and_border_left_down(.hpos(cat_posx - 1), 
                                     .vpos(cat_posy + 8), 
                .playfield_gfx(cat_flag[1]));
  
  playfield cat_and_border_right_up(.hpos(cat_posx + 14), 
                .vpos(cat_posy), 
                .playfield_gfx(cat_flag[2]));
  playfield cat_and_border_right_down(.hpos(cat_posx + 14), 
                                      .vpos(cat_posy + 8), 
                .playfield_gfx(cat_flag[3]));
  
  playfield cat_and_border_up_left(.hpos(cat_posx), 
                                     .vpos(cat_posy - 1), 
                .playfield_gfx(cat_flag[4]));
  playfield cat_and_border_up_rigth(.hpos(cat_posx + 13), 
                                      .vpos(cat_posy - 1), 
                 .playfield_gfx(cat_flag[5]));
  
  playfield cat_and_border_down_left(.hpos(cat_posx), 
                                     .vpos(cat_posy + 8), 
                .playfield_gfx(cat_flag[6]));
  playfield cat_and_border_down_rigth(.hpos(cat_posx + 13), 
                                      .vpos(cat_posy + 8), 
                 .playfield_gfx(cat_flag[7]));
  
  cat_bitmap cat_sprite(.x(dcat_x <= 15 ? dcat_x[3:0] : 0),
                        .y(dcat_y <= 11 ? dcat_y[3:0] : 0),
                        .playfield_gfx(cat_gfx));
  
  collider #(3, 3, 10, 10, 15, 11) coll(.hpos1(mouse_posx), 
                    .hpos2(cat_posx), 
                    .vpos1(mouse_posy), 
                    .vpos2(cat_posy), 
                    .collide(flag_reset));
  
  initial begin 
    mouse_posx = 220;
    mouse_posy = 30;
    cat_posx = 20;
    cat_posy = 215;
  end
  
  // по x
  always @(posedge vsync) begin
    if (reset || flag_reset) begin
      mouse_posx <= 220;    
    end else begin 
      if (!mouse_flag[0] && !mouse_flag[1]) begin
        if (switches_p1[0])
          mouse_posx <= mouse_posx - 1;
      end else
        mouse_posx <= mouse_posx + 1;
      if (!mouse_flag[2] && !mouse_flag[3]) begin
        if (switches_p1[1])
          mouse_posx <= mouse_posx + 1;
      end else
        mouse_posx <= mouse_posx - 1;
    end
  end
  
  // по y
  always @(posedge vsync) begin
    if (reset || flag_reset) begin
      mouse_posy <= 30;
    end else begin 
      if (!mouse_flag[4] && !mouse_flag[5]) begin
        if (switches_p1[2])
          mouse_posy <= mouse_posy - 1;
      end else
        mouse_posy <= mouse_posy + 1;
      if (!mouse_flag[6] && !mouse_flag[7]) begin
        if (switches_p1[3])
          mouse_posy <= mouse_posy + 1;
      end else
        mouse_posy <= mouse_posy - 1;
    end  
  end
  
  // по x
  always @(posedge vsync) begin
    if (reset || flag_reset) begin
      cat_posx <= 20;    
    end else begin 
      if (!cat_flag[0] && !cat_flag[1]) begin
        if (switches_p2[0])
          cat_posx <= cat_posx - 2;
      end else
        cat_posx <= cat_posx + 2;
      if (!cat_flag[2] && !cat_flag[3]) begin
        if (switches_p2[1])
          cat_posx <= cat_posx + 2;
      end else
        cat_posx <= cat_posx - 2;
    end
  end
  
  // по y
  always @(posedge vsync) begin
    if (reset || flag_reset) begin
      cat_posy <= 215;
    end else begin 
      if (!cat_flag[4] && !cat_flag[5]) begin
        if (switches_p2[2])
          cat_posy <= cat_posy - 2;
      end else
        cat_posy <= cat_posy + 2;
      if (!cat_flag[6] && !cat_flag[7]) begin
        if (switches_p2[3])
          cat_posy <= cat_posy + 2;
      end else
        cat_posy <= cat_posy - 2;
    end  
  end
    
  // video signal mixer
  wire r = display_on && (mouse_gfx || cat_gfx);
  wire g = display_on && (mine_gfx || mouse_gfx || cat_gfx);
  wire b = display_on && (mouse_gfx || cat_gfx);
  assign rgb = {b,g,r};
  
endmodule

module collider(hpos1, hpos2, vpos1, vpos2, collide);
        input    [8 : 0] hpos1;
        input    [8 : 0] hpos2;
        input    [8 : 0] vpos1;
        input    [8 : 0] vpos2;
    output collide;
        wire    hor_collide;
        wire    ver_collide;

        parameter hspeed = 0;        // object 1 horizontal speed (to know depth for collision)
        parameter vspeed = 0;        // object 1 vertical speed (to know depth for collision)
        parameter FROM_HSIZE = 0;    // object 1 horizontal size
        parameter FROM_VSIZE = 0;    // object 1 vertical size
        parameter TO_HSIZE = 0;        // object 2 horizontal size
        parameter TO_VSIZE = 0;        // object 2 vertical size

        wire hor_collide_left = hpos1 + FROM_HSIZE >= hpos2 && hpos1 + FROM_HSIZE <= hpos2 + 2 * hspeed;
        wire hor_collide_righ = hpos1 <= hpos2 + TO_HSIZE && hpos1 >= hpos2 + TO_HSIZE - 2 * hspeed; 
        wire hor_collide_nsid = vpos1 >= vpos2 - FROM_VSIZE && vpos1 <= vpos2 + TO_VSIZE;

        wire ver_collide_left = vpos1 + FROM_VSIZE >= vpos2 && vpos1 + FROM_VSIZE < vpos2 + 2 * vspeed;
        wire ver_collide_righ = vpos1 <= vpos2 + TO_VSIZE && vpos1 >= vpos2 + TO_VSIZE - 2 * vspeed; 
        wire ver_collide_nsid = hpos1 >= hpos2 - FROM_HSIZE && hpos1 <= hpos2 + TO_HSIZE;

        assign hor_collide = (hor_collide_left || hor_collide_righ) && hor_collide_nsid;
        assign ver_collide = (ver_collide_left || ver_collide_righ) && ver_collide_nsid;
  assign collide = hor_collide | ver_collide;
    endmodule