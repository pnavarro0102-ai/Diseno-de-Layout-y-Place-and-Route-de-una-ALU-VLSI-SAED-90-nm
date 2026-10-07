##############################################
#
# Script para Synthesis (sin constraints)
#
# Author: Pablo Navarro
#
##############################################

#remover cualquier diseno anterior
remove_design -designs

#Agregamos las bibliotecas
set target_library [ls ../libs/saed90nm_max.db]
set link_library   [ls ../libs/saed90nm_max.db]

#Leer el Verilog(archivo por archivo)
set verilog_files [ls ../source/*.v]

foreach file $verilog_files {
    puts "INFO: Reading verilog $file"
    read_file -format verilog $file
}

#Ejecutamos Analyze
foreach file $verilog_files {
    puts "INFO: Analyzing verilog $file"
    analyze -format verilog $file
}

#Definir el TOP y hacemos elaborate
current_design ALU
elaborate ALU

#linking
link

#source constraints
source ../scripts/constraints.tcl
propagate_constraints

#Guardar db inicial
write -hierarchy -format ddc -output ../dbs/diseno_precompile.ddc

#Check y compile
check_design
compile_ultra

#Guardado final
write -hierarchy -format ddc -output ../dbs/diseno_postcompile.ddc
set verilogout_no_tri true
change_names -hierarchy -rules verilog
write -hierarchy -format verilog -output ../dbs/diseno.v
write_sdc ../dbs/diseno.sdc

##############################################
