//@ test 8

function test(n)
{
    k = 2*2;
    r = 0;

    while (k >= 0){
	r = r + 1;
	r = r + 1;
	k = k - 1;
    }

    return r;
}

