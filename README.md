# traffic-light-fsm
A mini project to better understand the implementation of fsm and verilog in real life situations.

What it does
Its not just a basic red green yellow loop. The controller handles three real world situations:

Normal sequence – NS becomes green and then turns yellow, then EW becomes green and then turns yellow, repeating in this pattern
Crossing for pedestrians – If the button is pressed, then the FSM waits for the existing green to end, stops all roads, and provides the pedestrian with time to cross using a walk signal, followed by a flashing don’t walk sign
Emergency vehicle – When an ambulance or a fire truck is seen, the light turns to red immediately and remains in red until the emergency ends

the timer module and it's testbecnh was done as a learning exercise as I realised it is not required for the fsm.
