class uart_xtn extends uvm_sequence_item;
	`uvm_object_utils(uart_xtn)

	//Add the Properties
	rand bit[7:0] txd;
	     bit[7:0] rxd;
	     bit parity;
	//methods
	extern function new(string name = "uart_xtn");
	extern function void do_print(uvm_printer printer);
endclass

//Constructor New
function uart_xtn::new(string name = "uart_xtn");
	super.new(name);
endfunction

//Print Method
function void uart_xtn::do_print(uvm_printer printer);
	super.do_print(printer);

	printer.print_field("txd", this.txd, $bits(this.txd), UVM_DEC);
	printer.print_field("rxd", this.rxd, $bits(this.rxd), UVM_DEC);
	printer.print_field("parity", this.parity, $bits(this.parity), UVM_DEC);
endfunction

