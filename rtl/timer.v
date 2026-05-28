// this is used to count down
 module timer #(
    parameter WIDTH  = 8,           // counter bit width
    parameter PERIOD = 30           // default count value
)(
    input  wire             clk,
    input  wire             rst_n,  // async active-low reset
    input  wire             en,     // enable counting
    input  wire             load,   // reload counter
    input  wire [WIDTH-1:0] period, // dynamic period (used when load=1)
    output reg              done    // pulses high for 1 clk when count hits 0
);
 
    reg [WIDTH-1:0] count;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= PERIOD - 1;
            done  <= 1'b0;
        end else begin
            done <= 1'b0; // default: no pulse
  
            if (load) begin
                count <= period - 1;
            end else if (en) begin
                if (count == 0) begin
                    count <= PERIOD - 1; // auto-reload
                    done  <= 1'b1;
                end else begin
                    count <= count - 1;
                end
            end
        end
    end
 
endmodule