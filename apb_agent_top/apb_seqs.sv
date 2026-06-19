class apb_seqs extends uvm_sequence #(apb_xtn);
	`uvm_object_utils(apb_seqs)

	//method
	extern function new(string name = "apb_seqs");
endclass

//Constructor New
function apb_seqs::new(string name = "apb_seqs");
	super.new(name);
endfunction

/*-----------------------------------------------------------------------------------
		Sequence for Half Duplex
-----------------------------------------------------------------------------------*/

class apb_hd_seqs extends apb_seqs;
	`uvm_object_utils(apb_hd_seqs)

	//methods
	extern function new(string name = "apb_hd_seqs");
	extern task body();
endclass

//Constructor New
function apb_hd_seqs::new(string name = "apb_hd_seqs");
	super.new(name);
endfunction

//Body Method
task apb_hd_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");


		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);


		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001110;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b10000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'd1;});
		finish_item(req);

		//TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Read
-----------------------------------------------------------------------------------*/
class apb_read extends apb_seqs;
	`uvm_object_utils(apb_read)
	
	//methods
	extern function new(string name = "apb_read"); 
	extern task body();
endclass

//Constructor New
function apb_read::new(string name = "apb_read");
	super.new(name);
endfunction

//Body Method
task apb_read::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//IIR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h0;});
		finish_item(req);
		get_response(req);

		//RBR
		if(req.iir[3:0]==8'h4) begin
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0; pwrite == 1'h0;});
		finish_item(req);
		end

		//LSR
		if(req.iir[3:0]==8'h6) begin
		start_item(req);
		assert(req.randomize() with {paddr == 8'h14; pwrite == 1'h0;});
		finish_item(req);
		end
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Half Duplex - RXD
-----------------------------------------------------------------------------------*/
class apb_hd1_seqs extends apb_seqs;
	`uvm_object_utils(apb_hd1_seqs)

	//apb_read rdh;	

	//methods
	extern function new(string name = "apb_hd1_seqs");
	extern task body();
endclass

//Constructor New
function apb_hd1_seqs::new(string name = "apb_hd1_seqs");
	super.new(name);
endfunction

//Body Method
task apb_hd1_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'd1;});
		finish_item(req);

		//RBR
		//rdh.body();
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Full Duplex
-----------------------------------------------------------------------------------*/

class apb_fd_seqs extends apb_seqs;
	`uvm_object_utils(apb_fd_seqs)

	//methods
	extern function new(string name = "apb_fd_seqs");
	extern task body();
endclass

//Constructor New
function apb_fd_seqs::new(string name = "apb_fd_seqs");
	super.new(name);
endfunction

//Body Method
task apb_fd_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'd1;});
		finish_item(req);

		//TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);

		//RBR
		//rdh.body();
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for LoopBack
-----------------------------------------------------------------------------------*/

class apb_lb_seqs extends apb_seqs;
	`uvm_object_utils(apb_lb_seqs)

	//methods
	extern function new(string name = "apb_lb_seqs");
	extern task body();
endclass

//Constructor New
function apb_lb_seqs::new(string name = "apb_lb_seqs");
	super.new(name);
endfunction

//Body Method
task apb_lb_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000001;});
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h10; pwrite == 1'h1; pwdata == 8'b00010000;});
		finish_item(req);

		//TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);

		//RBR
		//rdh.body();
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Parity Error
-----------------------------------------------------------------------------------*/
class apb_par_seqs extends apb_seqs;
	`uvm_object_utils(apb_par_seqs)
		
	//methods
	extern function new(string name = "apb_par_seqs");
	extern task body();
endclass

//Constructor New
function apb_par_seqs::new(string name = "apb_par_seqs");
	super.new(name);
endfunction

//Body Method
task apb_par_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000101;});
		finish_item(req);
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Framing Error
-----------------------------------------------------------------------------------*/
class apb_frameerr_seqs extends apb_seqs;
	`uvm_object_utils(apb_frameerr_seqs)
		
	//methods
	extern function new(string name = "apb_frameerr_seqs");
	extern task body();
endclass

//Constructor New
function apb_frameerr_seqs::new(string name = "apb_frameerr_seqs");
	super.new(name);
endfunction

//Body Method
task apb_frameerr_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00000001;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000101;});
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h10; pwrite == 1'h1; pwdata == 8'b00000000;});
		finish_item(req);

		/*/TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);*/

		//RBR
		//rdh.body();
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Break Error
-----------------------------------------------------------------------------------*/
class apb_breakerr_seqs extends apb_seqs;
	`uvm_object_utils(apb_breakerr_seqs)
		
	//methods
	extern function new(string name = "apb_breakerr_seqs");
	extern task body();
endclass

//Constructor New
function apb_breakerr_seqs::new(string name = "apb_breakerr_seqs");
	super.new(name);
endfunction

//Body Method
task apb_breakerr_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b01011011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000101;});
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h10; pwrite == 1'h1; pwdata == 8'b00010000;});
		finish_item(req);

		//TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for overrun Error
-----------------------------------------------------------------------------------*/
class apb_orerr_seqs extends apb_seqs;
	`uvm_object_utils(apb_orerr_seqs)
		
	//methods
	extern function new(string name = "apb_orerr_seqs");
	extern task body();
endclass

//Constructor New
function apb_orerr_seqs::new(string name = "apb_orerr_seqs");
	super.new(name);
endfunction

//Body Method
task apb_orerr_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00011011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b00000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000101;});
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h10; pwrite == 1'h1; pwdata == 8'b00000000;});
		finish_item(req);

		/*/TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);*/
	end
endtask

/*-----------------------------------------------------------------------------------
		Sequence for Timeout Error
-----------------------------------------------------------------------------------*/
class apb_timeoerr_seqs extends apb_seqs;
	`uvm_object_utils(apb_timeoerr_seqs)
		
	//methods
	extern function new(string name = "apb_timeoerr_seqs");
	extern task body();
endclass

//Constructor New
function apb_timeoerr_seqs::new(string name = "apb_timeoerr_seqs");
	super.new(name);
endfunction

//Body Method
task apb_timeoerr_seqs::body();
	//send the seqs of all the registers
	begin
		req = apb_xtn::type_id::create("req");

		//DIV_LSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h1c; pwrite == 1'h1; pwdata == 8'd54;});
		finish_item(req);

		//DIV_MSB
		start_item(req);
		assert(req.randomize() with {paddr == 8'h20; pwrite == 1'h1; pwdata == 8'h0;});
		finish_item(req);

		//LCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h0c; pwrite == 1'h1; pwdata == 8'b00001011;});
		finish_item(req);

		//FCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h08; pwrite == 1'h1; pwdata == 8'b01000110;});
		finish_item(req);

		//IER
		start_item(req);
		assert(req.randomize() with {paddr == 8'h04; pwrite == 1'h1; pwdata == 8'b00000111;});
		finish_item(req);

		//MCR
		start_item(req);
		assert(req.randomize() with {paddr == 8'h10; pwrite == 1'h1; pwdata == 8'b00010000;});
		finish_item(req);

		//TXD
		start_item(req);
		assert(req.randomize() with {paddr == 8'h00; pwrite == 1'h1; pwdata inside {[0:255]};});
		finish_item(req);

		//RBR
		//rdh.body();
	end
endtask

