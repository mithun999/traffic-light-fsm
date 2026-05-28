`timescale 1ns/1ps

module tb_timer;

//inputs
reg clk;
reg rst_n;
reg en;
reg load;
reg [7:0] period;
// outputs
wire done;

  timer #(
        .WIDTH  (8),
        .PERIOD (10)       // short period so easier to simulate
  ) dut(
    .clk(clk),
    .rst_n(rst_n),
    .en (en),
    .load (load),
    .period (period),
    .done(done)
  );

  initial clk=0;
  always #5 clk=~clk;//created a clock with time period 10ns(5ns on and 5ns off)
// task
 task apply_reset;
        begin
            rst_n  = 0;
            en     = 0;
            load   = 0;
            period = 0;
            repeat(4) @(posedge clk); // hold reset for 4 ticks
            rst_n = 1;                // release reset
            @(posedge clk);           // wait one more tick to settle
        end
    endtask
 
    //  task: wait N ticks 
    task wait_ticks;
        input integer n;
        integer i;
        begin
            for(i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask
  // To check every time done pulsed
  always @(posedge clk) begin
    if (done)
    $display("[%0t] Done pusled ",$time);
  end
// test stimulus
  initial begin
    $dumpfile("tb_timer.vcd");
    $dumpvars(0,tb_timer);

    $display("  Scenario 1: Reset ");
  apply_reset;
  if (done !== 1'b0)
            $display("FAIL: done should be 0 after reset");
        else
            $display("PASS: done is 0 after reset");




    $display("   Scenario 2:normal countdown");
    // check the difference between the done as it shloud be 10 ticks
    apply_reset;
    en=1;
    repeat(25) @(posedge clk)begin
        if(done)
        $display("done is high at %0t",$time);
    end
    en=0;



    $display("   Scenario 3:Enable pause");
    apply_reset;
    en=1;
    repeat(4) @(posedge clk);
    $display("paused");
    en=0;
    wait_ticks(5);
    $display("resuming");
    en=1;
    wait_ticks(10);


    $display("Scenario 4: reset mid count");
    apply_reset;
    en=1;
    wait_ticks(4);
     $display("   Applying reset mid-count...");
        rst_n = 0;              // reset while counting
        @(posedge clk);
        rst_n = 1;
        if (done !== 1'b0)
            $display("FAIL: done should be 0 after mid-count reset");
        else
            $display("PASS: reset mid-count works correctly");
        wait_ticks(5);
 
        $display("\nALL SCENARIOS DONE \n");
        $finish;
    end
endmodule




  
  
  
  