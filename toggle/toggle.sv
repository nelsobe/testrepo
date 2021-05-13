module toggle (output logic q, input logic clk);
   always @(posedge clk)
     q <= ~q;
endmodule // toggle
