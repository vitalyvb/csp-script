//@ test 8

function test(n)
{
    r = 0;

    for (i=0;i<10;i=i+1)
	for (j=i;j<10;j=j+1)
	    r = r+i+j;

    return r-495;
}

