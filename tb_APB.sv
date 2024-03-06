`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 12:05:31 PM
// Design Name: 
// Module Name: tb_APB
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


module tb_APB #(parameter WIDTH = 8)();

    logic                    PCLK;
    logic                    rd_clk;
    logic                    PRESET_N;
    logic                    PSEL;
    logic        [WIDTH-1:0] PADDR;
    logic        [WIDTH-1:0] PWDATA;
    logic                    PENABLE;
    logic                    PWRITE;
    logic                    PREADY;
    logic                    PSLVERR;
    logic [WIDTH-1:0]        PRDATA;
    logic                    w_wr_rst_busy;
    logic                    w_rd_rst_busy;
    
    apb_fifo DUT (.*);
    
    initial begin
        PCLK = 'b1;
        forever #5 PCLK = !PCLK;
    end
    
    initial begin
        rd_clk = 'b1;
        forever #10 rd_clk = !rd_clk;
    end
    
    initial begin
        PRESET_N = 'b0;
        #100 PRESET_N = 'b1;
    end
    
    initial begin
        {PSEL,PADDR,PWDATA,PENABLE,PWRITE,PREADY} = 'b0;
        @(posedge PRESET_N);
        #100;
        wait(!w_wr_rst_busy & !w_rd_rst_busy);
        @(posedge PCLK);
//        repeat (3) begin
            APB_WRITE();
            APB_READ();
            APB_READ();
//            wait(PREADY);
//        end
        #100 $finish();    
    end
    
    task APB_WRITE();
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        {PADDR,PWDATA,PWRITE} = {8'haa,8'hbb,1'b1};
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b1;
        @(posedge PREADY);
        #20;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    endtask
    
    task APB_READ();
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        {PADDR,PWDATA,PWRITE} = {8'haa,8'h0,1'b0};
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b1;
        @(posedge PREADY);
        #20;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    endtask
    
    initial begin
        $dumpfile("APB_wave.vcd");
        $dumpvars(0,tb_APB);
    end
  
endmodule
