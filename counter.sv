`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 03:25:42 PM
// Design Name: 
// Module Name: counter
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


module counter #(parameter COUNT_DEPTH = 5)(
    input                              clk,
    input                              reset_n,
    input                              count_en,
    output logic [COUNT_DEPTH - 1 : 0] count
    );
    
    always_ff@(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            count <= 'b0;
        end else if(count_en) begin
            count <= count+1; 
        end else begin
            count <= 'b0;
        end
    end
endmodule
