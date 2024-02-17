`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 03:14:13 PM
// Design Name: 
// Module Name: apb_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module apb_fifo #(parameter WIDTH = 8)(

    //APB signals
    input                    PCLK,
    input                    rd_clk,
    input                    PRESET_N,
    input                    PSEL,
    input        [WIDTH-1:0] PADDR,
    input        [WIDTH-1:0] PWDATA,
    input                    PENABLE,
    input                    PWRITE,
    output logic             PREADY,
    output logic             PSLVERR,
    output logic [WIDTH-1:0] PRDATA,
    output                   w_wr_rst_busy,
    output                   w_rd_rst_busy
    );
    
        //WRITE_FIFO Signals
    
    wire             w_full;
    wire             w_wr_ack;
//    wire             w_wr_rst_busy;
//    wire             w_rd_rst_busy;
    wire             w_wr_en;
    wire [WIDTH*2:0] w_din;
    
    //READ_FIFO Signals
    
    wire             r_empty;
    wire             r_valid;
//    wire r_wr_rst_busy;
//    wire r_rd_rst_busy;
    wire [WIDTH-1:0] r_dout;
    wire             r_rd_en;
    
    wire             fifo_reset;
    
    assign fifo_reset = !PRESET_N;
  WRITE_FIFO f1 (
  .rst(fifo_reset),                  // input wire rst
  .wr_clk(PCLK),            // input wire wr_clk
  .rd_clk(rd_clk),            // input wire rd_clk
  .din(w_din),                  // input wire [16 : 0] din
  .wr_en(w_wr_en),              // input wire wr_en
  .rd_en(r_rd_en),              // input wire rd_en
  .dout(r_dout),                // output wire [16 : 0] dout
  .full(w_full),                // output wire full
  .wr_ack(w_wr_ack),            // output wire wr_ack
  .empty(r_empty),              // output wire empty
  .valid(r_valid),              // output wire valid
  .wr_rst_busy(w_wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(w_rd_rst_busy)  // output wire rd_rst_busy
);

 APB a1 ( .PCLK(PCLK),         
          .PRESET_N(PRESET_N),     
          .PSEL(PSEL),         
          .PADDR(PADDR),        
          .PWDATA(PWDATA)               ,     
          .PENABLE(PENABLE)             ,
          .PWRITE(PWRITE)               ,
          .PREADY(PREADY)               ,
          .PSLVERR(PSLVERR)             ,
          .PRDATA(PRDATA)               ,
          .w_full(w_full)               ,
          .w_wr_ack(w_wr_ack)           ,
          .w_wr_rst_busy(w_wr_rst_busy) ,
          .w_rd_rst_busy(w_rd_rst_busy) ,
          .w_wr_en(w_wr_en)             ,
          .w_din(w_din)                 ,
          .r_empty(r_empty)             ,
          .r_valid(r_valid)             ,
          .r_wr_rst_busy(r_wr_rst_busy) ,
          .r_rd_rst_busy(r_rd_rst_busy) ,
          .r_dout(r_dout)               ,
          .r_rd_en(r_rd_en)
); 
endmodule
