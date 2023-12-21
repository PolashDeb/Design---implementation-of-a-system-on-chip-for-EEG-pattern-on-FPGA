module polash3(
  input clk,
input signed [15:0] data_in,
input signed [15:0] fil_out,
output  signed [15:0] up,
output  signed [15:0] low,
output  signed [15:0] high_out,
output  signed [15:0] deri_out,
output  signed [15:0] sqr_out,
output  signed [15:0] avg_out,
output  signed [15:0] data_out,
output  signed [15:0] error,
output  signed [15:0] arm

    );
reg signed [15:0] up_out;
wire signed [15:0] d1,d2,d3,d4,d5,d6,d7;
wire signed [15:0] high;

reg signed [15:0] down_out;
reg signed [15:0] data_wait;





////up sampling L=2
integer i=1'b0;
always @ (posedge clk) 
begin 
	if(clk)
	begin
       if (i==1'b0) 
		  begin
           up_out <= data_in;
			  i=1'b1;
        end
       else 
		  begin
          up_out <= 16'd0;
          i=1'b0;
        end
	 end
	else
	begin
        if (i==1'b0) 
		  begin
          up_out <= data_in;
			 i=1'b1;
        end
       else
		  begin
         up_out <= 16'd0;
         i=1'b0;
        end        
    end 
end
assign up = up_out; 

///// filter


///lowpass

df A1(clk,reset,up,d1);


 assign low=(up_out+d1);

///highpass

df A2(clk,reset,low,d2);


 assign high=-((low)-(d2));
 
df A3(clk,reset,high,d3);


assign high_out=2*(d3+high);

///derivate

df A4(clk,reset,high_out,d4);
df A5(clk,reset,d4,d5);
 
assign deri_out= -( ((high_out)-d5 )/8 );

///square

assign sqr_out=( (deri_out)*(deri_out));

//average filter

df A6(clk,reset,sqr_out,d6);
df A7(clk,reset,d6,d7);

assign avg_out=( sqr_out+d6+d7 )/3;


///down sampling M=2
integer j=1'b0;

always @ (posedge clk )
begin
 if (j==1'b0) 
		  begin
           
			  data_wait<= avg_out;
			  j=1'b1;
        end
   else 
		 begin
         down_out <= avg_out;
          j=1'b0;
       end     
  
end
assign data_out = down_out;




//  feature 


wire signed [15:0] total;
reg signed [15:0] a;
reg signed [15:0] d=16'd0;
reg signed [15:0] sum = 16'd0;

integer k=0;	
always @ (posedge clk) 
begin
 
 
        if(k==0)
           begin
	         a<=fil_out;
	         k=1;
          end
         else
	         begin
	        sum<=sum+d;
	         d<=-a;
	         k=0;
	        end
  
end

assign error=data_in-fil_out;
assign total=error+sum;


//
integer l=0;
reg signed [15:0] e;
reg signed [15:0] f;

always @ (posedge clk )
begin
 if (l==0) 
		  begin
           
			  e<= total;
			  l=1;
        end
   else 
		 begin
         f <= total;
          l=0;
       end     
  
end
assign arm=e;



endmodule