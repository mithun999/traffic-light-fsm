`timescale 1ns/1ps

module top(
    input wire clk,
    input wire   rst_n,
    input  wire  ped_req,
    input  wire   emergency,
 
    output wire   ns_red, ns_yellow, ns_green,
    output wire   ew_red, ew_yellow, ew_green,
    output wire   ped_walk_led,
    output wire  ped_dont_led,
    output wire [2:0] state_out
);

    wire [2:0] ns_light ,ew_light;
    wire ped_walk,ped_dont;

    traffic_fsm #(
        .GREEN_TIME  (30),
        .YELLOW_TIME (5),
        .PED_TIME    (20),
        .FLASH_COUNT (6)
    ) u_fsm (
        .clk (clk),
        .rst_n  (rst_n),
        .ped_req   (ped_req),
        .emergency (emergency),
        .ns_light  (ns_light),
        .ew_light (ew_light),
        .ped_walk  (ped_walk),
        .ped_dont(ped_dont),
        .state_out (state_out)
    );

    assign {ns_red, ns_yellow, ns_green} = ns_light;
    assign {ew_red, ew_yellow, ew_green} = ew_light;
    assign ped_walk_led = ped_walk;
    assign ped_dont_led = ped_dont;
 
endmodule