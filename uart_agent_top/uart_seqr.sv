class uart_seqr extends uvm_sequencer #(uart_xtn);
	`uvm_component_utils(uart_seqr)

	extern function new(string name = "uart_seqr", uvm_component parent);
	
endclass

//Constructor New
function uart_seqr::new(string name = "uart_seqr", uvm_component parent);
	super.new(name,parent);
endfunction

