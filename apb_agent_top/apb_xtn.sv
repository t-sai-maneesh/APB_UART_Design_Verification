class apb_xtn extends uvm_sequence_item;
	`uvm_object_utils(apb_xtn)

	//Add the properties of apb interface
	     bit presetn;	
	rand bit [7:0] paddr;
	rand bit [7:0] pwdata;
	rand bit pwrite;
	     bit penable;
	     bit psel;
	     bit [7:0] prdata;
	     bit pready;
	     bit pslverr;
	     bit irq;
	
	//UART Registers
	     bit [7:0] thr[$];
	     bit [7:0] rbr[$];
	     bit [7:0] ier;
	     bit [7:0] iir;
	     bit [7:0] fcr;
	     bit [7:0] lcr;
	     bit [7:0] lsr;
	     bit [7:0] mcr;
	     bit [15:0] divisor;

	//constraints
	constraint c1{pwrite dist {0:=10,1:=10};}

	//methods
	extern function new(string name = "apb_xtn");
	extern function void do_print(uvm_printer printer);
endclass

//Constructor New
function apb_xtn::new(string name = "apb_xtn");
	super.new(name);
endfunction

//Print Method
function void apb_xtn::do_print(uvm_printer printer);
	super.do_print(printer);

	printer.print_field("presetn", this.presetn, $bits(this.presetn), UVM_BIN);
	printer.print_field("paddr",   this.paddr,   $bits(this.paddr),   UVM_HEX);
	printer.print_field("pwdata",  this.pwdata,  $bits(this.pwdata),  UVM_DEC);
	printer.print_field("pwrite",  this.pwrite,  $bits(this.pwrite),  UVM_BIN);
	printer.print_field("penable", this.penable, $bits(this.penable), UVM_DEC);
	printer.print_field("psel",    this.psel,    $bits(this.psel),    UVM_DEC);
	printer.print_field("prdata",  this.prdata,  $bits(this.prdata),  UVM_DEC);
	printer.print_field("pready",  this.pready,  $bits(this.pready),  UVM_BIN);
	printer.print_field("pslverr", this.pslverr, $bits(this.pslverr), UVM_BIN);
	printer.print_field("irq",     this.irq,     $bits(this.irq),     UVM_BIN);

	foreach(thr[i])
		printer.print_field($sformatf("thr[%0d]",i), this.thr[i], $bits(this.thr[i]), UVM_DEC);
	foreach(rbr[i])
		printer.print_field($sformatf("rbr[%0d]",i), this.rbr[i], $bits(this.rbr[i]), UVM_DEC);
	printer.print_field("ier", this.ier, $bits(this.ier), UVM_DEC);
	printer.print_field("iir", this.iir, $bits(this.iir), UVM_DEC);
	printer.print_field("fcr", this.fcr, $bits(this.fcr), UVM_DEC);
	printer.print_field("lcr", this.lcr, $bits(this.lcr), UVM_DEC);
	printer.print_field("lsr", this.lsr, $bits(this.lsr), UVM_DEC);
	printer.print_field("mcr", this.mcr, $bits(this.mcr), UVM_DEC);
	printer.print_field("div_msb", this.divisor[15:8], $bits(this.divisor[15:8]), UVM_DEC);
	printer.print_field("div_lsb", this.divisor[7:0],  $bits(this.divisor[7:0]),  UVM_DEC);
endfunction

