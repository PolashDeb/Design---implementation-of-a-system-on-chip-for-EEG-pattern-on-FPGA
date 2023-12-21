module df(clk,reset,x,y
    );
input clk,reset;
input signed [15:0] x;
output reg  signed [15:0] y;
always @(posedge clk,posedge reset)
begin
if(reset)
begin
    
    y<=0;
	 
end
else 
begin
  y<=x;
end	 

   
end

endmodule



