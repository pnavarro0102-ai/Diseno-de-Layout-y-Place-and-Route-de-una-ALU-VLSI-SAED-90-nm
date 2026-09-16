###############################################
#
#Script para Placement y Route
#
#Author: Pablo Navarro
#
###############################################

#Crear una base DB
create_lib ../dbs/diseno1ns.ndm -ref_libs ../libs/my_ref_lib.ndb
create_block diseno1ns 

#Agregar el diseno
read_verilog ../source/diseno.v -top ALU
uniquify
link

#Crear Floorplan
initialize_floorplan -control_type core -core_utilization 0.85 -shape R \
-side_length {236 177}
read_parasitic_tech -tlup ../libs/saed90nm_1p9m_1t_nominal.tluplus 

report_tracks > ../reports/tracks1ns.txt

#Power
create_net -power VDD
create_net -ground VSS
create_power_domain VCC
create_supply_net VDD -domain VCC
create_supply_net VSS -domain VCC
create_supply_port VDD -domain VCC
create_supply_port VSS -domain VCC
connect_supply_net VDD -ports VDD
connect_supply_net VSS -ports VSS
set_domain_supply_net VCC -primary_power_net VDD -primary_ground_net VSS
commit_upf

#Revisar y conectar power
resolve_pg_net
connect_pg_net -auto


#Crear Power mesh
create_pg_mesh_pattern power_mesh -layer { \
 { {vertical_layer M8} {width: 2} {spacing: interleaving} {pitch: 32} } \
 { {vertical_layer M6} {width: 2} {spacing: interleaving} {pitch: 32} } \
 { {horizontal_layer M7} {width: 2} {spacing: interleaving} {pitch: 28} } \
}
set_pg_strategy my_strat -core -pattern \
 { {name: power_mesh} {nets: {VDD VSS} } } \
 -extension { {stop: desing_boundarry} }
compile_pg -strategies my_strat

#Save_lib
save_lib

#cp -r dbs/diseno1ns.ndm dbs/diseno1ns_FP_POWER.ndm

#Agregar constraints
source ../scripts/constraints8ns.tcl

#Place a puertos
place_pins -ports [get_ports]

#start_gui

#Placement
reset_placement -spread_cells
set_app_options -name place.coarse.fix_hard_macros -value false
set_app_options -name plan.place.auto_create_blockages -value auto
create_placement -floorplan
legalize_placement

#Constraints de optimizacion 
set_voltage 0.70 -corners default -object_list [get_supply_nets VDD]
set_parasitic_parameters \
-early_spec ../libs/saed90nm_1p9m_1t_nominal.tluplus -early_temperature 125 \
-late_spec ../libs/saed90nm_1p9m_1t_nominal.tluplus -late_temperature 125

#Reglas de clocking
set_clock_routing_rules -default_rule \
-max_routing_layer M6 \
-min_routing_layer M4

#Configuracion para evitar scan
set_app_options -name place.coarse.continue_on_missing_scandef -value true


#Optimization

place_opt

report_power                     > ../reports/reports1nsplaceopt/power_placeopt_1ns.txt
report_cell                      > ../reports/reports1nsplaceopt/cell_placeopt_1ns.txt  
report_qor                       > ../reports/reports1nsplaceopt/qor_placeopt_1ns.txt
report_clocks                    > ../reports/reports1nsplaceopt/clocks_placeopt_1ns.txt
report_utilization               > ../reports/reports1nsplaceopt/utilization_placeopt_1ns.txt
report_ports                     > ../reports/reports1nsplaceopt/ports_placeopt_1ns.txt
report_supply_nets               > ../reports/reports1nsplaceopt/power_placeopt_nets_1ns.txt
report_timing -max_paths 20 -delay_type max > ../reports/reports1nsplaceopt/timing_setup_placeopt_1ns.txt
report_timing -max_paths 20 -delay_type min > ../reports/reports1nsplaceopt/timing_hold_placeopt_1ns.txt

clock_opt

report_power                     > ../reports/reports1nsclockopt/power_clockopt_1ns.txt
report_cell                      > ../reports/reports1nsclockopt/cell_clockopt_1ns.txt  
report_qor                       > ../reports/reports1nsclockopt/qor_clockopt_1ns.txt
report_clocks                    > ../reports/reports1nsclockopt/clocks_clockopt_1ns.txt
report_utilization               > ../reports/reports1nsclockopt/utilization_clockopt_1ns.txt
report_ports                     > ../reports/reports1nsclockopt/ports_clockopt_1ns.txt
report_supply_nets               > ../reports/reports1nsclockopt/power_clockopt_nets_1ns.txt
report_timing -max_paths 20 -delay_type max > ../reports/reports1nsclockopt/timing_setup_clockopt_1ns.txt
report_timing -max_paths 20 -delay_type min > ../reports/reports1nsclockopt/timing_hold_clockopt_1ns.txt

#Routing
route_global
route_auto

route_opt

report_power                     > ../reports/reports1nsrouteopt/power_routeopt_1ns.txt
report_cell                      > ../reports/reports1nsrouteopt/cell_routeopt_1ns.txt  
report_qor                       > ../reports/reports1nsrouteopt/qor_routeopt_1ns.txt
report_clocks                    > ../reports/reports1nsrouteopt/clocks_routeopt_1ns.txt
report_utilization               > ../reports/reports1nsrouteopt/utilization_routeopt_1ns.txt
report_ports                     > ../reports/reports1nsrouteopt/ports_routeopt_1ns.txt
report_supply_nets               > ../reports/reports1nsrouteopt/power_routeopt_nets_1ns.txt
report_timing -max_paths 20 -delay_type max > ../reports/reports1nsrouteopt/timing_setup_routeopt_1ns.txt
report_timing -max_paths 20 -delay_type min > ../reports/reports1nsrouteopt/timing_hold_routeopt_1ns.txt

#Save
save_lib

###############################################
