module fp_add (
        input logic         clk,
        input logic [31:0]  dataa,
        input logic [31:0]  datab,
        output logic [31:0] result);
//latency = 10
    import "DPI-C" function void fp_add(input int dataa,input int datab,output int result);


    logic [31:0] __fp_float;
    always_ff @(posedge clk) begin
        // $display("display %d %d\n",dataa,datab);
        fp_add(dataa,datab,__fp_float);
        result = __fp_float;
    end
endmodule