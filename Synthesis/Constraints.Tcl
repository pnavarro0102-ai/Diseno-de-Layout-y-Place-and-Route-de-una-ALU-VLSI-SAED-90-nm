###############################################
#
#Script para constraints en Syn
#
#Author: Pablo Navarro
#
###############################################

#create clocks
create_clock -period 0.8 [get_ports CLK]

set_dont_touch_network [get_clocks CLK]

#uncertainty
set_clock_uncertainty -setup 0.08 [get_clocks CLK]
set_clock_uncertainty -hold 0.08 [get_clocks CLK]

#latency
set_clock_latency 0 [get_clocks CLK]

#In ports
set_input_delay -max 0.4 -clock [get_clocks CLK] [remove_from_collection [all_inputs] [get_ports CLK]]
set_input_delay -min 0.0 -clock [get_clocks CLK] [remove_from_collection [all_inputs] [get_ports CLK]]

#fanout limit
set_max_fanout 10 ALU

###############################################
