package uart_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	`include "apb_agt_config.sv"
	`include "uart_agt_config.sv"
	`include "env_config.sv"	

	`include "apb_xtn.sv"
	`include "apb_seqr.sv"
	`include "apb_seqs.sv"
	`include "apb_driver.sv"
	`include "apb_monitor.sv"
	`include "apb_agent.sv"
	`include "apb_agent_top.sv"

	`include "uart_xtn.sv"
	`include "uart_seqr.sv"
	`include "uart_seqs.sv"
	`include "uart_driver.sv"
	`include "uart_monitor.sv"
	`include "uart_agent.sv"
	`include "uart_agent_top.sv"
	
	`include "uart_scoreboard.sv"

	`include "uart_env.sv"

	`include "uart_test.sv"
endpackage	

