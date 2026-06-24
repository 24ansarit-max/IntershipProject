`timescale 1ns/1ps

module and_gate(input a,input b,output y);
    assign y = a & b;
endmodule

module half_adder(input a,input b,output sum,output carry);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

module full_adder(input a,input b,input cin,output sum,output cout);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module array_multiplier_4bit(
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    wire p00,p01,p02,p03;
    wire p10,p11,p12,p13;
    wire p20,p21,p22,p23;
    wire p30,p31,p32,p33;

    and_gate g00(a[0],b[0],p00);
    and_gate g01(a[0],b[1],p01);
    and_gate g02(a[0],b[2],p02);
    and_gate g03(a[0],b[3],p03);

    and_gate g10(a[1],b[0],p10);
    and_gate g11(a[1],b[1],p11);
    and_gate g12(a[1],b[2],p12);
    and_gate g13(a[1],b[3],p13);

    and_gate g20(a[2],b[0],p20);
    and_gate g21(a[2],b[1],p21);
    and_gate g22(a[2],b[2],p22);
    and_gate g23(a[2],b[3],p23);

    and_gate g30(a[3],b[0],p30);
    and_gate g31(a[3],b[1],p31);
    and_gate g32(a[3],b[2],p32);
    and_gate g33(a[3],b[3],p33);

    wire s1,c1;
    wire s2,c2a,c2b;
    wire s3a,c3a,s3b,c3b,c3c;
    wire s4a,c4a,s4b,c4b,c4c;
    wire s5a,c5a,s5b,c5b,c5c;
    wire s6,c6;

    assign product[0] = p00;

    half_adder ha1(
        p01,p10,
        product[1],c1
    );

    full_adder fa2(
        p02,p11,p20,
        s2,c2a
    );

    half_adder ha2(
        s2,c1,
        product[2],c2b
    );

    full_adder fa3a(
        p03,p12,p21,
        s3a,c3a
    );

    full_adder fa3b(
        s3a,p30,c2a,
        s3b,c3b
    );

    half_adder ha3(
        s3b,c2b,
        product[3],c3c
    );

    full_adder fa4a(
        p13,p22,p31,
        s4a,c4a
    );

    full_adder fa4b(
        s4a,c3a,c3b,
        s4b,c4b
    );

    full_adder fa4c(
        s4b,c3c,1'b0,
        product[4],c4c
    );

    full_adder fa5a(
        p23,p32,c4a,
        s5a,c5a
    );

    full_adder fa5b(
        s5a,c4b,c4c,
        product[5],c5b
    );

    full_adder fa6(
        p33,c5a,c5b,
        product[6],product[7]
    );

endmodule
