###############################################
#
#Script para constraints en Place
#
#Author: Pablo Navarro
#
###############################################

#create clocks
create_clock -period 1.0 [get_ports CLK]

set_dont_touch_network [get_clocks CLK]

#uncertainty
set_clock_uncertainty -setup 0.01 [get_clocks CLK]
set_clock_uncertainty -hold 0.01 [get_clocks CLK]

#latency
set_clock_latency 0 [get_clocks CLK]

#In and Out ports
set_input_delay -max 0.5 -clock [get_clocks CLK] [remove_from_collection [all_inputs] [get_ports CLK]]
set_input_delay -min 0.0 -clock [get_clocks CLK] [remove_from_collection [all_inputs] [get_ports CLK]]

set_output_delay -max 0.5 -clock [get_clocks CLK] [all_outputs]
set_output_delay -min 0.0 -clock [get_clocks CLK] [all_outputs]

#Definir trans
set_max_transition 0.3 [current_design]

###############################################
