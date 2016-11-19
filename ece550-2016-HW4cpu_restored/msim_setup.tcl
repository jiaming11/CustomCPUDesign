#CREATED BY PETER MURPHY FOR TESTING ALTERA GENERATED IP FOR CYCLONE DEVICES
# 1 OCTOBER 2016
#
# STEP 1:
#be sure to set the path to quartus correctly, here:
set path_to_quartus C:/altera_lite/16.0/quartus
# STEP 2:
#set the path to your project directory here.  This directory MUST contain ALL of your VHDL files
set path_to_project C:\Users\Young-hoon Kim\Desktop\ECE550\HW4\cpu550-2016fa-skeleton-rev1_restored
#set path_to_sim $path_to_project/simulation_files
set type_of_sim compile_all
set sim_cycloneiv 1

vlib work
if { $sim_cycloneiv } {
	if {[string equal $type_of_sim "compile_all"]} {
		vlib lpm
		vmap lpm lpm
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
		vlib altera_mf
		vmap altera_mf altera_mf
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
		vlib altera
		vmap altera altera
		vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
		vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives.vhd
		vlib sgate
		vmap sgate sgate
		vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
		vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
		vlib altgxb
		vlib cycloneiv
		vmap cycloneiv cycloneiv
		vcom -work cycloneiv -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiv_atoms.vhd
		vcom -work cycloneiv -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiv_components.vhd
		
	} elseif {[string equal $type_of_sim "functional"]} {
	# required for functional simulation of designs that call LPM & altera_mf functions
		vlib lpm
		vmap lpm lpm
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
		vlib altera_mf
		vmap altera_mf altera_mf
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
	} elseif {[string equal $type_of_sim "ip_functional"]} {
	# required for IP functional simualtion of designs
		vlib lpm
		vmap lpm lpm
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
		vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
		vlib altera_mf
		vmap altera_mf altera_mf
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
		vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
		vlib sgate
		vmap sgate sgate
		vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
		vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	} elseif {[string equal $type_of_sim "cycloneiv"]} {
		# required for gate-level simulation of CYCLONEIV designs
		vlib cycloneiv
		vmap cycloneiv cycloneiv
		vcom -work cycloneiv -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiv_atoms.vhd
		vcom -work cycloneiv -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiv_components.vhd
	} elseif {[string equal $type_of_sim "cycloneiii"]} {

	} else {
		puts "invalid code"
	}
}


#STEP 3: add any other .vhd or .vhdl files to the following list in this same format as follows:
# vcom "$path_to_project/<name_of_vhdl_file>.vhd -work work"
# Note that the '<>' signs are not to be included.  For a reference, use the following
# 3 vcom commands.

vcom "$path_to_project/dmem.vhd"					-work work
vcom "$path_to_project/imem.vhd"        			-work work
vcom "$path_to_project/processor.vhd"	    		-work work
vcom "$path_to_project/control.vhd"	        		-work work
vcom "$path_to_project/reg.vhd"	        			-work work
vcom "$path_to_project/regfile.vhd"	       			-work work
vcom "$path_to_project/reg0_2port.vhd"	   			-work work
vcom "$path_to_project/reg_2port.vhd"	   			-work work
vcom "$path_to_project/mux.vhd"	       	 			-work work
vcom "$path_to_project/adder_cs.vhd"	   			-work work
vcom "$path_to_project/adder_rc.vhd"	   			-work work
vcom "$path_to_project/skeleton.vhd"	   			-work work
vcom "$path_to_project/ps2.vhd"	       				-work work
vcom "$path_to_project/lcd.vhd"	        			-work work
vcom "$path_to_project/decoder5to32.vhd"			-work work
vcom "$path_to_project/shifter.vhd"	        		-work work
vcom "$path_to_project/alu.vhd"	        			-work work
vcom "$path_to_project/skeleton_testbench.vhd"	    -work work


#STEP 4: Add the files/entities you just added to simulate.  Just add 'work.<name_of_vhdl_file>', as follows:
vsim -novopt work.skeleton_testbench work.dmem work.imem work.processor work.control work.reg work.regfile work.reg0_2port work.reg_2port work.mux work.adder_cs work.adder_rc work.skeleton work.ps2 work.lcd work.decoder5to32 work.shifter work.alu

#STEP 5 & 6 (optional)
#if you have a saved wave.do file, uncomment out the following line

add wave -position insertpoint  \
sim:/skeleton_testbench/clk \
sim:/skeleton_testbench/rst \
sim:/skeleton_testbench/ps2_data_sig \
sim:/skeleton_testbench/lcd_data_sig \
sim:/skeleton_testbench/leds_sig \
sim:/skeleton_testbench/lcd_rw_sig \
sim:/skeleton_testbench/lcd_en_sig \
sim:/skeleton_testbench/lcd_rs_sig \
sim:/skeleton_testbench/lcd_on_sig \
sim:/skeleton_testbench/lcd_blon_sig \
sim:/skeleton_testbench/address_sig \
sim:/skeleton_testbench/wren_sig \
sim:/skeleton_testbench/q_sig \
sim:/skeleton_testbench/data_sig \
sim:/skeleton_testbench/clk_period

run 100us

#do wave.do
#feel free to uncomment the following line to automatically run the simulation for 25us
#run 25us
