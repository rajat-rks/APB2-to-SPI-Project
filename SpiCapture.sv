`timescale 1ns / 1ps

module SPICapture(MOSI, MISO, SCLK, resetn, w_empty, w_dout, r_din, r_wr_en, w_rd_en);
parameter COUNT_WIDTH = 3;
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;

    input wire SCLK;
    input wire resetn; // global reset signal
    input wire w_empty;
    input wire [ADDR_WIDTH+DATA_WIDTH:0] w_dout;
    input wire MISO;
    output logic MOSI;
    output logic w_rd_en;
  //R_FIFO signals
    output logic [DATA_WIDTH-1:0] r_din;
    output logic r_wr_en;
    
// Store Transaction bit Read or Write
    logic Wr; //Wr = 1 Write Transaction; Wr = 0  Read Transaction;

//SIPO for Read Transaction
logic [DATA_WIDTH-1:0] R_SIPO;

// State Machine 
parameter IDLE = 2'b00;
parameter READ_FIFO_0 = 2'b01;
parameter READ_ADDR = 2'b10;
parameter READ_WR_DATA = 2'b11;

// Valid signals to indicate successful capture
    logic [1:0] ps, ns; //Present and next states 

 //Counter Signals
  logic [COUNT_WIDTH-1:0] count;
  logic count_start;

  //Counter  
always_ff @ (posedge SCLK, negedge resetn)
begin
    if(resetn == 1'b0)
    begin
        count <= 'b0;
    end
    else
    begin
        if(count_start == 1'b1)
        begin
            count <= count + 1;
        end
        else
        begin
            count <= 'b0;
        end
    end
end

    logic [(DATA_WIDTH + ADDR_WIDTH):0] In_PISO;
    logic load_en;
    logic shift;
    logic serial_out;
    logic PISO_data_valid; // Indication that data is loaded onto PISO
    
//Parallel in serial out at the input of spi block
assign load_en = ~w_empty;
assign MOSI = serial_out;
always_ff@(posedge SCLK, negedge resetn)
begin
    if(resetn == 1'b0)
    begin
        w_rd_en <= 1'b0;
        In_PISO <= 'b0;
        PISO_data_valid <= 1'b0;
        serial_out <= 1'bz;
    end
    else if(load_en == 1'b1 && ps == IDLE)
    begin
        w_rd_en <= 1'b1;
        In_PISO <= w_dout;
        PISO_data_valid <= 1'b1;
        serial_out <= 1'bz;
    end
    else if (shift == 1'b1)
    begin
        w_rd_en <= 1'b0;
        PISO_data_valid <= 1'b1;
        serial_out <= In_PISO[16];
        In_PISO <= In_PISO << 1;  //Left Shift data. 
    end
    else
    begin
        w_rd_en <= 1'b0;
        PISO_data_valid <= 1'b0;
        serial_out <= 1'bz;
        In_PISO <= In_PISO;
    end
end

//Registering the Transaction bit
always_ff @ (posedge SCLK, negedge resetn)
begin
    if(resetn == 1'b0)
    begin
        Wr <= 1'b0;
    end
    else if(ps == READ_FIFO_0)
    begin
        Wr <= In_PISO[16];
    end
    else
    begin
        Wr <= Wr;
    end
end 


//State Machine
always_ff @ (posedge SCLK, negedge resetn)
begin
    if(resetn == 1'b0)
    begin
        ps <= IDLE;
    end
    else
    begin
        ps <= ns;
    end
end
//Next state logic for state machine
always_comb
begin
    case(ps)
        IDLE:begin
                      count_start <= 1'b0;
                      shift <= 1'b0;
                      if(PISO_data_valid == 1'b0)
                      begin
                          ns <= IDLE;
                          r_wr_en <= 1'b0; //Signal for Read_FIFO
                      end
                      else
                      begin
                          ns <= READ_FIFO_0;
                          r_wr_en <= 1'b0; //Signal for Read_FIFO
                      end
        end
        
        READ_FIFO_0:begin
                       count_start <= 1'b0;
                       ns <= READ_ADDR;
                       r_wr_en <= 1'b0;
                       shift <= 1'b1;    
        end
        
        READ_ADDR:begin
                        count_start <= 1'b1;
                         shift <= 1'b1;
                        if(count < 3'b111)
                        begin
                            ns <= READ_ADDR;
                            r_wr_en <= 1'b0;
                        end
                        else
                        begin
                            ns <= READ_WR_DATA;
                            r_wr_en <= 1'b0;
                        end
        end
        
       READ_WR_DATA:begin
                        count_start <= 1'b1;
                        if(Wr == 1'b0)
                                shift <= 1'b0;
                            else
                                shift <= 1'b1;
                        if(count < 3'b111)
                        begin
                            ns <= READ_WR_DATA;
                            r_wr_en <= 1'b0;
                        end
                        else
                        begin
                            ns <= IDLE;
                            r_wr_en <= 1'b1; //Data is ready in the SIPO, load it into Read_FIFO
                        end
       end 
    endcase 
end

//Sampling MISO line if read Transaction
assign r_din = R_SIPO;
always_ff @(posedge SCLK, negedge resetn)
begin
    if(resetn == 1'b0)
    begin
        R_SIPO <= 'b0;    
    end
    else if(ps == READ_WR_DATA && Wr == 0)
    begin
        R_SIPO <= {MISO, R_SIPO[DATA_WIDTH-1:1]};
    end
    else
    begin
        R_SIPO <= R_SIPO;
    end
end
endmodule

    






