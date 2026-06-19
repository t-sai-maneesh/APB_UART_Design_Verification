class uart_seqs extends uvm_sequence #(uart_xtn);
	`uvm_object_utils(uart_seqs)
	
	//methods
	extern function new(string name = "uart_seqs");
endclass

//Constructor New
function uart_seqs::new(string name = "uart_seqs");
	super.new(name);
endfunction

/*-----------------------------------------------------------------------------------
		Sequence for Half Duplex
-----------------------------------------------------------------------------------*/

class uart_hd_seqs extends uart_seqs;
	`uvm_object_utils(uart_hd_seqs)
	//methods
	extern function new(string name = "uart_hd_seqs");
	extern task body();
endclass

//Constructor New
function uart_hd_seqs::new(string name = "uart_hd_seqs");
	super.new(name);
endfunction

//Body Method
task uart_hd_seqs::body();
	//send the seqs of all the registers
	begin
		req = uart_xtn::type_id::create("req");
		/*/DIV_LSB
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h1c; xtn.pwrite == 1'h1; xtn.pwdata == 8'd26;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h20; xtn.pwrite == 1'h1; xtn.pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h0c; xtn.pwrite == 1'h1; xtn.pwdata == 8'b00000011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h08; xtn.pwrite == 1'h1; xtn.pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h04; xtn.pwrite == 1'h1; xtn.pwdata == 8'd0;});
		finish_item(req);

		//IIR
		start_item(req);
		assert(req.randomize() with {xtn.paddr == 8'h08; xtn.pwrite == 1'h0;});
		finish_item(req);

		//RXD
		if(xtn.iir[3:0]==8'h4)
		begin
			start_item(req);
			assert(req.randomize() with {xtn.paddr == 8'h00; xtn.pwrite == 1'h0;});
			finish_item(req);
		end*/
		
		//THR
		start_item(req);
		assert(req.randomize());
		finish_item(req);
	end
endtask
