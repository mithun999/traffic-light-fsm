`timescale 1ns/1ps
module traffic_fsm #(
     parameter GREEN_TIME  = 30,
    parameter YELLOW_TIME = 5,
    parameter PED_TIME    = 20,
    parameter FLASH_COUNT = 6
)

(input  wire clk,
    input  wire  rst_n,      // active-low asyn
    input  wire   ped_req,    // pedestrian button (which can be pressed by the pedestrians)
    input  wire    emergency, // for emergency vehicles  such as ambulances
    output reg [2:0] ns_light,
    output reg [2:0] ew_light,
    output reg        ped_walk,   // walk signal
    output reg        ped_dont,   // don't walk 
    output reg  [2:0] state_out // this is the current state
    );

    // states for traffic polls and other buttons
    localparam [2:0] 
        NS_GREEN  = 3'd0,
        NS_YELLOW = 3'd1,
        EW_GREEN  = 3'd2,
        EW_YELLOW = 3'd3,
        PED_WALK  = 3'd4,
        PED_FLASH = 3'd5,
        EMERGENCY = 3'd6;
    // states for light
    localparam [2:0]
        RED=3'd4,
        YELLOW=3'd2,
        GREEN=3'd1;
       
    //

    reg [2:0] state, next_state;
    reg [7:0] timer;
    reg [3:0] flash_cnt;
    reg       ped_pending;
    
    // Pedestrian request
   always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ped_pending <= 0;
        else if (ped_req)
            ped_pending <= 1;
        else if (state == PED_WALK)
            ped_pending <= 0;
    end

    // state change 
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
        state<=NS_GREEN;//base case
        else
        state<= next_state;
    end

    // timer assignment for each signal
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            timer<=GREEN_TIME-1;
            flash_cnt<=0;
        end
        else begin
            if(state!=next_state)begin
                case(next_state)
                     NS_GREEN:  timer<=  GREEN_TIME  - 1;
                    NS_YELLOW: timer <= YELLOW_TIME - 1;
                    EW_GREEN:  timer <= GREEN_TIME  - 1;
                    EW_YELLOW: timer <= YELLOW_TIME - 1;
                    PED_WALK:  timer <= PED_TIME- 1;
                    PED_FLASH:begin
                        timer<=4-1;
                        flash_cnt<=FLASH_COUNT;
                    end
                    default:timer<=0;
                endcase
            end
            else begin
                if(state==PED_FLASH) begin
                    if(timer!=0)
                    timer<=timer-1;
                    else begin
        timer<=4-1;
        flash_cnt<=flash_cnt-1;
    end
end
else begin
    if(timer!=0)
        timer<=timer-1;
end
            end
        end
    end
    
    
    

        // combinational logic
        always@(*)begin
            next_state=state;
            if(emergency)begin// highest preference
                next_state=EMERGENCY;
            end
            else begin
                case(state)
                NS_GREEN: if(timer==0) next_state=ped_pending?PED_WALK:NS_YELLOW;
                NS_YELLOW: if(timer == 0) next_state = EW_GREEN;
                EW_GREEN:   if(timer == 0) next_state = EW_YELLOW;
                EW_YELLOW:  if(timer == 0) next_state = NS_GREEN;
                PED_WALK:   if(timer == 0) next_state = PED_FLASH;
                PED_FLASH:  if(flash_cnt == 0) next_state = EW_GREEN;
                EMERGENCY:  if(!emergency) next_state = NS_GREEN;
                endcase
            end
        end

        //output
        always @(*) begin
          ns_light  = RED;
        ew_light  = RED;
        ped_walk  = 0;
        ped_dont  = 1;
        state_out = state;

             case (state)
            NS_GREEN: ns_light = GREEN;
            NS_YELLOW:ns_light = YELLOW;
            EW_GREEN: ew_light = GREEN;
            EW_YELLOW: ew_light = YELLOW;
            PED_WALK:  begin ped_walk = 1; ped_dont = 0; end
            PED_FLASH: ped_dont = flash_cnt[0]; // toggles each flash
            EMERGENCY: ; // all RED already by default
        endcase
    end
 
endmodule


    
 





